# TestFlight Build & Release Guide

Complete guide to building and uploading Balam.AI to TestFlight.

## Prerequisites

- Apple Developer account enrolled ($99/year)
- App Store Connect access
- Xcode 15+ installed
- Flutter SDK installed

## Pre-flight Checklist

- [ ] Bundle ID: `com.balam.balamAi` (matches Xcode project)
- [ ] Team ID: `PJPHU42VG4`
- [ ] iOS deployment target: 16.0
- [ ] App icons generated (run `dart run flutter_launcher_icons`)
- [ ] Splash screens generated (run `dart run flutter_native_splash:create`)
- [ ] Version bumped in `pubspec.yaml`

## One-Time Setup in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. My Apps → **+** → New App
3. Fill in:
   - Platform: iOS
   - Name: **Balam.AI**
   - Primary Language: English (U.S.)
   - Bundle ID: `com.balam.balamAi` (select from dropdown)
   - SKU: `balam-ai-001`
   - User Access: Full Access
4. Fill metadata from `testflight/app_store_metadata.md`

## Build & Upload

### Option A: Using Flutter CLI (fastest)

```bash
# From project root
cd ~/Desktop/AppAltai/Balam.AI

# Clean build
flutter clean
flutter pub get

# Build release archive
flutter build ipa --release

# Archive is at: build/ios/ipa/balam_ai.ipa
# Upload via Transporter.app (Mac App Store)
```

Then open **Transporter.app**, drag the .ipa, click Deliver.

### Option B: Using Xcode (more control)

```bash
# Open Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** → **Any iOS Device (arm64)** as target
2. Product → Archive
3. Wait for archive to finish (5-10 min)
4. In Organizer: **Distribute App** → **App Store Connect** → **Upload**
5. Select automatic signing, continue through wizard

## After Upload

1. Wait 10-30 minutes for Apple processing (you'll get an email)
2. Go to App Store Connect → Your App → TestFlight tab
3. Build will appear. Click it and:
   - Fill in "What to Test" notes
   - Answer Export Compliance: **No** (we don't use encryption beyond HTTPS)
4. Add Internal Testers (you, your team — instant access)
5. Add External Testers (up to 10,000 — needs Beta App Review, 24-48hr)

## Bumping Version for Next Build

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+2    # increment +N for each TestFlight build
```

Format: `<marketing-version>+<build-number>`
- Marketing version: 1.0.0 (shown to users)
- Build number: 2 (must increase every upload)

## Troubleshooting

**"No signing certificate" error**
- Open Xcode → Runner target → Signing & Capabilities
- Check "Automatically manage signing"
- Select Team: PJPHU42VG4

**"Missing Compliance" warning in TestFlight**
- App Store Connect → Build → Provide Export Compliance Information
- Select: "No" (standard HTTPS only)

**"Invalid binary" after upload**
- Usually iOS deployment target too low. We use 16.0.
- Check `ios/Podfile` and `ios/Runner.xcodeproj/project.pbxproj`

## Useful Commands

```bash
# Check current version
grep "version:" pubspec.yaml

# Clean iOS build completely
cd ios && pod deintegrate && rm -rf Pods Podfile.lock && pod install && cd ..

# List available simulators
xcrun simctl list devices available | grep iPhone

# Regenerate icons after design change
python3 tools/generate_branding.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
