#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is required. Install Flutter stable and run this script again." >&2
  exit 1
fi

if [[ -d "$project_root/android" || -d "$project_root/ios" ]]; then
  echo "android/ or ios/ already exists; no platform files were changed."
  exit 0
fi

temporary_root="$(mktemp -d)"
trap 'rm -rf "$temporary_root"' EXIT

flutter create \
  --platforms=android,ios \
  --org=com.shadematchglobal \
  --project-name=shade_match_global \
  "$temporary_root/generated"

cp -R "$temporary_root/generated/android" "$project_root/android"
cp -R "$temporary_root/generated/ios" "$project_root/ios"

echo "Created iOS and Android host projects."
