const express = require('express');
const OpenAI = require('openai');
const pool = require('../db/pool');
const { optionalAuth } = require('../middleware/auth');
const { fallbackAssist, normalizeLang, firstSentence } = require('../services/aiFallback');

const router = express.Router();

const MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';
const LLM_TIMEOUT_MS = 14000;

function llmEnabled() {
  const key = process.env.OPENAI_API_KEY;
  return Boolean(key && key !== 'your-openai-api-key-here');
}

function getClient() {
  if (!llmEnabled()) return null;
  return new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
    timeout: LLM_TIMEOUT_MS,
    maxRetries: 0,
  });
}

function compactContext(raw) {
  if (!raw || typeof raw !== 'object') return {};
  const route = raw.route && typeof raw.route === 'object' ? raw.route : {};
  const nearest = raw.nearestAlert && typeof raw.nearestAlert === 'object' ? raw.nearestAlert : null;
  const camera = raw.nextCamera && typeof raw.nextCamera === 'object' ? raw.nextCamera : null;
  const vehicle = raw.vehicle && typeof raw.vehicle === 'object' ? raw.vehicle : null;
  const zones = Array.isArray(raw.zonesOnRoute) ? raw.zonesOnRoute.slice(0, 6) : [];
  const alerts = Array.isArray(raw.alerts) ? raw.alerts.slice(0, 4) : [];
  return {
    gps: raw.gps && typeof raw.gps === 'object'
      ? {
          lat: raw.gps.lat,
          lon: raw.gps.lon,
          speedKmh: raw.gps.speedKmh,
        }
      : null,
    route: {
      originLabel: route.originLabel,
      destLabel: route.destLabel,
      remainingMeters: route.remainingMeters,
      durationSeconds: route.durationSeconds,
      navigating: Boolean(route.navigating),
      hasRoute: Boolean(route.hasRoute),
      alternativeCount: route.alternativeCount || 0,
      selectedRoute: route.selectedRoute,
    },
    zonesOnRoute: zones.map((z) => ({
      id: z.id,
      name: z.name,
      city: z.city,
      country: z.country,
      active: z.active,
      restrictions: z.restrictions,
      minimumEuroLevel: z.minimumEuroLevel,
    })),
    nearestAlert: nearest
      ? {
          zoneName: nearest.zoneName || nearest.name,
          status: nearest.status,
          distanceMeters: nearest.distanceMeters,
          vehicleAllowed: nearest.vehicleAllowed,
        }
      : null,
    nextCamera: camera
      ? {
          distanceMeters: camera.distanceMeters,
          maxspeed: camera.maxspeed,
        }
      : null,
    alerts: alerts.map((a) => ({
      id: a.id,
      kind: a.kind,
      title: a.title,
      message: a.message,
    })),
    vehicle: vehicle
      ? {
          type: vehicle.type,
          fuel: vehicle.fuel,
          euroClass: vehicle.euroClass,
          euroLevel: vehicle.euroLevel,
        }
      : null,
    savedPlaces: Array.isArray(raw.savedPlaces) ? raw.savedPlaces.slice(0, 8) : [],
  };
}

function systemPrompt(lang, intent) {
  const languageName = {
    it: 'Italian',
    nl: 'Dutch',
    en: 'English',
    de: 'German',
    fr: 'French',
  }[lang] || 'Italian';
  const hintMode = String(intent || '') === 'alert_hint';
  return `You are MilieuAlert, a driving co-pilot for Low Emission Zones (LEZ / milieuzone / Umweltzone / ZFE) and live navigation.
Reply in ${languageName} only.
${hintMode ? 'Reply with ONE short sentence (max 140 characters).' : 'Max two short sentences. No bullet walls. No markdown.'}
Be driver-safe and actionable, like: "tra 400 m zona ambientale X, veicolo non conforme, usa itinerario alternativo Y".
Use only facts from the JSON context. Do not invent cameras, zones, or distances.
If the vehicle is not allowed, say so clearly and suggest an alternative route or saved Home/Work if present.
If there is no route, tell the driver how to set A→B or Casa/Lavoro.
Never mention API keys, models, or that you are an LLM.`;
}

