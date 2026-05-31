# Balam — Sprint Roadmap

**Authored: 2026-06-01.** Each sprint has a goal, tasks with acceptance criteria, and exit conditions. WIP cap: 3 tasks in progress at any time. Owner column blank = not yet assigned.

Strategy substrate: [STRATEGIC_VISION.md](STRATEGIC_VISION.md).
Sync to AltaiOS: [SYNC_TO_ALTAIOS.md](SYNC_TO_ALTAIOS.md) (deferred).

---

## Sprint 1 — Proof of Artifact 🚀 IN PROGRESS

**Sprint opened: 2026-06-01.** Duration: 1 week. Why first: artifact is the unlock. Proves the whole framing works before any UI rewrite.

Goal: ship the Sunday Chapter cron + Home card. Mom hears a 60-second narrated audio chapter of her child's week, every Sunday at 7pm local.

Kickoff brief: [standups/2026-06-01-sprint-1-kickoff.md](standups/2026-06-01-sprint-1-kickoff.md)

| # | Status | Task | Acceptance | Owner |
|---|---|---|---|---|
| 1.1 | 🧪 awaiting verify | Design Sunday Chapter Home card | **Code complete 2026-06-01.** 5 states implemented per Designer spec. Files: `lib/features/home/{widgets/sunday_chapter_card.dart, providers/sunday_chapter_provider.dart, models/sunday_chapter.dart}`. Verify on TestFlight build. | Timur |
| 1.2 | 🧪 awaiting verify | Cloud Function cron: fire Sunday 7pm per parent's TZ | **Code complete 2026-06-01.** Hourly UTC cron, TZ scan, idempotent via Firestore transaction on weekId. File: `functions/src/jobs/sunday_chapter.ts`. Companion: `users/{uid}.timezoneOffsetMinutes` captured by Flutter on auth state change. Verify: `firebase deploy --only functions:scheduledSundayChapters` + monitor logs. | Timur |
| 1.3 | 🧪 awaiting prompt review | Chapter persona prompt for Claude | **Code complete 2026-06-01.** File: `functions/src/ai/personas/sunday_chapter.ts`. **Next step: fire `generateSundayChapterManual({force: true})` from `firebase functions:shell` and review narrative quality before scaling to cron.** | Timur |
| 1.5 | 🧪 awaiting verify | Native share sheet (save to Photos / share to WhatsApp/IG) | **Code complete 2026-06-01.** Built into the card's played state. Uses `dio` to download audio + `share_plus` Share.shareXFiles. iOS + Android verify pending. | Timur |
| 1.4 | ⚪ queued | TTS audio narration | OpenAI `tts-1` model (Cartesia/ElevenLabs deferred). Audio <1MB, ~$0.014/chapter. **Blocker: `OPENAI_API_KEY` Firebase secret + `openai` npm install.** Wire after task 1.3 prompt review passes. | |
| 1.6 | ⚪ queued | Dogfood with Timur's family + Izzatillo + Adam for 1 weekend | 3/3 say "yes I'd pay for this" or feedback drives v1.1 | |

Exit: Sunday Chapter ships in TestFlight build N+1, with 3 families having received at least one chapter.

---

## Sprint 2 — The Promise

**Duration: 1 week. Reframes the app around the 18-year vault narrative.**

Goal: rewrite onboarding around the one-sentence promise. Add the letter-at-18 mechanic.

| # | Task | Acceptance |
|---|---|---|
| 2.1 | Onboarding screen rewrite: full-bleed one-sentence promise | *"By the time they're 18, you'll have written them a book about who they were — without trying. It starts today."* |
| 2.2 | "Letters waiting" counter on Home | Shows N letters recorded, increments on each save |
| 2.3 | Letter-at-18 modal trigger logic | Fires at most 1x/week, on earned milestones (first word, first step, hard 3am, Sunday Chapter completion) |
| 2.4 | Voice recording UX (30s cap) | One tap to record, waveform visual, save-or-discard |
| 2.5 | Store letters in encrypted vault with reveal-date metadata | Letter stored with `reveal_at: child.birthday_18` field |

Exit: 5 dogfood parents have each recorded ≥1 voice letter.

