#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


HEX = re.compile(r"^#[0-9A-F]{6}$")
URL = re.compile(r"^https://", re.IGNORECASE)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("catalog", type=Path)
    args = parser.parse_args()
    data = json.loads(args.catalog.read_text(encoding="utf-8"))
    shades = data["shades"]
    ids = [shade["id"] for shade in shades]
    errors: list[str] = []

    if len(ids) != len(set(ids)):
        errors.append("Shade IDs are not unique")
    if len(shades) != data["release"]["shadeCount"]:
        errors.append("Release shade count does not match shade records")
    if len({shade["brandName"] for shade in shades}) != data["release"]["verifiedBrandCount"]:
        errors.append("Release brand count does not match shade records")

    for shade in shades:
        label = f"{shade['brandName']} {shade['productName']} {shade['shadeCode']}"
        if not 1 <= shade["universalDepth"] <= 30:
            errors.append(f"{label}: depth outside 1-30")
        if not URL.match(shade["sourceUrl"]):
            errors.append(f"{label}: recorded source is not HTTPS")
        visuals = shade.get("visualReferences", [])
        if not visuals:
            errors.append(f"{label}: no visual fallback")
            continue
        primary = [visual for visual in visuals if visual.get("isPrimary")]
        if len(primary) != 1:
            errors.append(f"{label}: expected exactly one primary visual")
        for visual in visuals:
            display_hex = visual.get("displayHex")
            if display_hex and not HEX.match(display_hex):
                errors.append(f"{label}: invalid display hex {display_hex!r}")
            if visual["kind"] == "universal_profile_estimate" and visual.get("matchEligible"):
                errors.append(f"{label}: estimated visual cannot be match evidence")

    if errors:
        print("\n".join(errors[:100]))
        raise SystemExit(f"Catalog validation failed with {len(errors)} error(s)")

    print(
        json.dumps(
            {
                "valid": True,
                "shades": len(shades),
                "verifiedBrands": len({shade["brandName"] for shade in shades}),
                "directoryBrands": len(data["brandDirectory"]),
                "undertoneCounts": Counter(shade["undertoneCode"] for shade in shades),
                "profileFallbacks": sum(
                    1
                    for shade in shades
                    if shade["visualReferences"][0]["kind"] == "universal_profile_estimate"
                ),
            },
            indent=2,
            default=dict,
        )
    )


if __name__ == "__main__":
    main()
