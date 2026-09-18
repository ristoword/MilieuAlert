# European LEZ coverage

Snapshot generated into `europe-zones.json` and served by `GET /api/zones/data`.
Alerts and drop-off still use the same `/api/zones/data` polygons; no Flutter change.

## What is loaded now

Open catalog (TyreMap CC BY 4.0) plus official national GeoJSON and OSM polygons where Overpass responded:

| Source | Role |
| --- | --- |
| TyreMap Europe emission zones (CC BY 4.0) | Fullest public city catalog (LEZ / ULEZ / ZTL / Umweltzone / ZFE / ZBE / CAZ / IG-L) |
| NDW (CC0) | Netherlands milieuzone + zero-emission zones with official polygons |
| Antwerpen LEZ GeoJSON | Official Belgian polygon |
| Base nationale ZFE `aires.geojson` (Licence Ouverte) | French ZFE |
| OpenStreetMap `boundary=low_emission_zone` (ODbL) | Extra polygons (west/south Europe on last import; Overpass 429 elsewhere) |

Minimum countries requested (NL BE DE FR IT ES UK AT SE DK PL CZ PT) plus CH and NO are all present.

## Remaining gaps (open data cannot fully provide)

- **Vienna** has no permanent city LEZ in TyreMap, OSM LEZ tags, or national GeoJSON. Austria in the snapshot is IG-L corridors: Graz, Innsbruck, Linz, Salzburg.
- **Brussels GIS WFS** and **Gent Stad open-data GeoJSON** failed at import time (network / 404). Brussels and Ghent still come from TyreMap + OSM.
- **OSM Overpass** rate-limited (HTTP 429) for central, eastern, northern Europe and Italian ZTL relations. Cities without a published polygon use a **centroid buffer** (`geometrySource: approx`) from TyreMap coordinates — not a cadastral boundary. Examples: Warsaw, Prague, Copenhagen, Oslo, Zurich, many small Spanish ZBE and Italian ZTL.
- **French `voies.geojson`** (road-level ZFE exceptions) is not ingested; area polygons only.
- **Sticker rules** (Crit'Air, Umweltplakette, DGT) are not fully modeled; EcoEntry still uses a single `minimumEuroLevel`.
- **No open polygon** found for some planned/odd-even schemes (Athens ring is in the catalog; seasonal/odd-even hours may be incomplete).
- EU members **without a known environmental zone in the catalog**: Luxembourg, Slovenia, Romania (and microstates). Not omitted by mistake — the open lists have no active LEZ row.

Refresh: `npm run import-zones` in `backend/` (optional OSM enrich scripts if Overpass is healthy).
