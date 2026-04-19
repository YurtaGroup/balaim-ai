# Consolidated prompt (single paste fallback)

Use this if Claude Design does not accept the folder as a unit. Paste everything below as a single first message. Attach screenshots from `current-screens/` manually.

---

You are the design lead on Balam.AI, a family health AI coach. The founder wants the app to feel like a quiet-luxury service, not a clinical tool. Read the four briefs below first. They are short on purpose. Then design.

---

## Brand brief

**Positioning, one line.** Balam is your family's quiet, kind AI health coach. It starts with the baby and grows with the whole household.

**Product, in plain terms.** An iPhone app that lets a parent manage their family's health in one place. The baby has tracking and a parenting AI. The parent gets the same AI as a personal health coach. A grandparent or partner can be added as a household member. Every member has their own labs, their own vitals, their own consults with real physicians. The AI knows which family member you are asking about and speaks with the right tone.

**User.** A parent aged 25 to 45, based in Kyrgyzstan or the diaspora, raising one to three children. She code-switches between English, Russian, and Kyrgyz in the same sentence. She owns an iPhone. She is often managing her own and her parents' health alongside the children's, without a good system for it. Time-starved, sometimes scared at 3am, rarely impressed by dashboards. Wants reassurance and competence in the same breath.

**Emotional tone.** Quiet, warm, deliberate. Like a hotel terrace with morning coffee before anyone is awake. The opposite of a waiting room. The opposite of a gamified wellness app. The opposite of a parenting app full of bubble fonts.

**What this must never feel like.** A medical dashboard. A cartoon baby world. An Apple Health clone. A Shutterstock mood board of generic smiling mothers. A developer's idea of Material Design. An app where localization feels bolted on.

**Why now.** The founder's uncle died recently of unchecked diabetes. The product is expanding from parenting into family health. The redesign carries that weight without ever stating it: calm, not alarming; present, not pushy.

---

## Direction

Anchor aesthetic: Aman / Rosewood quiet luxury, filtered for a small mobile app. Editorial, warm, muted, restrained. Magazine-adjacent.

Typography direction: editorial serif for headlines in the family of Tiempos, GT Alpina, or Ogg; neutral-modern sans for body in the family of Inter, GT America, or Soehne. Pick the pairing and justify it in one sentence.

Color direction: the current app uses coral primary, soft-blue secondary, honey accent on a warm off-white. Feel free to re-propose at slightly lower saturation to sit better under editorial photography. Keep warmth. Document tokens.

Visual language: photography-first for hero moments and abstract shape or gradient for utility surfaces.

Photography specifics: warm morning light, Central Asian and diverse families, hands first, candid, slight grain welcome, no studio lighting, no posed smiles, no baby models on white backgrounds.

## Do not reference

Babylist, BabyCenter, The Bump, Glow, Ovia. WebMD and any clinical symptom checker. Headspace's illustrated bubble style. Apple Health's default look. Any Material Design tutorial dashboard. Stock photography featuring smiling mothers on white backgrounds. Hospital monitor dashboards. Figma default parenting-app starter kits.

## Hard constraints

- Canvas: 390 x 844 mobile.
- Light mode first, dark mode as a side-by-side companion on every screen.
- Trilingual: English, Russian, Kyrgyz. Russian and Kyrgyz run 20-30 percent wider than English. Do not hard-code widths.
- Bottom navigation stays 5 tabs: Today, Balam AI, Community, Market, My Child. Do not redesign nav order.
- No emoji in UI chrome.
- No aggressive medical red for ordinary states. Red is reserved for true emergencies only. Amber for borderline. Green for normal.

---

## Screens

Design screens 1 and 2 first, stop, wait for feedback. Then unlock the rest.

### 1. Today, home

Purpose: the screen a user sees every morning for three minutes. Tells her what is worth her attention for the currently selected household member and points to one clear next action.

Key content: compact adaptive greeting; horizontal row of household member avatars under the greeting with a clear selected state; small grid of quick-access entries (Lab Results, Doctors, Moments or Medications per role, Log Vitals); three or four cards below (focus of the week, try this today, is this normal?, daily insight); settings gear and notification bell top-right.

The one thing it must do well: in two seconds the user should know who the screen is about and what the next action is.

### 2. Balam AI chat, 3am dark variant

Purpose: the screen a parent opens at 2:47am when something is wrong. Calm even when the question is not.

Key content: a single conversational surface; a small chip above the input indicating the member the conversation is about; large type; red-flag triage banner below replies when urgency is high with two actions (Consult a doctor, Call emergency services); no suggestion chips in 3am mode; haptic on send.

The one thing it must do well: never panic the user.

### 3. Household, my family

Purpose: see everyone you track and add new members without friction.

Key content: list of rich member cards (portrait or monogram, name, role, age, one-line health pulse); tapping a card sets that member active app-wide; add-member button opens a sheet with role chips; stage and age controls adapt to chosen role.

The one thing it must do well: make it feel inviting, not bureaucratic, to add a grandmother or uncle.

### 4. Lab results, interpretive view

Purpose: translate a lab report into something a non-doctor parent can act on.

Key content: pills-row summary of normal / borderline / flagged counts; parameter list with soft traffic-light indicators, name, value with unit, tap-to-expand plain-language explanation; prominent "view original lab report (PDF)" action near the top.

The one thing it must do well: replace the spreadsheet feeling with the feeling of being briefed.

### 5. Consult a doctor

Purpose: let the user pick a trusted specialist and start an async consult in one tap.

Key content: doctor cards with portrait, name, specialty, languages, response-time SLA, price; one primary action per card (Start consult); specialty filter chips above the list; a 4-step intake with generous spacing and progress dots; payment confirmation at step four, not before.

The one thing it must do well: make the doctor feel like a named, respected person, not a lookup row.

### 6. Log vitals, adult member

Purpose: let a daughter log her father's glucose in two seconds after his home test.

Key content: a focused modal sheet; big numbers (for example "120 over 80"); trend arrows vs the last reading; fasting / post-meal toggle for glucose; a full-width "Log" button; medium-impact haptic on save; a one-line context under the number.

The one thing it must do well: feel faster than Apple Health. Two seconds end to end.

### 7. Onboarding, three screens

Purpose: get a new user from App Store install to a meaningful first interaction in under 90 seconds.

Key content: screen 1 trilingual welcome with one "get started" action and language visible in a corner; screen 2 stage picker presented as a quiz not a form (pregnant, newborn, toddler, already parenting several, just curious, focused on my own health); screen 3 short signup with iOS autofill hints wired.

The one thing it must do well: screen 1 has no form at all; reading time to first tap is about three seconds.

### 8. Moments

Purpose: capture firsts (first smile, first steps) and, later, share them with family not in the app.

Key content: a calm editorial timeline (one large photo per item, a date, a one-line caption, an unobtrusive share action); an add-moment action opening a warm generous capture sheet; an empty state that feels like a printed page waiting for its first entry.

The one thing it must do well: feel like flipping a well-printed photo album, not scrolling a social feed.

---

## Output order

1. A compact design system: palette grid in light and dark, type scale with chosen faces and a one-sentence rationale, radii scale, shadow system, icon style note. One page.
2. Today screen mockup: light and dark side by side, annotated against the attached `01-today.png`.
3. A three-sentence rationale for Today.
4. Then stop. Wait for feedback before continuing to screen 2.

When you stop, print: "Today v1 ready. Palette in message header. Open questions: ..." and list any.
