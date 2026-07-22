<!-- PHASE-PROGRESS:START — the resume marker. Every skill reads this first and rewrites it as it works. Keep it accurate. -->
```yaml
# RESUME MARKER — read this first, always.
org_name: Wren & Slate
created: 2026-07-22
last_updated: 2026-07-22
current_phase: complete
last_completed_step: completeness-pass + sequencing
status: complete
resonance_confirmed: true
phases:
  profile-and-plays:      complete
  strategy-readout:       complete
  architecture-and-stack: complete
  build-spec:             complete
next_action: "None — spec complete. Hand the Build Spec to the builder; start with Play 1 (High-LTV identification + VIP routing)."
```
<!-- PHASE-PROGRESS:END -->

---

# GTM Brain — Wren & Slate

> Draft spec produced through the GTM-Brain interview. Two linked tiers:
> the **Strategy Readout** (for the operator — is this your business?) sits above the fold;
> the **Build Spec** (for the builder — can you stand up a v1?) sits below it.

## Raw capture

### Org profile (Phase 1)
- **Industry / business model:** Direct-to-consumer home-goods & apparel brand, Shopify Plus. ~$40M annual revenue, ~470K orders/year, blended AOV ~$85. "We're two catalogs in one store — a home line (textiles, ceramics, small furniture) and an apparel line (elevated basics, seasonal drops). Roughly 60% of revenue is home, 40% apparel, and the crossover buyers are our best customers."
- **Motion (PLG / sales-led / hybrid; inbound vs outbound weight):** "Marketing-led, no sales team. Everything is paid acquisition plus lifecycle. We buy the first order on Meta and Google, and we make our money on the second, third, fourth. It's a retention business wearing an acquisition business's costume."
- **Who they sell to (segments, ICP in their words):** "Women 30–55, household income $90K+, design-conscious, buy for the home and themselves. We don't think in 'accounts' — we think in customers and segments. The unit is a person and their order history." Best cohort: full-price first-time buyers acquired on non-brand search or Meta prospecting who cross the home↔apparel line within 90 days.
- **GTM team shape & who runs plays:** VP Growth & Retention (Maya, the operator running this interview) owns the P&L for CAC and LTV; a 2-person paid team runs Meta + Google; a lifecycle marketer owns Klaviyo flows; a RevOps/analytics contractor owns Triple Whale and the Segment setup; support is 4 agents in Gorgias. "No data scientist on staff. Whatever we build has to run in tools my team already touches."
- **Stated GTM goals (this quarter / this year):** "Blended MER is drifting down — we were at 3.1, we're at 2.6 and CAC keeps climbing. The board wants blended ROAS back above 3.0 without cutting spend, which means the spend has to get smarter and retention has to carry more. Three specific things this year: (1) find our high-LTV customers *earlier* so we treat them right before they churn, (2) stop the leak of repeat buyers who quietly go dark, and (3) stop paying Meta to reacquire people who are already my customers."
- **The decisions they most wish were automatic / made better:** "Which new customer is going to be worth $500 vs $80 — I want to know that at order one, not order four. Which of my repeat buyers is about to lapse and what discount (if any) they actually need — right now lifecycle blasts everyone 20% off, which is lighting margin on fire. And which segments to feed the ad platforms as lookalike seeds vs suppress — that's done by gut in a spreadsheet once a month and it's stale the day it's built."

### Discovered plays (Phase 1) — no menu was shown; these emerged from the conversation
- **Play 1: High-LTV identification + VIP routing** — "The whole retention P&L turns on catching the whales early. If I know at order one who's going to be high-LTV, I can give them concierge treatment and early access instead of treating everyone identically and losing the good ones to a bad support experience or a generic flow."
- **Play 2: Lapse detection + winback (margin-protected)** — "My repeat buyers don't announce they're leaving — they just stop. I want the brain to see the cadence break before it's terminal and trigger the *right* winback — soft for someone still engaged, deeper only for someone genuinely worth a discount, and skip the ones who'll never be profitable. Offer depth is the whole game because every point of discount is margin."
- **Play 3: Paid-acquisition audience feedback loop** — "Close the loop between who my best customers are and what I tell Meta and Google to go find. Seed lookalikes off high-LTV, suppress my existing customers from prospecting so I stop paying to reacquire them, and suppress the churned-unprofitable from retargeting. This is what moves blended MER."
- **(Priority order the operator gave):** 1 → 2 → 3. "One and two are the retention engine; three is how retention makes acquisition cheaper. But one feeds three — the LTV scores are the seed — so one is genuinely first."

