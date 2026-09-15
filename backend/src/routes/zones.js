const express = require('express');
const router = express.Router();

router.get('/sync', async (req, res) => {
  res.json({
    sources: [
      {
        country: 'NL',
        name: 'NDW Emission Zones',
        url: 'https://data.ndw.nu/api/rest/static-road-data/emission-zones/v1/map',
        format: 'GeoJSON',
        license: 'CC-0',
      },
      {
        country: 'BE',
        city: 'Antwerpen',
        name: 'Antwerpen LEZ',
        url: 'https://geodata.antwerpen.be/arcgissql/rest/services/P_Portal/portal_publiek4/MapServer/283/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&f=geojson',
        format: 'GeoJSON',
      },
      {
        country: 'BE',
        city: 'Brussels',
        name: 'Brussels LEZ',
        url: 'https://gis.brussels.be/geoserver/bm_network/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=bm_network:lez_zone&outputFormat=application/json&srsName=EPSG:4326',
        format: 'GeoJSON',
      },
    ],
    last_updated: new Date().toISOString(),
  });
});

module.exports = router;
