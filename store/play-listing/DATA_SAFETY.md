# Data safety — risposte Console (MilieuAlert)

Package: `com.milieuzone.milieu_alert`  
Privacy URL: https://milieualert-production.up.railway.app/privacy

## Raccoglie dati? Sì

| Tipo Play | Dati | Raccolti | Condivisi | Obbligatori | Uso dichiarato | Venduti |
|---|---|---|---|---|---|---|
| Posizione | Posizione approssimativa | Sì | No (solo nostri server) | Sì, per navigare | Funzionalità app | **No** |
| Posizione | Posizione precisa | Sì | No | Sì, per navigare / geofence | Funzionalità app | **No** |
| Posizione | Posizione in background | Sì, se l’utente concede “sempre” | No | No (consenso OS) | Funzionalità app (avvisi zona in guida) | **No** |
| Info personali | Nome (display name) | Sì, se account | No | No | Funzionalità app | **No** |
| Info personali | Email | Sì, se account | No | No (account facoltativo) | Funzionalità app / account | **No** |
| Info utente | Altro: classe Euro, carburante, targa opzionale | Sì | No | No | Funzionalità app (EcoEntry) | **No** |
| Attività app | Azioni in-app (segnalazioni autovelox/incidenti, log zona) | Sì | Sì, segnalazioni visibili ad altri conducenti (tipo + coordinate, non identità) | No | Funzionalità app | **No** |
| Audio | Voce | No (TTS in uscita, non registriamo microfono) | — | — | — | — |
| Foto / video | Fotocamera dispositivo | **No** | — | — | “Camere” = autovelox, non scatti | — |
| File e documenti | No | — | — | — | — | — |
| Calendario / contatti | No | — | — | — | — | — |
| ID dispositivo | ID dispositivo anonimo per voti/segnalazioni | Sì | No | No | Funzionalità app / anti-abuso | **No** |

## Domande ricorrenti Console

- **I dati sono venduti?** No.
- **I dati sono usati per pubblicità?** No.
- **Crittografia in transito?** Sì (HTTPS; `usesCleartextTraffic=false`).
- **L’utente può chiedere la cancellazione?** Sì: assistenza@gestionesemplificata.com e/o account in-app.
- **Account obbligatorio?** No per aprire la mappa; sì per sincronizzare profilo.
- **Destinazione condivisione segnalazioni:** altri utenti vedono pin mappa (tipo evento + posizione), non email.

## Permessi Android da dichiarare in linea

`INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE` / `_LOCATION`, `POST_NOTIFICATIONS`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `com.android.vending.BILLING` (abbonamento 1,99 €/mese).

Altri permessi uniti dai plugin (non usati per ads): `ACCESS_NETWORK_STATE`, `VIBRATE`, `ACTIVITY_RECOGNITION` (migliora il GPS in guida, non fitness), `SCHEDULE_EXACT_ALARM` / ignore-battery per avvisi. In Data safety, se il questionario chiede **attività fisica**: sì, raccolta per funzionalità app, non condivisa, non venduta.

AAB verificato: `applicationId=com.milieuzone.milieu_alert`, `versionCode=2`, `versionName=1.0.1`, `minSdk=26`, `targetSdk=35`, `usesCleartextTraffic=false`.
