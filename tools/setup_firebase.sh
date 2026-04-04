#!/bin/bash
# Balam.AI Firebase Setup — Automated
# Prerequisites:
#   - firebase-tools installed (npm install -g firebase-tools)
#   - flutterfire_cli installed (dart pub global activate flutterfire_cli)
#   - You're logged in: firebase login
# Usage: ./tools/setup_firebase.sh <project-id>

set -e

PROJECT_ID="${1:-balam-ai-2a037}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Balam.AI Firebase Setup${NC}"
echo -e "${BLUE}  Project: ${PROJECT_ID}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$PROJECT_ROOT"
export PATH="$PATH:$HOME/.pub-cache/bin"

# Step 1 — Verify prerequisites
echo -e "${YELLOW}[1/6]${NC} Checking prerequisites..."
if ! command -v firebase &> /dev/null; then
  echo -e "${RED}✗ firebase-tools not installed${NC}"
  echo "  Run: npm install -g firebase-tools"
  exit 1
fi
if ! command -v flutterfire &> /dev/null; then
  echo -e "${RED}✗ flutterfire_cli not installed${NC}"
  echo "  Run: dart pub global activate flutterfire_cli"
  exit 1
fi
echo -e "${GREEN}  ✓ firebase-tools and flutterfire installed${NC}"

# Step 2 — Verify login
echo -e "${YELLOW}[2/6]${NC} Checking Firebase login..."
if ! firebase projects:list &> /dev/null; then
  echo -e "${RED}✗ Not logged in. Run: firebase login${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓ Logged into Firebase${NC}"

# Step 3 — Set active project
echo -e "${YELLOW}[3/6]${NC} Setting active project..."
firebase use "$PROJECT_ID" --add 2>&1 | tail -3
echo -e "${GREEN}  ✓ Project set to $PROJECT_ID${NC}"

# Step 4 — Run flutterfire configure (interactive)
echo -e "${YELLOW}[4/6]${NC} Configuring Flutter for Firebase..."
echo -e "${BLUE}  Select: iOS, Android, Web (space to toggle, enter to confirm)${NC}"
flutterfire configure \
  --project="$PROJECT_ID" \
  --platforms=ios,android,web \
  --ios-bundle-id=com.balam.balamAi \
  --android-package-name=com.balam.balam_ai \
  --yes
echo -e "${GREEN}  ✓ firebase_options.dart generated${NC}"

# Step 5 — Update main.dart to use firebase_options
echo -e "${YELLOW}[5/6]${NC} Updating main.dart to use generated options..."
MAIN_DART="$PROJECT_ROOT/lib/main.dart"
if ! grep -q "firebase_options.dart" "$MAIN_DART"; then
  # Add import + update Firebase.initializeApp call
  sed -i.bak \
    -e "s|import 'core/theme/app_theme.dart';|import 'firebase_options.dart';\nimport 'core/theme/app_theme.dart';|" \
    -e "s|await Firebase.initializeApp();|await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);|" \
    "$MAIN_DART"
  rm "$MAIN_DART.bak"
  echo -e "${GREEN}  ✓ main.dart now uses DefaultFirebaseOptions.currentPlatform${NC}"
else
  echo -e "${GREEN}  ✓ main.dart already configured${NC}"
fi

# Step 6 — Deploy Firestore rules
echo -e "${YELLOW}[6/6]${NC} Deploying Firestore security rules..."
firebase deploy --only firestore:rules --project="$PROJECT_ID" 2>&1 | tail -5
echo -e "${GREEN}  ✓ Rules deployed${NC}"

# Done
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Setup Complete! 🎉${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "${YELLOW}1.${NC} Enable Email/Password auth in Firebase Console:"
echo "     https://console.firebase.google.com/project/$PROJECT_ID/authentication/providers"
echo ""
echo -e "${YELLOW}2.${NC} Create Firestore database (production mode):"
echo "     https://console.firebase.google.com/project/$PROJECT_ID/firestore"
echo ""
echo -e "${YELLOW}3.${NC} Run the app to test:"
echo "     flutter run"
echo ""
echo -e "${YELLOW}4.${NC} Build for TestFlight:"
echo "     flutter build ipa --release"
echo ""