### Architecture inputs per play (Phase 3)
- **Entity, all three plays:** the CUSTOMER — a single person stitched across Shopify (customer record, order history, guest-checkout orders), Klaviyo (email/SMS profile, engagement), and Segment (anonymous browse → known identity). "The hard part is that the same human is a guest checkout under one email, a subscriber under another, and an anonymous browser on their phone. If we resolve that wrong, every score is wrong."
- **Play 1 evidence discussed:** first-order value + item mix + discount used (Shopify), acquisition channel/campaign (Triple Whale attribution), first-30-day email/SMS + browse engagement (Klaviyo + Segment). Decision: predict 24-month LTV early, assign a VIP tier, route treatment.
- **Play 2 evidence discussed:** order timestamps → cadence vs the customer's own historical interval (Shopify), engagement-decay trend (Klaviyo), discount-dependence as a margin proxy (Shopify) — with a noted gap that true product-level margin isn't cleanly available. Decision: detect lapse stage, choose offer depth capped by margin.
- **Play 3 evidence discussed:** realized + predicted LTV deciles (from Play 1), active-customer status, churned-unprofitable status, blended MER / channel CAC (Triple Whale). Decision: which segments to seed as lookalikes, which to suppress, sync to Meta + Google.

### Named tool stack (Phase 3)
- `~~commerce/orders` → **Shopify Plus** (system of record for customers, orders, catalog; owns customer tags; Admin API + webhooks). Confidence: high.
- `~~email/SMS` → **Klaviyo** (lifecycle flows, profiles, segments; owns the winback + VIP welcome flows). Confidence: high.
- `~~ads` → **Meta Ads** + **Google Ads** (prospecting, retargeting, Custom Audiences / Customer Match, lookalikes/similar audiences). Confidence: high.
- `~~web/marketing analytics + attribution` → **Triple Whale** (blended MER/ROAS, channel CAC, post-iOS attribution, customer-journey view). Confidence: high.
- `~~customer data platform` → **Segment** (identity resolution, computed traits/audiences, destination syncs). Confidence: medium — "it's set up but the identity-graph config and the ad-platform audience destinations are half-configured; my contractor owns it."
- `~~conversation intelligence / support` → **Gorgias** (support tickets, macros, priority routing by customer tag; CSAT). Confidence: high.
- `~~enrichment` → **Shopify order history + Klaviyo profiles** (first-party only — no third-party B2B/firmographic enrichment; the enrichment *is* the behavioral history). Confidence: high.
- **Tools mentioned that don't map cleanly:** a Google Sheet the paid team hand-builds monthly for seed/suppression audiences (the manual process Play 3 replaces); Shopify Flow (native automation, candidate for lightweight tag-writes).

<!-- =============================================================================
     STRATEGY READOUT  (above the fold — operator-facing, business language)
============================================================================= -->

## Strategy Readout

*Read this and tell me: is this your business?*

### What your GTM Brain is for

Wren & Slate makes its money on the second, third, and fourth order — you buy the first one on Meta and Google, and retention has to carry the rest. Your GTM Brain owns the customer-economics decisions that determine whether that model works: **which customers are worth investing in, which are quietly leaving, and how much to pay to acquire more like your best ones.** It watches every customer's order history and engagement the way your sharpest retention analyst would if they never slept, and it turns that into three decisions you make every day — who gets VIP treatment, who gets a winback and how deep, and which segments your ad platforms should chase or leave alone. The goal is the one the board gave you: blended ROAS back above 3.0 without cutting spend, by making the spend smarter and letting retention carry more of the load.

### The priority plays it runs

1. **High-LTV identification + VIP routing** — spot your whales at *order one*, not order four.
   - *The decision it makes for you:* which new and recent customers are likely to become high-LTV, and what treatment they get — concierge onboarding and early access for the ones who'll be worth $500+, standard care for the rest — decided from their first order, how they were acquired, and how they engage in the first 30 days.
   - *Why it's a priority:* your whole retention P&L turns on catching the good customers before a generic experience loses them. This is the play you ranked first, and it produces the LTV scores the other two plays depend on.
