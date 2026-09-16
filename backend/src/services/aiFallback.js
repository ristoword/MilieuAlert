function normalizeLang(raw) {
  const v = String(raw || 'it').toLowerCase().slice(0, 2);
  if (['it', 'nl', 'en', 'de', 'fr'].includes(v)) return v;
  return 'it';
}

function fmtDist(meters) {
  if (meters == null || !Number.isFinite(Number(meters))) return null;
  const m = Number(meters);
  if (m < 1000) return `${Math.round(m)} m`;
  return `${(m / 1000).toFixed(1)} km`;
}

function firstSentence(text) {
  const raw = String(text || '').replace(/\s+/g, ' ').trim();
  if (!raw) return '';
  const match = raw.match(/^[^.!?]+[.!?]?/);
  const cut = (match ? match[0] : raw).trim();
  return cut.length > 220 ? `${cut.slice(0, 217)}...` : cut;
}

function pack(reply, lang) {
  const text = String(reply || '').replace(/\s+/g, ' ').trim();
  return {
    reply: text,
    hint: firstSentence(text),
    source: 'fallback',
    language: lang,
  };
}

function phrases(lang) {
  const table = {
    it: {
      approachingDenied: (zone, dist) =>
        `Tra ${dist} zona ambientale ${zone}, veicolo non conforme: evita l’ingresso o scegli un itinerario alternativo.`,
      approachingOk: (zone, dist) =>
        `Tra ${dist} entri in ${zone}. Il veicolo risulta conforme: procedi e rispetta i limiti.`,
      insideDenied: (zone) =>
        `Sei dentro ${zone} e il veicolo non è autorizzato. Esci al più presto o cambia percorso.`,
      insideOk: (zone) =>
        `Sei dentro ${zone}: veicolo autorizzato. Mantieni i limiti e gli orari della zona.`,
      camera: (dist, limit) =>
        limit
          ? `Autovelox tra ${dist}, limite ${limit} km/h: rallenta ora.`
          : `Autovelox tra ${dist}: controlla la velocità.`,
      delay: (msg) => msg || 'Il tragitto è più lento: valuta un itinerario alternativo.',
      newZone: (msg) => msg || 'Nuova zona ambientale sul percorso: verifica se il veicolo è conforme.',
      activating: (msg) => msg || 'Una zona si attiva durante il viaggio: cambia percorso se il veicolo non è conforme.',
      briefingClear: (dest, dist) =>
        dest
          ? `Percorso verso ${dest}${dist ? `, mancano ${dist}` : ''}. Nessuna zona critica ora. Guida e ti avviso io.`
          : 'Nessun itinerario attivo. Imposta A e B, oppure Casa/Lavoro, e chiedimi le zone.',
      briefingZones: (dest, dist, names, alts) =>
        `Verso ${dest}${dist ? `, ${dist}` : ''}: zone ${names}.${alts ? ' Hai itinerari alternativi.' : ' Verifica conformità prima di entrare.'}`,
      noRoute: 'Non c’è un percorso A→B. Digita destinazione, tocca Casa/Lavoro o Calcola percorso, poi chiedimi le zone.',
      homeMissing: 'Casa non è ancora salvata. Tocca Casa + nella barra luoghi e salva l’indirizzo.',
      workMissing: 'Lavoro non è ancora salvato. Tocca Lavoro + e imposta l’ufficio.',
      altNone: 'Non ci sono itinerari alternativi al momento. Ricalcola il percorso o cambia destinazione.',
      altSwitch: (n) => `Passo all’itinerario ${n}. Controllo zone e autovelox sul nuovo tragitto.`,
      goingHome: 'Imposto Casa come destinazione e calcolo il percorso più sicuro possibile.',
      goingWork: 'Imposto Lavoro come destinazione e calcolo il percorso.',
      vehicleOk: (zone) =>
        zone
          ? `Con il veicolo attuale ${zone} risulta accessibile. Conferma sempre le regole ufficiali.`
          : 'Veicolo elettrico o classe sufficiente: nessuna restrizione evidente ora.',
      vehicleBad: (zone, euro, fuel) =>
        `Il tuo ${euro || 'veicolo'} ${fuel || ''} non è conforme per ${zone}. Usa un altro itinerario o mezzo.`,
      help:
        'Posso dirti zone LEZ sul percorso, se il veicolo può entrare, autovelox vicini e alternative. Prova: “ci sono zone?”, “autovelox?”, “portami a casa”.',
    },
    nl: {
      approachingDenied: (zone, dist) =>
        `Over ${dist} milieuzone ${zone}, voertuig niet toegelaten: kies een alternatieve route.`,
      approachingOk: (zone, dist) =>
        `Over ${dist} rijd je ${zone} in. Voertuig lijkt toegelaten: houd de limiet aan.`,
      insideDenied: (zone) =>
        `Je bent in ${zone} en het voertuig is niet toegelaten. Verlaat de zone of wijzig de route.`,
      insideOk: (zone) => `Je bent in ${zone}: voertuig toegelaten. Respecteer de regels.`,
      camera: (dist, limit) =>
        limit
          ? `Flitser over ${dist}, limiet ${limit} km/u: minderen.`
          : `Flitser over ${dist}: controleer je snelheid.`,
      delay: (msg) => msg || 'De route is trager: overweeg een alternatief.',
      newZone: (msg) => msg || 'Nieuwe milieuzone op de route: check toelating.',
      activating: (msg) => msg || 'Een zone wordt actief tijdens je rit: kies een andere route indien nodig.',
      briefingClear: (dest, dist) =>
        dest
          ? `Route naar ${dest}${dist ? `, nog ${dist}` : ''}. Geen kritieke zone nu.`
          : 'Geen route. Stel A en B of Thuis/Werk in.',
      briefingZones: (dest, dist, names, alts) =>
        `Naar ${dest}${dist ? `, ${dist}` : ''}: zones ${names}.${alts ? ' Er zijn alternatieven.' : ''}`,
      noRoute: 'Nog geen A→B-route. Kies een bestemming of Thuis/Werk.',
      homeMissing: 'Thuis is nog niet opgeslagen.',
      workMissing: 'Werk is nog niet opgeslagen.',
      altNone: 'Geen alternatieve routes nu.',
      altSwitch: (n) => `Ik schakel naar route ${n}.`,
      goingHome: 'Bestemming Thuis, route wordt berekend.',
      goingWork: 'Bestemming Werk, route wordt berekend.',
      vehicleOk: (zone) =>
        zone ? `Met dit voertuig lijkt ${zone} toegelaten.` : 'Geen duidelijke beperking nu.',
      vehicleBad: (zone, euro, fuel) =>
        `Je ${euro || 'voertuig'} ${fuel || ''} mag ${zone} niet in. Kies een andere route.`,
      help: 'Ik help met milieuzones, toelating, flitsers en alternatieven. Vraag: “zones?”, “flitser?”, “naar huis”.',
    },
    en: {
      approachingDenied: (zone, dist) =>
        `In ${dist}: LEZ ${zone} — vehicle not allowed. Take an alternative.`,
      approachingOk: (zone, dist) =>
        `In ${dist} you enter ${zone}. Vehicle looks allowed — keep to the limit.`,
      insideDenied: (zone) =>
        `You are inside ${zone} and the vehicle is not authorized. Leave or reroute now.`,
      insideOk: (zone) => `Inside ${zone}: vehicle authorized. Keep to zone rules.`,
      camera: (dist, limit) =>
        limit
          ? `Speed camera in ${dist}, limit ${limit} km/h: slow down.`
          : `Speed camera in ${dist}: check your speed.`,
      delay: (msg) => msg || 'The route is slower now. Consider an alternative.',
      newZone: (msg) => msg || 'A new LEZ is on the route. Check if your vehicle is allowed.',
      activating: (msg) => msg || 'A zone becomes active during the trip. Reroute if you are not allowed.',
      briefingClear: (dest, dist) =>
        dest
          ? `Route to ${dest}${dist ? `, ${dist} left` : ''}. No critical zone right now.`
          : 'No A→B route yet. Set destination or Home/Work.',
      briefingZones: (dest, dist, names, alts) =>
        `To ${dest}${dist ? `, ${dist}` : ''}: zones ${names}.${alts ? ' Alternatives available.' : ''}`,
      noRoute: 'No A→B route yet. Set a destination, then ask about zones.',
      homeMissing: 'Home is not saved yet. Save it from the places bar.',
      workMissing: 'Work is not saved yet.',
      altNone: 'No alternative routes right now.',
      altSwitch: (n) => `Switching to route ${n}.`,
      goingHome: 'Setting Home as destination and calculating a route.',
      goingWork: 'Setting Work as destination and calculating a route.',
      vehicleOk: (zone) =>
        zone ? `With this vehicle ${zone} looks allowed.` : 'No clear restriction right now.',
      vehicleBad: (zone, euro, fuel) =>
        `Your ${euro || 'vehicle'} ${fuel || ''} is not allowed in ${zone}. Use another route.`,
      help: 'I can warn about LEZs, vehicle access, cameras and alternatives. Try “any zones?”, “camera?”, “take me home”.',
    },
    de: {
      approachingDenied: (zone, dist) =>
        `In ${dist} Umweltzone ${zone}: Fahrzeug nicht zugelassen. Alternative wählen.`,
      approachingOk: (zone, dist) =>
        `In ${dist} ${zone}. Fahrzeug wirkt zugelassen.`,
      insideDenied: (zone) =>
        `Du bist in ${zone}, Fahrzeug nicht erlaubt. Zone verlassen.`,
      insideOk: (zone) => `In ${zone}: Fahrzeug erlaubt.`,
      camera: (dist, limit) =>
        limit
          ? `Blitzer in ${dist}, ${limit} km/h: langsamer.`
          : `Blitzer in ${dist}.`,
      delay: (msg) => msg || 'Route langsamer: Alternative prüfen.',
      newZone: (msg) => msg || 'Neue Zone auf der Route.',
      activating: (msg) => msg || 'Zone wird während der Fahrt aktiv.',
      briefingClear: (dest, dist) =>
        dest ? `Route nach ${dest}${dist ? `, noch ${dist}` : ''}. Keine kritische Zone.` : 'Keine Route.',
      briefingZones: (dest, dist, names, alts) =>
        `Nach ${dest}${dist ? `, ${dist}` : ''}: Zonen ${names}.${alts ? ' Alternativen vorhanden.' : ''}`,
      noRoute: 'Keine A→B-Route. Ziel setzen.',
      homeMissing: 'Zuhause noch nicht gespeichert.',
      workMissing: 'Arbeit noch nicht gespeichert.',
      altNone: 'Keine Alternativen.',
      altSwitch: (n) => `Wechsle zu Route ${n}.`,
      goingHome: 'Ziel Zuhause, Route wird berechnet.',
      goingWork: 'Ziel Arbeit, Route wird berechnet.',
      vehicleOk: (zone) => (zone ? `${zone} wirkt erlaubt.` : 'Keine klare Sperre.'),
      vehicleBad: (zone, euro, fuel) =>
        `Dein ${euro || 'Fahrzeug'} ${fuel || ''} darf ${zone} nicht einfahren.`,
      help: 'Ich helfe bei Umweltzonen, Zufahrt, Blitzern und Alternativen.',
    },
    fr: {
      approachingDenied: (zone, dist) =>
        `Dans ${dist} ZFE ${zone} : véhicule non autorisé. Prenez un itinéraire alternatif.`,
      approachingOk: (zone, dist) =>
        `Dans ${dist} vous entrez dans ${zone}. Véhicule a priori autorisé.`,
      insideDenied: (zone) =>
        `Vous êtes dans ${zone} et le véhicule n’est pas autorisé. Sortez ou changez d’itinéraire.`,
      insideOk: (zone) => `Dans ${zone} : véhicule autorisé.`,
      camera: (dist, limit) =>
        limit
          ? `Radar dans ${dist}, limite ${limit} km/h : ralentissez.`
          : `Radar dans ${dist}.`,
      delay: (msg) => msg || 'Itinéraire plus lent : envisagez une alternative.',
      newZone: (msg) => msg || 'Nouvelle zone sur l’itinéraire.',
      activating: (msg) => msg || 'Une zone s’active pendant le trajet.',
      briefingClear: (dest, dist) =>
        dest ? `Vers ${dest}${dist ? `, ${dist}` : ''}. Pas de zone critique.` : 'Pas d’itinéraire.',
      briefingZones: (dest, dist, names, alts) =>
        `Vers ${dest}${dist ? `, ${dist}` : ''}: zones ${names}.${alts ? ' Alternatives dispo.' : ''}`,
      noRoute: 'Pas d’itinéraire A→B. Définissez une destination.',
      homeMissing: 'Maison pas encore enregistrée.',
      workMissing: 'Travail pas encore enregistré.',
      altNone: 'Pas d’itinéraires alternatifs.',
      altSwitch: (n) => `Passage à l’itinéraire ${n}.`,
      goingHome: 'Destination Maison, calcul de l’itinéraire.',
      goingWork: 'Destination Travail, calcul de l’itinéraire.',
      vehicleOk: (zone) => (zone ? `${zone} semble accessible.` : 'Pas de restriction claire.'),
      vehicleBad: (zone, euro, fuel) =>
        `Votre ${euro || 'véhicule'} ${fuel || ''} n’est pas conforme pour ${zone}.`,
      help: 'Je vous aide pour ZFE, accès véhicule, radars et alternatives.',
    },
  };
  return table[lang] || table.it;
}

