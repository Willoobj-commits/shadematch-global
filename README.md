# ShadeMatch Global — Flutter iOS and Android

This package converts the existing worldwide shade matcher into an evidence-aware Flutter app. It includes 1,578 manufacturer-sourced shade records across 34 matchable brands, a canonical directory of 171 brands, a clear colour sample for every populated shade, cross-brand matching, manual profile selection, visual-evidence labels, shade details, source links, and saved shades.

## What changed from the website

- Every shade has a large, accessible visual sample.
- A visual is explicitly classified as measured, calibrated, official, or a generated universal-profile sample.
- Generated profile colours are never treated as measured matching evidence.
- The matcher uses data-driven undertone vectors rather than the first character of a code.
- Distant candidates are withheld instead of being presented as approximate matches.
- Product, formula/market variant, shade, source, visual asset, and colour measurement are separate entities in the production schema.
- The six undertone codes used but not documented in the workbook guide are now defined: `G`, `PCH`, `WN`, `CN`, `NR`, and `CB`.

The source workbook did not contain licensed shade images or laboratory measurements. The initial app therefore labels every included chip as **Profile sample — not an official product swatch**. The database and Flutter model are ready to display official images and measured swatches as they are verified. Recorded source pages are retained, but each must still be classified during production ingestion as manufacturer, authorized retailer, editorial, or other evidence.

## Run the app

Prerequisites: Flutter stable, Xcode/CocoaPods for iOS, and Android Studio/JDK for Android.

```bash
chmod +x scripts/bootstrap_platforms.sh scripts/verify.sh
./scripts/bootstrap_platforms.sh
flutter pub get
flutter test
flutter analyze
flutter run
```

`bootstrap_platforms.sh` creates the standard iOS and Android host projects without overwriting the app source.

## Key locations

- `lib/` — Flutter UI, catalogue repository, visual model, and matcher
- `assets/data/catalog_v1.json` — validated offline seed catalogue
- `assets/data/source_manifest.json` — source and output checksums for reproducibility
- `tools/build_catalog.py` — deterministic workbook-to-app converter
- `tools/validate_catalog.py` — catalogue integrity and visual-policy validation
- `schemas/catalog_v2.schema.json` — portable import contract for catalogue releases
- `docs/SCHEMA_AND_VISUAL_EVIDENCE_HANDOFF.md` — production architecture and revised schema
- `supabase/migrations/` — production PostgreSQL/Supabase schema
- `supabase/rollback/` — empty-staging rollback; production uses forward repair

## Rebuild the catalogue

```bash
python3 -m pip install -r tools/requirements.txt
python3 tools/build_catalog.py \
  /path/to/worldwide_makeup_shade_matching_system_global_v1.xlsx \
  assets/data/catalog_v1.json \
  --registry-js /path/to/latest-website/data.js
python3 tools/validate_catalog.py assets/data/catalog_v1.json
```

## Release boundary

This is a functional offline-first source build. The current execution environment did not include the Flutter SDK, so platform host folders, `flutter analyze`, widget rendering, and device builds must be completed in a Flutter-enabled macOS/CI environment. The included Python catalogue validation has been run successfully.