2. **Lapse detection + winback (margin-protected)** — see the cadence break before it's terminal, and win them back with the *right* offer.
   - *The decision it makes for you:* which repeat buyers are lapsing — measured against their *own* buying rhythm, not a blanket rule — and exactly how deep a winback offer each one warrants: nothing but free shipping for someone still engaged, a real discount only for someone genuinely worth it, and skip the ones who'll never be profitable. Offer depth is capped so you stop lighting margin on fire with reflexive 20%-off blasts.
   - *Why it's a priority:* repeat buyers don't announce they're leaving, they just stop — and the current "blast everyone 20% off" habit is the margin leak you named directly.
3. **Paid-acquisition audience feedback loop** — tell Meta and Google who to chase and who to leave alone.
   - *The decision it makes for you:* which customer segments to feed the ad platforms as lookalike seeds (your highest-LTV customers) and which to suppress — stop paying to reacquire people who are already your customers, stop retargeting the churned-and-unprofitable — refreshed continuously instead of a stale monthly spreadsheet.
   - *Why it's a priority:* this is the play that moves blended MER, and it runs on the LTV scores Play 1 produces — retention making acquisition cheaper.

### What it will feel like when it's working

Your lifecycle marketer stops sending the same 20%-off winback to everyone and starts sending the *right* offer to the right lapsing customer automatically — margin per winback goes up, not down. Your best customers get flagged and routed to concierge treatment within a day of their first order, while your paid team stops hand-building the seed/suppression spreadsheet each month because the audiences update themselves off live LTV. And the number the board watches — blended ROAS — moves, because you're no longer paying to reacquire customers you already have and your lookalikes are seeded on who actually becomes valuable, not who just clicked once.

### The shape underneath (one paragraph, plain-English)

Underneath, the brain does four things in a loop. It **watches the signals** that predict customer value — orders, browsing, email and SMS engagement, how each customer was acquired — pulled from the tools you already run. It **stitches those signals to the right person**, which is the hard part in e-commerce: the same human is a guest checkout under one email, a subscriber under another, and an anonymous phone browser, and the brain resolves them into one customer so every score is about a real person, not a stray row. It then turns that into **trustworthy, dated facts** — this customer's predicted LTV, their lapse risk against their own rhythm, which segment they belong in — and applies clear rules to **decide** which play to run on whom. And it **learns**: it watches whether the whale actually made a second purchase, whether the winback worked and at what margin, whether the lookalike seeds produced good customers — and tunes its own thresholds from what happened. That's the difference between this and the flows and spreadsheets you have now, which run the same rule forever regardless of what it produces.

> **Resonance checkpoint.** Operator confirms: ☑ *"Yes, this is my business."*  |  ☐ *Needs correction:*
> — *(Confirmed by Maya, VP Growth & Retention, 2026-07-22: "This is exactly it — especially framing offer depth as the margin decision and calling out that the LTV score is the seed for the ad loop. Correct one thing in the build: our 'active customer' suppression has to exclude anyone in an active winback flow, or Play 2 and Play 3 fight each other.")* — folded into Play 3 below.

<!-- =============================================================================
     — — — — — — — — — — — —  FOLD  — — — — — — — — — — — —
     BUILD SPEC  (below the fold — technical-team-facing)
============================================================================= -->

## Build Spec

*For the eng team / technical marketer standing up v1. Every play below is specified against the
fixed GTM-Brain skeleton (evidence → identity → fact/decision + OODA+L loop). See
`gtm-brain-skeleton.md` for the model; `category-map.md` for the capability vocabulary.*

### System overview

