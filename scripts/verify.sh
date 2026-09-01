#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

python3 tools/validate_catalog.py assets/data/catalog_v1.json

if command -v flutter >/dev/null 2>&1; then
  flutter pub get
  flutter analyze
  flutter test
else
  echo "Catalogue passed. Flutter SDK not found, so Flutter checks were skipped." >&2
fi
