# Clinical Scope of Practice (Draft v0.1)

> The clinical contract between Balam.AI's software and its medical advisors. What the AI is allowed to say, what requires a human co-sign, what escalates immediately. This draft gets reviewed + signed by the Medical Director (Jane Mone) and the KG Founding Medical Advisor (Prof. Uzakbaev) before the first kit ships.

---

## 1. What Balam.AI IS

- A **decision-support tool** for families.
- A **longitudinal record** of home health readings (BP, urine dipstick, temperature, weight, glucose).
- An **escalation router**: flags abnormal readings and routes them to a licensed human clinician for review within 24 hours.

## 2. What Balam.AI IS NOT

- Not a diagnostic device. The AI does not make a diagnosis.
- Not an emergency service. Emergency pathways (911/103/112/ER) are presented prominently for any red-flag reading (see §5).
- Not a prescription service. All medication suggestions come from a licensed clinician, not the AI.

## 3. AI autonomy tiers

| Tier | AI authority | Example |
|---|---|---|
| **Green — autonomous** | AI may respond, log, suggest lifestyle/behavioral actions | "Your BP reading of 118/76 is in the normal range. Keep the streak going." |
| **Yellow — autonomous + flagged for MD audit** | AI responds, logs, a sample of these cases is audited weekly by the medical director | "Your BP of 138/88 is elevated. Retest tomorrow morning before coffee. If three readings stay above 135/85 this week, we'll have a clinician review." |
| **Orange — MD co-sign required before user sees output** | AI drafts, holds, notifies the on-call MD, MD must approve or edit within 24h before user sees response | Dipstick shows 2+ proteinuria in a pregnant user; AI draft is pre-populated for MD review, user sees "Your reading is being reviewed by Dr. ___." |
| **Red — emergency override** | AI presents emergency message immediately, does not draft AI-authored content | Systolic ≥180 or diastolic ≥120 (hypertensive emergency); or dipstick 3+ protein + BP ≥140/90 in pregnancy (likely preeclampsia) |

## 4. Condition-specific thresholds (draft — to be reviewed by MDs)

### 4.1 Hypertension (adult)

| Reading | Tier |
|---|---|
| <120/80 | Green |
| 120–129 / <80 | Green (flag "elevated") |
| 130–139 / 80–89 | Yellow |
| 140–179 / 90–119 | Orange |
| ≥180 / ≥120 | **Red** — "Go to nearest ER or call 103 now" |
| Any reading + chest pain, vision loss, severe headache | **Red** |

### 4.2 Pregnancy (preeclampsia screen)

| Combination | Tier |
|---|---|
| BP <140/90 AND dipstick negative protein | Green |
| BP ≥140/90 OR dipstick 1+ protein | Orange |
| BP ≥140/90 AND dipstick ≥2+ protein | **Red** |
| Any severe headache, RUQ pain, or visual disturbance, regardless of BP | **Red** |

### 4.3 Diabetes (adult)

| Reading | Context | Tier |
|---|---|---|
| Fasting glucose <100 | — | Green |
| Fasting glucose 100–125 | 2+ readings | Yellow |
| Fasting glucose ≥126 | 2+ readings | Orange |
| Fasting glucose ≥300 OR symptoms (polyuria, vomiting, AMS) | any | **Red** (DKA screen) |
| Dipstick ketones large + glucose ≥250 | diabetic | **Red** |

### 4.4 Pediatric — infant weight (0–12 months)

| Pattern | Tier |
|---|---|
| Weight on curve | Green |
| Weight plateau <2% over 14d | Yellow |
| Weight drop >5% over 14d OR crossing 2 percentile lines down | Orange |
| Any fever ≥38°C in infant <3mo | **Red** |

### 4.5 Pediatric — fever

| Age | Temp | Tier |
|---|---|---|
| <3 mo | ≥38.0°C | **Red** |
| 3–36 mo | 38.0–38.9°C, ≤72h, no red flags | Yellow |
| 3–36 mo | ≥39.5°C OR ≥72h | Orange |
| Any age | Altered mental status, non-blanching rash, respiratory distress | **Red** |

## 5. Emergency-override UI behavior

On any **Red** classification:
1. Full-screen emergency card (cannot be dismissed by swipe).
2. Localized emergency number pre-dialed: Kyrgyzstan 103, US 911, Russia 103.
3. One-tap "Call Jane / Call on-call MD" button.
4. Text: "This reading needs immediate in-person evaluation. Balam.AI cannot help you with this from here."
5. Firestore event logged with full reading + timestamp + user ack.

## 6. MD review SLA

| Tier | SLA for human touch |
|---|---|
| Green | n/a |
| Yellow | weekly audit sample (≥5% of cases) |
| Orange | ≤24 hours to user-visible response |
| Red | User sees emergency UI immediately; MD notified within 15 minutes for case log (not for patient instruction — that's the emergency system's job) |

## 7. Audit trail

Every AI response in Yellow/Orange/Red tier is logged to `clinical_audit/{caseId}` with:
- Full input (reading, member profile, 30-day history)
- AI draft output
- Tier classification
- MD reviewer (if applicable), review timestamp, MD edit diff
- User action (read / ignored / escalated / followed advice)

This log is the defense against any clinical-safety claim and the training corpus for the next model iteration.

## 8. Protocol versioning

Every change to this document requires sign-off from the Medical Director. Protocols are versioned (`v0.1`, `v0.2`…); the running version is embedded into every AI call so retrospective audits can reproduce which protocol applied.

## 9. Open questions for the first MD review session

1. Preeclampsia threshold — should we lower BP trigger to 135/85 in third-trimester per NICE, or stay at 140/90 per ACOG?
2. Pediatric fever — how aggressive on the 3–36mo band? Parents will over-trigger if Orange fires too often.
3. Dipstick proteinuria — how do we handle false positives from concentrated urine (morning sample)? Do we ask for repeat with hydration?
4. Language of the **Red** card — one message per jurisdiction, or one universal? MDs to approve wording.
5. Which conditions do we explicitly NOT touch in v1 (e.g., mental health crisis, oncology, cardiac arrhythmia from BP-cuff irregular-heartbeat flag)? Explicit out-of-scope list matters for liability.

---

**Signed:**
- Medical Director (US): ____________________________ Jane Mone, NP  Date: ______
- Founding Medical Advisor (KG): ____________________________ Prof. K.A. Uzakbaev, MD, DMSc  Date: ______
- Founder: ____________________________ Timur Mone  Date: ______
