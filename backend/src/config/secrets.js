const crypto = require('crypto');

const FALLBACK = 'fallback-secret-change-me';
const JWT_SECRET = process.env.JWT_SECRET || FALLBACK;

if (JWT_SECRET === FALLBACK && process.env.NODE_ENV === 'production') {
  // Do not crash the live API, but make the misconfiguration impossible to miss.
  console.error(
    '[SECURITY] JWT_SECRET is not set: tokens are signed with a public default. Set JWT_SECRET on Railway now.'
  );
}

/** Constant-time string comparison (avoids leaking secrets via timing). */
function safeEqual(a, b) {
  const x = Buffer.from(String(a ?? ''));
  const y = Buffer.from(String(b ?? ''));
  if (x.length !== y.length) return false;
  return crypto.timingSafeEqual(x, y);
}

module.exports = { JWT_SECRET, safeEqual };
