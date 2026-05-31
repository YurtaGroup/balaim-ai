# Balam.AI — App Store Connect Listing (US-first, paste-ready)

Drafted 2026-05-31 for the v3 hyper-focus product (3 tabs: Home · Ask · Child) + the Mom emotional layer + the Montessori Invitation engine.

Update [project_vision.md](memory/project_vision.md) if you revise positioning here.

---

## App Name (30 chars max)

> **Balam — Your Parenting Coach**

Alternates if Apple flags the primary:
- **Balam: Pediatric AI Coach**
- **Balam — Montessori Coach**

## Subtitle (30 chars max)

> **A Montessori coach for parents**

Alternates:
- **The mom-friend in your phone**
- **Today's parenting, made small**

## Promotional Text (170 chars, no review required to update)

> Balam writes you a friend-shaped reply when you check in, and a tiny Montessori invitation for your child every day — using whatever's already in your kitchen.

## Keywords (100 chars, comma-sep)

> montessori,parenting,baby,toddler,pediatric,mom,sleep,milestone,breastfeeding,childcare,family

(95 chars — leaves room for adjustments.)

---

## Description (4000 chars max)

> **Balam is the parenting coach that fits in your pocket.**
>
> Most parenting apps log your baby. Balam coaches *you*.
>
> Every morning, Balam writes a small, doable Montessori invitation for your child — one tiny activity, set up in 60 seconds, using something that's already in your kitchen or laundry basket. No purchases. No Pinterest. No screen time for the baby. Just one specific thing to try today, anchored to the developmental window your child is actually in right now.
>
> Every evening, you log a 30-second observation — "she pulled all the pots out of the cabinet again" — and Balam reads what your child is telling you. Tomorrow's invitation adjusts. That's Montessori's "follow the child," finally implemented in software.
>
> **For you, too.** Tap one of five emojis on the Home screen and Balam answers — like a friend, not a chatbot. No platitudes, no "you've got this," no advice unless you ask. Just the witness most parents never get.
>
> **What's inside Balam:**
>
> ◆  **Today's Invitation** — One Montessori activity, matched to your child's age and what you've been noticing this week. Real tools, real tasks, no purchases.
>
> ◆  **The Observation Log** — 30-second voice or text capture. Balam tags it with the sensitive period it lights up, the Montessori category it lives in, and the pediatric milestone it satisfies. Same log → both readings → a developmental story you can hand to your pediatrician.
>
> ◆  **"How are you?"** — A 5-emoji daily check-in for *you*. Mom before kid. Streak detection if it's been hard for a few days; gentle nudges if you've gone quiet. Crisis-aware escalation when it matters.
>
> ◆  **The Family Health Vault** — Snap a photo of an after-visit summary, a prescription bottle, or a lab result. Balam extracts the meds, dates, and follow-ups into a structured record. Your child's medical story, in one place.
>
> ◆  **Ask Balam** — Grounded in your child's vault. The 3am "is this normal?" question gets a real answer using what Balam actually knows about your kid.
>
> **For parents 0–3, especially first-timers.** Built by a parent for parents. English with full Russian and Kyrgyz support — more languages coming.
>
> **Balam Premium** ($9 / month or $79 / year) — unlimited AI questions, multi-child support, partner sharing, PDF export of your child's developmental story for pediatrician visits. The free tier always works: the vault, the mood check-in, the proactive notices, and three AI questions every week.
>
> No ads. No data sale. The mood thread is yours and yours alone.
>
> Built on Anthropic's Claude. The model is Montessori-trained on the actual method — not the Pinterest aesthetic.

(≈ 2,950 chars. Room for legal / trademark lines if needed.)

---

## What's New in This Version (4000 chars max)

For build 1.7.0+20:

