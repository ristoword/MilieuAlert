# Scheda Google Play — MilieuAlert

Stesso account sviluppatore di **IoChef** (Gestione Semplificata).
Package Android: `com.milieuzone.milieu_alert` (diverso da `com.gestionesemplificata.iochef`).

## Impostazioni console

| Campo | Valore |
|---|---|
| Nome app | MilieuAlert |
| Tipo | App |
| Categoria | Mappe e navigazione |
| Gratuita / a pagamento | Gratuita + IAP abbonamento `milieualert_premium_2_99` a **2,99 €/mese** |
| Lingua predefinita | Italiano |
| Altre lingue scheda | Nederlands, English |
| Contatto sviluppatore | assistenza@gestionesemplificata.com (stesso di Gestione Semplificata / IoChef) |
| Privacy | https://milieualert-production.up.railway.app/privacy |
| Tag | milieuzone, ZTL, LEZ, GPS, navigatore, autovelox, EcoEntry |

## Asset in `store/play/`

| File | Spec |
|---|---|
| `icon-512.png` | Icona alta risoluzione 512×512 |
| `feature-graphic.png` | Feature graphic 1024×500 (ZONE + MilieuAlert + milieuzone) |
| `screenshot-01-mappa.png` | Telefono ~1080×1920 |
| `screenshot-02-segnala.png` | Telefono ~1080×1920 |
| `screenshot-03-veicolo.png` | Telefono ~1080×1920 |
| `screenshot-04-navigazione.png` | Telefono ~1080×1920 |

## Content rating

Vedi `CONTENT_RATING.md`. Location GPS, non kids.

## Data safety

Vedi `DATA_SAFETY.md`. Posizione approssimativa + precisa per navigazione; non venduta.

## Firma (upload key)

- Keystore locale (fuori dal git): `C:\Users\PC\AppData\Local\MilieuAlert\milieualert-upload.jks`
- Alias: `milieualert`
- Password: solo in `android/key.properties` (gitignored) e copia locale.
- Template: `android/key.properties.example`

## AAB

`build\app\outputs\bundle\release\app-release.aab`  
Copia utile: `C:\Users\PC\OneDrive\Documenti\Desktop\MilieuAlert-Play\app-release.aab`

Verificato nel merged manifest: `com.milieuzone.milieu_alert`, versionCode 1, versionName 1.0.0, minSdk 26, targetSdk 35, INTERNET + FINE/COARSE/BACKGROUND location, HTTPS only.
