# BALAM_RULES.md
## Load this file at the start of every Claude session about balam.ai

---

## What is balam.ai?
balam.ai — "Балам" means "my child" in Kyrgyz, warm and instantly understood by every local mother. It is an AI-first mobile app for new and expecting mothers in Kyrgyzstan and Central Asia. It is being built by a woman founder with an English teaching background and a deep understanding of the local culture.

**Tagline:** "The Village in Your Pocket"

---

## Core Pillars (never forget these four)
1. **AI Daily Guide** — Personalized daily + monthly baby development cards, AI chat (Ask balam.ai)
2. **Photo Community ("Ask the Village")** — Mom uploads photo of baby issue (rash, etc.), community + experts respond
3. **Expert Panel** — 1 Pediatrician, 1 Child Psychologist, 1 Gynecologist, verified and integrated into the app
4. **Marketplace + Local Services** — Eco products (Mama Znaet exclusive for diapers), eco certified clothes, cake marketplace for local bakers

---

## Key Decisions Already Made
- App name: **balam.ai**
- Platform: React Native (Expo) — iOS + Android
- AI: Anthropic Claude API (claude-sonnet-4-6)
- Backend: Supabase + Node.js
- Primary market: Kyrgyzstan (Bishkek first, then Osh, then regional)
- Primary language: Russian, then Kyrgyz
- Primary device: Android (80% of KG market)
- Expert model: 3 verified doctors, paid via 30% platform commission on consults
- Cake marketplace is in MVP (high-emotion, high-frequency use case for Kyrgyz baby culture)
- Mama Znaet is target exclusive launch partner for diapers
- All marketplace products must pass eco/health vetting — no Chinese unbranded imports

---

## What Makes balam.ai Different
- **Photo community** — visual, honest, peer-driven. Not text-only like every other parenting app.
- **Culturally built, not translated** — кырк чилде, local foods, Kyrgyz/Russian tone
- **Expert trust layer** — real verified doctors respond in community, not just on a "book a consult" page
- **Age-matched community** — you see posts from moms with babies close to yours in age
- **Warm AI** — not a medical disclaimer machine, a knowledgeable friend

---

## Target User
**Primary:** Aizat, 24–34, new mom, 0–24 month baby, Android, Russian-speaking, Bishkek or regional KG city
**Pain:** overwhelmed, isolated, uncertain about baby health, can't access specialists easily

---

## Tone & Voice (for content generation)
- Warm, confident, non-judgmental
- Never clinical or cold
- Never preachy or lecturing
- Culturally aware: extended family dynamics, local food, Kyrgyz traditions respected
- Russian primary, Kyrgyz secondary
- AI never diagnoses. Always recommends doctor for anything medical.

---

## MVP Scope (build first)
- Daily AI card + monthly guide
- Ask balam.ai chat (5/day free)
- Photo community (post + reply + photo)
- 1 pediatrician on panel
- Cake marketplace (WhatsApp redirect for orders)
- Android app, Russian language

---

## Files in This Project
- `docs/BALAM_PRD.md` — Full product requirements document
- `docs/EXPERT_PANEL.md` — Expert onboarding + process doc
- `docs/COMMUNITY_GUIDELINES.md` — Moderation rules + community standards
- `docs/BRAND.md` — Visual identity, voice, tone
- `src/` — React Native app source code
- `api/` — Backend API
- `design/` — Design system + screen specs

---

## Things Claude Should Always Do When Working on balam.ai
1. Keep cultural context in mind — this is Kyrgyzstan, not Russia or the US
2. Remember the photo community is the signature feature — treat it with care
3. Medical safety first — AI never diagnoses, always escalates red flags
4. Think mobile-first, Android-first, low-bandwidth-aware
5. Moms are the users AND the content creators — everything should feel built by and for them
6. Experts are partners, not just features — their experience in the app matters
