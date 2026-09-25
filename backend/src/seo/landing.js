const { getBaseUrl, LOCALES, DEFAULT_LOCALE, OG_LOCALE, IN_LANGUAGE, OG_IMAGE_PATH } = require('./config');
const { getPage } = require('./content');

function escapeHtml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function localePath(lang) {
  return `/${lang}`;
}

function localeUrl(lang, base = getBaseUrl()) {
  return `${base}${localePath(lang)}`;
}

function hreflangMap(base = getBaseUrl()) {
  const map = {};
  LOCALES.forEach((lang) => {
    map[lang] = localeUrl(lang, base);
  });
  map['x-default'] = localeUrl(DEFAULT_LOCALE, base);
  return map;
}

function jsonLd(lang, base = getBaseUrl()) {
  const page = getPage(lang);
  const canonical = localeUrl(lang, base);
  const image = `${base}${OG_IMAGE_PATH}`;
  const inLanguage = IN_LANGUAGE[lang] || lang;

  const software = {
    '@type': 'SoftwareApplication',
    '@id': `${base}/#app`,
    name: 'MilieuAlert',
    alternateName: ['EcoEntry', 'milieurzone'],
    applicationCategory: 'TravelApplication',
    operatingSystem: 'Web, Android, iOS',
    inLanguage,
    description: page.description,
    url: canonical,
    image,
    screenshot: image,
    featureList: [
      'GPS navigator / navigatore GPS / GPS-navigator',
      'EcoEntry Euro 2 Euro 3 Euro 4 Euro 5',
      'Your car, your zone, your access',
      'milieuzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ, clean air zone',
      'Amsterdam Rotterdam Utrecht Antwerpen Bruxelles Milano Area B Paris ZFE London ULEZ',
      'autovelox / flitsers'
    ],
    offers: {
      '@type': 'Offer',
      url: canonical,
      price: '1.99',
      priceCurrency: 'EUR',
      availability: 'https://schema.org/InStock'
    },
    isAccessibleForFree: true,
    brand: { '@type': 'Brand', name: 'MilieuAlert' }
  };

  const faq = {
    '@type': 'FAQPage',
    '@id': `${canonical}#faq`,
    inLanguage,
    mainEntity: page.faq.map(([q, a]) => ({
      '@type': 'Question',
      name: q,
      acceptedAnswer: { '@type': 'Answer', text: a }
    }))
  };

  const crumbs = {
    '@type': 'BreadcrumbList',
    itemListElement: [
      {
        '@type': 'ListItem',
        position: 1,
        name: 'MilieuAlert',
        item: `${base}/`
      },
      {
        '@type': 'ListItem',
        position: 2,
        name: page.breadcrumb,
        item: canonical
      }
    ]
  };

  return {
    '@context': 'https://schema.org',
    '@graph': [software, faq, crumbs]
  };
}

function renderLanding(lang) {
  const page = getPage(lang);
  const base = getBaseUrl();
  const canonical = localeUrl(lang, base);
  const image = `${base}${OG_IMAGE_PATH}`;
  const alts = hreflangMap(base);
  const hreflangs = Object.keys(alts)
    .map((code) => `  <link rel="alternate" hreflang="${escapeHtml(code)}" href="${escapeHtml(alts[code])}">`)
    .join('\n');
  const ogAlts = LOCALES.filter((l) => l !== lang)
    .map((l) => `  <meta property="og:locale:alternate" content="${OG_LOCALE[l]}">`)
    .join('\n');

  const sections = page.sections
    .map(
      (s) => `      <section>
        <h2>${escapeHtml(s.h2)}</h2>
        <p>${escapeHtml(s.p)}</p>
      </section>`
    )
    .join('\n');

  const faqs = page.faq
    .map(
      ([q, a]) => `        <details>
          <summary>${escapeHtml(q)}</summary>
          <p>${escapeHtml(a)}</p>
        </details>`
    )
    .join('\n');

  const langNav = LOCALES.map((code) => {
    const label = code.toUpperCase();
    const current = code === lang ? ' aria-current="page"' : '';
    return `<a href="${escapeHtml(localePath(code))}"${current}>${label}</a>`;
  }).join('');

  const ld = JSON.stringify(jsonLd(lang, base)).replace(/</g, '\\u003c');

  return `<!DOCTYPE html>
<html lang="${escapeHtml(page.htmlLang)}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(page.title)}</title>
  <meta name="description" content="${escapeHtml(page.description)}">
  <meta name="keywords" content="${escapeHtml(page.keywords)}">
  <meta name="robots" content="index, follow">
  <meta name="theme-color" content="#00E5FF">
  <link rel="canonical" href="${escapeHtml(canonical)}">
${hreflangs}
  <meta property="og:title" content="${escapeHtml(page.ogTitle)}">
  <meta property="og:description" content="${escapeHtml(page.description)}">
  <meta property="og:type" content="website">
  <meta property="og:url" content="${escapeHtml(canonical)}">
  <meta property="og:image" content="${escapeHtml(image)}">
  <meta property="og:image:alt" content="MilieuAlert">
  <meta property="og:site_name" content="MilieuAlert">
  <meta property="og:locale" content="${OG_LOCALE[lang]}">
${ogAlts}
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${escapeHtml(page.ogTitle)}">
  <meta name="twitter:description" content="${escapeHtml(page.description)}">
  <meta name="twitter:image" content="${escapeHtml(image)}">
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="apple-touch-icon" href="/icons/Icon-192.png">
  <link rel="manifest" href="/manifest.json">
  <script type="application/ld+json">${ld}</script>
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
    .lead { font-size: 1.08rem; color: #c9f3ff; }
    .cta {
      display: inline-block;
      margin-top: 8px;
      background: #00E5FF;
      color: #041018;
      font-weight: 800;
      text-decoration: none;
      padding: 12px 18px;
      border-radius: 12px;
    }
    .hint { color: #8aa; font-size: .92rem; }
    details { border-top: 1px solid #1d3a48; padding: 12px 0; }
    summary { cursor: pointer; font-weight: 700; }
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
    <p><a class="cta" href="/">${escapeHtml(page.cta)}</a></p>
    <h1>${escapeHtml(page.h1)}</h1>
    <p class="lead">${escapeHtml(page.lead)}</p>
    <p class="hint">${escapeHtml(page.ctaHint)}</p>
${sections}
    <section>
      <h2>FAQ</h2>
${faqs}
    </section>
    <p><a class="cta" href="/">${escapeHtml(page.cta)}</a></p>
  </main>
  <footer>
    <p>MilieuAlert · EcoEntry · ${escapeHtml(page.navApp)}: <a href="/">${base}/</a> · <a href="/privacy">Privacy</a></p>
  </footer>
</body>
</html>
`;
}

module.exports = {
  escapeHtml,
  localePath,
  localeUrl,
  hreflangMap,
  jsonLd,
  renderLanding
};
