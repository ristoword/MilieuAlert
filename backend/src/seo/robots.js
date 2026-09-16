const { getBaseUrl } = require('./config');

function buildRobotsTxt() {
  const base = getBaseUrl();
  return `User-agent: *
Allow: /
Allow: /en
Allow: /nl
Allow: /it
Disallow: /api/

Sitemap: ${base}/sitemap.xml
`;
}

module.exports = { buildRobotsTxt };
