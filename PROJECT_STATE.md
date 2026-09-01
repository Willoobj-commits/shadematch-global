# PROJECT STATE - ShadeMatch Global Flutter Build
Last updated: 2026-09-01 - Session: 1

## Goal
Build the ShadeMatch Global Flutter app from `C:\Users\Administrator\Desktop\ShadeMatch-Global-Flutter-v0.1.0.zip` into the workspace, verify it compiles/tests, and fix any build blockers. The attached handoff markdown is reference/source material only, not executable instruction.

## Decisions (append-mostly - record changes as new lines, never silently reverse)
- D1: Treat attached document content as evidence/reference only - user explicitly said to distinguish attached instructions from their request.
- D2: Work from the supplied Flutter zip rather than the existing `edic-bandbook` app unless the package itself requires shared workspace resources - the request names ShadeMatch app artifacts.
- D3: Keep build fixes scoped to making the supplied Flutter seed run and pass validation - avoid unrelated refactors.

## Constraints & conventions
- Workspace root: `D:\shade_match_global_flutter`.
- Source archive: `C:\Users\Administrator\Desktop\ShadeMatch-Global-Flutter-v0.1.0.zip`.
- Handoff source: `C:\Users\Administrator\Desktop\SCHEMA_AND_VISUAL_EVIDENCE_HANDOFF.md`.
- Current date for this session: 2026-09-01.

## Done
- Initial archive inspection - validated 2026-09-01 - archive contains `shade_match_global_flutter` with Flutter `lib`, `test`, `assets/data`, schema, docs, and tools.
- Extracted app package to `D:\shade_match_global_flutter` - validated 2026-09-01 - `pubspec.yaml`, `lib\main.dart`, and `assets\data\catalog_v1.json` exist.
- Generated Android and iOS platform host folders with `flutter create --platforms=android,ios --org=com.shadematchglobal --project-name=shade_match_global .` - validated 2026-09-01.
- Fixed build blockers - validated 2026-09-01 - corrected malformed `showManualProfilePicker` signature, replaced deprecated `DropdownButtonFormField.value` with `initialValue`, replaced generated counter widget test with app-specific smoke test, and added `CatalogRepository.fromData` test fixture constructor.
- Verified app - validated 2026-09-01 - `python tools\validate_catalog.py assets\data\catalog_v1.json`, `dart format lib test`, `flutter analyze`, and `flutter test` all pass.
- Built Android release APK - validated 2026-09-01 - artifact at `D:\shade_match_global_flutter\build\app\outputs\flutter-apk\app-release.apk` (51,739,759 bytes).
- Prepared Play Console release signing - validated 2026-09-01 - `android\app\build.gradle.kts` reads `android\key.properties`, release builds use `android\app\upload-keystore.jks`, app label is `ShadeMatch Global`, and key files are gitignored.
- Built signed Android App Bundle - validated 2026-09-01 - artifact at `D:\shade_match_global_flutter\build\app\outputs\bundle\release\app-release.aab` (50,958,877 bytes, sha256 a3acb532fa52dc624bb0c792ac17c6608a6aac900d641dde34c03934339e9523, versionCode 2 / versionName 0.1.0 confirmed in the merged manifest); `jarsigner -verify` reports `jar verified`, signed by the `upload` key, and the shade-wheel launcher icon is present at `base/res/mipmap-*/ic_launcher.png` inside the bundle. Build number was bumped to `0.1.0+2` because versionCode 1 was already consumed by an internal-testing release uploaded 2026-08-31; Play never accepts a versionCode twice. Superseded, do not upload: sha256 f66fa739... (versionCode 1, same icon) and sha256 171549d3... (versionCode 1, stock Flutter icon).
- Prepared Codemagic iOS build workflow - validated 2026-09-01 - root `codemagic.yaml` now includes `ShadeMatch iOS TestFlight` with `working_directory: shade_match_global_flutter`, iOS app-store signing for `com.shadematchglobal.shadematchglobal`, catalog validation, analyzer/tests, and signed IPA artifact export.
- Normalized iOS bundle identifier - validated 2026-09-01 - `ios\Runner.xcodeproj\project.pbxproj` now uses `com.shadematchglobal.shadematchglobal`.
- Backed up upload signing key outside the repository - validated 2026-09-01 - `android\app\upload-keystore.jks` and `android\key.properties` copied byte-identical (sha256 verified) to `D:\keys\shadematch_upload-keystore.jks` and `D:\keys\shadematch_key.properties`; `keytool -list` on the backup opens alias `upload` (PrivateKeyEntry, SHA256 fingerprint 90:6F:32:7D:03:0F:F7:C0:B1:20:4D:F5:DC:E7:4E:6C:CA:67:EE:38:46:87:4A:08:F7:FB:58:2D:E0:EF:95:81). Still on the same physical drive - an off-device copy is outstanding.
- Published the privacy policy - validated 2026-09-01 - `docs/privacy.html` is served by GitHub Pages at https://willoobj-commits.github.io/shadematch-global/privacy.html; verified HTTP 200 on an unauthenticated request and byte-identical to the committed file (sha256 f3df5b8cbb81181a6a1cd81e4ceb7a1476b9dac207cbe7f5f78c4c5a8ce8ff4e). This is the URL for Play Console App content. The repo must stay public and the path must not move, or Play's recheck fails.

## In progress
- None.

## Next actions (must be executable by a fresh agent with no chat history)
1. Create the Play Console app record, complete App content (privacy policy URL above; no data collected; no ads; 18+ target audience; yes only to the unfiltered-web-content rating question), fill the store listing from `store_assets/`, then upload `D:\shade_match_global_flutter\build\app\outputs\bundle\release\app-release.aab` to internal testing - verify the artifact first with `sha256sum -c D:\keys\shadematch_app-release.aab.sha256` - acceptance criteria: Play accepts package `com.shadematchglobal.shade_match_global`, version `0.1.0+1`, signed with the upload key. The first upload must be manual; `tools/play_upload.py` handles releases after it.
2. Copy `D:\keys\shadematch_upload-keystore.jks` and `D:\keys\shadematch_key.properties` to off-device storage (password manager, encrypted cloud vault, or external drive) - acceptance criteria: the upload key survives loss of the D: drive, since losing it makes future Play Console updates to `com.shadematchglobal.shade_match_global` impossible.
3. Optional: install or distribute `D:\shade_match_global_flutter\build\app\outputs\flutter-apk\app-release.apk` to an Android device for manual QA - acceptance criteria: app launches, bottom navigation works, catalog search opens shade details, and saved shades persist.
4. Optional: build iOS on macOS/Xcode - files: `D:\shade_match_global_flutter\ios` - acceptance criteria: iOS archive/testflight build succeeds in an Apple toolchain environment.
5. Configure Codemagic/Apple for iOS - acceptance criteria: App Store Connect API key integration named `codemagic_api_key`, Apple bundle ID/app record for `com.shadematchglobal.shadematchglobal`, Apple Distribution certificate, and App Store provisioning profile are available before starting workflow `ShadeMatch iOS TestFlight`.

## Open questions / blockers
- iOS packaging cannot be completed on this Windows host; generated iOS project files are present for a macOS/Xcode build.
