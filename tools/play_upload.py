#!/usr/bin/env python3
"""Upload a signed app bundle to a Google Play track.

Requires a Play Developer API service account that has been granted access to
this app in Play Console. The service account JSON is never read from the
repository - pass its path explicitly or set PLAY_SERVICE_ACCOUNT_JSON.

    python tools/play_upload.py --track internal --dry-run
    python tools/play_upload.py --track internal \
        --service-account D:/keys/play-service-account.json

Note: Google requires the first bundle for a new app to be uploaded through
the Play Console web UI. This script is for the releases after that one.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import sys
from pathlib import Path

PACKAGE_NAME = "com.shadematchglobal.shade_match_global"
DEFAULT_BUNDLE = Path("build/app/outputs/bundle/release/app-release.aab")
SCOPE = "https://www.googleapis.com/auth/androidpublisher"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--bundle", type=Path, default=DEFAULT_BUNDLE, help="path to the .aab (default: %(default)s)")
    parser.add_argument("--track", default="internal", choices=["internal", "alpha", "beta", "production"])
    parser.add_argument("--package", default=PACKAGE_NAME, help="application id (default: %(default)s)")
    parser.add_argument(
        "--service-account",
        type=Path,
        default=os.environ.get("PLAY_SERVICE_ACCOUNT_JSON"),
        help="service account JSON key path, or set PLAY_SERVICE_ACCOUNT_JSON",
    )
    parser.add_argument("--release-notes", default="", help="what's new text for this release")
    parser.add_argument("--expect-sha256", help="abort unless the bundle matches this digest")
    parser.add_argument("--dry-run", action="store_true", help="validate inputs and exit without contacting Google")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.bundle.is_file():
        print(f"error: bundle not found at {args.bundle}", file=sys.stderr)
        print("build it first: flutter build appbundle --release", file=sys.stderr)
        return 1

    digest = sha256(args.bundle)
    size = args.bundle.stat().st_size
    print(f"bundle   {args.bundle} ({size:,} bytes)")
    print(f"sha256   {digest}")
    print(f"package  {args.package}")
    print(f"track    {args.track}")

    if args.expect_sha256 and digest != args.expect_sha256:
        print(f"error: bundle digest does not match --expect-sha256 {args.expect_sha256}", file=sys.stderr)
        return 1

    if args.dry_run:
        print("\ndry run - nothing was uploaded")
        return 0

    if not args.service_account:
        print("error: no service account key given", file=sys.stderr)
        print("pass --service-account PATH or set PLAY_SERVICE_ACCOUNT_JSON", file=sys.stderr)
        return 1

    key_path = Path(args.service_account)
    if not key_path.is_file():
        print(f"error: service account key not found at {key_path}", file=sys.stderr)
        return 1

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
        from googleapiclient.errors import HttpError
        from googleapiclient.http import MediaFileUpload
    except ImportError:
        print("error: missing dependencies", file=sys.stderr)
        print("install them: python -m pip install google-api-python-client google-auth", file=sys.stderr)
        return 1

    credentials = service_account.Credentials.from_service_account_file(str(key_path), scopes=[SCOPE])
    service = build("androidpublisher", "v3", credentials=credentials, cache_discovery=False)
    edits = service.edits()

    try:
        edit_id = edits.insert(body={}, packageName=args.package).execute()["id"]
        print(f"\nedit     {edit_id}")

        media = MediaFileUpload(str(args.bundle), mimetype="application/octet-stream", resumable=True)
        request = edits.bundles().insert(editId=edit_id, packageName=args.package, media_body=media)

        response = None
        while response is None:
            status, response = request.next_chunk()
            if status:
                print(f"upload   {int(status.progress() * 100)}%", end="\r", flush=True)

        version_code = response["versionCode"]
        print(f"upload   done - version code {version_code}")

        release = {"versionCodes": [str(version_code)], "status": "completed"}
        if args.release_notes:
            release["releaseNotes"] = [{"language": "en-US", "text": args.release_notes}]

        edits.tracks().update(
            editId=edit_id,
            track=args.track,
            packageName=args.package,
            body={"track": args.track, "releases": [release]},
        ).execute()
        print(f"track    assigned to {args.track}")

        edits.commit(editId=edit_id, packageName=args.package).execute()
        print(f"commit   done - version {version_code} is live on {args.track}")

    except HttpError as error:
        print(f"\nerror: Play API rejected the request: {error}", file=sys.stderr)
        if error.resp.status == 403:
            print("check the service account has access to this app in Play Console", file=sys.stderr)
        elif error.resp.status == 404:
            print(f"check that {args.package} exists in this Play Console account", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
