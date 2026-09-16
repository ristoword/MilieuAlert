function normalizeTravelMode(raw) {
  const m = String(raw || 'car').toLowerCase().trim();
  if (m === 'foot' || m === 'walk' || m === 'walking' || m === 'piedi') {
    return 'foot';
  }
  if (
    m === 'transit' ||
    m === 'public' ||
    m === 'mezzi' ||
    m === 'pt' ||
    m === 'otp'
  ) {
    return 'transit';
  }
  return 'car';
}

module.exports = { normalizeTravelMode };