- **Brain purpose (technical restatement):** a stateful customer-economics decision system. It maintains a resolved, per-customer fact set — predicted and realized LTV, lapse stage, RFM segment, margin tier, audience membership — and applies decision policies that drive three plays: VIP tiering + routing, margin-protected winback, and paid-audience seed/suppression sync. The entity is always the **customer** (never a B2B account); the loop closes on realized purchase and margin outcomes.
- **The fixed skeleton, instantiated for Wren & Slate:**
  - *Evidence layer:* Shopify orders + catalog (order value, item/category mix, discount codes, timestamps, guest-vs-account); Klaviyo engagement (email/SMS opens, clicks, list membership, flow history); Segment behavioral (anonymous + known browse, product views, add-to-cart); Triple Whale (first/last-touch attribution, channel CAC, blended MER); Gorgias (ticket volume, CSAT, contact reasons). No third-party enrichment — the behavioral history *is* the enrichment.
  - *Identity layer:* resolve one **customer** across Shopify `customer_id` + email(s), Klaviyo profile (email + phone), and Segment `anonymous_id → user_id`. Must stitch: multiple emails to one person, guest-checkout orders back to a known customer, and anonymous browse to a known customer on login/order. Segment is the identity graph of record; Shopify `customer_id` is the canonical key facts are written against. **Identity precision is where every LTV/lapse score is won or lost** — a mis-merge produces a confidently wrong VIP tier or winback.
  - *Fact/Decision layer:* the core facts are `predicted_ltv`, `realized_ltv_90d`, `vip_tier`, `days_since_last_order`, `median_interpurchase_interval`, `lapse_risk`, `engagement_decay`, `rfm_segment`, `margin_tier`, `winback_offer_depth`, and the Play-3 `segment_membership` tags. Each is typed, sourced to the evidence + resolved customer, and dated. Decision policies are explicit `IF/THEN` rules over these facts (below).
  - *Loop:* **hybrid cadence.** Play 1 is **event-triggered** (Shopify `orders/create` webhook → compute on new/early customers). Play 2 is a **nightly batch** (recompute cadence + lapse facts across the repeat base). Play 3 is a **scheduled sync** (nightly/weekly audience recompute + push to ad platforms). Learn runs as a rolling weekly recalibration job that compares predicted vs realized outcomes and adjusts thresholds.

### The tool stack (capability → named tool)

| Capability (`~~category`) | Wren & Slate's tool | Tier/notes | Confidence |
|---|---|---|---|
| `~~commerce/orders` | **Shopify Plus** | System of record for customers/orders/catalog; owns customer **tags**; Admin API + `orders/create`, `customers/update` webhooks; Shopify Flow available | High |
| `~~email/SMS` | **Klaviyo** | Lifecycle flows + segments; profile **properties** are the write target for `vip_tier`, `lapse_risk`, `winback_offer_depth`; owns VIP-welcome + winback flows | High |
| `~~ads` | **Meta Ads** + **Google Ads** | Custom Audiences / Customer Match (email+phone hash), lookalike / similar audiences, value-based bidding; suppression via audience exclusions | High |
| `~~web/marketing analytics + attribution` | **Triple Whale** | Blended MER/ROAS, channel CAC, post-iOS first-party attribution, customer-journey; read source for `acquisition_channel`, `blended_mer`, `channel_cac` | High |
| `~~customer data platform` | **Segment** | Identity resolution (graph of record), computed traits + audiences, destination syncs to Klaviyo/Meta/Google | Medium — identity-graph + ad destinations half-configured |
| `~~conversation intelligence / support` | **Gorgias** | Priority routing by Shopify customer tag; CSAT + contact-reason signal; VIP concierge queue | High |
| `~~enrichment` | **Shopify order history + Klaviyo profiles** | First-party behavioral only; no external B2B/firmographic enrichment | High |

### Plays — the "how", one per play

#### Play: High-LTV identification + VIP routing

- **Capability contract**
  - *Inputs:* first order (value, item/category mix, discount code, full-price flag), `acquisition_channel`/campaign (Triple Whale), first-30-day engagement (Klaviyo opens/clicks + Segment browse), resolved `customer_id`.
  - *Outputs:* `predicted_ltv` (fact), `vip_tier` (fact) written to Shopify customer tag + Klaviyo profile property; a routing action (VIP welcome flow enrolled, Gorgias priority tag set, early-access segment membership).
  - *Trigger:* event — Shopify `orders/create` webhook (fires on first and each early order, re-scores through order 3).
