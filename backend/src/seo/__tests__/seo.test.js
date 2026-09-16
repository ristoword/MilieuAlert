const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  renderLanding,
  jsonLd,
  localeUrl,
  hreflangMap,
  getPage,
  buildSitemapXml,
  buildRobotsTxt,
  LOCALES
} = require('../index');

describe('MilieuAlert locale SEO', () => {
  it('builds unique titles, H1 and descriptions per locale', () => {
    const en = getPage('en');
    const nl = getPage('nl');
    const it = getPage('it');
    assert.notEqual(en.title, nl.title);
    assert.notEqual(nl.title, it.title);
    assert.notEqual(en.h1, it.h1);
    assert.match(en.title, /GPS navigator/i);
    assert.match(nl.title, /GPS-navigator/i);
    assert.match(it.title, /Navigatore GPS/i);
    assert.match(en.description, /milieuzone/);
    assert.match(nl.description, /lage-emissiezone/);
    assert.match(it.description, /ZTL ambientale/);
  });

  it('renders crawlable HTML with canonical, hreflang, OG, Twitter, FAQ and CTA', () => {
    const html = renderLanding('it');
    assert.match(html, /<html lang="it"/);
    assert.match(html, /<h1>/);
    assert.match(html, /rel="canonical" href="https:\/\/milieualert-production\.up\.railway\.app\/it"/);
    assert.match(html, /hreflang="en"/);
    assert.match(html, /hreflang="nl"/);
    assert.match(html, /hreflang="x-default"/);
    assert.match(html, /property="og:image" content="https:\/\/milieualert-production\.up\.railway\.app\/icons\/Icon-512\.png"/);
    assert.match(html, /name="twitter:card" content="summary_large_image"/);
    assert.match(html, /application\/ld\+json/);
    assert.match(html, /<a class="cta" href="\/"/);
    assert.match(html, /autovelox/);
    assert.match(html, /EcoEntry/);
    assert.doesNotMatch(html, /rank 1|primo posto garantito| gegarandeerd nummer 1/i);
  });

  it('JSON-LD includes SoftwareApplication, FAQPage and BreadcrumbList', () => {
    const ld = jsonLd('en');
    const types = ld['@graph'].map((n) => n['@type']).sort();
    assert.deepEqual(types, ['BreadcrumbList', 'FAQPage', 'SoftwareApplication']);
    const app = ld['@graph'].find((n) => n['@type'] === 'SoftwareApplication');
    assert.equal(app.name, 'MilieuAlert');
    assert.ok(app.alternateName.includes('milieurzone'));
    assert.equal(app.applicationCategory, 'TravelApplication');
    const faq = ld['@graph'].find((n) => n['@type'] === 'FAQPage');
    assert.ok(faq.mainEntity.length >= 6);
  });

  it('sitemap lists /, /en, /nl, /it with hreflang', () => {
    const xml = buildSitemapXml(new Date('2026-09-16'));
    assert.match(xml, /https:\/\/milieualert-production\.up\.railway\.app\/<\/loc>/);
    assert.match(xml, /\/en<\/loc>/);
    assert.match(xml, /\/nl<\/loc>/);
    assert.match(xml, /\/it<\/loc>/);
    assert.match(xml, /hreflang="en"/);
    assert.match(xml, /hreflang="nl"/);
    assert.match(xml, /hreflang="it"/);
    assert.match(xml, /hreflang="x-default"/);
    assert.match(xml, /<lastmod>2026-09-16<\/lastmod>/);
  });

  it('robots allows locale landings and points to sitemap', () => {
    const txt = buildRobotsTxt();
    assert.match(txt, /Allow: \//);
    assert.match(txt, /Allow: \/en/);
    assert.match(txt, /Disallow: \/api\//);
    assert.match(txt, /Sitemap: https:\/\/milieualert-production\.up\.railway\.app\/sitemap\.xml/);
  });

  it('hreflang map and locale URLs stay on the public origin', () => {
    const base = 'https://milieualert-production.up.railway.app';
    assert.equal(localeUrl('nl', base), `${base}/nl`);
    const map = hreflangMap(base);
    LOCALES.forEach((lang) => assert.equal(map[lang], `${base}/${lang}`));
    assert.equal(map['x-default'], `${base}/en`);
  });
});
