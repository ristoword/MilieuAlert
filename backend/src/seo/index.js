const { LOCALES, getBaseUrl } = require('./config');
const { renderLanding, jsonLd, localeUrl, hreflangMap } = require('./landing');
const { getPage } = require('./content');
const { buildSitemapXml } = require('./sitemap');
const { buildRobotsTxt } = require('./robots');
const { renderPrivacy, privacyPath, privacyUrl, privacyHreflangMap } = require('./privacy');

function sendHtml(res, html) {
  res
    .type('html; charset=utf-8')
    .set('Cache-Control', 'public, max-age=300, must-revalidate')
    .send(html);
}

function mount(app) {
  app.get('/robots.txt', (_req, res) => {
    res
      .type('text/plain; charset=utf-8')
      .set('Cache-Control', 'public, max-age=3600')
      .send(buildRobotsTxt());
  });

  app.get('/sitemap.xml', (_req, res) => {
    res
      .type('application/xml; charset=utf-8')
      .set('Cache-Control', 'public, max-age=3600')
      .send(buildSitemapXml());
  });

  // GDPR pages — registered before static / SPA so Flutter index.html cannot win.
  // Do not add a '/privacy/' redirect: Express treats /privacy and /privacy/ as
  // the same route and that redirect would loop.
  app.get('/privacy', (_req, res) => sendHtml(res, renderPrivacy(null)));
  LOCALES.forEach((lang) => {
    app.get(`/privacy/${lang}`, (_req, res) => sendHtml(res, renderPrivacy(lang)));
  });

  LOCALES.forEach((lang) => {
    app.get(`/${lang}/`, (_req, res) => {
      res.redirect(301, `/${lang}`);
    });
    app.get(`/${lang}`, (_req, res) => sendHtml(res, renderLanding(lang)));
  });
}

module.exports = {
  mount,
  LOCALES,
  getBaseUrl,
  renderLanding,
  jsonLd,
  localeUrl,
  hreflangMap,
  getPage,
  buildSitemapXml,
  buildRobotsTxt,
  renderPrivacy,
  privacyPath,
  privacyUrl,
  privacyHreflangMap
};
