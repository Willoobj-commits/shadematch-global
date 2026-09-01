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
- Released to Play internal testing - validated 2026-09-01 - versionCode 2 / versionName 0.1.0 (sha256 a3acb532...) published to the internal testing track of app `Shade Match`, package `com.shadematchglobal.shade_match_global`. Play reported the install size as 8.6 MB, +33.3 KB against the versionCode 1 release, which independently corroborates that the new launcher icon is in the bundle. The app record and Play App Signing already existed from an upload on 2026-08-31, so neither needed setting up.
- Set up iOS shipping - validated 2026-09-01 - `codemagic.yaml` now has two workflows on `mac_mini_m2`: `ios-compile` (unsigned, run first to separate a macOS build failure from a signing failure) and `ios-testflight` (started by hand, no longer triggered on push). App Store Connect id 6807488973; the build number is read from TestFlight with a CI-counter fallback. A build already reached TestFlight before this. Signing is automatic (`distribution_type` + `bundle_identifier`) and works only because the App Store profile for `com.shadematchglobal.shadematchglobal` was created by hand on 2026-09-01 12:11 and runs to 2027-07-26 - automatic signing fetches, it does not create, so deleting or expiring that profile breaks the build. The manual fallback is documented in the file. Deployment target is 15.0, above the plugin floor (13.0, shared_preferences_foundation) and above Apple's 2027 minimum, so no `90068` warning. No Info.plist usage strings are needed - no plugin touches a protected resource. Added `.gitattributes` (`* text=auto eol=lf`) because this is authored on Windows and built on macOS.
- Replaced the iOS app icon - validated 2026-09-01 - all 15 entries in `ios/Runner/Assets.xcassets/AppIcon.appiconset` were byte-identical to Flutter's template, so the TestFlight build already uploaded carries the stock blue logo. `python tools/make_store_graphics.py --ios` rewrites them from `Contents.json`, flattened to RGB because App Store Connect rejects a 1024 icon with an alpha channel.

## In progress
- None.

## Next actions (must be executable by a fresh agent with no chat history)
1. Confirm the release on a real device - install from the internal-testing opt-in link - acceptance criteria: the launcher icon is the shade wheel on deep plum rather than Flutter's stock logo, the app launches, bottom navigation works, catalogue search opens shade details, and saved shades survive a force-quit. The icon has only ever been verified inside the bundle, never on a device.
2. Copy `D:\keys\shadematch_upload-keystore.jks` and `D:\keys\shadematch_key.properties` to off-device storage (password manager, encrypted cloud vault, or external drive) - acceptance criteria: the upload key survives loss of the D: drive, since losing it makes future Play Console updates to `com.shadematchglobal.shade_match_global` impossible.
3. Optional: install or distribute `D:\shade_match_global_flutter\build\app\outputs\flutter-apk\app-release.apk` to an Android device for manual QA - acceptance criteria: app launches, bottom navigation works, catalog search opens shade details, and saved shades persist.
4. Run the `ios-testflight` Codemagic workflow to ship the real app icon - the build currently on TestFlight still carries Flutter's stock logo - acceptance criteria: the workflow's `Verify the ipa was produced` step passes and the new build appears in TestFlight with a build number above the existing one. Run `ios-compile` first if anything in `lib/` or `ios/` changed.
5. Optional: raise iOS visibility - the App Store listing needs its own screenshots and description; the Play assets in `store_assets/` are sized for Play, not the App Store.

## Open questions / blockers
- iOS binaries still cannot be built on this Windows host - `flutter build` offers no `ipa` target. Codemagic provides the Mac and this is solved, not blocked.
