const { getBaseUrl, LOCALES, OG_LOCALE } = require('./config');

const CONTACT_EMAIL = 'assistenza@gestionesemplificata.com';
const CONTROLLER = 'Gestione Semplificata';
const UPDATED = '18 settembre 2026';

function escapeHtml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function privacyPath(lang) {
  return lang ? `/privacy/${lang}` : '/privacy';
}

function privacyUrl(lang, base = getBaseUrl()) {
  return `${base}${privacyPath(lang)}`;
}

function privacyHreflangMap(base = getBaseUrl()) {
  return {
    it: privacyUrl('it', base),
    nl: privacyUrl('nl', base),
    en: privacyUrl('en', base),
    'x-default': privacyUrl(null, base)
  };
}

const PAGES = {
  it: {
    htmlLang: 'it',
    title: 'Informativa privacy | MilieuAlert',
    description:
      'Informativa GDPR di MilieuAlert: posizione GPS anche in background, segnalazioni autovelox, account e diritti degli interessati.',
    h1: 'Informativa sulla privacy',
    lead:
      'Questa pagina spiega quali dati personali tratta MilieuAlert (app Android e PWA), perché li tratta e quali diritti hai ai sensi del Regolamento (UE) 2016/679 (GDPR).',
    sections: [
      {
        h2: '1. Titolare del trattamento',
        html: `<p>Il titolare è <strong>${CONTROLLER}</strong>, stesso sviluppatore dell’app IoChef.</p>
<p>Email privacy e diritti: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a></p>
<p>App: <strong>MilieuAlert</strong> · package Android <code>com.milieuzone.milieu_alert</code> · sito <a href="https://milieualert-production.up.railway.app">https://milieualert-production.up.railway.app</a></p>`
      },
      {
        h2: '2. Dati che trattiamo',
        html: `<h3>Posizione GPS (approssimativa e precisa, anche in background)</h3>
<p>Durante la navigazione raccogliamo latitudine, longitudine, velocità, direzione e accuratezza. Se concedi il permesso “sempre” / posizione in background, il GPS continua mentre l’app è in secondo piano o lo schermo è spento, per avvisarti prima di entrare in una milieuzone, ZTL ambientale o LEZ e per mostrare autovelox/flitsers sul percorso. Senza posizione l’app non può navigare né geofencare le zone.</p>
<p>La posizione è usata per <strong>funzionalità dell’app (navigazione e avvisi)</strong>, non per pubblicità e non viene venduta.</p>
<h3>Account</h3>
<p>Se ti registri: indirizzo email, hash della password (non conserviamo la password in chiaro), nome visualizzato, lingua, paese, consenso al trattamento, data di creazione e ultimo accesso. L’account è facoltativo per alcune funzioni di base, necessario per sincronizzare il profilo e lo storico.</p>
<h3>Veicolo (EcoEntry)</h3>
<p>Classe Euro, carburante, tipo veicolo e, se la inserisci, targa. Servono a confrontare “la tua auto” con “la tua zona”.</p>
<h3>Segnalazioni community (autovelox / telecamere / incidenti)</h3>
<p>Se segnali un autovelox fisso o mobile, una coda o un incidente, salviamo tipo di evento, coordinate, eventuale direzione, nota testuale (max 280 caratteri), identificativo dispositivo anonimo e, se sei loggato, il collegamento all’account. Le segnalazioni sono visibili ad altri conducenti sulla mappa. Non usiamo la fotocamera del telefono: “camere” significa autovelox / flitsers, non scatti fotografici.</p>
<h3>Percorsi e conversazioni assistente</h3>
<p>Eventi di ingresso/uscita zona (coordinate, nome zona, esito EcoEntry) e, se usi l’assistente, il testo delle domande e delle risposte, per migliorare gli avvisi di guida.</p>
<h3>Dati tecnici</h3>
<p>Log di server (IP, orario, user-agent) per sicurezza, rate-limit e diagnostica. Token di sessione sull’apparecchio.</p>`
      },
      {
        h2: '3. Finalità e basi giuridiche',
        html: `<ul>
<li><strong>Esecuzione del contratto</strong> (art. 6.1.b): account, navigazione, EcoEntry, sincronizzazione.</li>
<li><strong>Consenso</strong> (art. 6.1.a e, per GPS, permessi di sistema): posizione precisa e in background; puoi revocarla dalle impostazioni del telefono.</li>
<li><strong>Legittimo interesse</strong> (art. 6.1.f): sicurezza del servizio, prevenzione abusi sulle segnalazioni, log tecnici.</li>
<li><strong>Obbligo legale</strong> (art. 6.1.c): richieste dell’autorità, conservazione fiscale se attiva una fatturazione.</li>
</ul>
<p>Non usiamo i dati per profilazione pubblicitaria né li vendiamo a broker. Gli acquisti in-app (Google Play Billing, abbonamento 1,99 €/mese, product id <code>milieualert_premium_2_99</code>) sono gestiti da Google; riceviamo solo lo stato dell’abbonamento per sbloccare le funzioni premium.</p>`
      },
      {
        h2: '4. Destinatari e trasferimenti',
        html: `<p>I dati sono trattati sui nostri server (hosting Railway) e, se usi l’assistente AI, da un fornitore di modelli linguistici solo per generare la risposta di guida. Mappe e geocoding possono interrogare servizi cartografici terzi con coordinate della zona visibile, non un identikit dell’utente.</p>
<p>Se un fornitore è extra-SEE, adottiamo clausole contrattuali tipo o misure equivalenti. Nessuna vendita a terzi a fini di marketing.</p>`
      },
      {
        h2: '5. Conservazione',
        html: `<ul>
<li>Account: finché l’account è attivo, poi cancellazione o anonimizzazione entro 30 giorni dalla richiesta.</li>
<li>Posizione live: in memoria sul dispositivo; sul server solo se associata a un evento (segnalazione, log zona).</li>
<li>Segnalazioni community: scadono automaticamente (eventi transitori) o restano se confermate come punto mappa.</li>
<li>Log tecnici: di norma fino a 90 giorni.</li>
</ul>`
      },
      {
        h2: '6. I tuoi diritti',
        html: `<p>Puoi chiedere accesso, rettifica, cancellazione, limitazione, portabilità e opposizione, e revocare il consenso in qualsiasi momento, scrivendo a <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>. Hai diritto di reclamare presso il Garante per la protezione dei dati personali (Italia) o l’autorità del tuo paese UE.</p>
<p>Per cancellare l’account: Impostazioni nell’app oppure la stessa email. La revoca del GPS si fa dalle autorizzazioni Android / iOS / browser.</p>`
      },
      {
        h2: '7. Minori',
        html: `<p>MilieuAlert è un navigatore per conducenti, non è destinato ai bambini e non è una kids app. Non raccogliamo consapevolmente dati di minori di 16 anni.</p>`
      },
      {
        h2: '8. Sicurezza e aggiornamenti',
        html: `<p>Password con hash, HTTPS obbligatorio sull’app Android (<code>usesCleartextTraffic=false</code>), accesso API autenticato. Questa informativa è aggiornata al ${UPDATED}. Le modifiche sostanziali saranno pubblicate su questa URL, che è anche l’indirizzo richiesto da Google Play.</p>`
      }
    ]
  },
  nl: {
    htmlLang: 'nl',
    title: 'Privacyverklaring | MilieuAlert',
    description:
      'AVG-privacyverklaring van MilieuAlert: GPS-locatie (ook op de achtergrond), flitsermeldingen, accounts en jouw rechten.',
    h1: 'Privacyverklaring',
    lead:
      'Deze pagina legt uit welke persoonsgegevens MilieuAlert (Android-app en PWA) verwerkt, waarom, en welke rechten je hebt onder de AVG (EU 2016/679).',
    sections: [
      {
        h2: '1. Verwerkingsverantwoordelijke',
        html: `<p>Verantwoordelijke is <strong>${CONTROLLER}</strong>, dezelfde ontwikkelaar als de app IoChef.</p>
<p>Privacy-e-mail: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a></p>
<p>App: <strong>MilieuAlert</strong> · Android-package <code>com.milieuzone.milieu_alert</code></p>`
      },
      {
        h2: '2. Welke gegevens',
        html: `<h3>GPS-locatie (bij benadering én nauwkeurig, ook op de achtergrond)</h3>
<p>Tijdens navigatie verwerken we breedte-/lengtegraad, snelheid, koers en nauwkeurigheid. Met toestemming “altijd” blijft GPS actief op de achtergrond voor milieuzone-/LEZ-waarschuwingen en flitsers op de route. Locatie is nodig voor de kernfunctie (navigatie), wordt niet verkocht en niet gebruikt voor ads.</p>
<h3>Account</h3>
<p>E-mail, wachtwoord-hash, weergavenaam, taal, land, toestemmingen, aanmaak- en laatste activiteit.</p>
<h3>Voertuig (EcoEntry)</h3>
<p>Euroklasse, brandstof, voertuigtype en optioneel kenteken.</p>
<h3>Community-meldingen (flitsers / camera’s / incidenten)</h3>
<p>Type (vaste of mobiele flitser, file, incident), coördinaten, optionele toelichting, anoniem device-id, en account-id als je bent ingelogd. “Camera’s” betekent snelheidscamera’s/flitsers, niet de telefooncamera.</p>
<h3>Ritten en assistent</h3>
<p>Zone-events en, als je de assistent gebruikt, vraag- en antwoordtekst. Technische logs: IP, tijdstip, user-agent.</p>`
      },
      {
        h2: '3. Doelen en grondslagen',
        html: `<ul>
<li><strong>Overeenkomst</strong> (art. 6.1.b): account, navigatie, EcoEntry.</li>
<li><strong>Toestemming</strong> (art. 6.1.a + systeemrechten): nauwkeurige en achtergrondlocatie.</li>
<li><strong>Gerechtvaardigd belang</strong> (art. 6.1.f): beveiliging, misbruikpreventie, logs.</li>
<li><strong>Wettelijke plicht</strong> (art. 6.1.c) indien van toepassing.</li>
</ul>
<p>Geen verkoop van gegevens, geen ad-profilering. In-app aankopen (Google Play, €1,99/maand, product <code>milieualert_premium_2_99</code>) worden door Google afgehandeld; wij zien alleen of het abonnement actief is.</p>`
      },
      {
        h2: '4. Ontvangers',
        html: `<p>Hosting (Railway) en, voor de rij-assistent, een AI-leverancier alleen om het antwoord te genereren. Kaarttegeltjes van derden zien het zichtbare kaartgebied, geen marketingprofiel. Extra-EER: SCC of gelijkwaardig.</p>`
      },
      {
        h2: '5. Bewaartermijn',
        html: `<p>Account zolang actief, daarna verwijdering/anonimisering binnen 30 dagen na verzoek. Live GPS blijft op het toestel; op de server alleen bij een event. Community-meldingen verlopen of blijven als kaartpunt. Logs doorgaans tot 90 dagen.</p>`
      },
      {
        h2: '6. Jouw rechten',
        html: `<p>Inzage, rectificatie, wissing, beperking, overdraagbaarheid, bezwaar en intrekking van toestemming via <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>. Klacht bij je nationale AP. GPS uitzetten: Android-/iOS-/browserrechten.</p>`
      },
      {
        h2: '7. Kinderen',
        html: `<p>MilieuAlert is een navigator voor bestuurders, geen kids-app. We verzamelen niet bewust gegevens van kinderen onder 16.</p>`
      },
      {
        h2: '8. Beveiliging',
        html: `<p>Wachtwoord-hash, HTTPS, geen cleartext-verkeer in de Android-release. Bijgewerkt op ${UPDATED}. Deze URL is de privacy policy voor Google Play.</p>`
      }
    ]
  },
  en: {
    htmlLang: 'en',
    title: 'Privacy policy | MilieuAlert',
    description:
      'MilieuAlert GDPR privacy policy: GPS location including background, speed-camera reports, accounts and your rights.',
    h1: 'Privacy policy',
    lead:
      'This page explains which personal data MilieuAlert (Android app and PWA) processes, why, and your rights under the GDPR (EU 2016/679).',
    sections: [
      {
        h2: '1. Controller',
        html: `<p>The controller is <strong>${CONTROLLER}</strong>, the same developer as the IoChef app.</p>
<p>Privacy email: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a></p>
<p>App: <strong>MilieuAlert</strong> · Android package <code>com.milieuzone.milieu_alert</code></p>`
      },
      {
        h2: '2. Data we process',
        html: `<h3>GPS location (approximate and precise, including background)</h3>
<p>While you navigate we process latitude, longitude, speed, heading and accuracy. If you grant “allow all the time” / background location, GPS continues when the app is in the background or the screen is off, so we can warn you before a milieuzone / LEZ / ZTL and show speed cameras (autovelox / flitsers) on the remaining route. Location is required for core navigation. It is <strong>not sold</strong> and not used for ads.</p>
<h3>Accounts</h3>
<p>If you register: email, password hash (never stored in clear text), display name, language, country, processing consent, created/last-active timestamps.</p>
<h3>Vehicle (EcoEntry)</h3>
<p>Euro class, fuel, vehicle type and optional licence plate, to match your car to the zone ahead.</p>
<h3>Community reports (cameras / incidents)</h3>
<p>If you report a fixed or mobile speed camera, traffic jam or incident we store event type, coordinates, optional heading, a short note, an anonymous device id and, if logged in, your account id. Reports appear for other drivers. “Cameras” means speed cameras, not the phone camera — we do not access photos.</p>
<h3>Trips and copilot</h3>
<p>Zone entry/exit events and, if you use the assistant, question/answer text. Technical logs: IP, time, user-agent.</p>`
      },
      {
        h2: '3. Purposes and legal bases',
        html: `<ul>
<li><strong>Contract</strong> (Art. 6(1)(b)): account, navigation, EcoEntry.</li>
<li><strong>Consent</strong> (Art. 6(1)(a) plus OS permissions): precise and background location.</li>
<li><strong>Legitimate interests</strong> (Art. 6(1)(f)): security, abuse prevention, logs.</li>
<li><strong>Legal obligation</strong> (Art. 6(1)(c)) where applicable.</li>
</ul>
<p>We do not sell personal data or use it for advertising profiles. In-app purchases (Google Play Billing, €1.99/month, product id <code>milieualert_premium_2_99</code>) are processed by Google; we only store subscription status to unlock premium features.</p>`
      },
      {
        h2: '4. Recipients',
        html: `<p>Hosting (Railway) and, for the driving assistant, an AI provider solely to generate the reply. Map tile providers see the visible map area, not a marketing profile. Transfers outside the EEA use SCCs or equivalent safeguards.</p>`
      },
      {
        h2: '5. Retention',
        html: `<p>Account while active, then deletion/anonymisation within 30 days of a request. Live GPS stays on-device; the server only stores it when tied to an event. Community reports expire or remain as map pins. Technical logs typically up to 90 days.</p>`
      },
      {
        h2: '6. Your rights',
        html: `<p>Access, rectification, erasure, restriction, portability, objection and withdrawal of consent: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>. You may lodge a complaint with your EU data protection authority. Turn GPS off in Android / iOS / browser settings.</p>`
      },
      {
        h2: '7. Children',
        html: `<p>MilieuAlert is a driver navigator, not a kids app. We do not knowingly collect data from children under 16.</p>`
      },
      {
        h2: '8. Security',
        html: `<p>Password hashing, HTTPS, Android release with cleartext traffic disabled. Updated ${UPDATED}. This URL is the privacy policy for Google Play.</p>`
      }
    ]
  }
};

