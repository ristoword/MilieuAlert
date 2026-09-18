const { getBaseUrl, LOCALES, DEFAULT_LOCALE } = require('./config');
const { localeUrl, hreflangMap } = require('./landing');
const { privacyUrl, privacyHreflangMap } = require('./privacy');

function xmlEscape(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function xhtmlLinks(base) {
  const map = hreflangMap(base);
  return Object.keys(map)
    .map((code) => `    <xhtml:link rel="alternate" hreflang="${xmlEscape(code)}" href="${xmlEscape(map[code])}"/>`)
    .join('\n');
}

function urlEntry(loc, lastmod, priority, changefreq, links) {
  return `  <url>
    <loc>${xmlEscape(loc)}</loc>
    <lastmod>${lastmod}</lastmod>
    <changefreq>${changefreq}</changefreq>
    <priority>${priority}</priority>
${links}
  </url>`;
}

function buildSitemapXml(now) {
  const base = getBaseUrl();
  const lastmod = (now || new Date()).toISOString().split('T')[0];
  const links = xhtmlLinks(base);
  const chunks = [];

  chunks.push(urlEntry(`${base}/`, lastmod, '0.8', 'weekly', links));
  LOCALES.forEach((lang) => {
    const priority = lang === DEFAULT_LOCALE ? '1.0' : '0.95';
    chunks.push(urlEntry(localeUrl(lang, base), lastmod, priority, 'weekly', links));
  });

  const privacyMap = privacyHreflangMap(base);
  const privacyLinks = Object.keys(privacyMap)
    .map((code) => `    <xhtml:link rel="alternate" hreflang="${xmlEscape(code)}" href="${xmlEscape(privacyMap[code])}"/>`)
    .join('\n');
  chunks.push(urlEntry(privacyUrl(null, base), lastmod, '0.7', 'monthly', privacyLinks));
  LOCALES.forEach((lang) => {
    chunks.push(urlEntry(privacyUrl(lang, base), lastmod, '0.7', 'monthly', privacyLinks));
  });

  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xhtml="http://www.w3.org/1999/xhtml">
${chunks.join('\n')}
</urlset>
`;
}

module.exports = { buildSitemapXml };
