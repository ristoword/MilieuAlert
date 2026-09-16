const { LOCALES, getBaseUrl } = require('./config');
const { renderLanding, jsonLd, localeUrl, hreflangMap } = require('./landing');
const { getPage } = require('./content');
const { buildSitemapXml } = require('./sitemap');
const { buildRobotsTxt } = require('./robots');

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

  LOCALES.forEach((lang) => {
    app.get(`/${lang}/`, (_req, res) => {
      res.redirect(301, `/${lang}`);
    });
    app.get(`/${lang}`, (_req, res) => {
      res
        .type('html; charset=utf-8')
        .set('Cache-Control', 'public, max-age=300, must-revalidate')
        .send(renderLanding(lang));
    });
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
  buildRobotsTxt
};
