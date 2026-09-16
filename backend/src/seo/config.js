function stripSlash(url) {
  return String(url || '').replace(/\/+$/, '');
}

function getBaseUrl() {
  const raw =
    process.env.MILIEUALERT_BASE_URL ||
    process.env.PUBLIC_BASE_URL ||
    'https://milieualert-production.up.railway.app';
  return stripSlash(raw);
}

const LOCALES = ['en', 'nl', 'it'];
const DEFAULT_LOCALE = 'en';

const OG_LOCALE = {
  en: 'en_US',
  nl: 'nl_NL',
  it: 'it_IT'
};

const IN_LANGUAGE = {
  en: 'en',
  nl: 'nl-NL',
  it: 'it-IT'
};

const OG_IMAGE_PATH = '/icons/Icon-512.png';

module.exports = {
  getBaseUrl,
  LOCALES,
  DEFAULT_LOCALE,
  OG_LOCALE,
  IN_LANGUAGE,
  OG_IMAGE_PATH
};
