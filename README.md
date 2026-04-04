# Balam.AI

> Your AI parenting companion — from pre-pregnancy through the first two years.

Named after the Mayan word for jaguar, a protector. Balam.AI is a super app for parents built with Flutter, designed to support the full parenting journey with AI-powered personalized guidance, evidence-based developmental content, community, and a curated marketplace.

## Features

- **Pregnancy Tracker** — Week-by-week baby development, tracking (weight, water, sleep, kick counter), symptoms, and tips
- **Baby Development (0-24 months)** — Evidence-based milestones, feeding guides, sleep patterns, vaccine schedules, and red flags curated month by month
- **Balam AI Companion** — Personalized AI chat grounded in the user's stage and tracking data (powered by Claude)
- **Community** — Stage-matched groups, moderated Q&A with verified professionals
- **Professional Network** — Directory of doctors, nurses, midwives, doulas, lactation consultants
- **Marketplace** — Curated products filtered by parenting stage and baby age

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile + Web | Flutter 3.41 + Dart |
| State Management | Riverpod |
| Routing | GoRouter |
| Auth | Firebase Auth (with demo fallback) |
| Database | Cloud Firestore |
| AI | Claude API via Cloud Functions |
| Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging |
| Analytics | Firebase Analytics |
| Payments | Stripe + RevenueCat |

## Getting Started

### Prerequisites

- Flutter 3.41+ ([install guide](https://docs.flutter.dev/get-started/install))
- Xcode 15+ (for iOS)
- Android Studio (for Android)
- Node.js 20+ (for Cloud Functions)

### Run Locally

```bash
# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run -d "iPhone 17 Pro"

# Run on Chrome
flutter run -d chrome --web-port 8080

# Run on Android
flutter run -d android
```

The app runs in **demo mode** without any backend configuration. Try the one-click demo accounts on the login screen.

### Demo Accounts

| Email | Role |
|-------|------|
| `parent@balam.ai` | Parent experience |
| `dad@balam.ai` | Dad perspective |
| `admin@balam.ai` | Admin dashboard |
| `doctor@balam.ai` | Professional view |
| `vendor@balam.ai` | Marketplace seller |

Any password works in demo mode.

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/           # Brand colors and app theme
│   ├── router/          # GoRouter config + shell
│   ├── constants/       # App constants, env config
│   ├── data/            # Seed data (vendors, products)
│   └── services/        # Auth, Firestore, demo services
├── features/
│   ├── auth/            # Login, onboarding, stage selection
│   ├── journey/         # Pregnancy & baby tracker
│   ├── ai/              # Balam AI chat
│   ├── community/       # Posts, groups, feed
│   ├── professionals/   # Doctor directory
│   ├── marketplace/     # Products & vendors
│   └── admin/           # Admin dashboard
└── shared/
    ├── models/          # Data models
    ├── widgets/         # Reusable UI
    └── utils/           # Helpers
```

## Firebase Setup (Optional)

The app works fully in demo mode. To connect Firebase:

```bash
# Install tools
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login
firebase login

# Configure (generates lib/firebase_options.dart)
flutterfire configure
```

See `testflight/README.md` for TestFlight deployment and Cloud Functions setup.

## Development

### Regenerate Branding

```bash
# App icon & splash logo
python3 tools/generate_branding.py

# iOS + Android icon sets
dart run flutter_launcher_icons

# Native splash screens
dart run flutter_native_splash:create
```

### Analyze & Test

```bash
flutter analyze
flutter test
```

### Build for Production

```bash
# iOS
flutter build ipa --release

# Android
flutter build apk --release
flutter build appbundle --release

# Web
flutter build web --release
```

## Architecture Decisions

- **Feature-first folder structure** — each feature is self-contained
- **Demo mode first** — app works without Firebase, auth has a demo fallback
- **No hardcoded data in screens** — all seed data lives in `lib/core/data/seed_data.dart`
- **Theme centralization** — colors in `lib/core/theme/app_colors.dart`, single source of truth
- **Material Icons over emoji** — consistent rendering across all platforms

## Contributing

This is a private project. Not accepting external contributions at this time.

## License

Copyright © 2026 AppAltai. All rights reserved.
