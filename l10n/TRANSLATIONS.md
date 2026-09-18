# Translations (Italian source)

Italian is the **default locale** and the **source of truth**. English and Dutch are generated from it. Do not invent copy in EN/NL first.

| Role | Path |
|---|---|
| AI master catalog (snake_case → Italian) | `l10n/source_it.json` |
| Flutter template ARB | `lib/l10n/app_it.arb` |
| English app strings | `lib/l10n/app_en.arb` |
| Dutch app strings | `lib/l10n/app_nl.arb` |
| Play listing IT / EN / NL | `store/play-listing/{it,en,nl}.txt` |

`source_it.json` uses **English snake_case keys** and **Italian values**. Flutter ARB files use the same ideas as **camelCase** getters (`go_hint_lez` → `goHintLez`). Keep keys in sync.

## Terms (do not “translate away”)

- Keep **milieuzone** in every language (product + search term).
- EN long form: **low emission zone**. NL: **milieuzone**. IT source: zona ambientale / milieuzone as already written.
- Keep **EcoEntry**, **LEZ**, **ZTL**, **autovelox**, **flitsers**, **VAI/GO/GA** as driver-facing short actions.

## How to add a new string

1. Add the Italian sentence to `l10n/source_it.json` (`strings`) with a new snake_case key.
2. Add the same key in camelCase to `lib/l10n/app_it.arb` (template). If it has `{placeholders}`, add an `@key` metadata block with types.
3. Translate into `lib/l10n/app_en.arb` and `lib/l10n/app_nl.arb` (and DE/FR if those locales still ship).
4. Use it in UI: `l10nOf(context).yourNewKey` (see `lib/l10n/l10n_ext.dart`).
5. Regenerate:

```powershell
C:\flutter\bin\flutter.bat gen-l10n
C:\flutter\bin\flutter.bat analyze
```

Default locale is Italian (`localeProvider` falls back to `it`).

## How to regenerate EN/NL with AI from `source_it.json`

Give the model `l10n/source_it.json` and this prompt:

> Translate every `strings` value from Italian into professional driver/navigation copy.  
> Target locales: English (`en`) and Dutch (`nl`).  
> Keep product terms: milieuzone (all languages), EcoEntry, LEZ, ZTL, autovelox/flitsers.  
> EN: use “low emission zone” in full sentences; keep “milieuzone” on chips, paywall, and Play search phrases.  
> NL: milieuzone, flitser, bestuurder, route. Formal “u” is fine.  
> Return two ARB JSON objects with the same camelCase keys as `lib/l10n/app_it.arb` (no `@metadata` needed).  
> Also refresh `store/play-listing/en.txt` and `nl.txt` from `play_listing` (short ≤80, title ≤30, full ≤4000).

Then paste the ARB objects into `app_en.arb` / `app_nl.arb` and run `flutter gen-l10n`.

Do **not** rewrite turn-by-turn engine strings (`instructionIt` in navigation models) or AI fallback corpora in the same pass unless you are localizing those layers on purpose.