---

## Sprint 3 — Trust Architecture

**Duration: 2 weeks. The privacy spine. Ship before scaling marketing.**

Goal: ship E2EE for photos + voice + observations. Publish the Trust Constitution.

| # | Task | Acceptance |
|---|---|---|
| 3.1 | Client-side key generation, iCloud Keychain + Android Keystore wrapping | Key never leaves device; deterministic per user; recoverable via Keychain restore |
| 3.2 | Encrypted photo upload pipeline | Server receives only ciphertext + ID + timestamp; client decrypts on retrieval |
| 3.3 | Encrypted voice memo upload pipeline | Same model as 3.2; audio decryption inline on playback |
| 3.4 | Encrypted observation text | All `observations/{id}.text` ciphered at rest |
| 3.5 | Migrate Cloud Functions to ephemeral-decrypt-then-discard model | RAM-only plaintext, `no-store` to Claude API, re-encrypt response |
| 3.6 | Write Trust Constitution (the 5 commitments) | Published at balam.ai/trust |
| 3.7 | External auditor outreach (security + privacy lawyer) | At least one engagement letter signed |

Exit: Trust Constitution live. E2EE flag default ON for new users. Migration plan for legacy users documented.

---

## Sprint 4 — Custody by Design

**Duration: 1 week. The most revolutionary UX in the product.**

Goal: ship the 18-year custody settings screen. The first time any company designs for "this product transfers to the user in 18 years."

| # | Task | Acceptance |
|---|---|---|
| 4.1 | Custody settings screen design | Shows transfer date, trustee, what's sealed vs open |
| 4.2 | Trustee designation flow | Parent picks 1-2 trustees by email; trustees confirm |
| 4.3 | "What is sealed / what is open" picker | Per-content-type toggles: photos, voice letters, observations, health records |
| 4.4 | Birthday-of-18 transfer mechanic (UI only; deferred actual transfer logic) | Screen shows countdown + preview of what child will receive |
| 4.5 | Estate plan disclosure copy + legal review | Wording reviewed by privacy lawyer |

Exit: any parent can designate a trustee + preview their child's 18-year inheritance.

---

## Sprint 5 — Doctor Channel v1

**Duration: 2 weeks. WhatsApp obliteration. Seeds Jane + Uzakbaev.**

Goal: extend `features/consult/` from one-doctor demo into a real thread product. Doctor inbox + payments + brief + scripts.

| # | Task | Acceptance |
|---|---|---|
| 5.1 | Auto-generated clinical brief (Claude prompt against child vault) | Doctor opens thread → brief appears in <3s, ≤200 words |
| 5.2 | Photo encrypt + auto-tag (rash/eye/throat/diaper) via Claude Vision | Tags accurate on 8/10 dogfood photos |
| 5.3 | Voice memo transcription + tag | Whisper or equivalent; tag matches symptom domain |
| 5.4 | Stripe Connect for consult payments | Doctor onboards, payouts work, 20% take rate captured |
| 5.5 | Prescription / referral writing pad component | Doctor signs inline, PDF generated, filed in vault |
| 5.6 | Doctor inbox redesign | Thread list, brief preview, payment status, unread badge |
| 5.7 | Time-limited grant mechanism | Parent grants 90-day window; auto-expires; visible to parent |

Exit: Jane + Uzakbaev each have 5 active patient threads. 10 paid consults processed via Stripe.

---

## Sprint 6 — Artifact Calendar

**Duration: 2 weeks. Multi-cadence virality. Same engine, new templates.**

Goal: monthly montage video + birthday cinematic + milestone mini-clips.

| # | Task | Acceptance |
|---|---|---|
| 6.1 | Monthly photo montage Cloud Function (ffmpeg in container) | 30s vertical video, photos + Claude narration overlay |
| 6.2 | Birthday cinematic template (90s, music bed, dramatic edit) | Triggers on child birthday at 7am local |
| 6.3 | Milestone mini-clip auto-cut (15s) | Fires on first word / first step / first laugh logs |
| 6.4 | Push notification triggers (birthday, monthly, milestone) | Notifications deep-link to the artifact |
| 6.5 | Save-to-Photos pipeline for all video artifacts | iOS + Android; vertical 9:16 export |
| 6.6 | "School transition" template stub (defer trigger logic) | Template exists, manually fireable |

