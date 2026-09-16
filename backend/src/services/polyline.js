/**
 * Google encoded polyline decoder.
 * MOTIS v2+ uses precision 6; v1 used 7.
 */
function decodePolyline(encoded, precision = 6) {
  if (!encoded || typeof encoded !== 'string') return [];
  const factor = 10 ** precision;
  const points = [];
  let index = 0;
  let lat = 0;
  let lon = 0;
  while (index < encoded.length) {
    let result = 0;
    let shift = 0;
    let b;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlat = result & 1 ? ~(result >> 1) : result >> 1;
    lat += dlat;

    result = 0;
    shift = 0;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlon = result & 1 ? ~(result >> 1) : result >> 1;
    lon += dlon;
    points.push({ lat: lat / factor, lon: lon / factor });
  }
  return points;
}

module.exports = { decodePolyline };