function resolveLang(lang) {
  if (lang && PAGES[lang]) return lang;
  return 'it';
}

function renderPrivacy(lang) {
  const code = resolveLang(lang);
  const page = PAGES[code];
  const base = getBaseUrl();
  const canonical = lang ? privacyUrl(code, base) : privacyUrl(null, base);
  const alts = privacyHreflangMap(base);
  const hreflangs = Object.keys(alts)
    .map((l) => `  <link rel="alternate" hreflang="${escapeHtml(l)}" href="${escapeHtml(alts[l])}">`)
    .join('\n');
  const langNav = LOCALES.map((l) => {
    const current = l === code ? ' aria-current="page"' : '';
    return `<a href="${escapeHtml(privacyPath(l))}"${current}>${l.toUpperCase()}</a>`;
  }).join('');
  const sections = page.sections
    .map((s) => `      <section>\n        <h2>${escapeHtml(s.h2)}</h2>\n        ${s.html}\n      </section>`)
    .join('\n');

  return `<!DOCTYPE html>
<html lang="${escapeHtml(page.htmlLang)}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(page.title)}</title>
  <meta name="description" content="${escapeHtml(page.description)}">
  <meta name="robots" content="index, follow">
  <meta name="theme-color" content="#00E5FF">
  <link rel="canonical" href="${escapeHtml(canonical)}">
${hreflangs}
  <meta property="og:title" content="${escapeHtml(page.title)}">
  <meta property="og:description" content="${escapeHtml(page.description)}">
  <meta property="og:type" content="website">
  <meta property="og:url" content="${escapeHtml(canonical)}">
  <meta property="og:locale" content="${OG_LOCALE[code]}">
  <link rel="icon" type="image/png" href="/favicon.png">
  <style>
    :root { color-scheme: dark; }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, Segoe UI, sans-serif;
      background: #0A0A1A;
      color: #e8f9ff;
      line-height: 1.55;
    }
    a { color: #00E5FF; }
    header, main, footer { max-width: 760px; margin: 0 auto; padding: 20px 22px; }
    header { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
    .brand { display: flex; align-items: center; gap: 10px; text-decoration: none; color: inherit; font-weight: 800; letter-spacing: .08em; }
    .brand img { border-radius: 12px; background: #fff; }
    .langs a { margin-left: 12px; text-decoration: none; font-weight: 700; }
    .langs a[aria-current="page"] { color: #fff; }
    h1 { font-size: 1.85rem; line-height: 1.2; margin: 12px 0 16px; }
    h2 { font-size: 1.2rem; margin: 28px 0 8px; color: #8be9ff; }
    h3 { font-size: 1.02rem; margin: 18px 0 6px; color: #c9f3ff; }
    .lead { font-size: 1.08rem; color: #c9f3ff; }
    ul { padding-left: 1.2rem; }
    code { font-size: .9em; color: #8be9ff; }
    footer { color: #8aa; font-size: .88rem; }
  </style>
</head>
<body>
  <header>
    <a class="brand" href="/">
      <img src="/icons/Icon-512.png" alt="MilieuAlert" width="40" height="40">
      MILIEUALERT
    </a>
    <nav class="langs" aria-label="Language">${langNav}</nav>
  </header>
  <main>
    <h1>${escapeHtml(page.h1)}</h1>
    <p class="lead">${escapeHtml(page.lead)}</p>
${sections}
  </main>
  <footer>
    <p><a href="/">${escapeHtml(base)}</a> · <a href="/privacy">Privacy</a> · ${CONTROLLER}</p>
  </footer>
</body>
</html>
`;
}

module.exports = {
  CONTACT_EMAIL,
  PAGES,
  privacyPath,
  privacyUrl,
  privacyHreflangMap,
  resolveLang,
  renderPrivacy
};