async function completeWithLlm({ message, intent, language, context }) {
  const client = getClient();
  if (!client) return null;
  const compact = compactContext(context);
  const completion = await client.chat.completions.create({
    model: MODEL,
    temperature: 0.3,
    max_tokens: intent === 'alert_hint' ? 80 : 180,
    messages: [
      { role: 'system', content: systemPrompt(language, intent) },
      {
        role: 'user',
        content: JSON.stringify({
          intent: intent || 'chat',
          driverMessage: message || '',
          context: compact,
        }),
      },
    ],
  });
  const text = completion.choices && completion.choices[0] && completion.choices[0].message
    ? completion.choices[0].message.content
    : '';
  const reply = String(text || '').replace(/\s+/g, ' ').trim();
  if (!reply) return null;
  return {
    reply,
    hint: firstSentence(reply),
    source: 'llm',
    language,
  };
}

async function assistPayload(req) {
  const message = req.body && req.body.message != null ? String(req.body.message) : '';
  const intent = (req.body && req.body.intent) || 'chat';
  const language = normalizeLang(req.body && (req.body.language || req.body.lang));
  const context = compactContext((req.body && req.body.context) || {});
  const fallback = fallbackAssist({ message, intent, language, context });

  if (!llmEnabled()) {
    return fallback;
  }

  try {
    const llm = await Promise.race([
      completeWithLlm({ message, intent, language, context }),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('llm-timeout')), LLM_TIMEOUT_MS)
      ),
    ]);
    if (llm && llm.reply) return llm;
  } catch (err) {
    console.error('AI llm failed:', err && err.message ? err.message : 'unknown');
  }
  return fallback;
}

async function logConversation(req, message, result) {
  if (!req.user || !message) return;
  try {
    await pool.query(
      `INSERT INTO ai_conversations (user_id, session_id, user_message, ai_response, context)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        req.user.id,
        (req.body && req.body.sessionId) || 'assist',
        message,
        result.reply,
        JSON.stringify({
          intent: req.body && req.body.intent,
          language: result.language,
          source: result.source,
        }),
      ]
    );
  } catch (dbErr) {
    console.error('Failed to log AI conversation:', dbErr.message);
  }
}

router.post('/assist', optionalAuth, async (req, res) => {
  try {
    const message = req.body && req.body.message != null ? String(req.body.message) : '';
    const result = await assistPayload(req);
    await logConversation(req, message, result);
    res.json(result);
  } catch (err) {
    console.error('AI assist error:', err && err.message ? err.message : 'unknown');
    const language = normalizeLang(req.body && req.body.language);
    const fallback = fallbackAssist({
      message: req.body && req.body.message,
      intent: req.body && req.body.intent,
      language,
      context: req.body && req.body.context,
    });
    res.json(fallback);
  }
});

router.post('/chat', optionalAuth, async (req, res) => {
  try {
    const { message } = req.body || {};
    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }
    const result = await assistPayload(req);
    await logConversation(req, String(message), result);
    res.json({ response: result.reply, ...result });
  } catch (err) {
    console.error('AI chat error:', err && err.message ? err.message : 'unknown');
    const fallback = fallbackAssist({
      message: req.body && req.body.message,
      intent: 'chat',
      language: req.body && req.body.language,
      context: req.body && req.body.context,
    });
    res.json({ response: fallback.reply, ...fallback });
  }
});

router.post('/zone-check', optionalAuth, async (req, res) => {
  try {
    const { vehicleType, fuelType, euroClass, zoneName, zoneCountry } = req.body || {};
    if (!vehicleType || !fuelType || !euroClass || !zoneName) {
      return res.status(400).json({ error: 'vehicleType, fuelType, euroClass, and zoneName are required' });
    }
    const language = normalizeLang(req.body.language);
    const message = `Can this vehicle enter ${zoneName}?`;
    const context = {
      vehicle: { type: vehicleType, fuel: fuelType, euroClass },
      nearestAlert: { zoneName, status: 'approaching', vehicleAllowed: null },
      zonesOnRoute: [{ name: zoneName, city: zoneCountry }],
    };
    const result = await assistPayload({
      body: { message, intent: 'chat', language, context },
      user: req.user,
    });
    res.json({
      vehicle: { vehicleType, fuelType, euroClass },
      zone: { name: zoneName, country: zoneCountry },
      analysis: result.reply,
      source: result.source,
      disclaimer: 'Verify with official sources.',
    });
  } catch (err) {
    console.error('Zone check error:', err && err.message ? err.message : 'unknown');
    res.status(500).json({ error: 'AI service unavailable' });
  }
});

module.exports = router;
