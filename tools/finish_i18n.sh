#!/bin/bash
# Finishes the i18n setup that was started.
# Run: cd ~/Desktop/AppAltai/Balam.AI && ./tools/finish_i18n.sh

set -e
cd "$(dirname "$0")/.."

echo "🌍 Finishing i18n setup..."

# 1. Generate l10n classes
echo "[1/4] Generating l10n classes..."
flutter gen-l10n

# 2. Verify it compiles
echo "[2/4] Running flutter analyze..."
flutter analyze

# 3. Commit
echo "[3/4] Committing..."
git add -A
git commit -m "Add 3-language support: English, Russian, Kyrgyz

Infrastructure:
- Flutter gen_l10n with 3 ARB files (~200 strings each)
- L.of(context) wired into main.dart, shell nav, profile screen
- Language switcher in Profile: English / Русский / Кыргызча
- localeProvider in main.dart for global locale switching
- Supported locales: en, ru, ky

To add new translated strings:
1. Add to lib/l10n/app_en.arb
2. Add same key to app_ru.arb and app_ky.arb
3. Run: flutter gen-l10n
4. Use: L.of(context).yourNewKey
"

# 4. Push
echo "[4/4] Pushing to GitHub..."
git push

echo ""
echo "✅ Done! 3-language support is live."
echo ""
echo "To switch language in the app:"
echo "  Profile → Language section → tap English / Русский / Кыргызча"
echo ""
echo "To add new translations:"
echo "  1. Edit lib/l10n/app_en.arb, app_ru.arb, app_ky.arb"
echo "  2. Run: flutter gen-l10n"
echo "  3. Use: L.of(context).yourKey in your widgets"