function vehicleDenied(ctx) {
  const alert = ctx.nearestAlert || {};
  if (alert.vehicleAllowed === false) return true;
  const vehicle = ctx.vehicle || {};
  const zones = ctx.zonesOnRoute || [];
  const euro = Number(vehicle.euroLevel);
  for (const z of zones) {
    if (z.minimumEuroLevel != null && Number.isFinite(euro) && euro < Number(z.minimumEuroLevel)) {
      return true;
    }
    if (vehicle.fuel && Array.isArray(z.allowedFuelTypes) && z.allowedFuelTypes.length) {
      const ok = z.allowedFuelTypes.map((x) => String(x).toLowerCase());
      if (!ok.includes(String(vehicle.fuel).toLowerCase()) && String(vehicle.fuel).toLowerCase() !== 'electric') {
        return true;
      }
    }
  }
  return false;
}

function alertLine(alert, ctx, p, lang) {
  const kind = String((alert && alert.kind) || '').toLowerCase();
  const msg = alert && alert.message;
  if (kind.includes('camera')) {
    const dist = fmtDist(ctx.nextCamera && ctx.nextCamera.distanceMeters) || fmtDist(400) || '400 m';
    return p.camera(dist, ctx.nextCamera && ctx.nextCamera.maxspeed);
  }
  if (kind.includes('activating') || kind.includes('zoneactivating')) {
    return p.activating(msg);
  }
  if (kind.includes('newzone') || kind.includes('zone')) {
    return p.newZone(msg);
  }
  if (kind.includes('delay') || kind.includes('detour') || kind.includes('faster')) {
    return p.delay(msg);
  }
  if (msg) return msg;
  return fallbackFromSituation(ctx, p, lang).reply;
}