- **Observe — evidence needed:** first-order value + item/category mix + discount code → from `~~commerce/orders` (Shopify); acquisition channel + campaign + first-order-was-full-price economics → from `~~web/marketing analytics + attribution` (Triple Whale); first-30-day email/SMS opens+clicks → from `~~email/SMS` (Klaviyo); first-session + first-30-day product views / add-to-carts → from `~~customer data platform` (Segment).
- **Orient — entity + resolution:** acts on the **customer**; must resolve guest-checkout first orders back to a single `customer_id`, merge duplicate emails, and attach any pre-purchase anonymous browse (Segment `anonymous_id → user_id`) so early-engagement facts aren't split across ghost profiles.
- **Decide — facts + policy:**
  - Facts consumed:
    - `predicted_ltv = number ($, 24-month) · from first-order + acquisition + early-engagement model on customer · as of 2026-07-21 · confidence med` *(v1 heuristic; upgrades to a fitted model — see build notes)*
    - `first_order_full_price = boolean · from Shopify order + discount codes on customer · as of 2026-07-21 · confidence high`
    - `acquisition_channel = enum{meta_prospecting, meta_retargeting, google_nonbrand, google_brand, organic, referral, email} · from Triple Whale on customer · as of 2026-07-21 · confidence med` *(post-iOS attribution — see gaps)*
    - `early_engagement_score = number(0–100) · from Klaviyo opens/clicks + Segment browse, first 30 days · as of 2026-07-21 · confidence med`
    - `category_affinity = enum{home, apparel, mixed} · from Shopify item mix on customer · as of 2026-07-21 · confidence high`
    - `vip_tier = enum{none, silver, gold, concierge} · derived from predicted_ltv percentile + full_price + affinity · as of 2026-07-21 · confidence med`
  - Reference distribution (24-mo `predicted_ltv`, from historical base): median ~$180, P75 ~$320, P90 ~$520, P95 ~$720.
  - Decision policy:
    - `IF predicted_ltv ≥ P95 ($720) THEN vip_tier = concierge` → named CX owner, hand-written note, first look at drops.
    - `IF predicted_ltv ≥ P90 ($520) AND first_order_full_price THEN vip_tier = gold` → VIP welcome flow + early access + Gorgias priority.
    - `IF predicted_ltv in [P75,P90) OR (predicted_ltv ≥ P90 AND NOT first_order_full_price) THEN vip_tier = silver` → priority support, early-access list, no concierge.
    - `IF category_affinity = mixed THEN bump one tier` (crossover buyers are the best cohort per profile).
    - `ELSE vip_tier = none` → standard flows.
- **Act — the action:** write `vip_tier` to the Shopify customer **tag** (`vip:gold`) and the Klaviyo profile **property**; tag drives Gorgias priority routing; property enrolls the customer in the Klaviyo VIP-welcome flow and the early-access segment. Concierge tier also opens a Gorgias task for the CX owner.
- **Learn — outcome + feedback:** outcome signal = actual 2nd/3rd purchase within 90/180 days and `realized_ltv_90d` vs `predicted_ltv`. Feeds back into the predicted-LTV model thresholds and the percentile cut-points (weekly recalibration); systematically wrong tiers (e.g. many "gold" who never repeat) tighten the policy. `realized_ltv_90d` also becomes the seed signal for Play 3.
- **Build notes for v1:** compute in **Segment** as a computed trait, or in a lightweight warehouse job if one exists; **v1 `predicted_ltv` is a transparent heuristic** — a weighted score over first-order value, `first_order_full_price`, `acquisition_channel` (prospecting-full-price > retargeting-discount), and `early_engagement_score` — banded to tiers by the percentiles above. Do **not** block v1 on an ML model; ship the heuristic, log predicted-vs-realized, fit a model once there's labeled data. Wire: Shopify `orders/create` webhook → Segment trait recompute → sync trait to Klaviyo profile property (native Klaviyo destination) and write the Shopify tag (Admin API or Shopify Flow). Build order: identity resolution first (nothing works without it), then the heuristic + tag/property writes, then the Klaviyo flow + Gorgias routing.

#### Play: Lapse detection + winback (margin-protected)

