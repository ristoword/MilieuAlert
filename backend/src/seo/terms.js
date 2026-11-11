const { getBaseUrl, LOCALES, OG_LOCALE } = require('./config');
const { CONTACT_EMAIL } = require('./privacy');

const CONTROLLER = 'Gestione Semplificata';
const UPDATED = '5 novembre 2026';

function escapeHtml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function termsPath(lang) {
  return lang ? `/terms/${lang}` : '/terms';
}

function termsUrl(lang, base = getBaseUrl()) {
  return `${base}${termsPath(lang)}`;
}

const PAGES = {
  it: {
    htmlLang: 'it',
    title: 'Termini di servizio | MilieuAlert',
    description:
      'Termini di servizio di MilieuAlert: uso dell’app, prova gratuita di 15 giorni, abbonamento Premium 1,99 €/mese tramite Google Play, responsabilità.',
    h1: 'Termini di servizio',
    lead: `Questi termini regolano l’uso dell’app MilieuAlert (Android e PWA). Aggiornati al ${UPDATED}. Usando l’app li accetti.`,
    privacy: 'Informativa privacy',
    sections: [
      {
        h2: '1. Chi siamo',
        html: `<p>MilieuAlert è fornita da <strong>${CONTROLLER}</strong>. Contatti: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>.</p>`
      },
      {
        h2: '2. Il servizio',
        html: `<p>MilieuAlert è un navigatore che avvisa il conducente delle zone a basse emissioni (ZTL ambientali, milieuzone, LEZ), mostra segnalazioni di autovelox/flitsers e offre guida vocale. Le informazioni su zone, orari e divieti provengono da fonti pubbliche e da segnalazioni degli utenti e possono essere incomplete, non aggiornate o errate.</p>`
      },
      {
        h2: '3. Guida responsabile — nessuna garanzia',
        html: `<ul>
<li>L’app è un <strong>aiuto</strong>, non sostituisce segnaletica stradale, Codice della Strada e buon senso. Rispetta sempre i cartelli e le indicazioni delle autorità.</li>
<li>Non usare il telefono in modo che distragga dalla guida. L’interazione con lo schermo durante la marcia è sotto la tua responsabilità.</li>
<li>Non garantiamo che un percorso eviti sanzioni, né l’esattezza di zone, orari, velocità o posizioni di controlli. Non rispondiamo di multe, ritardi o danni derivanti dall’affidamento sull’app, nei limiti consentiti dalla legge.</li>
<li>Le segnalazioni della community sono inserite dagli utenti e non verificate da noi.</li>
</ul>`
      },
      {
        h2: '4. Account',
        html: `<p>Alcune funzioni richiedono un account. Sei responsabile della riservatezza delle credenziali e dei dati inseriti, che devono essere veritieri. Possiamo sospendere account che violano questi termini (per esempio segnalazioni false o abusi dell’API).</p>`
      },
      {
        h2: '5. Prova gratuita e abbonamento Premium',
        html: `<ul>
<li><strong>15 giorni gratuiti</strong> con tutte le funzioni, dalla prima apertura/registrazione. Dopo la prova resta disponibile la navigazione base; le funzioni Premium richiedono l’abbonamento.</li>
<li><strong>MilieuAlert Premium: 1,99 € al mese</strong> (IVA inclusa dove dovuta), con rinnovo automatico mensile fino a disdetta.</li>
<li>Su Android il pagamento è gestito da <strong>Google Play</strong> con il metodo di pagamento associato al tuo account Google. Noi non vediamo né conserviamo i dati della tua carta.</li>
<li><strong>Disdetta:</strong> in qualsiasi momento da Google Play → Pagamenti e abbonamenti → Abbonamenti → MilieuAlert. La disdetta ha effetto alla fine del periodo già pagato; non sono previsti rimborsi parziali del periodo in corso, salvo quanto previsto dalla legge e dalle regole di Google Play.</li>
<li>Prezzi e condizioni possono cambiare; ti avviseremo secondo le regole di Google Play prima che la modifica si applichi al tuo rinnovo.</li>
<li>Diritto di recesso dei consumatori (UE): per contenuti digitali fornibili subito si applicano le regole di Google Play e della normativa sui consumatori.</li>
</ul>`
      },
      {
        h2: '6. Parcheggio (EasyPark)',
        html: `<p>Il pulsante “Paga la sosta” apre l’app o il sito di terze parti (EasyPark). Il pagamento della sosta avviene esclusivamente nell’app del terzo, con i suoi termini; MilieuAlert non gestisce pagamenti di parcheggio e non è affiliata a EasyPark.</p>`
      },
      {
        h2: '7. Uso consentito',
        html: `<p>Non puoi: inserire segnalazioni false, aggirare i limiti dell’API, decompilare o rivendere il servizio, usarlo per attività illecite o in modo da compromettere la sicurezza di altri conducenti.</p>`
      },
      {
        h2: '8. Proprietà intellettuale',
        html: `<p>App, marchio e contenuti sono di ${CONTROLLER} o dei rispettivi titolari (dati cartografici: OpenStreetMap contributors e altri fornitori). Ti concediamo una licenza personale, non esclusiva e revocabile per usare l’app.</p>`
      },
      {
        h2: '9. Dati personali',
        html: `<p>Il trattamento dei dati è descritto nell’<a href="/privacy/it">Informativa privacy</a>.</p>`
      },
      {
        h2: '10. Limitazione di responsabilità',
        html: `<p>Il servizio è fornito “così com’è”. Nei limiti consentiti dalla legge, non rispondiamo di danni indiretti o della temporanea indisponibilità del servizio. Restano salvi i diritti inderogabili dei consumatori e la responsabilità che non può essere esclusa per legge.</p>`
      },
      {
        h2: '11. Modifiche, legge applicabile e contatti',
        html: `<p>Possiamo aggiornare questi termini; la versione in vigore è sempre a questo indirizzo. Se continui a usare l’app dopo le modifiche, le accetti. Si applica la legge italiana, ferme restando le norme imperative a tutela del consumatore del tuo paese di residenza. Per domande: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>.</p>`
      }
    ]
  },
  en: {
    htmlLang: 'en',
    title: 'Terms of service | MilieuAlert',
    description:
      'MilieuAlert terms of service: app use, 15-day free trial, Premium subscription at €1.99/month via Google Play, liability.',
    h1: 'Terms of service',
    lead: `These terms govern your use of the MilieuAlert app (Android and PWA). Updated ${UPDATED}. By using the app you accept them.`,
    privacy: 'Privacy policy',
    sections: [
      {
        h2: '1. Who we are',
        html: `<p>MilieuAlert is provided by <strong>${CONTROLLER}</strong>. Contact: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>.</p>`
      },
      {
        h2: '2. The service',
        html: `<p>MilieuAlert is a navigation app that warns drivers about low-emission zones (LEZ / milieuzone / ZTL), shows speed-camera reports and provides voice guidance. Zone, schedule and restriction data come from public sources and user reports and may be incomplete, outdated or wrong.</p>`
      },
      {
        h2: '3. Drive responsibly — no guarantees',
        html: `<ul>
<li>The app is an <strong>aid</strong>; it does not replace road signs, traffic law or common sense. Always follow signs and the authorities’ instructions.</li>
<li>Do not use your phone in a way that distracts you from driving. You are responsible for any interaction while moving.</li>
<li>We do not guarantee that a route avoids fines, nor the accuracy of zones, schedules, speeds or enforcement locations. To the extent permitted by law we are not liable for fines, delays or damage resulting from reliance on the app.</li>
<li>Community reports are submitted by users and are not verified by us.</li>
</ul>`
      },
      {
        h2: '4. Accounts',
        html: `<p>Some features need an account. You are responsible for keeping your credentials safe and for providing accurate information. We may suspend accounts that breach these terms (for example false reports or API abuse).</p>`
      },
      {
        h2: '5. Free trial and Premium subscription',
        html: `<ul>
<li><strong>15 days free</strong> with all features, from first launch/sign-up. After the trial, basic navigation remains available; Premium features require a subscription.</li>
<li><strong>MilieuAlert Premium: €1.99 per month</strong> (VAT included where applicable), renewing automatically every month until cancelled.</li>
<li>On Android, payment is handled by <strong>Google Play</strong> using the payment method on your Google account. We never see or store your card details.</li>
<li><strong>Cancel</strong> any time in Google Play → Payments &amp; subscriptions → Subscriptions → MilieuAlert. Cancellation takes effect at the end of the period already paid; no partial refunds for the current period except as required by law and Google Play policies.</li>
<li>Prices and terms may change; we will notify you as required by Google Play before a change applies to your renewal.</li>
<li>EU consumer withdrawal rights: for digital content supplied immediately, Google Play rules and consumer law apply.</li>
</ul>`
      },
      {
        h2: '6. Parking (EasyPark)',
        html: `<p>The “Pay for parking” button opens a third-party app or website (EasyPark). Parking is paid only inside the third party’s app under its own terms; MilieuAlert does not process parking payments and is not affiliated with EasyPark.</p>`
      },
      {
        h2: '7. Acceptable use',
        html: `<p>You must not submit false reports, bypass API limits, reverse-engineer or resell the service, use it for unlawful purposes or in ways that endanger other road users.</p>`
      },
      {
        h2: '8. Intellectual property',
        html: `<p>The app, brand and content belong to ${CONTROLLER} or their owners (map data: OpenStreetMap contributors and other providers). We grant you a personal, non-exclusive, revocable licence to use the app.</p>`
      },
      {
        h2: '9. Personal data',
        html: `<p>How we process data is described in the <a href="/privacy/en">Privacy policy</a>.</p>`
      },
      {
        h2: '10. Limitation of liability',
        html: `<p>The service is provided “as is”. To the extent permitted by law we are not liable for indirect damages or temporary unavailability. Mandatory consumer rights and liability that cannot be excluded by law are unaffected.</p>`
      },
      {
        h2: '11. Changes, governing law and contact',
        html: `<p>We may update these terms; the current version is always at this address. Continued use after changes means you accept them. Italian law applies, without prejudice to mandatory consumer protection rules of your country of residence. Questions: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>.</p>`
      }
    ]
  },
  nl: {
    htmlLang: 'nl',
    title: 'Gebruiksvoorwaarden | MilieuAlert',
    description:
      'Gebruiksvoorwaarden van MilieuAlert: gebruik van de app, 15 dagen gratis proef, Premium-abonnement €1,99/maand via Google Play, aansprakelijkheid.',
    h1: 'Gebruiksvoorwaarden',
    lead: `Deze voorwaarden gelden voor het gebruik van de MilieuAlert-app (Android en PWA). Bijgewerkt op ${UPDATED}. Door de app te gebruiken ga je akkoord.`,
    privacy: 'Privacyverklaring',
    sections: [
      {
        h2: '1. Wie wij zijn',
        html: `<p>MilieuAlert wordt aangeboden door <strong>${CONTROLLER}</strong>. Contact: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>.</p>`
      },
      {
        h2: '2. De dienst',
        html: `<p>MilieuAlert is een navigatie-app die waarschuwt voor milieuzones (LEZ / ZTL), flitsermeldingen toont en gesproken navigatie biedt. Gegevens over zones, tijden en verboden komen uit openbare bronnen en meldingen van gebruikers en kunnen onvolledig, verouderd of onjuist zijn.</p>`
      },
      {
        h2: '3. Verantwoord rijden — geen garanties',
        html: `<ul>
<li>De app is een <strong>hulpmiddel</strong> en vervangt geen verkeersborden of verkeerswetgeving. Volg altijd de borden en aanwijzingen van de autoriteiten.</li>
<li>Gebruik je telefoon niet op een manier die je afleidt tijdens het rijden. Je bent zelf verantwoordelijk voor bediening onderweg.</li>
<li>Wij garanderen niet dat een route boetes voorkomt, noch de juistheid van zones, tijden, snelheden of controlelocaties. Voor zover wettelijk toegestaan zijn wij niet aansprakelijk voor boetes, vertraging of schade door vertrouwen op de app.</li>
<li>Community-meldingen worden door gebruikers ingevoerd en niet door ons gecontroleerd.</li>
</ul>`
      },
      {
        h2: '4. Account',
        html: `<p>Sommige functies vereisen een account. Je bent verantwoordelijk voor je inloggegevens en voor juiste informatie. Wij kunnen accounts blokkeren die deze voorwaarden schenden (bijvoorbeeld valse meldingen of misbruik van de API).</p>`
      },
      {
        h2: '5. Gratis proef en Premium-abonnement',
        html: `<ul>
<li><strong>15 dagen gratis</strong> met alle functies, vanaf de eerste start/registratie. Daarna blijft basisnavigatie beschikbaar; Premium-functies vereisen een abonnement.</li>
<li><strong>MilieuAlert Premium: €1,99 per maand</strong> (incl. btw waar van toepassing), maandelijks automatisch verlengd tot opzegging.</li>
<li>Op Android verloopt de betaling via <strong>Google Play</strong> met de betaalmethode van je Google-account. Wij zien of bewaren je kaartgegevens niet.</li>
<li><strong>Opzeggen</strong> kan altijd in Google Play → Betalingen en abonnementen → Abonnementen → MilieuAlert. Opzegging gaat in aan het einde van de reeds betaalde periode; geen gedeeltelijke restitutie voor de lopende periode, behalve wanneer de wet of het beleid van Google Play dat vereist.</li>
<li>Prijzen en voorwaarden kunnen wijzigen; wij informeren je volgens de regels van Google Play voordat een wijziging voor jouw verlenging geldt.</li>
<li>Herroepingsrecht (EU): voor direct geleverde digitale inhoud gelden de regels van Google Play en het consumentenrecht.</li>
</ul>`
      },
      {
        h2: '6. Parkeren (EasyPark)',
        html: `<p>De knop “Parkeren betalen” opent een app of website van een derde (EasyPark). Parkeren wordt uitsluitend in de app van die derde betaald onder diens voorwaarden; MilieuAlert verwerkt geen parkeerbetalingen en is niet verbonden aan EasyPark.</p>`
      },
      {
        h2: '7. Toegestaan gebruik',
        html: `<p>Het is niet toegestaan valse meldingen te doen, API-limieten te omzeilen, de dienst te reverse-engineeren of door te verkopen, of de dienst te gebruiken voor onwettige doeleinden of op een manier die andere weggebruikers in gevaar brengt.</p>`
      },
      {
        h2: '8. Intellectueel eigendom',
        html: `<p>App, merk en inhoud behoren toe aan ${CONTROLLER} of hun rechthebbenden (kaartdata: OpenStreetMap-bijdragers en andere aanbieders). Je krijgt een persoonlijke, niet-exclusieve, herroepbare licentie om de app te gebruiken.</p>`
      },
      {
        h2: '9. Persoonsgegevens',
        html: `<p>Hoe wij gegevens verwerken staat in de <a href="/privacy/nl">Privacyverklaring</a>.</p>`
      },
      {
        h2: '10. Beperking van aansprakelijkheid',
        html: `<p>De dienst wordt geleverd “zoals hij is”. Voor zover wettelijk toegestaan zijn wij niet aansprakelijk voor indirecte schade of tijdelijke onbeschikbaarheid. Dwingende consumentenrechten en niet uit te sluiten aansprakelijkheid blijven onverlet.</p>`
      },
      {
        h2: '11. Wijzigingen, toepasselijk recht en contact',
        html: `<p>Wij kunnen deze voorwaarden aanpassen; de geldende versie staat altijd op dit adres. Doorgebruik na een wijziging betekent acceptatie. Italiaans recht is van toepassing, onverminderd dwingende consumentenbescherming in je woonland. Vragen: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a>.</p>`
      }
    ]
  }
};

