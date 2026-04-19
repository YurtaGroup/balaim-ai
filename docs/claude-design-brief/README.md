# Claude Design Brief — upload folder

This folder is the upload payload for Anthropic's Claude Design (claude.ai/design). Every file in here exists to give the designer session exactly what it needs on the first pass and nothing it does not.

## How to use it

**Option A — drag-and-drop (preferred).** Open Claude Design, start a new design, drag `docs/claude-design-brief.zip` (sibling of this folder) into the upload target. Paste `PROMPT.md` as the first message.

**Option B — paste-and-attach (fallback if the folder tool rejects zips).** Paste the entire contents of `ALL-IN-ONE-PROMPT.md` as the first message. Then attach each file in `current-screens/` individually via the paperclip.

## What comes back

Claude Design will return mockups in whatever native format its canvas uses. Do two things with each reviewed iteration:

1. Export the approved screens as PNG and drop them into the Balam.AI repo at `docs/claude-design-brief/approved/<screen>/vN.png`.
2. Open a Claude Code session at the repo root and ask it to port the approved mockup into Flutter (it knows the codebase; it will translate the mockup into a widget under `lib/features/...`).

## Guardrails for the designer session

Baked into `PROMPT.md` and `CONSTRAINTS` block inside every file:

- 390 x 844 mobile canvas
- Light mode first, dark mode as a side-by-side companion
- Trilingual text (English, Russian, Kyrgyz; Russian and Kyrgyz run roughly 20-30 percent wider)
- No emoji in UI chrome
- No aggressive medical red for ordinary states; red is reserved strictly for emergencies
- Bottom navigation stays 5 tabs; do not redesign navigation order

## Where each input lives

- `PROMPT.md` — first turn for Claude Design
- `BRAND-BRIEF.md` — product, user, tone, positioning in one page
- `SCREENS.md` — 8 screens to design with purpose and the one thing each must do well
- `REFERENCES.md` — what to study, what to explicitly avoid
- `ALL-IN-ONE-PROMPT.md` — everything above merged into a single paste
- `current-screens/` — baseline screenshots of the current app (seeded with Today; capture the others live with `xcrun simctl io booted screenshot docs/claude-design-brief/current-screens/NN-name.png`)