function fallbackFromSituation(ctx, p) {
  const zone = ctx.nearestAlert || {};
  const dist = fmtDist(zone.distanceMeters);
  const name = zone.zoneName || zone.name || 'LEZ';
  const denied = vehicleDenied(ctx);
  const status = String(zone.status || '').toLowerCase();

  if (status === 'inside' && denied) return pack(p.insideDenied(name), ctx.lang);
  if (status === 'inside') return pack(p.insideOk(name), ctx.lang);
  if ((status === 'approaching' || dist) && denied && name) {
    return pack(p.approachingDenied(name, dist || '400 m'), ctx.lang);
  }
  if (status === 'approaching' && name) {
    return pack(p.approachingOk(name, dist || '400 m'), ctx.lang);
  }

  const cam = ctx.nextCamera;
  if (cam && cam.distanceMeters != null && Number(cam.distanceMeters) < 800) {
    return pack(p.camera(fmtDist(cam.distanceMeters), cam.maxspeed), ctx.lang);
  }

  const alerts = ctx.alerts || [];
  if (alerts.length) {
    return pack(alertLine(alerts[0], ctx, p), ctx.lang);
  }

  const route = ctx.route || {};
  const dest = route.destLabel || route.destination;
  const remain = fmtDist(route.remainingMeters);
  const zones = ctx.zonesOnRoute || [];
  const alts = Number(route.alternativeCount || 0) > 1;
  if (zones.length && dest) {
    const names = zones
      .map((z) => z.name)
      .filter(Boolean)
      .slice(0, 3)
      .join(', ');
    return pack(p.briefingZones(dest, remain, names, alts), ctx.lang);
  }
  if (dest || route.hasRoute) {
    return pack(p.briefingClear(dest, remain), ctx.lang);
  }
  return pack(p.help, ctx.lang);
}