> **The Mom layer + the Montessori layer — Balam grows up.**
>
> ◆  *"How are you?"* on Home. Five emojis, no labels. Tap one, get a friend-shaped 2-3 sentence reply from Balam. After hard days, gentle nudges. Crisis-aware.
>
> ◆  *Today's Invitation.* One Montessori activity, written for your child's age and what you've been noticing. No purchases, no screens, no crafts. Tap loved / lost interest / too early and tomorrow's invitation adjusts.
>
> ◆  *"I noticed…"* in the Child tab. 30-second voice or text. Balam reads what your child is showing you and tags the sensitive period, the Montessori category, and the matched pediatric milestone. Same log → two readings.
>
> ◆  Polish: faster Home, cleaner empty states, font rendering fixed.

---

## Age Rating

- **4+** (no objectionable content)

## Primary Category

- **Health & Fitness** — primary
- **Education** — secondary

(Considered Lifestyle/Family. Health & Fitness wins because the mood layer + vault are health features and reviewers respond to "health" framing better than "lifestyle" for this product shape.)

## Privacy — what to declare

- **Data Collected:** Email (auth), child's name + date of birth, user-uploaded photos (vault), user-typed/spoken observations and mood notes, app interaction analytics.
- **Linked to user:** All of the above.
- **Used for tracking:** **None.** Balam does not track across apps or sell data.
- **Third-party SDKs:** Firebase (Google), Anthropic Claude, RevenueCat.

## Privacy Policy URL

> https://balam.ai/privacy  *(verify this resolves — host one if not)*

## Terms of Use (EULA)

> https://balam.ai/terms  *(verify this resolves — host one if not)*

## Support URL

> https://balam.ai/support  *(verify this resolves)*

## Marketing URL (optional)

> https://balam.ai

---

## Screenshots — shot list (6 required for iPhone 6.7")

Use the running app on iPhone 17 Pro simulator in light mode. Capture via Cmd+S in Simulator (saves to ~/Desktop).

1. **Home — Mood + Invitation.** MoodCard with "How are you, Mom?" + 5 emojis on top, today's Invitation card directly below.
2. **Mood reply.** Card flipped to the warm-friend response after a tap.
3. **Child timeline.** A few vault records + a moment + a tagged observation (with the period/category/milestone chips visible).
4. **Ask.** AI chat with one grounded answer that quotes the vault.
5. **"I noticed…"** entry sheet, mid-typing.
6. **Emergency mode entry.** The red emergency pill + a brief Pediatrician reply.

Caption each (max 5 short words):

1. *"Mom before kid. Always."*
2. *"A friend writes back."*
3. *"One timeline. One child. Everything."*
4. *"Grounded in your kid's vault."*
5. *"Follow the child."*
6. *"The 3am promise."*

---

## TestFlight Beta Notes (for external testers)

Pasteable into the TestFlight build description:

> **What to try this week:**
> 1. On Home, tap one of the 5 emojis. If you tap 😞 / 😔 / 😐 you'll be asked if you want to share more. Hit Save. Balam writes back in ~5–8 seconds.
> 2. In the Child tab, hit + → "I noticed…" and write one sentence about what your kid did today. Within 10 seconds, the entry shows up in the timeline with chips for what it means (e.g. "Order", "Practical Life", "Fine motor").
> 3. Wait for today's Invitation card on Home to load — one Montessori activity for today. Try it (or don't), then tap 🌱 loved / 🌀 lost interest / 🚫 too early. Tomorrow's invitation will adjust.
>
> **What's deliberately not done yet:**
> - Voice memos (text-only for now)
> - PDF export of the developmental story
> - Android
>
> **What to flag:** anything that surprises you, anything that took more than 30 seconds to figure out, anything Balam said that landed wrong.

---

## Pre-submission checklist

- [ ] RevenueCat key bound (`firebase functions:secrets:set REVENUECAT_API_KEY`)
- [ ] In-App Purchases approved for `balam_premium_monthly` and `balam_premium_yearly`
- [ ] Privacy Policy URL resolves
- [ ] Terms of Use URL resolves
- [ ] Support URL resolves
- [ ] Six 6.7" screenshots uploaded
- [ ] Crisis keyword list reviewed by Jane Mone NP
- [ ] App Review demo account: temporary login Apple can use to see all premium features (otherwise expect rejection)
- [ ] App Privacy section filled in (see "Data Collected" above)
- [ ] App Tracking Transparency (ATT) — not needed (we don't track across apps)