Exit: 3 dogfood families have generated ≥1 monthly montage AND 1 milestone mini-clip.

---

## Sprint 7 — Voice & Family Tier

**Duration: 2 weeks. The Family tier unlock — Mom's voice narrating her own kid's book.**

Goal: ship voice cloning + partner share. Launch the $19/mo Family tier.

| # | Task | Acceptance |
|---|---|---|
| 7.1 | ElevenLabs/Cartesia voice clone integration | Mom records 60s sample, clone trained in <2 min |
| 7.2 | Chapter narration in Mom's cloned voice (opt-in) | Sunday Chapter v2 plays in Mom's voice if enabled |
| 7.3 | Partner invite flow | Email/SMS invite, partner installs, both see vault |
| 7.4 | Multi-seat vault permissions | E2EE key shared via secure channel; both phones decrypt |
| 7.5 | Family tier paywall ($19/mo) | RevenueCat product, upgrade flow, post-upgrade unlock |
| 7.6 | Voice clone consent + revocation flow | Mom can delete clone anytime; deletion is irreversible client-side |

Exit: Family tier live in App Store. 3 dogfood families have partner-shared their vault.

---

## Sprint 8 — Print + Time Capsule

**Duration: 1 week. The artifact revenue line. Pure-margin physical goods.**

Goal: ship The Book ($79-129) and The Time Capsule USB ($199 pre-order).

| # | Task | Acceptance |
|---|---|---|
| 8.1 | Lulu/Blurb API integration | Order placed, book printed, shipped to a dogfood parent |
| 8.2 | Year compilation rendering (chapters + photos + voice letter transcripts) | PDF generated end-to-end from real data |
| 8.3 | Time Capsule USB pre-order page | Stripe checkout, $199 captured, $0 fulfilled (defer hardware) |
| 8.4 | Stripe products + checkout flow | Both products purchasable from Settings |
| 8.5 | Premium-tier upsell placement on the artifact reveal pages | "Print this book →" CTA after Sunday Chapter / monthly montage |

Exit: First Book ordered + shipped. ≥3 Time Capsule USB pre-orders.

---

## Future Sprints (post Sprint 8)

Deferred but tracked — pull into the active pipeline only after Sprint 8 ships:

- **Sleep coach** (the founder's roadmap #2 — survival feature, retention)
- **Visual symptom checker** (Claude Vision pipeline already partly built)
- **Pediatrician PDF export** (premium killer for well-child visits)
- **Apple Health / Owlet / smart-bottle integration** (wearable data flows into the coach)
- **The Chapter Closes — graduation / school transition triggers** (year-2 emotional artifact)
- **International localization** (Russian / Turkish / Spanish / Arabic — each unlocks 5-30M households)
- **Institution licensing program** (schools + daycares + pediatric practices)
- **Sovereign data export tool** (signed cryptographic archives — credibility booster for the Trust Constitution)
- **Estate / trustee actual transfer logic** (the 18-year transfer ceremony — design moment)

---

## Sprint discipline rules

1. **WIP cap = 3 tasks in progress** across the whole roadmap. If 3, nothing new starts.
2. **Every task has acceptance criteria.** No "we'll know it when we see it."
3. **Sprints don't extend.** If we miss exit conditions, the missing task moves to next sprint or gets killed.
4. **One sprint at a time.** Don't fan out — finish Sprint 1, then Sprint 2.
5. **Stale tasks (>30 days untouched) get archived** with a "killed because" line. Stale backlog lies about the team's intentions.

---

## How to use this with the Balam PM agent

When you want a status, ask:
> *Balam PM: what's the state of Sprint N?*

When you want to move a task to in-progress:
> *Balam PM: move task 1.3 to in-progress, I'm building it now.*

When you finish a sprint:
> *Balam PM: close Sprint N, write the retro, advance to Sprint N+1.*

The agent reads this file, edits in place, and surfaces only the relevant slice — keeping the conversation tokens lean.
