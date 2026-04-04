# balam.ai — The Best App for Moms
## Product Requirements Document v2.0

**Product:** balam.ai (Балам — "my child" in Kyrgyz)
**Platform:** iOS + Android (React Native / Expo)
**Market:** Kyrgyzstan → Central Asia
**Stage:** Pre-seed → MVP
**Last Updated:** April 2026

---

## Table of Contents

1. [Vision & Philosophy](#1-vision--philosophy)
2. [Problem Statement](#2-problem-statement)
3. [Target Users](#3-target-users)
4. [Core Features](#4-core-features)
   - 4.1 AI Daily Baby Guide
   - 4.2 Photo Community ("Ask the Village")
   - 4.3 Expert Panel (Doctor, Psychologist, Gynecologist)
   - 4.4 Marketplace
   - 4.5 Local Services (Cakes & Celebrations)
5. [User Flows](#5-user-flows)
6. [Expert Panel Process](#6-expert-panel-process)
7. [AI Architecture](#7-ai-architecture)
8. [Technical Stack](#8-technical-stack)
9. [Monetization](#9-monetization)
10. [Go-to-Market](#10-go-to-market)
11. [MVP Scope](#11-mvp-scope)
12. [Success Metrics](#12-success-metrics)
13. [Screen Inventory](#13-screen-inventory)
14. [Risks & Mitigations](#14-risks--mitigations)

---

## 1. Vision & Philosophy

### Vision
Every mother in Central Asia — whether in Bishkek or a village in Naryn — gets the same quality of guidance, community, and trusted care that only privileged urban families have had access to.

### Philosophy: "The Village in Your Pocket"
There's an African proverb: *It takes a village to raise a child.* balam.ai is that village — rebuilt for the 21st century, powered by AI, driven by real moms, and anchored by trusted medical experts.

The three pillars of trust in balam.ai:
1. **AI** — Always available, always personalized, never judges
2. **Community** — Real moms who've been there, photo-first and honest
3. **Experts** — Verified doctors who answer real questions, not pamphlet answers

### What We Are NOT
- We are not WebMD (anxiety machine)
- We are not a Russian parenting forum from 2009 (toxic, outdated)
- We are not a generic app translated into Russian (culturally blank)
- We are not a marketplace pretending to care about moms

---

## 2. Problem Statement

### The Five Crises of New Motherhood in Kyrgyzstan

**Crisis 1: The Diagnostic Void**
A mom sees a rash on her baby's cheek at 11pm. Her options: panic-Google and find cancer, wake up her mother-in-law, wait until morning for a clinic that may or may not take her seriously. There is no trusted, fast, visual answer system.

**Crisis 2: The Isolation Epidemic**
Especially for first-time moms, the transition to motherhood in KG is isolating. Extended family may live far, social circles change, and Telegram groups are chaotic, unmoderated, and full of conflicting advice.

**Crisis 3: Product Trust Collapse**
Bazaar products have no ingredient transparency. International brands are expensive. Chinese imports dominate the cheap tier with unknown chemical compositions. Moms are buying blind for the most vulnerable humans on earth.

**Crisis 4: Expert Access Inequality**
Good pediatricians in Bishkek charge 800–2000 som per visit. In Osh or rural areas, specialists barely exist. A mom in Naryn has no access to a child psychologist at all.

**Crisis 5: Celebration Logistics Hell**
A baby's first birthday is a major cultural event in Kyrgyzstan. Finding a trusted cake baker, coordinating design, and ensuring quality is a 3-day Telegram ordeal.

---

## 3. Target Users

### Primary: Aizat — The New Mom (24–34)
- First or second child, 0–24 months
- Smartphone-first (Android 80%)
- Russian-speaking primarily, some Kyrgyz
- Lives in Bishkek, Osh, or regional city
- Pain: overwhelmed, isolated, uncertain
- Goal: know her baby is healthy, feel supported, not judged

### Secondary: Nazgul — The Expecting Mom (32+ weeks)
- Preparing, anxious, wants community before baby arrives
- Joins balam.ai pre-birth, transitions seamlessly to mom experience
- Use case: "What should I prepare?" → "My newborn has jaundice"

### Tertiary: Local Expert — Dr. Aigerim
- Pediatrician, psychologist, or gynecologist in Bishkek
- Currently gets inquiries through personal WhatsApp/Instagram — unscalable
- Wants structured, paid platform to help more patients without clinic overhead

### Quaternary: Local Business — Bakery Owner Jyldyz
- Home baker, makes 10–20 custom cakes/month
- Gets orders via Telegram or Instagram DMs — no platform, no reviews
- Wants a storefront, trusted audience, and reliable order flow

---

## 4. Core Features

---

### 4.1 — AI Daily Baby Guide

**The daily ritual:** Every morning, mom gets a personalized "Today with [Baby Name]" card.

#### Daily Card Contents
```
┌─────────────────────────────────────────┐
│  🌅 Good morning, Aizat                 │
│  Timka is 6 weeks and 3 days old        │
│                                         │
│  🧠 THIS WEEK'S MILESTONE               │
│  Social smiling begins! Watch for       │
│  Timka responding to your voice...      │
│                                         │
│  🎮 TODAY'S ACTIVITY (5 min)            │
│  Mirror time: hold a mirror 20cm away   │
│                                         │
│  ⚠️  WATCH FOR                          │
│  Not smiling by 8 weeks → mention to    │
│  your pediatrician                      │
│                                         │
│  💚 FOR YOU TODAY                       │
│  Your body at 6 weeks postpartum...     │
└─────────────────────────────────────────┘
```

#### Monthly Deep Dive Report
- Physical milestones (motor, reflexes, weight/height)
- Cognitive & sensory development
- Sleep patterns (what's normal, what's not)
- Feeding guide (breast, formula, introduction of solids by stage)
- Local food guide: when to introduce каша, курутоб, fruit purées — adapted to Kyrgyz diet
- Vaccination reminders: KG Ministry of Health national schedule
- WHO growth percentile tracker with local context

#### Ask balam.ai (AI Chat)
- 24/7 in Russian + Kyrgyz + English
- Trained context: WHO guidelines, AAP, KG health ministry protocols
- Warm tone — like a knowledgeable friend, not a medical disclaimer machine
- Smart escalation logic:
  - Yellow flag → "This is worth mentioning to your doctor soon"
  - Red flag → "Please contact a doctor today" + show Expert Panel booking
  - Emergency → "Call 103 now" — immediate, unmissable UI

---

### 4.2 — Photo Community: "Ask the Village" ⭐ (SIGNATURE FEATURE)

**Concept:** The single most powerful feature. Mom sees a rash, takes a photo, posts it — and within minutes real moms + optionally a verified doctor respond.

This transforms balam.ai from an app moms use occasionally into one they open every day.

#### How It Works

**Posting Flow (Mom side):**
1. Tap "Ask the Village" from home screen
2. Choose category:
   - 👶 Baby health (rash, feeding, sleep, poop color, eye discharge...)
   - 🍼 Feeding & nutrition
   - 😴 Sleep & crying
   - 🧠 Development & behavior
   - 💚 Mom's health (for herself)
   - 🎉 Recommendations (products, bakers, clinics)
3. Upload 1–3 photos (optional but encouraged)
4. Write question (minimum 10 characters, voice input supported)
5. Choose visibility: Public / Moms Only / Anonymous
6. Post → immediately visible to community

**Community Response Flow:**
- Other moms see it in their feed, sorted by baby age proximity
- Heart reaction ("I've been there") + text reply
- Moms can attach their own comparison photo ("my baby had the same, looked like this")
- Upvote helpful answers
- "Resolved" button — mom marks which answer helped her

**Expert Triage (Automated):**
- AI scans photo + text for urgency keywords
- Low urgency → community handles it
- Medium urgency → "Would you like the pediatrician to review this? Response within 24h"
- High urgency → "⚠️ This needs medical attention. Book a consult now or call 103"

**Photo Analysis by AI:**
- AI provides a non-diagnostic first response: "This could be a few things — here's what other moms and our pediatrician say about similar situations"
- Always includes: "This is not a medical diagnosis. For certainty, consult a doctor."
- Suggests relevant past community posts: "3 moms had similar questions — see what helped them"

#### Feed Design
- Home feed = chronological + age-filtered ("posts from moms with babies 0–3 months older or younger than yours")
- Trending posts badge
- "Answered by Doctor" badge prominently displayed — high trust signal
- Search: by symptom, topic, or keyword

#### Safety & Moderation
- No photo of child's private parts ever allowed — AI + human moderation
- AI auto-flags: distressing images, potential abuse indicators → human review + report
- No medical advice presented as diagnosis
- Misinformation flagging system — community + expert can flag wrong advice
- Doctor can add official correction to any post

---

### 4.3 — Expert Panel 👩‍⚕️

**The cornerstone of trust.** Three verified local experts, integrated into the app's daily flow — not hidden behind a "Book Consultation" button.

#### The Three Experts

| Role | What They Cover | Response SLA | Integration Points |
|------|----------------|--------------|-------------------|
| **Child Doctor (Педиатр)** | Rashes, fever, feeding, milestones, vaccinations, any physical health | 24h for community, 4h for booked consult | Photo posts triage, Daily card "Ask doctor", Consult booking |
| **Child Psychologist (Психолог)** | Sleep, tantrums, anxiety, postpartum depression, behavior, development concerns | 48h community, 24h consult | Mom wellbeing card, Behavior posts, PPD screening |
| **Gynecologist (Гинеколог)** | Postpartum recovery, contraception, pelvic health, returning to sex, next pregnancy | 48h community, 24h consult | Mom health section, Monthly mom check-in |

#### Expert Presence in the App

**In the Community Feed:**
- Expert sees all posts tagged with their specialty
- Can respond to any post — response gets "✓ Verified Doctor" badge
- Doctor can "adopt" a post as an educational case (anonymized with mom's permission) → becomes pinned resource

**Weekly Live Q&A (MVP Lite → then in-app):**
- Week 1: Pediatrician answers top 10 community questions from the week
- Week 2: Psychologist — postpartum mental health focus
- Week 3: Gynecologist — postpartum body recovery
- Week 4: All three — open Q&A
- Format: Text-based (video in Phase 2)
- Moms upvote questions they want answered

**Expert Profile Page:**
- Photo, credentials, clinic affiliation
- "About me" — personal, warm, not clinical
- All their community responses (searchable)
- Education articles they've written
- Booking button

#### Consultation Booking Flow
1. Mom taps "Book with Dr. [Name]"
2. Chooses: Video call / Text consultation / In-clinic (if in Bishkek)
3. Selects time slot (doctor sets availability in expert dashboard)
4. Describes concern (text + optional photo)
5. Pays in-app (Mbank / O!Dengi / card)
6. Receives confirmation + reminder

#### Expert Dashboard (Separate Web App)
- Incoming post notifications (by specialty tag)
- Community response panel
- Consultation queue
- Earnings dashboard
- Ability to publish articles/tips (becomes app content)
- Analytics: most common questions, trends

#### Expert Compensation Model
- Community posts: free (part of brand-building; balam.ai handles matching)
- Consultations: expert gets 70%, balam.ai keeps 30%
- Minimum guaranteed: if month earns < 10,000 KGS from consults, balam.ai tops up (MVP period only, to build trust with experts)
- Bonuses for: response rate >90%, rating >4.8, weekly Q&A participation

---

### 4.4 — Marketplace

**Philosophy:** Curated by a mom, for moms. Every product passes the "Would I give this to my baby?" test.

#### Launch Partners
| Brand/Category | Deal | Product Standard |
|----------------|------|-----------------|
| **Mama Znaet** | Exclusive digital partner | Diapers, wipes, hygiene essentials |
| **Eco clothing** (Turkish/Kyrgyz cotton) | Exclusive | GOTS-certified, no azo dyes, under 3 chemical compounds |
| **Postnatal nutrition** | Preferred | Local nuts, dried fruits, lactation teas |
| **Montessori toys** | Curated | Age-matched, no plastic with BPA/phthalates |
| **Baby furniture** | Preferred | Safety-certified, anti-tip tested |

#### Product Trust System
Each product shows:
- ✅ Ingredient/material transparency score (1–10)
- 🌿 Eco certification badge
- 👶 Age-appropriateness range
- ⭐ Mom reviews (photo reviews weighted higher)
- "Recommended by Dr. [Pediatrician Name]" badge where applicable

#### Shopping Experience
- **Browse by baby age** (not category): "My baby is 4 months" → curated needs
- **"Month box"**: curated bundle for current baby stage, discounted
- **Wishlist + share**: "Send to grandma" feature — family gift guide
- **Reorder**: diaper reorder reminders ("You bought diapers 18 days ago — running low?")

---

### 4.5 — Local Services: Cakes & Celebrations

**Why cakes in MVP?** Every Kyrgyz baby has a massive 1-year (туйлоо) birthday. Cakes are high-emotion, high-value, high-frequency among balam.ai's exact demographic.

#### Cake Marketplace
- Baker registration: portfolio photos, price range, flavors, service area, minimum order
- Browse by: city / style (торт на туйлоо, тематический, с фотопечатью) / price / rating
- Request flow: date, design brief, size, allergies → baker responds with quote
- Reviews: photo-verified only (mom uploads photo of actual cake received)
- Payment: WhatsApp redirect (MVP) → in-app payment (Phase 2)

#### Future Local Services (Phase 2+)
- Baby photographers (1-year packages)
- Nanny/babysitter marketplace (background-checked)
- Lactation consultant home visits
- Baby massage therapist
- Pediatric home visit booking

---

## 5. User Flows

### Flow 1: First Open (New Mom)
```
Download → Onboarding (name, baby name, DOB, feeding method) 
→ Home with Day 1 card 
→ Prompt: "Join your mom circle" (age-matched community)
→ Prompt: "Meet our experts"
→ Daily habit established
```

### Flow 2: Photo Community Post (Core Loop)
```
See rash on baby (11pm)
→ Open balam.ai → "Ask the Village"
→ Take photo + type "Rash on cheek, appeared yesterday, no fever"
→ AI first response: "Could be heat rash or mild eczema — here's what to watch for"
→ 3 moms respond within 10 minutes: "My baby had the same! It was..."
→ Doctor notified, responds within 24h with verified answer
→ Mom marks resolved, peace of mind restored
→ Notification: "Dr. Aigerim answered your post" (next morning)
```

### Flow 3: Expert Consultation
```
Ongoing concern (not emergency)
→ Community post didn't fully resolve it
→ Tap "Book with Pediatrician"
→ Choose video call, tomorrow 10am
→ Describe concern, attach community post photos
→ Pay 800 KGS
→ Video call with Dr. (via in-app video, Phase 2) / video link (MVP)
→ Post-consult: written summary saved to mom's health records
```

### Flow 4: Marketplace Purchase
```
Daily card: "At 4 months, wooden rattles are great for grip development"
→ Tap "Shop for this" 
→ See 3 balam.ai-approved rattles
→ "Recommended by Dr. Aigerim" badge on one
→ Add to cart → Mbank checkout
→ Review prompt 7 days after delivery
```

---

## 6. Expert Panel Process

### Onboarding an Expert

**Step 1: Application**
Expert fills form: specialization, license number, years experience, clinic, why they want to join balam.ai

**Step 2: Verification**
balam.ai team verifies:
- Medical license with KG Ministry of Health registry
- Clean disciplinary record
- Active practice (not retired)

**Step 3: Onboarding call**
Founder meets expert (video call):
- Explain the platform mission
- Agree on community participation minimums (e.g., 5 community responses/week)
- Set consultation pricing together
- Sign partnership agreement

**Step 4: Profile setup**
Expert creates profile with balam.ai's help:
- Professional photo (balam.ai arranges photographer for Bishkek-based experts)
- Warm bio (balam.ai copywriter helps with tone)
- First 3 educational articles written with balam.ai content team

**Step 5: Soft launch**
Expert observes community for 2 weeks, responds to posts, no paid consults yet
→ Builds reputation, gets first reviews
→ Then enables paid consultations

### Weekly Expert Rhythm
```
Monday     → Doctor reviews weekend community posts, responds to flagged ones
Wednesday  → Psychologist weekly Q&A answers posted
Friday     → Gynecologist responds to mom health posts
Sunday     → All three: review week's top questions, provide summary article
```

### Quality Control
- Expert response rating: moms rate each expert response (helpful / not helpful)
- If rating drops below 4.5 → balam.ai founder calls for feedback conversation
- Community "trust score" visible on expert profile
- Expert can be removed if: multiple complaints, license issue, consistently slow response

---

## 7. AI Architecture

### Models & Roles
| Function | Model | Notes |
|----------|-------|-------|
| Daily card generation | Claude (Anthropic) | Generated nightly per baby profile |
| AI chat (Ask balam.ai) | Claude (Anthropic) | Real-time, context-aware |
| Photo post triage | Claude Vision | Urgency classification, category tagging |
| Community moderation | Claude | Auto-flag inappropriate content |
| Expert routing | Claude | Match post to right expert by specialty |

### Content Database
- WHO Multicentre Growth Study standards
- AAP (American Academy of Pediatrics) guidelines
- KG Ministry of Health vaccination schedule
- Local food introduction guide (reviewed by balam.ai pediatrician)
- Traditional Kyrgyz postpartum practices with modern medical context (кырк чилде, etc.)

### Safety Rules (Non-Negotiable)
1. AI never provides a diagnosis — ever
2. Every medical response includes a disclaimer
3. Red flag keywords trigger emergency escalation, not AI answers
4. All photo analysis is framed as informational, never conclusive
5. AI responses reviewed weekly by pediatrician for accuracy drift

### Localization
- Primary: Russian
- Secondary: Kyrgyz (full support by Month 3)
- Kyrgyz fonts: tested on all target Android devices
- Cultural review: all content reviewed by KG mom panel (5 moms, rotating)

---

## 8. Technical Stack

### Mobile App
```
Framework:     React Native (Expo managed workflow)
Language:      TypeScript
State:         Zustand + React Query
Navigation:    React Navigation v6
UI Library:    Custom components + NativeBase base
Storage:       AsyncStorage (local) + Supabase (remote)
```

### Backend
```
Runtime:       Node.js (Express or Fastify)
Database:      PostgreSQL (via Supabase)
File storage:  Supabase Storage (photos, documents)
Auth:          Supabase Auth (email, phone OTP)
Real-time:     Supabase Realtime (community feed)
```

### AI & Integrations
```
AI:            Anthropic Claude API (claude-sonnet-4-6)
Vision:        Claude claude-sonnet-4-6 (multimodal, photo analysis)
Push:          Expo Notifications + Firebase Cloud Messaging
Video calls:   Daily.co or Zoom SDK (Phase 2)
Payments:      Mbank API, O!Dengi, Stripe (international cards)
Maps:          Yandex Maps API (KG coverage better than Google)
```

### Expert Dashboard
```
Framework:     Next.js (web)
Auth:          Same Supabase Auth (role: expert)
Notifications: Email (Resend) + in-app
```

### Infrastructure
```
Hosting:       Supabase (DB + storage + auth) + Railway or Render (API)
CDN:           Cloudflare
Monitoring:    Sentry (errors) + PostHog (analytics)
CI/CD:         GitHub Actions → Expo EAS Build
```

### Performance Targets
- App cold start: < 2.5s on mid-range Android (Samsung A-series)
- AI chat response: < 3s
- Photo upload + AI triage: < 5s
- App bundle size: < 50MB
- Offline: daily cards + community read-only cached

---

## 9. Monetization

### Revenue Model

| Stream | How | Launch | Year 1 Target |
|--------|-----|--------|---------------|
| **Marketplace commission** | 15–20% of GMV | Month 6 | Primary revenue |
| **Expert consultations** | 30% platform fee | Month 4 | 50–100 consults/month |
| **Brand partnerships** | Fixed monthly + % | Month 3 | $500–2,000/month per brand |
| **Cake/services commission** | 10–12% per order | Month 1 (MVP) | 200 orders/month |
| **balam.ai Pro** | ~300–400 KGS/month | Month 8 | 500 subscribers |

### balam.ai Pro (Premium Tier)
- Unlimited AI chat (free tier: 5/day)
- Priority doctor response (12h instead of 24h)
- Full development reports (free: summary only)
- Exclusive deals & early access
- Ad-free experience
- Monthly personal "baby report" PDF

### Pricing Philosophy
- Free tier is genuinely powerful — no safety info behind paywall
- Pro pricing in KGS (local currency) — never dollars on the paywall screen
- Family plan: 500 KGS/month for mom + 1 family member (grandma gift)

---

## 10. Go-to-Market

### Phase 0: Build the Village (Months 1–2, pre-launch)
- Recruit 5 founding moms → advisory community, beta testers
- Sign first expert (pediatrician first — highest trust impact)
- Sign Mama Znaet partnership
- Build waitlist via Instagram + Telegram (@balamapp)
- Create 30 days of launch content (parenting tips, polls, countdowns)

### Phase 1: Bishkek Launch (Months 3–5)
- Launch: AI Guide + Photo Community + Cake Marketplace
- Distribution: 
  - OB/GYN clinic partnerships (flyers + QR in waiting rooms)
  - Instagram micro-influencers (5 moms, 5k–30k followers — trusted tier)
  - Telegram mommy channels (sponsor posts + organic seeding)
  - Local media: Kloop, 24.kg, AKIpress — "First AI app for KG moms"
- Target: 1,000 registered moms in first month

### Phase 2: Full Platform (Months 6–9)
- Launch marketplace (Mama Znaet exclusive)
- Add psychologist + gynecologist to expert panel
- In-app payments for everything
- Target: 5,000 MAU

### Phase 3: Regional Expansion (Months 10–18)
- Osh, Jalal-Abad, Karakol city launches
- Kyrgyz language full release
- Kazakhstan adaptation (separate app instance, different experts, KZT pricing)

---

## 11. MVP Scope

### ✅ Must Ship (MVP)
- [ ] Onboarding: baby profile (name, DOB, feeding method, birth weight)
- [ ] Daily AI development card (personalized by age)
- [ ] Monthly milestone guide (0–24 months)
- [ ] Ask balam.ai AI chat (5 messages/day free)
- [ ] Photo Community ("Ask the Village") — post, reply, photo upload, upvote
- [ ] Community feed with age filtering
- [ ] Pediatrician on panel (community responses, profile page)
- [ ] Cake marketplace (browse, WhatsApp redirect to order)
- [ ] Push notifications (daily card + community replies)
- [ ] Russian language
- [ ] Android app (Expo)
- [ ] Basic user profile

### 🔜 Post-MVP Priority (Month 2–4 post-launch)
- [ ] In-app payment (Mbank, O!Dengi)
- [ ] Expert consultation booking
- [ ] Product marketplace (Mama Znaet)
- [ ] Psychologist + Gynecologist added to panel
- [ ] Kyrgyz language
- [ ] Growth tracker (weight, height charts)
- [ ] Vaccination tracker
- [ ] iOS app

### 🔮 Phase 2 (Month 6+)
- [ ] balam.ai Pro subscription
- [ ] Video consultations
- [ ] Weekly live expert Q&A (in-app)
- [ ] Pregnancy mode (pre-birth)
- [ ] "Resolved" post tracking / community knowledge base
- [ ] Expert-authored articles
- [ ] Kazakhstan version

---

## 12. Success Metrics

### North Star: Weekly Active Moms (WAM)
We want daily habit. WAM > DAU as primary metric because some moms use it intensely on problem days.

### Milestones

| Metric | Month 3 | Month 6 | Month 12 |
|--------|---------|---------|----------|
| Registered users | 800 | 3,000 | 12,000 |
| WAM | 500 | 2,000 | 8,000 |
| Community posts/week | 200 | 1,000 | 4,000 |
| Photo posts/week | 80 | 400 | 1,500 |
| Doctor responses/week | 20 | 80 | 300 |
| Cake orders/month | 50 | 200 | 800 |
| Expert consults/month | — | 60 | 250 |
| NPS | >55 | >60 | >65 |

### Quality Metrics
- Photo post response time (community): < 15 minutes average
- Doctor response to community post: < 24h (100% of posts)
- AI chat satisfaction: > 80% "helpful" rating
- Zero medical harm incidents (tracked via complaint system)

---

## 13. Screen Inventory

### App Screens

```
AUTH
├── Splash / Onboarding (3 slides)
├── Sign Up (phone OTP)
└── Baby Profile Setup

HOME
├── Home Feed (daily card + community preview)
├── Daily Card Expanded
└── Monthly Report

COMMUNITY ("Ask the Village")
├── Community Feed (age-filtered)
├── Post Detail (photo + replies)
├── New Post (photo upload + text + category)
├── My Posts
└── Search / Browse by category

EXPERTS
├── Expert Panel Overview (3 experts)
├── Expert Profile
├── Book Consultation
└── My Consultations

MARKETPLACE
├── Shop Home (by baby age)
├── Product Detail
├── Cart
├── Checkout
└── Order History

CAKES
├── Cake Browse (city / style / price)
├── Baker Profile (portfolio, reviews)
└── Request a Cake (brief form)

AI CHAT
├── Chat with balam.ai
└── Chat History

PROFILE
├── My Profile (mom + baby info)
├── Baby Growth Tracker
├── Vaccination Log
├── Settings
└── balam.ai Pro Upgrade
```

### Expert Dashboard Screens (Web)
```
├── Dashboard (incoming posts, today's consults)
├── Community Queue (posts to review)
├── Write Response
├── Consultation Calendar
├── Consultation Detail
├── Earnings
├── My Articles
└── Profile Settings
```

---

## 14. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| AI misidentifies urgent rash as benign | Medium | Critical | Red flag keyword layer runs BEFORE AI response; any ambiguity → "see doctor"; pediatrician reviews AI prompts monthly |
| Expert doesn't respond in SLA | Medium | High | SLA alerts to expert + founder; backup expert on call; community bridges gap |
| Photo of child misused / shared | Low | Critical | Photos stored privately, never indexed publicly, watermarked with post ID; strict ToS |
| Community gives dangerous wrong advice | Medium | High | "Not medical advice" disclaimer on every post; flagging system; doctor can mark answers wrong |
| Moms don't trust AI for baby health | Medium | High | Expert endorsement, pediatrician co-branding, warm tone, transparent "how it works" |
| Low Android storage (common in KG) | High | Medium | < 50MB target; lazy loading; no autoplay video in MVP |
| Payment infrastructure failure | High | Medium | Start with WhatsApp order redirect; Mbank integration parallel track |
| Expert quits early | Low | High | 3-month minimum commitment in contract; founder maintains relationship weekly |

---

*balam.ai PRD v2.0 — Living document. Update after every sprint, user interview, and expert session.*
*"The village your baby deserves."*