function match(q, words) {
  return words.some((w) => q.includes(w));
}

function fallbackAssist({ message, intent, language, context }) {
  const lang = normalizeLang(language);
  const ctx = { ...(context && typeof context === 'object' ? context : {}), lang };
  const p = phrases(lang);
  const q = String(message || '').toLowerCase();
  const intentName = String(intent || 'chat').toLowerCase();

  if (intentName === 'alert_hint') {
    const alerts = ctx.alerts || [];
    if (alerts[0]) return pack(alertLine(alerts[0], ctx, p, lang), lang);
    return fallbackFromSituation(ctx, p);
  }

  if (intentName === 'nav_briefing') {
    return fallbackFromSituation(ctx, p);
  }

  if (match(q, ['casa', 'home', 'thuis', 'maison', 'zuhause', 'a casa'])) {
    const places = (ctx.savedPlaces || []).map((x) => String(x).toLowerCase());
    if (!places.some((x) => x === 'casa' || x === 'home' || x === 'thuis')) {
      return pack(p.homeMissing, lang);
    }
    return pack(p.goingHome, lang);
  }
  if (match(q, ['lavoro', 'work', 'werk', 'travail', 'arbeit', 'ufficio'])) {
    const places = (ctx.savedPlaces || []).map((x) => String(x).toLowerCase());
    if (!places.some((x) => x === 'lavoro' || x === 'work' || x === 'werk')) {
      return pack(p.workMissing, lang);
    }
    return pack(p.goingWork, lang);
  }
  if (match(q, ['alternativ', 'altro percorso', 'altro itinerario', 'andere route'])) {
    const n = Number((ctx.route && ctx.route.alternativeCount) || 0);
    if (n <= 1) return pack(p.altNone, lang);
    return pack(p.altSwitch(Math.min(n, 2)), lang);
  }
  if (match(q, ['autovelox', 'camera', 'flitser', 'blitzer', 'radar', 'speed cam'])) {
    const cam = ctx.nextCamera;
    if (cam && cam.distanceMeters != null) {
      return pack(p.camera(fmtDist(cam.distanceMeters), cam.maxspeed), lang);
    }
    const none =
      lang === 'nl'
        ? 'Geen flitser dichtbij op dit traject.'
        : lang === 'en'
          ? 'No speed camera close on this stretch.'
          : 'Nessun autovelox vicino su questo tratto.';
    return pack(none, lang);
  }
  if (match(q, ['veicol', 'euro', 'diesel', 'conforme', 'allowed', 'toegelaten', 'autorizz'])) {
    const zone =
      (ctx.nearestAlert && (ctx.nearestAlert.zoneName || ctx.nearestAlert.name)) ||
      (ctx.zonesOnRoute && ctx.zonesOnRoute[0] && ctx.zonesOnRoute[0].name) ||
      'la zona';
    const vehicle = ctx.vehicle || {};
    if (vehicleDenied(ctx)) {
      return pack(p.vehicleBad(zone, vehicle.euroClass || vehicle.euro, vehicle.fuel), lang);
    }
    return pack(p.vehicleOk(zone), lang);
  }
  if (match(q, ['zona', 'lez', 'milieu', 'umwelt', 'zfe', 'zone'])) {
    return fallbackFromSituation(ctx, p);
  }
  if (match(q, ['manca', 'quanto', 'remaining', 'arriver', 'eta', 'afstand'])) {
    return fallbackFromSituation(ctx, p);
  }
  if (!q.trim()) return fallbackFromSituation(ctx, p);
  return fallbackFromSituation(ctx, p);
}

module.exports = {
  normalizeLang,
  fallbackAssist,
  firstSentence,
};
