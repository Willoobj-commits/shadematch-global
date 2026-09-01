# Codemagic iOS Release

## Workflow

Use the root `codemagic.yaml` workflow named `ShadeMatch iOS TestFlight`.

The workflow builds the nested Flutter project at:

```text
shade_match_global_flutter
```

## Bundle ID

Create/register this bundle identifier in Apple Developer and App Store Connect:

```text
com.shadematchglobal.shadematchglobal
```

## Codemagic setup

1. Add the repository to Codemagic.
2. Ensure Codemagic is using the root `codemagic.yaml`.
3. Connect App Store Connect under Team settings -> Team integrations -> Developer Portal.
4. Name the integration key:

```text
codemagic_api_key
```

5. In Codemagic code signing identities, make sure an Apple Distribution certificate and App Store provisioning profile exist for `com.shadematchglobal.shadematchglobal`.
6. Start workflow `ShadeMatch iOS TestFlight`.

## Output

The workflow exports:

```text
build/ios/ipa/*.ipa
/tmp/xcodebuild_logs/*.log
```

## Notes

- The first App Store Connect upload may still require manual metadata, screenshots, category, age rating, privacy details, and review information in App Store Connect.
- Every App Store Connect upload needs a unique build number. The Codemagic workflow uses `$BUILD_NUMBER` for that.