- **Capability contract**
  - *Inputs:* full order history (timestamps, values, discounts) per resolved customer, engagement trend (Klaviyo), `margin_tier` proxy, `rfm_segment`.
  - *Outputs:* `lapse_risk` + `winback_offer_depth` (facts) written to Klaviyo profile property; action = enroll in the correctly-tiered Klaviyo winback flow (or suppress).
  - *Trigger:* schedule — nightly batch recompute over all customers with ≥2 orders.
- **Observe — evidence needed:** order timestamps + values + discount codes → from `~~commerce/orders` (Shopify); 30/60/90-day email+SMS open/click trend → from `~~email/SMS` (Klaviyo); site-return / browse-without-buy → from `~~customer data platform` (Segment); discount-dependence as a margin proxy → from Shopify order history. *(True product-level margin is a flagged data gap — see completeness pass.)*
- **Orient — entity + resolution:** acts on the **repeat customer**; must resolve the full order set to one `customer_id` (guest + account orders merged) so `median_interpurchase_interval` reflects the real rhythm, and attach engagement from the correct Klaviyo profile.
- **Decide — facts + policy:**
  - Facts consumed:
    - `days_since_last_order = number(days) · from Shopify on customer · as of 2026-07-21 · confidence high`
    - `median_interpurchase_interval = number(days) · from Shopify order history on customer · as of 2026-07-21 · confidence high` *(base median ~95d; apparel-affinity ~70d, home-affinity ~120d)*
    - `lapse_risk = enum{none, early, lapsing, lapsed, churned} · derived from days_since_last_order ÷ median_interpurchase_interval · as of 2026-07-21 · confidence high`
      - none <1.0×, early 1.0–1.5×, lapsing 1.5–2.0×, lapsed 2.0–3.0×, churned >3.0×.
    - `engagement_decay = enum{stable, declining, dark} · from Klaviyo 30/60/90-day open+click trend · as of 2026-07-21 · confidence med`
    - `margin_tier = enum{high, mid, low} · from historical discount-dependence on customer · as of 2026-07-21 · confidence low` *(proxy only — see gap)*
    - `rfm_segment = enum{champion, loyal, potential_loyalist, at_risk, hibernating, cant_lose, lost} · from Shopify RFM on customer · as of 2026-07-21 · confidence high`
  - Decision policy (offer depth is capped by `margin_tier` — the margin decision is the point of the play):
    - `IF lapse_risk = lapsing AND engagement_decay = stable THEN winback_offer_depth = soft` (free shipping / early access, **no discount** — still engaged, protect margin).
    - `IF lapse_risk = lapsed AND engagement_decay = declining AND margin_tier IN {high, mid} THEN winback_offer_depth = 15pct`.
    - `IF lapse_risk = lapsed AND margin_tier = low THEN winback_offer_depth = 10pct` (cap deep offers on thin-margin customers).
    - `IF lapse_risk = churned AND engagement_decay = dark AND margin_tier = low THEN suppress` (do not spend discount or paid retargeting — hand to Play 3 as `churned_unprofitable`).
    - `IF lapse_risk = churned AND rfm_segment = cant_lose THEN winback_offer_depth = 20pct` (the only path to the deepest offer — historically high-value, now dark).
    - `IF lapse_risk IN {none, early} THEN no action`.
  - Guardrail: never issue an offer deeper than `margin_tier` allows; `soft` is always the default when engagement is `stable`.
- **Act — the action:** write `lapse_risk` + `winback_offer_depth` to the Klaviyo profile property; the property enrolls the customer in the matching Klaviyo winback flow (soft / 10 / 15 / 20), SMS-first if the customer is email-`dark` but SMS-opted-in. `suppress` writes a `winback:suppress` tag (consumed by Play 3). Include a **holdout**: hold back ~10% of eligible customers per tier (no winback) to measure incremental reactivation and margin.
- **Learn — outcome + feedback:** outcome signal = reactivation (order within 30 days of winback) **and realized margin on the winback order** vs the holdout. Feeds back into offer-depth policy per `rfm_segment`/`margin_tier` (if `soft` reactivates as well as `15pct`, stop discounting that band) and into the lapse thresholds (if `lapsing` reactivates on its own, widen the wait before spending).
- **Build notes for v1:** nightly batch in **Segment** (computed traits) or a warehouse job; RFM + cadence facts are deterministic SQL/trait logic — no model needed. Wire: batch recompute → Klaviyo profile properties (native destination) → Klaviyo flows keyed on the property. **The offer-depth policy is only as good as `margin_tier`, which is a proxy in v1** (discount-dependence, not real COGS) — ship it, but flag it and plan to replace with a product-level margin feed (see gaps). Build order: cadence + RFM facts first, then the soft/discount tiering, then the holdout instrumentation.

