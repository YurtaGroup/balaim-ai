# balam.ai — The Best App for Moms
### "Балам" — my child in Kyrgyz. Your AI village for motherhood.

> AI-first mobile app for new mothers in Kyrgyzstan and Central Asia.
> Built with love, by a mom, for moms.

---

## Quick Start (VSCode Setup)

### Prerequisites
- Node.js 20+
- npm or yarn
- Expo CLI: `npm install -g expo@latest`
- Android Studio (for Android emulator) or physical Android device
- VSCode extensions recommended (see below)

### 1. Clone & Install
```bash
cd balam
npm install
```

### 2. Environment Variables
Create a `.env` file in the root:
```env
EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Backend only (never expose to client)
ANTHROPIC_API_KEY=your_claude_api_key
MBANK_API_KEY=your_mbank_key
```

### 3. Run the App
```bash
# Start Expo development server
npm start

# Run on Android
npm run android

# Run on iOS (Mac only)
npm run ios
```

### 4. Run the Backend API
```bash
cd api
npm install
npm run dev
```

---

## Project Structure

```
balam/
├── BALAM_RULES.md          ← Load this in Claude at session start
├── docs/
│   ├── BALAM_PRD.md        ← Full product requirements document
│   ├── EXPERT_PANEL.md      ← Expert onboarding & process
│   └── COMMUNITY_GUIDELINES.md
│
├── src/
│   ├── screens/             ← App screens (one file per screen)
│   │   ├── Home/
│   │   ├── Community/       ← "Ask the Village" feature
│   │   ├── Experts/
│   │   ├── Marketplace/
│   │   ├── Cakes/
│   │   └── Profile/
│   │
│   ├── components/          ← Reusable UI components
│   │   ├── DailyCard/
│   │   ├── PostCard/        ← Community post component
│   │   ├── ExpertBadge/
│   │   ├── UrgencyBanner/   ← Medical urgency alerts
│   │   └── ...
│   │
│   ├── navigation/          ← React Navigation setup
│   ├── services/            ← Supabase, API calls
│   ├── hooks/               ← Custom React hooks
│   ├── utils/               ← Helpers (date, age calc, etc.)
│   └── constants/
│       ├── index.ts         ← Colors, typography, config
│       └── types.ts         ← TypeScript type definitions
│
├── api/
│   ├── aiService.ts         ← Claude API integration (server-side)
│   ├── routes/
│   └── middleware/
│
└── design/                  ← Design system, mockups, assets
```

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `BALAM_RULES.md` | Load into Claude at session start — keeps AI context consistent |
| `docs/BALAM_PRD.md` | Full PRD — source of truth for product decisions |
| `src/constants/types.ts` | All TypeScript types — start here when building new features |
| `src/constants/index.ts` | Design system — colors, spacing, config |
| `api/aiService.ts` | All Claude AI calls — daily cards, chat, photo triage |

---

## VSCode Extensions (Recommended)

Install these for the best development experience:

```
Required:
- ES7+ React/Redux/React-Native snippets
- TypeScript Hero
- Prettier (set as default formatter)
- ESLint
- GitLens

React Native:
- React Native Tools (Microsoft)
- Expo Tools

Useful:
- Thunder Client (API testing)
- Tailwind CSS IntelliSense (if using NativeWind)
- Error Lens (inline error highlighting)
```

### VSCode Settings (add to .vscode/settings.json)
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "typescript.preferences.importModuleSpecifier": "non-relative",
  "editor.tabSize": 2,
  "files.exclude": {
    "node_modules": true,
    ".expo": true
  }
}
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   React Native App                       │
│         (TypeScript + Expo + React Navigation)           │
└──────────────────────┬──────────────────────────────────┘
                       │ REST + Realtime
┌──────────────────────▼──────────────────────────────────┐
│                  Supabase                                │
│    PostgreSQL + Auth + Storage + Realtime                │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│               balam.ai API (Node.js)                       │
│   Routes: /ai, /community, /experts, /marketplace        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│              Anthropic Claude API                        │
│   claude-sonnet-4-6 — Daily cards, Chat, Photo triage   │
└─────────────────────────────────────────────────────────┘
```

---

## Working with Claude on This Project

**Always start a Claude session by saying:**
> "Read BALAM_RULES.md and use it as context for our session"

Then paste the contents of `BALAM_RULES.md`.

This gives Claude full product context without re-explaining everything.

---

## Localization

Primary: Russian (ru)
Secondary: Kyrgyz (ky) — Phase 2

Translation files will live in `src/constants/i18n/ru.ts` and `src/constants/i18n/ky.ts`.

---

## Medical Safety

⚠️ balam.ai provides information, not medical advice.

All AI responses include appropriate disclaimers. Red-flag keywords trigger immediate emergency escalation. The pediatrician reviews AI prompts monthly for accuracy.

See `docs/COMMUNITY_GUIDELINES.md` for the full emergency protocol.

---

## Team

- **Founder** — Product, partnerships, community
- **CTO/Tech Lead** — React Native + Node.js + Supabase
- **Designer** — Mobile UX, brand identity
- **Content Lead (Part-time)** — Baby development content, Kyrgyz localization
- **Expert Panel** — 1 Pediatrician, 1 Psychologist, 1 Gynecologist

---

*"Балам — for every mom" 🌿**
