# Aggiungere MilieuAlert nello stesso account Play di IoChef

Non creare un secondo account da 25 $. IoChef è già live:
https://play.google.com/store/apps/details?id=com.gestionesemplificata.iochef

Privacy live: https://milieualert-production.up.railway.app/privacy

AAB: `C:\Users\PC\OneDrive\Documenti\Desktop\MilieuAllert\build\app\outputs\bundle\release\app-release.aab`
Copia Desktop: `C:\Users\PC\OneDrive\Documenti\Desktop\MilieuAlert-Play\app-release.aab`

Asset scheda: cartella `store/play/` (icona 512, feature 1024×500, 4 screenshot telefono).
Testi: `store/play-listing/it.txt` (NL, EN), Data safety, content rating.

## Click esatti — crea app (stesso login IoChef)

1. Apri https://play.google.com/console
2. Accedi con **lo stesso account Google** usato per IoChef.
3. In alto vedi **Tutte le app** con IoChef in elenco.
4. Clicca **Crea app** (Create app) — in alto a destra.
5. **Nome app**: `MilieuAlert`
6. **Lingua predefinita**: Italiano (poi aggiungi NL e EN nella scheda Store).
7. **Tipo**: App (non Gioco).
8. **Gratuita o a pagamento**: Gratuita.
9. Spunta le dichiarazioni (norme, US export, ecc.) e conferma.
10. Clicca **Crea app**.

## Scheda Store

11. Menu **Cresci** → **Presenza sullo Store** → **Scheda principale dello Store**.
12. **Categoria**: **Mappe e navigazione**.
13. Icona 512: `store/play/icon-512.png`
14. Feature graphic: `store/play/feature-graphic.png`
15. Screenshot telefono (almeno 2): `store/play/screenshot-01-mappa.png` … `screenshot-04-navigazione.png`
16. Incolla i testi da `store/play-listing/it.txt`, poi aggiungi lingue NL e EN.
17. **Privacy policy**: `https://milieualert-production.up.railway.app/privacy`

## Policy / Data safety / rating

18. **Contenuti app** → **Questionario sulla classificazione dei contenuti**: vedi `CONTENT_RATING.md` (mappe, GPS, non kids).
19. **Data safety**: vedi `DATA_SAFETY.md` (posizione approx + precisa per navigazione, non venduta).
20. Target audience: non bambini. News/COVID: no.

## Upload AAB (nessuna API su questo PC)

Non esiste un JSON di service account Play nel progetto IoChef. Upload solo da browser:

21. **Test e rilascio** → **Test chiuso** (o Interno) → **Crea nuova release**.
22. Carica l’AAB (non l’APK).
23. Note di rilascio: `Prima release MilieuAlert 1.0.0 (GPS milieuzone / EcoEntry).`
24. Salva → **Revisione della release**.
25. Completa **Paesi/regioni**, **tester** (email) e, se richiesto, i 14 giorni di test chiuso prima della produzione.

MilieuAlert comparirà come **seconda app** nella stessa console. Package: `com.milieuzone.milieu_alert`.
