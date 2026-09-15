const express = require('express');
const OpenAI = require('openai');
const pool = require('../db/pool');
const { optionalAuth } = require('../middleware/auth');

const router = express.Router();

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';

const SYSTEM_PROMPT = `You are MilieuAlert AI Assistant, an expert on European Low Emission Zones (Milieuzone, LEZ, Umweltzone, ZFE). You help drivers understand:
- Which zones they can enter with their vehicle
- Current regulations and restrictions
- Environmental zone rules across Europe (Netherlands, Belgium, Germany, France, Italy)
- Tips for planning trips avoiding restricted zones
Always be accurate and note when information may have changed. Recommend checking official sources.
Respond in the user's preferred language. Keep responses concise and actionable.`;

router.post('/chat', optionalAuth, async (req, res) => {
  try {
    const { message, context, language } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const langInstruction = language ? `Respond in ${language}.` : '';
    const contextInfo = context ? `Context: ${context}` : '';

    const completion = await openai.chat.completions.create({
      model: MODEL,
      messages: [
        { role: 'system', content: `${SYSTEM_PROMPT}\n${langInstruction}` },
        ...(contextInfo ? [{ role: 'system', content: contextInfo }] : []),
        { role: 'user', content: message },
      ],
      max_tokens: 500,
      temperature: 0.7,
    });

    const response = completion.choices[0].message.content;

    if (req.user) {
      try {
        await pool.query(
          `INSERT INTO ai_conversations (user_id, session_id, user_message, ai_response, context)
           VALUES ($1, $2, $3, $4, $5)`,
          [req.user.id, req.body.session_id || 'anonymous', message, response, JSON.stringify({ context, language })]
        );
      } catch (dbErr) {
        console.error('Failed to log AI conversation:', dbErr);
      }
    }

    res.json({ response });
  } catch (err) {
    console.error('AI chat error:', err);
    res.status(500).json({ error: 'AI service unavailable', response: 'Sorry, the AI assistant is temporarily unavailable.' });
  }
});

router.post('/zone-check', optionalAuth, async (req, res) => {
  try {
    const { vehicleType, fuelType, euroClass, zoneName, zoneCountry } = req.body;

    if (!vehicleType || !fuelType || !euroClass || !zoneName) {
      return res.status(400).json({ error: 'vehicleType, fuelType, euroClass, and zoneName are required' });
    }

    const prompt = `Check if this vehicle can enter the specified emission zone:
Vehicle: ${vehicleType}, ${fuelType}, ${euroClass}
Zone: ${zoneName}, ${zoneCountry || 'Europe'}

Provide:
1. Whether the vehicle is likely allowed (yes/no/uncertain)
2. Brief explanation of the zone's rules
3. Any important notes or exceptions
4. Official source to verify`;

    const completion = await openai.chat.completions.create({
      model: MODEL,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: prompt },
      ],
      max_tokens: 400,
      temperature: 0.3,
    });

    const response = completion.choices[0].message.content;

    res.json({
      vehicle: { vehicleType, fuelType, euroClass },
      zone: { name: zoneName, country: zoneCountry },
      analysis: response,
      disclaimer: 'This is an AI-generated analysis. Always verify with official sources.',
    });
  } catch (err) {
    console.error('Zone check error:', err);
    res.status(500).json({ error: 'AI service unavailable' });
  }
});

module.exports = router;