function resolveLang(lang) {
  if (lang && PAGES[lang]) return lang;
  return 'it';
}

function renderTerms(lang) {
  const code = resolveLang(lang);
  const page = PAGES[code];
  const base = getBaseUrl();
  const canonical = termsUrl(lang ? code : null, base);
  const alts = {
    it: termsUrl('it', base),
    nl: termsUrl('nl', base),
    en: termsUrl('en', base),
    'x-default': termsUrl(null, base)
  };
  const hreflangs = Object.keys(alts)
    .map((l) => `  <link rel="alternate" hreflang="${escapeHtml(l)}" href="${escapeHtml(alts[l])}">`)
    .join('\n');
  const langNav = LOCALES.map((l) => {
    const current = l === code ? ' aria-current="page"' : '';
    return `<a href="${escapeHtml(termsPath(l))}"${current}>${l.toUpperCase()}</a>`;
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
    body { margin: 0; font-family: system-ui, Segoe UI, sans-serif; background: #0A0A1A; color: #e8f9ff; line-height: 1.55; }
    a { color: #00E5FF; }
    header, main, footer { max-width: 760px; margin: 0 auto; padding: 20px 22px; }
    header { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
    .brand { display: flex; align-items: center; gap: 10px; text-decoration: none; color: inherit; font-weight: 800; letter-spacing: .08em; }
    .brand img { border-radius: 12px; background: #fff; }
    .langs a { margin-left: 12px; text-decoration: none; font-weight: 700; }
    .langs a[aria-current="page"] { color: #fff; }
    h1 { font-size: 1.85rem; line-height: 1.2; margin: 12px 0 16px; }
    h2 { font-size: 1.2rem; margin: 28px 0 8px; color: #8be9ff; }
    .lead { font-size: 1.08rem; color: #c9f3ff; }
    ul { padding-left: 1.2rem; }
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
    <p><a href="/">${escapeHtml(base)}</a> · <a href="/privacy/${code}">${escapeHtml(page.privacy)}</a> · ${CONTROLLER}</p>
  </footer>
</body>
</html>
`;
}

module.exports = { PAGES, termsPath, termsUrl, resolveLang, renderTerms };