#### Play: Paid-acquisition audience feedback loop

- **Capability contract**
  - *Inputs:* per-customer LTV facts (`predicted_ltv`, `realized_ltv_90d`) from Play 1, active/lapsed/churned status from Play 2, `blended_mer` + `channel_cac` from Triple Whale.
  - *Outputs:* `segment_membership` tags (fact) per customer, synced as Meta Custom Audiences + Google Customer Match lists (seed + suppression); lookalike/similar audiences built on the seed; value-based bidding fed by LTV.
  - *Trigger:* schedule — nightly/weekly segment recompute + push to ad platforms.
- **Observe — evidence needed:** LTV deciles → from Play 1 facts (`predicted_ltv`, `realized_ltv_90d`); active-customer + churned-unprofitable status → from Play 2 facts (`lapse_risk`, `winback:suppress` tag); blended MER + new-customer CAC by channel → from `~~web/marketing analytics + attribution` (Triple Whale).
- **Orient — entity + resolution:** acts on **customer segments** (aggregates) for seeding, and on the **individual customer** (hashed email + phone) for audience matching/suppression. Must resolve one identity per person to avoid double-counting across Meta and Google, and to ensure a customer in an **active winback flow is excluded from "active-customer" suppression** (the operator's Phase-2 correction — Play 2 and Play 3 must not fight: a `lapsed`/`lapsing` customer in a winback belongs in `lapsed_winback_target`, never `active_customer_suppress`).
- **Decide — facts + policy:**
  - Facts consumed:
    - `realized_ltv_90d = number($) · from Shopify orders on customer · as of 2026-07-21 · confidence high`
    - `ltv_decile = enum{1..10} · derived from predicted+realized LTV on customer · as of 2026-07-21 · confidence med`
    - `customer_status = enum{active, lapsing, lapsed, churned_unprofitable} · from Play 2 facts on customer · as of 2026-07-21 · confidence high`
    - `segment_membership = enum-set{high_ltv_seed, active_customer_suppress, lapsed_winback_target, churned_unprofitable_suppress} · derived on customer · as of 2026-07-21 · confidence high`
    - `blended_mer = number · from Triple Whale (account-level) · as of 2026-07-21 · confidence med`
    - `channel_cac = number($) · from Triple Whale per channel · as of 2026-07-21 · confidence med`
  - Decision policy:
    - `IF ltv_decile ≥ 9 (top 20%) THEN segment_membership += high_ltv_seed` → source for Meta lookalike + Google similar audiences (value-based).
    - `IF customer_status = active AND NOT in active winback flow THEN segment_membership += active_customer_suppress` → excluded from **prospecting** campaigns (stop paying to reacquire).
    - `IF customer_status IN {lapsing, lapsed} THEN segment_membership += lapsed_winback_target` → dedicated retargeting audience (paired with Play 2's flow), **overrides** active suppression.
    - `IF customer_status = churned_unprofitable (winback:suppress) THEN segment_membership += churned_unprofitable_suppress` → excluded from **retargeting** (stop wasting spend).
    - Value-based bidding: pass `predicted_ltv`/`realized_ltv_90d` as the conversion value so Meta/Google optimize toward high-LTV, not just first-purchase.
- **Act — the action:** sync `segment_membership` to **Meta Custom Audiences** and **Google Customer Match** (hashed email + phone) via the CDP audience destinations; build lookalike (Meta) / similar (Google) audiences on `high_ltv_seed`; apply `*_suppress` lists as campaign exclusions; feed conversion value via the server-side path (see gap). Replaces the hand-built monthly spreadsheet.
- **Learn — outcome + feedback:** outcome signal = blended MER / ROAS trend, new-customer **LTV:CAC by channel**, and the realized LTV of lookalike-sourced cohorts vs baseline. Feeds back into the seed definition (which LTV decile produces the best lookalikes — maybe top 10% beats top 20%) and the suppression thresholds (measure the MER lift from suppressing active customers).
- **Build notes for v1:** compute `segment_membership` in **Segment** off Play 1 + Play 2 facts; push via Segment's native Meta + Google audience destinations on a schedule; build lookalikes in-platform on the synced seed. **Start manual-parity:** reproduce the current monthly spreadsheet's seed/suppress logic as an automated nightly sync first (immediate win, low risk), then layer value-based bidding. The **exact Segment→Meta/Google audience-sync mechanism and the server-side Conversions API (Meta CAPI / Google Enhanced Conversions) value-based path are flagged** — see gaps. Build order: seed + suppression sync first (parity with today, automated), then value-based bidding once CAPI is confirmed.

### Completeness pass — gaps (flag, never omit)

**Data gaps** — a chosen play needs evidence the org has not described:
- ⚠️ **Play 2 needs product-level margin/COGS, but Wren & Slate described no source for it.** `margin_tier` is a v1 *proxy* (discount-dependence from Shopify order history), not real margin — so the offer-depth cap, which is the entire point of the play, rests on an approximation. Required: a product-level COGS feed (from an ERP/inventory system, a Shopify metafield per SKU, or a finance export) joined to line items, so `margin_after_offer` can be computed per customer and the discount cap becomes true-margin-based rather than discount-history-based. Ship v1 on the proxy; prioritize this feed for v2.
- ⚠️ **`acquisition_channel` is attribution-incomplete post-iOS (affects Plays 1 & 3).** Triple Whale mitigates with first-party + statistical attribution, but a share of first orders will have an unresolved or modeled channel, weakening `predicted_ltv` (Play 1) and value-based bidding accuracy (Play 3). Treat `acquisition_channel` as `confidence med`; don't let a single channel signal dominate the LTV heuristic. Consider server-side event capture to raise attribution coverage (ties to the CAPI item below).

**Integration-knowledge gaps** — a named tool whose how-to the interviewer cannot credibly specify:
- ⚠️ **`~~customer data platform` → Segment: the identity-graph config and the ad-platform audience-sync destinations are half-configured (operator-stated).** The concrete path — how Segment merges `anonymous_id → user_id`, resolves guest-checkout orders to a `customer_id`, and pushes computed audiences to Meta Custom Audiences + Google Customer Match — is not specified here. Builder should confirm: the Segment identity-resolution ruleset (merge keys, external IDs), whether the Meta/Google **audience destinations** are the native Segment integrations or require a reverse-ETL/tool in between, and the sync cadence/limits. *(Flagged rather than hand-waved: identity resolution is the layer every LTV/lapse score depends on — if Segment's graph is wrong, so is every fact.)*
- ⚠️ **`~~ads` → Meta/Google server-side value-based bidding (CAPI / Enhanced Conversions) is named but not specified.** Passing `predicted_ltv`/`realized_ltv_90d` as a conversion value for value-based optimization requires a server-side conversion path (Meta Conversions API, Google Enhanced Conversions for Leads/Web) — the exact event schema, value mapping, and who sends the server-side events (Shopify's native CAPI, Triple Whale, or a custom function) is a builder decision. Builder should confirm the server-side event source and the LTV→conversion-value mapping. v1 can ship seed/suppression audiences *without* value-based bidding (parity with today's spreadsheet) and add this second.

### Sequencing recommendation

Build **Play 1 (High-LTV identification + VIP routing) first** — it's the operator's top priority, its evidence and tools are all in place, and it produces the LTV facts the other two plays consume, so nothing downstream is real until it exists. But the true first task cuts across all three: **stand up Segment identity resolution** (the flagged gap), because a mis-resolved customer poisons every score — treat it as Play 1's foundation, not a separate project. Then **Play 2 (lapse + winback)** on the same customer facts, shipping v1 on the `margin_tier` proxy while the product-margin feed is sourced. Then **Play 3 (audience loop)** last, since it depends on Play 1's LTV scores and Play 2's status facts — and ship it in two steps: automated seed/suppression sync at parity with today's spreadsheet first, then value-based bidding once the CAPI path is confirmed.
