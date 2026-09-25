/**
 * Unique on-page copy per locale. Same facts, different search intent — not calques.
 */

const CITIES =
  'Amsterdam, Rotterdam, Utrecht, Antwerpen, Bruxelles, Milano Area B, Paris ZFE, London ULEZ';

const PAGES = {
  en: {
    htmlLang: 'en',
    title: 'MilieuAlert GPS navigator | milieuzone, LEZ, EcoEntry Euro 2–5',
    description:
      'GPS navigator for milieuzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ and clean air zones. EcoEntry checks Euro 2–5: your car, your zone, your access. Autovelox and flitsers on the route.',
    keywords:
      'GPS navigator, milieuzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ, clean air zone, EcoEntry, Euro 2, Euro 3, Euro 4, Euro 5, your car your zone your access, Amsterdam, Rotterdam, Utrecht, Antwerpen, Bruxelles, Milano Area B, Paris ZFE, London ULEZ, autovelox, flitsers, MilieuAlert, milieurzone, environmental zone',
    ogTitle: 'MilieuAlert — GPS navigator for milieuzone and LEZ',
    h1: 'GPS navigator for environmental zones — your car, your zone, your access',
    lead:
      'MilieuAlert is a GPS navigator with EcoEntry: it matches your vehicle (Euro 2, Euro 3, Euro 4, Euro 5) to the milieuzone, LEZ or clean air zone ahead — then speaks before you enter.',
    cta: 'Open the GPS navigator',
    ctaHint: 'Free for 15 days, then €1.99/month. Install as a PWA.',
    navApp: 'Open app',
    breadcrumb: 'GPS navigator',
    sections: [
      {
        h2: 'Milieuzone, LEZ and environmental zone in one map',
        p: `Low-emission rules use many names: milieuzone (also searched as milieurzone), lage-emissiezone, Umweltzone, ZTL ambientale, LEZ, clean air zone. MilieuAlert treats them as one driving problem: can your car enter this zone on this route, right now?`
      },
      {
        h2: 'EcoEntry: Euro 2, Euro 3, Euro 4, Euro 5',
        p: 'Save your vehicle once. EcoEntry compares the Euro class with local access rules — diesel and petrol are not treated as the same sticker. The line is simple: your car, your zone, your access. No generic “green city” map that ignores what you drive.'
      },
      {
        h2: 'Cities drivers actually search',
        p: `${CITIES}. Coverage is Europe-wide LEZ / milieuzone / Umweltzone / ZFE / ZTL / ULEZ / ZBE (EU plus UK, Switzerland and Norway), using official GeoJSON where published. Open the navigator for the live map, not a static PDF.`
      },
      {
        h2: 'Autovelox and flitsers on the route',
        p: 'The same GPS navigation that watches zones also flags speed cameras: autovelox in Italy, flitsers in the Netherlands and Belgium. Pins on the remaining route, spoken when a new camera appears — next to the milieuzone alert, not instead of it.'
      },
      {
        h2: 'A navigator, not a brochure',
        p: 'MilieuAlert is turn-by-turn GPS navigation with voice, geofence alerts and an on-route assistant. It is not a replacement for the highway code. Zone rules change; the app is a warning layer so you can reroute before a fine.'
      }
    ],
    faq: [
      [
        'What is a milieuzone or LEZ?',
        'A milieuzone (Dutch), lage-emissiezone, Umweltzone, ZTL ambientale, LEZ or clean air zone is a low-emission area. Access depends on fuel and Euro class. MilieuAlert checks that against your saved vehicle before you drive in.'
      ],
      [
        'How does EcoEntry work with Euro 2, 3, 4 and 5?',
        'You register Euro 2, Euro 3, Euro 4 or Euro 5 (and fuel type). EcoEntry is the check: your car, your zone, your access — allow, warn or avoid — for the zone on the GPS route.'
      ],
      [
        'Which cities does the GPS navigator cover?',
        `Searches we build for include ${CITIES}. Open the live map in the PWA for current polygons; names on this page describe the product, not a legal register.`
      ],
      [
        'Does MilieuAlert show autovelox and flitsers?',
        'Yes. Navigation can show speed cameras on the remaining route (autovelox / flitsers) and announce new ones, together with milieuzone and LEZ alerts.'
      ],
      [
        'Is this a GPS navigator or only a zone list?',
        'It is a GPS navigator: map, route, voice, EcoEntry zone access and camera alerts. Zone data is there to decide access, not as a standalone encyclopedia.'
      ],
      [
        'Why “MilieuAlert” and “milieurzone”?',
        'MilieuAlert is the product name. Drivers also search milieuzone and the common misspelling milieurzone. Same app: environmental-zone GPS with EcoEntry.'
      ],
      [
        'How much does it cost?',
        '15 days after registration, then €1.99 per month. Open the PWA to start. Sold via Gestione Semplificata / Google Play.',
      ],
      [
        'Does this replace Google Maps or Waze?',
        'No. It is a specialist GPS navigator for LEZ / milieuzone access plus cameras. Use it when the fine risk is the environmental zone, not as a general traffic social network.'
      ]
    ]
  },

  nl: {
    htmlLang: 'nl',
    title: 'GPS-navigator MilieuAlert | milieuzone, LEZ, EcoEntry Euro 2–5',
    description:
      'GPS-navigator voor milieuzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ en clean air zone. EcoEntry toetst Euro 2–5: jouw auto, jouw zone, jouw toegang. Flitsers en autovelox op de route.',
    keywords:
      'GPS-navigator, milieuzone, milieurzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ, clean air zone, EcoEntry, Euro 2, Euro 3, Euro 4, Euro 5, jouw auto jouw zone jouw toegang, Amsterdam, Rotterdam, Utrecht, Antwerpen, Brussel, Milano Area B, Paris ZFE, London ULEZ, flitsers, autovelox, MilieuAlert',
    ogTitle: 'MilieuAlert — GPS-navigator voor milieuzone en LEZ',
    h1: 'GPS-navigator voor milieuzone — jouw auto, jouw zone, jouw toegang',
    lead:
      'MilieuAlert is een GPS-navigator met EcoEntry: hij legt jouw voertuig (Euro 2, Euro 3, Euro 4, Euro 5) naast de milieuzone of LEZ op de route en waarschuwt vóór je inrijdt.',
    cta: 'Open de GPS-navigator',
    ctaHint: '15 dagen gratis, daarna €1,99/maand. Installeer als PWA.',
    navApp: 'Open app',
    breadcrumb: 'GPS-navigator',
    sections: [
      {
        h2: 'Milieuzone, lage-emissiezone en LEZ op één kaart',
        p: 'Je zoekt milieuzone, milieurzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ of clean air zone. De app maakt er één rijvraag van: mag deze auto deze zone op dit traject in, nu?'
      },
      {
        h2: 'EcoEntry: Euro 2 tot Euro 5',
        p: 'Sla je auto één keer op. EcoEntry vergelijkt de Euroklasse met de lokale toegang — diesel is niet hetzelfde als benzine. De regel is kort: jouw auto, jouw zone, jouw toegang. Geen generieke “groene stad”-kaart zonder kentekenlogica.'
      },
      {
        h2: 'Steden waarnaar je écht navigeert',
        p: `${CITIES}. Dekking is Europa-breed: milieuzone, LEZ, Umweltzone, ZFE, ZTL, ULEZ en ZBE (EU plus VK, Zwitserland en Noorwegen), met officiële GeoJSON waar die bestaat. De live kaart zit in de navigator, niet in een PDF.`
      },
      {
        h2: 'Flitsers en autovelox op het traject',
        p: 'Zelfde GPS-navigatie als de zone-wacht: flitsers in NL/BE, autovelox in IT. Pins op het restant van de route, spraak als er een nieuwe camera bijkomt — naast de milieuzone-melding.'
      },
      {
        h2: 'Een navigator, geen folder',
        p: 'MilieuAlert is turn-by-turn GPS met spraak, geofence en een assistent op de route. Het vervangt de verkeerswet niet. Zones wijzigen; de app is een waarschuwing zodat je kunt omrijden vóór een boete.'
      }
    ],
    faq: [
      [
        'Wat is een milieuzone of LEZ?',
        'Een milieuzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ of clean air zone beperkt toegang op brandstof en Euroklasse. MilieuAlert toetst dat aan jouw opgeslagen auto vóór je inrijdt.'
      ],
      [
        'Hoe werkt EcoEntry met Euro 2, 3, 4 en 5?',
        'Je zet Euro 2, Euro 3, Euro 4 of Euro 5 plus brandstof. EcoEntry is de check: jouw auto, jouw zone, jouw toegang — toelaten, waarschuwen of mijden — voor de zone op de GPS-route.'
      ],
      [
        'Welke steden dekt de GPS-navigator?',
        `Onder meer ${CITIES}. Open de PWA voor actuele vlakken; deze pagina beschrijft het product, geen juridisch register.`
      ],
      [
        'Toont MilieuAlert flitsers en autovelox?',
        'Ja. Navigatie kan flitsers/autovelox op het resterende traject tonen en nieuwe camera’s omroepen, samen met milieuzone- en LEZ-alerts.'
      ],
      [
        'Is dit een GPS-navigator of alleen een zonelijst?',
        'Het is een GPS-navigator: kaart, route, spraak, EcoEntry-toegang en camera-alerts. Zonedata dient om toegang te beslissen.'
      ],
      [
        'Waarom MilieuAlert en milieurzone?',
        'MilieuAlert is de productnaam. Mensen zoeken milieuzone en vaak milieurzone. Dezelfde app: milieuzone-GPS met EcoEntry.'
      ],
      [
        'Wat kost het?',
        '15 dagen na registratie, daarna €1,99 per maand. Open de PWA. Verkoop via Gestione Semplificata / Google Play.'
      ],
      [
        'Vervangt dit Google Maps of Waze?',
        'Nee. Het is een specialistische GPS-navigator voor LEZ/milieuzone plus camera’s. Gebruik het als de boete in de milieuzone zit, niet als algemeen file-netwerk.'
      ]
    ]
  },

  it: {
    htmlLang: 'it',
    title: 'Navigatore GPS MilieuAlert | milieuzone, ZTL ambientale, LEZ',
    description:
      'Navigatore GPS per milieuzone, ZTL ambientale, LEZ, Umweltzone e clean air zone. EcoEntry verifica Euro 2–5: la tua auto, la tua zona, il tuo accesso. Autovelox e flitsers sul percorso.',
    keywords:
      'navigatore GPS, milieuzone, milieurzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ, clean air zone, EcoEntry, Euro 2, Euro 3, Euro 4, Euro 5, la tua auto la tua zona il tuo accesso, Amsterdam, Rotterdam, Utrecht, Antwerpen, Bruxelles, Milano Area B, Paris ZFE, London ULEZ, autovelox, flitsers, MilieuAlert',
    ogTitle: 'MilieuAlert — navigatore GPS per milieuzone e LEZ',
    h1: 'Navigatore GPS EcoEntry — la tua auto, la tua zona, il tuo accesso',
    lead:
      'MilieuAlert è un navigatore GPS con EcoEntry: confronta il veicolo (Euro 2, Euro 3, Euro 4, Euro 5) con la milieuzone, la ZTL ambientale o la LEZ sul percorso e avvisa prima dell’ingresso.',
    cta: 'Apri il navigatore GPS',
    ctaHint: '15 giorni gratis, poi 1,99€/mese. Installala come PWA.',
    navApp: 'Apri l’app',
    breadcrumb: 'Navigatore GPS',
    sections: [
      {
        h2: 'Milieuzone, ZTL ambientale e LEZ sulla stessa mappa',
        p: 'Le regole cambiano nome: milieuzone (anche cercata come milieurzone), lage-emissiezone, Umweltzone, ZTL ambientale, LEZ, clean air zone. MilieuAlert le riduce a una domanda di guida: quest’auto può entrare in questa zona su questo itinerario, adesso?'
      },
      {
        h2: 'EcoEntry: Euro 2, Euro 3, Euro 4, Euro 5',
        p: 'Registri il veicolo una volta. EcoEntry confronta la classe Euro con le regole locali — diesel e benzina non sono lo stesso bollino. La frase è quella del prodotto: your car, your zone, your access. Non una mappa “città green” che ignora cosa guidi.'
      },
      {
        h2: 'Città che i conducenti cercano davvero',
        p: `${CITIES}. Copertura europea: milieuzone, LEZ, Umweltzone, ZFE, ZTL, ULEZ e ZBE (UE più Regno Unito, Svizzera e Norvegia), con GeoJSON ufficiali dove esistono. La mappa viva è nel navigatore, non in un PDF.`
      },
      {
        h2: 'Autovelox e flitsers sul percorso',
        p: 'Lo stesso navigatore GPS che guarda le zone segnala gli autovelox e i flitsers (Paesi Bassi/Belgio). Pin sul tratto rimasto, voce se ne compare uno nuovo — insieme all’allerta milieuzone, non al posto suo.'
      },
      {
        h2: 'Un navigatore, non un depliant',
        p: 'MilieuAlert è navigazione turn-by-turn con voce, geofence e assistente di percorso. Non sostituisce il codice della strada. Le zone cambiano; l’app è uno strato di preavviso per deviare prima della sanzione.'
      }
    ],
    faq: [
      [
        'Che cos’è una milieuzone o una LEZ?',
        'Milieuzone, lage-emissiezone, Umweltzone, ZTL ambientale, LEZ o clean air zone sono aree a basse emissioni. L’accesso dipende da carburante e classe Euro. MilieuAlert lo confronta con il veicolo salvato prima che tu entri.'
      ],
      [
        'Come funziona EcoEntry con Euro 2, 3, 4 e 5?',
        'Indichi Euro 2, Euro 3, Euro 4 o Euro 5 e il carburante. EcoEntry è il controllo: la tua auto, la tua zona, il tuo accesso — consenti, avvisa o evita — per la zona sul percorso GPS.'
      ],
      [
        'Quali città copre il navigatore GPS?',
        `Tra le ricerche coperte: ${CITIES}. Apri la PWA per i poligoni aggiornati; questa pagina descrive il prodotto, non un albo legale.`
      ],
      [
        'MilieuAlert mostra autovelox e flitsers?',
        'Sì. La navigazione può mostrare autovelox/flitsers sul tratto restante e annunciare quelli nuovi, insieme alle allerte milieuzone e LEZ.'
      ],
      [
        'È un navigatore GPS o solo un elenco zone?',
        'È un navigatore GPS: mappa, itinerario, voce, accesso EcoEntry e allerte telecamere. I dati zona servono a decidere l’ingresso.'
      ],
      [
        'Perché MilieuAlert e milieurzone?',
        'MilieuAlert è il nome del prodotto. Si cerca milieuzone e spesso milieurzone. Stessa app: navigatore per zone ambientali con EcoEntry.'
      ],
      [
        'Quanto costa?',
        '15 giorni dopo la registrazione, poi 1,99€ al mese. Apri la PWA. Vendita tramite Gestione Semplificata / Google Play.'
      ],
      [
        'Sostituisce Google Maps o Waze?',
        'No. È un navigatore GPS specializzato su LEZ/milieuzone e autovelox. Usalo quando il rischio è la zona ambientale, non come social del traffico.'
      ]
    ]
  }
};

function getPage(lang) {
  return PAGES[lang] || PAGES.en;
}

module.exports = { PAGES, CITIES, getPage };
