const fs = require('fs');
const path = require('path');
const { LOCALES, renderLanding, buildSitemapXml, buildRobotsTxt } = require('../src/seo');

const pub = path.join(__dirname, '..', 'public');

function restore() {
  fs.mkdirSync(pub, { recursive: true });
  fs.writeFileSync(path.join(pub, 'robots.txt'), buildRobotsTxt());
  fs.writeFileSync(path.join(pub, 'sitemap.xml'), buildSitemapXml());
  LOCALES.forEach((lang) => {
    const dir = path.join(pub, lang);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'index.html'), renderLanding(lang));
  });
  console.log('Restored SEO files into backend/public (robots.txt, sitemap.xml, /en /nl /it).');
}

restore();
