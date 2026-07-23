# GTM Brain — Reference Architecture Template: Ecommerce Variant
### A buildable blueprint for a self-learning growth decision system at a mid-market ecommerce company

> **How to use this document.** This is a *template*, not a finished design — adapted for a mid-market ecommerce/DTC company (roughly `{{$20M–$300M GMV}}`, `{{100K–5M+ customer records}}`, an ecommerce platform + ESP + ad accounts, a small growth/data team). Substitute every `{{PLACEHOLDER}}`. In ecommerce, "GTM" means the **growth engine**: acquisition, conversion, retention, and lifetime value. The Brain decides — *per customer, per day* — which message, offer, and channel (including **none**) maximizes long-term margin, executes through agents, and gets smarter from every outcome, while your commerce platform stays the system of record for orders.

> **What's different from the SaaS variant.** (1) **Scale inverts:** millions of mostly-anonymous individuals instead of thousands of named accounts — identity is cross-device/cookie/email stitching, not account-based de-anonymization; (2) the unit of decision is the **customer × offer × channel × moment**, made millions of times, so the policy layer is fully algorithmic from day one; (3) **margin and inventory are hard constraints** — a discount to someone who would have bought anyway is negative-margin noise, and promoting an out-of-stock hero SKU is self-harm; (4) the ground truth discipline is **incrementality** (holdouts, geo tests), because last-click attribution lies; (5) consumer privacy law (GDPR/CCPA/**TCPA for SMS**) and frequency governance are existential, not hygienic.

---

## 0. Document control

| Field | Value |
|---|---|
| Owner | `{{Head of Growth / Retention lead / Data lead}}` |
| Sponsor | `{{CMO / VP Growth / CEO}}` |
| Version | `v0.2-EC (template)` — see Appendix D changelog |
| Status | Draft |
| Review cadence | Quarterly, or on major stack change |
| Related docs | Segmentation strategy, promo/margin policy, consent & preference policy, experimentation standards, creative guidelines |

---

## 1. First principles

1. **Own the decision, not just the data.** Your ESP knows "sent, opened, clicked." It doesn't know *why* this customer got 20% off (would 10% have converted them? would $0 have?), which win-back precedent justified the send, or that the same customer was suppressed from ads that week. The Brain stores the **event clock** — the reasoning behind every offer and suppression — and that trace compounds into proprietary growth intelligence.
2. **Two clocks.** The **State Clock** (orders, LTV-to-date, subscription status) lives in the platform and warehouse. The **Event Clock** — the sequence of exposures, offers, holdouts, and reasons — barely exists. The Brain adds it.
3. **Context graph over RAG.** Ecommerce context is **resolved customer identities, product/affinity relationships, and time-bounded behavioral facts** ("entered replenishment window on 6/12"; "discount-conditioned since Q4") — not document chunks. *(A semantic index over reviews and support tickets has a supporting role — voice-of-customer grounding for creative — but it serves the graph.)*
4. **Pre-compute, store, serve.** Per-customer state (segment, propensities, next-best-offer, fatigue budget) is computed *ahead of time* so that site personalization, triggered sends, and ad-audience syncs read ready state in milliseconds. At millions of customers, inference-time context assembly isn't just slow — it's economically impossible.
5. **Separation of concerns.** **Models compute** (CLV, churn/purchase propensity, discount sensitivity, affinity, timing — deterministic). **LLMs narrate** (copy variants, campaign briefs, review-mining summaries, merchandiser explanations). **Summary stores remember** ("segment K behaves like last year's post-holiday lapsed cohort; win-back at 10% worked, 20% was margin burn").
6. **Precision compounds — and margin is the casualty.** A five-step pipeline (identity → segment → propensity → offer → send) at 80% each is ~33% right end-to-end; at ecommerce scale that's millions of wrong-offer sends. Wrongness here means: discounting sure-buyers, promoting stockouts, messaging opted-out numbers (TCPA liability), or misidentifying the household gift-buyer as a lapsed customer. Every primitive clears its bar independently before composition.
7. **Incrementality or it didn't happen.** Every automated program carries a **persistent holdout**. The learning loop's ground truth is *lift over control*, never last-click revenue. A Brain trained on attribution myths learns to take credit, not to create value.
8. **Frequency is a budget, not a byproduct.** Attention is the scarce resource. The policy layer allocates each customer's contact budget across email/SMS/push/ads globally — and **"send nothing"** is very often the margin-maximizing action.

---

## 2. Reference architecture at a glance

The system is a closed **OODA+L** loop: **Observe → Orient → Decide → Act → Learn.**

```
                            ┌───────────────────────────────────────────────┐
                            │              HUMAN STRATEGY LAYER               │
                            │  Margin floors, promo calendar, brand rules,    │
                            │  frequency caps, consent policy, experiment     │
                            │  standards, kill-switches, approval queue       │
                            └───────────────┬───────────────────────────────┘
                                            │ steer / approve / override
   OBSERVE            ORIENT                ▼            DECIDE           ACT
┌──────────┐   ┌──────────────────────────────────┐  ┌───────────┐  ┌──────────────┐
│ Sources  │   │  Consumer Identity Resolution     │  │  Policy / │  │  Agent        │
│ web/app  │──▶│  (cross-device, email/phone,      │  │  Decision │─▶│  Execution    │
│ events,  │   │   household, consent-aware)       │  │  Engine   │  │  Layer        │
│ commerce │   │           ▼                       │  │           │  │ (lifecycle    │
│ platform,│   │  Context Graph (3 layers)         │  │ per-cust  │  │  email/SMS,   │
│ ESP/SMS, │   │   • Content (evidence, immutable) │  │ offer ×   │  │  audience     │
│ ads,     │   │   • Entity (customers, products,  │  │ channel × │  │  sync, onsite │
│ reviews, │   │     households, cohorts)          │  │ timing ×  │  │  personalize, │
│ support, │   │   • Fact (temporal assertions)    │  │ discount  │  │  offer, promo │
│ loyalty, │   │           ▼                       │  │ depth —   │  │  brief, review│
│ inventory│   │  Feature & Signal Computation     │  │ under     │  │  mining)      │
│ & margin │   │  (RFM, velocity, replenishment)   │  │ margin,   │  └──────┬───────┘
└────┬─────┘   │           ▼                       │  │ inventory,│         │ execute
     │         │  Model Layer (deterministic:      │  │ frequency,│         ▼
     │ STREAM  │   CLV, churn, purchase timing,    │  │ consent   │  ESP / SMS / ads /
     ▼         │   discount sensitivity, affinity) │  │ budgets;  │  onsite / app push
┌──────────┐   │           ▼                       │  │ incl. "do │         │
│ Ingestion│──▶│  Summary / Primitive Stores       │  │ nothing") │         │
│ & Stream │   │  (customer-state, offer, affinity,│  └─────▲─────┘         │
│ (CDP/bus)│   │   inventory, outcome/precedent)   │────────┘               │
└──────────┘   └──────────────────────────────────┘  ranked actions        │
     ▲                         LEARN                                        │
     └──────────────────────────────────────────────────────────────────────
        Holdout-measured outcomes → decision traces → incrementality &
        backtesting → model retraining → policy updates → consent/quality loops
```

**Cross-cutting spines:** Observability & lineage · Data quality / ground-truth · **Consent, privacy & frequency governance** · Orchestration & jobs. *(Note: unlike the SaaS/services variants, the real-time streaming path is genuinely P0 here — onsite personalization and abandonment triggers live or die on it.)*

---

## 3. Layer-by-layer specification

Each layer: **Purpose → What it must do → Build/Buy → Precision bar / SLO → Failure modes.**

### Layer 0 — Sources: the growth surface (OBSERVE)

| Category | Example sources | Signal type | Priority |
|---|---|---|---|
| Web/app behavioral | `{{GA4 / Snowplow / Segment / app SDK}}` | Views, carts, searches, sessions, device IDs | **P0** |
| Commerce platform | `{{Shopify / BigCommerce / Salesforce CC / custom}}` | Orders, refunds, subscriptions, customers | **P0** |
| ESP / SMS / push | `{{Klaviyo / Braze / Attentive / Iterable}}` | Sends, opens, clicks, conversions, **opt-outs** | **P0** |
| Ads platforms | `{{Meta / Google / TikTok / affiliates}}` | Spend, impressions, audiences, conversions | P0 |
| **Inventory & margin** | `{{ERP / OMS / PIM}}` | Stock levels, landed cost, contribution margin per SKU | **P0 — the constraint layer** |
| Reviews & UGC | `{{Yotpo / Okendo / marketplace reviews}}` | Sentiment, product issues, voice of customer | P1 |
| Support | `{{Gorgias / Zendesk}}` | Tickets, WISMO, complaints, churn signals | P1 |
| Loyalty/referral | `{{Smile / Yotpo / referral platform}}` | Points, tiers, advocacy | P1 |
| Payments/fraud | `{{Stripe / Signifyd}}` | Payment health, fraud flags, chargebacks | P1 |
| Retail/POS (if omnichannel) | `{{POS system}}` | In-store purchases for identity stitching | P2 |
| Consent & preferences | Preference center, CMP | **Lawful-basis state per channel** | **P0** |

**Build/Buy.** *Buy* connectors and event collection (CDP). *Build* only custom event schemas.

**Precision bar.** Every event: `source`, `event_type`, `occurred_at` (event time), device/customer identifier, and — for messaging events — consent state at time of event.

**Failure modes.** Inventory/margin not connected (the Brain optimizes revenue while destroying contribution); opt-outs syncing on a lag (TCPA exposure); server-side vs client-side event drift double-counting conversions.

---

### Layer 1 — Ingestion & streaming (OBSERVE)

**Purpose.** Two-speed ingestion where the real-time path is *first-class*: onsite personalization, cart/browse abandonment, and back-in-stock triggers need seconds; CLV modeling and cohort features can run in batch.

**What it must do.** Streaming events (web/app, cart) with P95 `{{< 2s}}` to available state; batch/CDC for platform, ads, ERP; event-time preserved; idempotency (dedupe client+server events); immutable raw landing zone; **consent state joined at ingest** so no downstream consumer can accidentally use non-consented data.

**Reference stack.** CDP `{{Segment/RudderStack}}` → warehouse `{{Snowflake/BigQuery}}` + real-time path `{{CDP destinations / Kafka-Redpanda if volume demands}}` → `{{dbt}}` → `{{Dagster/Temporal}}`. Reverse-ETL `{{Hightouch/Census}}` for activation syncs.

**SLO.** Behavioral events P95 `{{< 2s}}`; opt-out propagation to *all* channels `{{< 5 min}}` (this SLO is a legal control, not a preference); batch freshness `{{< 1h}}` for orders, `{{< 4h}}` for ads/margin.

**Failure modes.** Batch-only abandonment triggers (the moment passed); opt-out lag; treating ad-platform "conversions" as ground truth (they're claims, not facts — see §Layer 9).

---

### Layer 2 — Consumer identity resolution (ORIENT — the hard primitive at scale)

**Purpose.** Resolve millions of anonymous and known fragments — cookies, device IDs, emails, phone numbers, POS records — into canonical **customers** (and, where it matters, **households**), consent-aware and confidence-tiered.

**What it must do.**
- Deterministic stitching first (login, email click-through, order email), probabilistic second (device graphs, address matching) — with **calibrated confidence** and reversible merges.
- **Household modeling** where the catalog warrants it (`{{gifting, kids, shared subscriptions}}`) — the "lapsed customer" may be a gift-buyer who was never the end user.
- Anonymous-to-known **journey backfill**: when a visitor identifies, their prior anonymous history attaches (within consent policy).
- **Consent-aware by construction:** every identity carries per-channel lawful-basis state; suppression and erasure (GDPR Art. 17) execute across the *whole* graph, not one tool.
- Survive cookie decay: first-party ID strategy (`{{server-side collection, durable first-party cookies, logged-in incentives}}`).

**Build/Buy.** CDP identity resolution (*Buy*) covers most mid-market needs; *Build* a canonical customer table + household logic in the warehouse on top ("composable CDP" pattern). Identity vendors/data clean rooms only if omnichannel or marketplace complexity demands.

**Precision bar / SLO.** Deterministic tier for messaging: `{{≥ 99.5%}}` (a wrong-person SMS is a legal event, not just an annoyance). Probabilistic tier: usable for modeling/audiences, **never** for 1:1 messaging. Merge reversibility 100%; erasure requests completed `{{< 30d}}` across all stores.

**Failure modes.** Over-merging (two roommates become one "customer" with incoherent history); probabilistic IDs leaking into SMS sends; erasure that misses the graph copies; identity quality silently degrading as third-party cookies die.

---

### Layer 3 — The Context Graph (ORIENT — the core)

#### 3a. Content layer — *Evidence* (immutable)
Raw behavioral events, order records, message sends/receipts, ad exposures (where available), reviews, support transcripts, consent change records. Append-only; replayable. Store: `{{object storage + warehouse}}`.

#### 3b. Entity layer — *Identity* (resolved)
**Customers, households, products, categories, cohorts/segments, campaigns/offers, channels.** Product relationships are first-class: `substitutes`, `complements`, `replenishment_cycle`, `margin_band`, `size/fit profile`. Store: warehouse-native graph tables (a dedicated graph DB is usually unnecessary at this shape — relationships are shallow and regular).

#### 3c. Fact layer — *Assertions* (temporal, bi-temporal)
Time-bounded, sourced assertions — the customer event clock:

> *"Customer entered the `{{45-day}}` replenishment window for `{{SKU-114}}` on 6/12 (basis: 3 prior cycles); discount-conditioned since `{{Q4 promo}}` (fact valid_from 11/28); SMS consent granted 3/2, revoked 7/1; held out of `{{summer win-back}}` (control group)."*

Every fact: `subject_entity_id`, `predicate`, `value`, `valid_from/valid_to`, `knowledge_time`, `status`, `confidence`, `source_content_ids[]`. **Bi-temporal**, so you can reconstruct "what did we know when we chose this offer?" — the precondition for honest incrementality analysis and backtesting.

**Ecommerce predicates to model early:** `lifecycle_stage`, `replenishment_window`, `discount_sensitivity_band`, `channel_preference`, `consent_state(channel)`, `fatigue_budget_remaining`, `holdout_membership`, `predicted_next_purchase`, `at_risk`, `vip_tier`, `gift_buyer`, `size_fit_issue`.

**Failure modes.** Mutable facts (you lose the event clock); holdout membership not recorded as a fact (contaminated experiments forever); consent modeled in the ESP instead of the graph (channel-by-channel drift).

---

### Layer 4 — Feature & signal computation (ORIENT)

**Starter feature set:**
- **RFM + velocity:** recency/frequency/monetary and their trends.
- **Replenishment timing:** per customer × consumable SKU, from purchase-cycle history.
- **Engagement fatigue:** touches per channel per window vs. budget; unsubscribe-risk proxy.
- **Discount exposure history:** depth/frequency of discounts redeemed (feeds sensitivity modeling and *conditioning* detection).
- **Affinity vectors:** category/product propensities from behavior + purchases.
- **Session intent:** live-session features for onsite decisions (real-time path).
- **Inventory context:** stock cover and margin band per candidate SKU (join at decision time).

**Build/Buy.** *Build* in `{{dbt}}` + a real-time feature path for session/trigger features (`{{streaming transforms or CDP computed traits}}`) + serving cache. Enforce point-in-time correctness and train/serve parity — at this scale, silent skew is a revenue leak, not a rounding error.

**SLO.** Real-time features `{{< 2s}}`; daily features by `{{05:00 local}}` (before the day's sends are decided).

---

### Layer 5 — Model layer (ORIENT — deterministic compute)

| Model | Output | Notes |
|---|---|---|
| **CLV (predictive)** | Expected `{{24m}}` contribution margin per customer | The currency everything optimizes; margin-based, not revenue-based |
| **Churn / lapse propensity** | P(no purchase in next `{{90d}}` \| state) | Calibrated; drives win-back eligibility |
| **Purchase-timing / replenishment** | Next-purchase window per customer × category | Powers "right moment" over "right now" |
| **Discount sensitivity / uplift** | *Incremental* effect of offer depth per customer — **uplift modeling, not response modeling** | The margin engine: separates persuadables from sure-things and lost causes |
| **Product affinity / recommendation** | Ranked SKUs per customer/session | Inventory- and margin-aware re-ranking |
| **Channel responsiveness** | Per-customer channel effectiveness | Allocates the contact budget |
| **Fraud/abuse risk** | Promo-abuse, serial-returner flags | Protects the offer engine |

**Build/Buy.** *Build* on your outcomes (`{{GBTs / BTYD-style CLV / uplift models}}`, `{{MLflow}}`). Recommendation can be *Buy* early (`{{platform-native / Nosto-style}}`) and replaced when the graph makes yours better. **Calibration and uplift validity over AUC** — the policy layer allocates real margin against these numbers.

**Precision bar.** Every prediction logged with features + version. Uplift models validated against randomized holdouts, not observational data (they're worthless otherwise).

---

### Layer 6 — Summary / primitive stores (ORIENT → serve)

**Purpose.** Pre-compute, store, serve — at consumer scale this is a **customer-state store** serving millions of small records in `{{< 50ms}}`, not 500-token prose. LLM-shaped summaries exist at the *cohort/campaign* level for the humans and copy agents.

| Store | Contents | Consumed by |
|---|---|---|
| **Customer State Store** | Compact per-customer record: lifecycle, propensities, next-best-offer, fatigue budget, consent, holdout flags | Every channel agent, onsite, triggers |
| **Offer/Eligibility Store** | Which offers each segment/customer may receive (margin floors, promo calendar, abuse flags) | Policy engine, lifecycle agents |
| **Affinity Store** | Customer × product/category propensities | Recs, merchandising, creative |
| **Inventory/Margin Store** | Stock cover, contribution margin, markdown state per SKU | Policy constraints, recs re-ranking |
| **Outcome/Precedent Store** | What each play earned *vs. holdout*, by segment ("Q4 lapsed win-back: 10% off = +$4.10 incr. margin/send; 20% = +$1.20") | Learning loop, planning agents |
| **Cohort Summary Store** | LLM-ready compactions per segment/campaign (~500 tokens) for briefs and copy grounding | Planning/copy agents, weekly readout |

Example per-customer state record (~300 bytes, not tokens):

```json
{"cust":"c_88213","stage":"at_risk","clv_p50":412,"churn_90d":0.61,
 "next_window":{"cat":"skincare","open":"2026-07-25"},"uplift_10off":0.11,"uplift_20off":0.12,
 "nbo":"replen_reminder_no_discount","channels":{"email":0.7,"sms":0.2},
 "fatigue":{"email_left":1,"sms_left":0},"consent":{"email":true,"sms":false},
 "holdouts":["winback_q3_control"],"flags":["gift_buyer_hh"]}
```

**SLO.** State store read P95 `{{< 50ms}}`; state refresh `{{< 2s}}` after a triggering event, `{{daily}}` otherwise.

**Failure modes.** Building prose summaries per customer (wrong tool at this scale — burn); state store drifting from the fact layer; recommendation agents bypassing the inventory join.

---

### Layer 7 — Policy / decision engine (DECIDE)

**Purpose.** For every customer, every day (and every session, in real time): choose **offer × channel × timing × discount depth — or nothing** — to maximize incremental long-term margin under hard constraints.

**Decision types:**
1. **Lifecycle sends** (welcome, browse/cart abandon, post-purchase, replenishment, win-back): send/suppress, which variant, which depth.
2. **Discount depth allocation:** uplift-model-driven — persuadables get the minimum effective offer; sure-things and lost causes get **none** (this single decision usually funds the program).
3. **Contact-budget allocation:** each customer's weekly touch budget spent on the highest-uplift channel/message; everything else suppressed.
4. **Audience sync decisions:** who enters/exits ad audiences (suppress recent purchasers and sure-things from prospecting/retargeting spend).
5. **Onsite decisions (real-time):** which module/offer/rec set this session.
6. **Do nothing / wait:** first-class and *frequent* — "replenishment window opens in 9 days; a send today is wasted or margin-negative."

**Hard constraints:** contribution-margin floors per offer; promo-calendar and brand rules (no discount on `{{hero line}}`, MAP compliance); **inventory availability** (never promote < `{{X}}` weeks cover; push overstock within brand rules); frequency caps per channel and global; **consent per channel (blocking)**; abuse/fraud flags; experiment integrity (**holdout membership is inviolable — no play may touch a control group**).

**Design pattern.** Rules + calibrated scores first; graduate to **contextual bandits / uplift-driven policies** *earlier than the B2B variants* — millions of decisions and fast feedback make learned policies statistically honest here, provided the backtest + holdout harness exists first.

**Precision bar.** 100% decisions traced (sampled trace detail at full volume, full traces for experiments); constraints evaluated pre-send with a blocking consent gate.

**Failure modes.** Revenue-optimizing without margin (the classic self-own); response models instead of uplift models (you discount people who were buying anyway and call it success); each channel tool enforcing its own frequency caps with no global budget (the customer gets email+SMS+push+retargeting in one day); touching the holdout.

---

### Layer 8 — Agent execution layer (ACT)

| Agent | Job | Autonomy default |
|---|---|---|
| Lifecycle Messaging Agent | Assemble + trigger email/SMS/push from customer state + eligible offers | Autonomous within guardrails (this is the volume engine) |
| Offer/Discount Agent | Set depth per uplift + margin floor | Autonomous within floors; new depths via experiment only |
| Audience Sync Agent | Push suppression/inclusion lists to ad platforms | Autonomous |
| Onsite Personalization Agent | Session-time module/rec/offer selection | Autonomous (real-time path) |
| Recommendation Agent | Margin- and inventory-aware rec re-ranking | Autonomous |
| Copy/Creative Agent | Variant generation grounded in cohort summaries + voice-of-customer (reviews) + brand guide | Assisted → autonomous per template class after QA precision proven |
| Campaign Planning Agent | Draft promo/campaign briefs from precedent store ("last 3 win-backs by segment: incr. margin…") | Assisted |
| Review-Mining Agent | Surface product issues/themes from reviews & support | Autonomous (read-only) |
| Win-back/At-risk Agent | Orchestrate at-risk interventions | Autonomous within guardrails |

**Guardrails (mandatory).** Consent + frequency + margin + inventory checks **pre-send, blocking**; holdout exclusion enforced at the execution layer (defense in depth, not just policy); per-agent + global kill-switch; **deliverability infrastructure** — warmed domains/IPs, engagement-based sending, spam-rate circuit-breaker (`{{> 0.1%}}` pauses the program; at ecommerce volumes Gmail/Yahoo bulk-sender rules are existential); creative agents constrained to approved claims (no invented product claims — a compliance issue, not just a quality one); price/offer copy rendered from the offer store, never generated (an LLM must not "write" a discount into existence).

**Failure modes.** LLM-generated pricing/claims; a template bug at 2M-send scale (canary sends + progressive rollout are mandatory); audience syncs leaking suppressed segments to ad platforms; agent volume outrunning deliverability warmup.

---

### Layer 9 — Learning loop (LEARN)

**Purpose.** Turn every outcome into model/policy improvement — with **incrementality as the only accepted ground truth.**

- **Persistent holdouts:** every always-on program keeps a `{{5–10%}}` control; membership recorded as facts; reported metric = *lift over control* in contribution margin.
- **Experiment platform:** A/B and bandit tests with pre-registered metrics, minimum runtimes, and interference controls; geo-holdouts / MMM-lite for channel-level incrementality where user-level control is impossible (ads).
- **Outcome capture:** conversions joined to decisions via decision_id where possible; ad-platform-claimed conversions treated as *claims*, reconciled against internal ground truth.
- **Decision-trace store:** at volume, full traces for all experimental cells + sampled traces for steady-state; every trace links state → policy → action → holdout-adjusted outcome.
- **Backtesting:** point-in-time replay of candidate policies over historical state (no look-ahead) before any live traffic.
- **Retraining & promotion:** scheduled retrains; promote only on backtest + live experiment win; automatic rollback on guardrail-metric regression (unsubscribe rate, spam rate, margin).
- **Data-quality loops:** bounces, opt-outs, "not my order" support tickets, and return reasons feed identity + model correction.

**Precision bar.** No policy/model promotion without a controlled experiment. Holdout contamination = incident, not oops.

---

### Layer 10 — Human Strategy Layer (STEER)

**What leaders control:** margin floors + discount ladder; promo calendar + brand/MAP rules; frequency-cap policy; consent posture; experiment standards; play approval/retirement; autonomy levels; kill-switches.

**The three cadences:**
- **Daily (growth/retention team):** "Yesterday: `{{412K}}` decisions, `{{61%}}` were *suppress/do-nothing*. Replenishment program +`{{$18K}}` incr. margin vs. control. Spam-rate on `{{domain B}}` trending up — sends throttled automatically. `{{SKU-114}}` cover fell below 3 weeks — removed from promotion."
- **Weekly (growth leadership):** program-level incrementality league table (margin per send vs. control), discount-depth efficiency, fatigue/deliverability health, experiment readouts, at-risk cohort movement.
- **Quarterly (exec):** simulate — "raise sitewide floor to `{{60%}}` margin? kill the `{{20%-off}}` tier? shift `{{$200K}}` from retargeting to retention? enter SMS in `{{region}}`?" — projected margin/LTV deltas with confidence intervals.

**Build/Buy.** *Build* a thin control plane: config store (floors, caps, calendar), experiment console, approval queue, and the daily/weekly readouts. Explainability everywhere: any customer's "why did they get this?" answerable from the trace in one click (also your GDPR/CCPA access-request answer).

---

## 4. Cross-cutting spines

**4.1 Observability & lineage.** Trace any send/impression back through action → policy → state → facts → events. Monitor: pipeline freshness, feature/model drift, calibration, deliverability metrics, guardrail hits, holdout integrity.

**4.2 Data quality / ground-truth.** Event-schema contracts with CI; client/server reconciliation; ad-platform claims vs. internal truth reconciled weekly; return/support signals correcting identity and affinity.

**4.3 Consent, privacy & frequency governance (existential here).** Per-channel lawful basis in the graph; opt-out propagation `{{< 5 min}}` everywhere; **TCPA discipline for SMS** (express written consent, quiet hours, honoring STOP instantly); GDPR/CCPA access + erasure across all stores incl. traces (pseudonymize traces, don't lose the learning); minors' data policy; dark-pattern-free preference center. Frequency governance is a *global* budget owned by the policy layer — never per-tool.

**4.4 Orchestration & jobs.** Durable orchestrator for batch; the real-time trigger path bypasses it; canary + progressive rollout built into every send pipeline.

---

## 5. Canonical data contracts

### 5.1 Entity (customer node — consent- and household-aware)
```json
{
  "entity_id": "cust_88213",
  "type": "customer",
  "identifiers": [
    {"kind": "email", "value": "…", "confidence": 1.0, "basis": "order"},
    {"kind": "device", "value": "d_71a…", "confidence": 0.98, "basis": "login"},
    {"kind": "phone", "value": "…", "confidence": 1.0, "basis": "checkout_optin"}
  ],
  "household_id": "hh_5521",
  "consent": [
    {"channel": "email", "state": "granted", "valid_from": "2025-11-02"},
    {"channel": "sms", "state": "revoked", "valid_from": "2026-07-01", "prior": "granted@2026-03-02"}
  ],
  "relationships": [
    {"predicate": "member_of", "target": "cohort_q4_lapsed"},
    {"predicate": "gift_buyer_for", "target": "hh_5521", "confidence": 0.8}
  ],
  "provenance": ["evt_order_9912", "evt_login_5518"]
}
```

### 5.2 Fact (temporal assertion)
```json
{
  "fact_id": "fact_31877",
  "subject_entity_id": "cust_88213",
  "predicate": "replenishment_window",
  "value": {"category": "skincare", "sku_hint": "SKU-114"},
  "valid_from": "2026-07-25",
  "valid_to": "2026-08-10",
  "knowledge_time": "2026-07-12T05:00:00Z",
  "status": "active",
  "confidence": 0.84,
  "source_content_ids": ["orders_2025_2026_cycle_calc"]
}
```

### 5.3 Decision trace (offer decision — the compounding asset)
```json
{
  "decision_id": "dec_9915522",
  "occurred_at": "2026-07-25T09:00:00Z",
  "subject_entity_id": "cust_88213",
  "decision_type": "lifecycle_send",
  "inputs": {"state_version": "cs_v2026072505", "fact_ids": ["fact_31877"]},
  "features": {"churn_90d": 0.61, "uplift_0off": 0.09, "uplift_10off": 0.11, "fatigue_email_left": 1},
  "model_versions": {"uplift": "up_v9", "timing": "tm_v4", "clv": "clv_v11"},
  "policy_version": "policy_v13",
  "constraints_applied": ["consent_email_ok", "freq_cap_ok", "margin_floor_ok",
                          "inventory_cover_ok:SKU-114", "holdout_check:not_in_control"],
  "action": {"type": "send", "channel": "email", "template": "replen_reminder",
             "offer": "none", "agent": "lifecycle_v3", "autonomy": "autonomous"},
  "alternatives_considered": [
    {"action": "send_10off", "reason_rejected": "uplift delta +0.02 < margin cost; discount-conditioning risk"},
    {"action": "suppress", "reason_rejected": "window open + fatigue budget available"}],
  "explanation": "Replenishment window opened today; no-discount reminder captures 0.09 uplift; 10% adds only +0.02 for -{{$3.10}} margin.",
  "outcome": {"label": "purchased_no_discount", "margin": 21.40,
              "holdout_cell": "replen_program_treatment", "observed_at": "2026-07-27"}
}
```

---

## 6. Build vs. buy summary (mid-market ecommerce defaults)

| Component | Recommendation | Rationale |
|---|---|---|
| Event collection / CDP | **Buy** | `{{Segment/RudderStack}}` |
| ELT + warehouse + reverse-ETL | **Buy** | Commodity |
| ESP/SMS execution | **Buy** | `{{Klaviyo/Braze/Attentive}}` — execution rails, not the brain |
| Identity resolution | **Buy (CDP) + Build (canonical layer)** | Composable-CDP pattern |
| Recommendations | **Buy early → Build** | Replace when your graph beats the vendor |
| Consent management | **Buy (CMP) + Build (graph integration)** | Legal-grade, graph-enforced |
| Bi-temporal fact store + entity tables | **Build** | Core IP |
| Feature layer (batch + real-time) | **Build** | dbt + streaming path + cache |
| Models (CLV, churn, **uplift**, timing, affinity) | **Build** | Trained on your outcomes; the moat |
| Customer-state + offer + precedent stores | **Build** | Pre-compute-store-serve core |
| Policy engine (offer × channel × timing, global frequency budget) | **Build** | This *is* the product |
| Experimentation/holdout platform | **Build (or Buy `{{Eppo/Statsig}}` + Build holdout facts)** | Incrementality is the ground truth |
| Agents | **Build harness + Buy LLMs** | Copy/planning agents; execution via ESP APIs |
| Control plane | **Build (thin)** | Floors, caps, calendar, readouts |

> **Fastest path:** keep your ESP/ads tools as *execution rails*, and build the layer they all obey — canonical identity, the fact store, uplift models, the global policy/frequency engine, and holdout-measured precedent. The moat is knowing, per customer, the *minimum effective action* — knowledge that lives in your traces and nowhere else.

---

## 7. Phased implementation roadmap

### Phase 0 — Foundations (weeks `{{1–6}}`)
CDP + warehouse + ELT + reverse-ETL; event-schema contracts; connect platform, ESP/SMS, ads, **inventory/margin**, consent. **Exit:** P0 sources flowing, consent state joined at ingest, opt-out propagation `{{< 5 min}}` verified.

### Phase 1 — Identity + graph (weeks `{{5–12}}`)
Canonical customer table with tiers; household logic where relevant; entity + bi-temporal fact stores; erasure pipeline across stores. **Exit:** deterministic tier `{{≥ 99.5%}}`; anonymous-to-known backfill working; erasure audit passes.

### Phase 2 — Compute + state + first models (weeks `{{10–18}}`)
Feature layer (batch + real-time); CLV, churn, timing models — calibrated; customer-state store serving `{{< 50ms}}`; **persistent holdouts instituted on all existing always-on programs** (start the control clock now — you'll want the baseline). Ship the daily growth readout (report-only). **Exit:** state store live; team trusts the readout; holdouts clean.

### Phase 3 — Decide + act (weeks `{{16–26}}`)
Policy engine with margin/inventory/consent/frequency constraints + "do nothing"; global frequency budget takes over from per-tool caps; lifecycle + audience-sync agents on the new policy (canary → progressive rollout); **uplift models on discount depth** (the payback milestone); full/sampled decision traces. **Exit:** at least one program shows holdout-measured margin lift; zero consent/holdout violations.

### Phase 4 — Learn + optimize (from week `{{24}}`, ongoing)
Backtesting harness; experiment platform mature; bandit policies where volume supports them; copy-agent graduation per template class; quarterly simulation for planning. **Exit:** portfolio-level incremental margin trending up QoQ; discount spend down at flat-or-better conversion.

---

## 8. Team & operating model

| Role | Responsibility | Sizing |
|---|---|---|
| Growth/Retention architect (owner) | Ontology, policy design, strategy layer | `{{1}}` |
| Data engineer(s) | CDP, warehouse, real-time path, features | `{{1–2}}` |
| ML/DS | CLV, churn, **uplift**, experimentation rigor | `{{1–2}}` |
| Platform/backend eng | State stores, policy engine, agent harness | `{{1–2}}` |
| Lifecycle/retention marketer | Plays, creative direction, brand guardrails | `{{1–2}}` |
| Analyst | Incrementality reporting, data quality | `{{1}}` |

> Lean start: `{{3–4 FTE}}` by keeping ESP/ads as rails and building only the decision layer. The uplift-modeling DS skill is the hardest hire and the highest-leverage one.

---

## 9. KPIs, SLOs & the precision ladder

**System KPIs (holdout-adjusted, margin-denominated)**
- Incremental contribution margin per program vs. control (the headline).
- Discount efficiency: margin given ÷ incremental conversions (should fall).
- CLV trajectory by acquisition cohort; repeat rate; at-risk saves.
- **Suppression rate:** % of decisions that were "do nothing" (healthy systems suppress a lot).
- Deliverability health: inbox placement, spam rate, list-growth-net-of-churn.

**Precision ladder (autonomy gates)**

| Primitive | Bar |
|---|---|
| Identity — deterministic tier (messaging) | `{{≥ 99.5%}}` |
| Consent state at send time | **100% — blocking, audited** |
| Holdout integrity | **100% — contamination is an incident** |
| Frequency-budget enforcement | `{{≥ 99.9%}}` of sends within budget |
| Inventory check at promotion time | `{{≥ 99%}}` (no stockout promos) |
| Offer/price rendering | 100% from offer store; LLMs never generate prices/claims |
| Copy-agent brand/claims QA | `{{≥ 99%}}` pass before autonomous graduation per template class |

**Operational SLOs.** Trigger decisions P95 `{{< 2s}}`; state reads `{{< 50ms}}`; opt-out propagation `{{< 5 min}}`; spam-rate circuit-breaker armed 24/7.

---

## 10. Anti-patterns (ecommerce edition)

1. **Optimizing revenue, not margin.** The Brain that "grows sales" by leaking discounts is a value destroyer with good dashboards.
2. **Response models instead of uplift models.** Rewarding the system for conversions it didn't cause teaches it to discount sure-buyers.
3. **Last-click as ground truth.** Attribution is a claim; holdouts are evidence.
4. **Per-tool frequency caps.** Without a global contact budget, the customer gets carpet-bombed across channels — each tool "compliant."
5. **No "send nothing."** The most common optimal action in retention is silence.
6. **Ignoring inventory.** Promoting stockouts and starving overstock is self-harm the Brain must be constrained against.
7. **Prose summaries per customer.** At millions of customers, per-customer state is compact structured records; LLM summaries live at the cohort level.
8. **LLMs generating prices, discounts, or product claims.** Offers render from the offer store; claims come from approved sources. Full stop.
9. **Probabilistic identity in SMS.** A wrong-person text is a TCPA event.
10. **Holdout contamination.** One "quick blast to everyone" poisons every measurement downstream.
11. **Big-bang sends of new templates.** Canary + progressive rollout, always — a bug at 2M scale is a brand event.
12. **Deliverability as an afterthought.** Bulk-sender rules (Gmail/Yahoo) make spam-rate a hard constraint; agents can outrun warmup in a day.
13. **The inference-time trap.** Session personalization that calls an LLM with raw history will miss the session entirely.
14. **Write-back loops.** Tag Brain-originated events/audiences; exclude from ingestion (§12).
15. **Discount conditioning ignored.** Trained-to-wait customers are a modeled fact (`discount_conditioned`), not a mystery.

---

## 11. Coexistence statement

The Brain replaces neither the commerce platform nor the ESP. The **platform remains the record of orders and customers**; the **ESP/SMS/ads tools remain the execution rails**; the **warehouse remains for analytics**. The Brain is the **system of record for customer state, decisions, and incrementality** — the layer that tells every rail what to do, per customer, and *why* — sitting on top of, and syncing selectively into, the existing stack.

---

## 12. Write-back / activation contract

Write-back here is mostly **activation sync** (reverse-ETL to rails) plus selective platform enrichment.

| Destination | What's written | Cadence | Rule |
|---|---|---|---|
| ESP/SMS | Segments, per-customer properties (`brain__stage`, `brain__nbo`, `brain__offer_eligible`), suppression lists, trigger events | Real-time + hourly | Namespaced; ESP-native "smart" features disabled where they'd double-decide |
| Ads platforms | Audience inclusions/exclusions (suppress purchasers, sure-things) | `{{4–24h}}` | Hashed, consent-checked; exclusions are the priority sync |
| Commerce platform | `brain__vip_tier`, `brain__at_risk`, customer tags | Daily | Namespaced; append-safe |
| Support tool | Customer context card (state summary link) | On ticket open | Read-only deep link |
| Onsite/CMS | Personalization decisions via state-store API | Real-time | API reads, no data dump |

**Rules:** every Brain-originated event/property tagged (`brain_source=true`) and **excluded from ingestion** (a synced segment must never become its own signal); one decision-maker — where the Brain decides, the rail's native automation for that program is turned *off* (two brains = frequency chaos); consent re-checked at sync *and* at send; syncs keyed on decision_id (idempotent); audience membership changes logged as facts (auditable, and required for incrementality math).

---

## 13. Worked example — one play, end to end

**Play: replenishment window → minimum-effective-offer send.**

| T | Layer | What happens |
|---|---|---|
| T-14d | **Orient** | Timing model (tm_v4) computes `cust_88213` will enter the `{{skincare}}` replenishment window ~7/25 (3 prior cycles). Fact `fact_31877` written with validity 7/25–8/10. |
| T-1d | **Orient — state** | Nightly job refreshes state: churn 0.61 (at-risk), uplift(no offer)=0.09, uplift(10%)=0.11, email fatigue budget = 1, SMS consent revoked, not in any control cell. NBO computed: `replen_reminder_no_discount`. State record updated in `{{< 50ms}}`-readable store. |
| T0 09:00 | **Decide** | Policy v13 evaluates: `send(email, no discount)` maximizes incremental margin — the 10% offer adds +0.02 uplift for −`{{$3.10}}` margin and carries conditioning risk; `suppress` loses an open, decaying window. Constraints: consent ✓ (email only), frequency ✓, margin ✓, inventory ✓ (SKU-114 cover 6 wks), holdout ✓. Trace `dec_9915522` written with alternatives + explanation. Autonomy: autonomous (program graduated in `{{May}}` after holdout-proven lift). |
| T0 09:00:02 | **Act** | Lifecycle agent triggers the ESP template; product block renders from affinity + inventory stores; **price/offer content rendered from the offer store** (none, in this case); send from warmed domain within budget. Activation contract logs the send as `brain_source=true`. |
| T+2d | **Learn** | Purchase, full price, margin $21.40. Outcome joins to `dec_9915522`. Program-level readout: replenishment cohort +`{{$4.30}}` incr. margin/send vs. persistent 10% holdout this month; the "no-discount beats 10% here" precedent strengthens in the outcome store — next quarter's discount ladder review cites it. |

**Notice:** the decision was made *before* the moment (pre-computed window + state); "10% off" was genuinely considered and rejected on uplift-vs-margin math; SMS never entered the picture (consent fact); the holdout stayed untouched; and the outcome is measured against control, not attribution.

---

## 14. Simulation engine (the quarterly "what if")

- **Discount-ladder simulation:** replay last `{{2 quarters}}` of offer decisions under a modified ladder (kill the 20% tier; raise floors) → projected conversion, margin, and conditioning-rate deltas.
- **Frequency-policy simulation:** tighten/loosen the global contact budget → projected revenue vs. unsubscribe/spam-rate movement (using fatigue-response curves from traces).
- **Budget-shift scenarios:** move `{{$X}}` from retargeting to retention (or SMS launch in `{{region}}`) → projected incremental margin using channel-level incrementality estimates (geo tests/MMM-lite), with wide honest intervals.
- **Assortment/promo-calendar what-ifs:** hero-SKU exclusion, overstock-push windows → margin and inventory-cover projections.

**Mechanism:** bi-temporal snapshot → counterfactual parameters → replay policy in simulation (no side effects) → score with calibrated + uplift models → deltas with confidence intervals. Shares ~80% machinery with the backtest harness; ship backtesting first. **Honesty rule:** simulations inherit model error and off-policy bias — label projections as model-based, attach assumptions, and flag extrapolation beyond observed behavior.

---

## 15. Cost model (template)

| Category | Line items | Annual estimate |
|---|---|---|
| CDP + ELT + reverse-ETL | Event collection, pipelines, activation | `{{$60–180K}}` |
| Warehouse + real-time infra | Compute, streaming path, state-store serving | `{{$50–150K}}` |
| Execution rails (existing spend, noted for completeness) | ESP/SMS/ads tooling | `{{already budgeted}}` |
| Experimentation platform | `{{Buy or build}}` | `{{$0–60K}}` |
| LLM inference | Copy variants, cohort summaries, briefs (cohort-level — cheap by design) | `{{$10–50K}}` |
| Team (§8) | `{{3–6 FTE}}` blended | `{{$500K–1.3M}}` |
| **Total (net new)** | | `{{~$620K–1.75M/yr}}` |

**Payback math to track from day one:** discount spend avoided on sure-buyers (uplift targeting) + margin lift vs. holdouts + ad spend saved via suppression audiences + list-health/deliverability preservation. In most deployments, **uplift-based discount allocation is the line item that pays for everything else** — instrument it first.

---

## 16. Risk register (template)

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | TCPA violation (SMS to revoked/wrong number) | Med | **Severe (statutory damages per message)** | Deterministic-only SMS identity; blocking consent gate; `{{< 5 min}}` opt-out SLO; audit |
| R2 | Deliverability collapse (spam-rate breach at volume) | Med | High | Circuit-breaker; warmup discipline; engagement-based sending; canary rollouts |
| R3 | Margin erosion from mis-specified uplift/offers | Med | High | Margin floors as hard constraints; holdout-measured ladder reviews |
| R4 | Holdout contamination | Med | High (measurement blindness) | Execution-layer exclusion; contamination = incident with postmortem |
| R5 | GDPR/CCPA erasure or access failure across stores | Low | Severe | Erasure pipeline across graph + traces (pseudonymize); quarterly audit |
| R6 | LLM-generated price/claim error at scale | Med | High | Prices/claims render-only from stores; template QA gates; canary sends |
| R7 | Identity over-merge (household confusion, wrong history) | Med | Med | Reversible merges; household modeling; support-ticket feedback loop |
| R8 | Two-brains conflict (ESP-native automation vs. Brain) | High early | Med | One-decision-maker rule per program (§12); migration checklist |
| R9 | Write-back loops (synced segment becomes signal) | Med | Med | §12 tagging + ingestion exclusion |
| R10 | Third-party signal decay (cookies, ad-platform data access) | High | Med | First-party ID strategy; server-side collection; clean-room optionality |
| R11 | Scope creep / big-bang | High | High | Phase gates; one program to holdout-proven lift before expansion |

---

## 17. Maturity model & adoption

**Self-assessment:**

| Level | Name | You have… | Next move |
|---|---|---|---|
| 0 | Blasting | Calendar sends to everyone; per-tool logic; last-click reporting | Phase 0 |
| 1 | Unified | CDP + warehouse; consistent events; consent centralized | Phase 1: identity + graph |
| 2 | Segmented | Lifecycle segments + basic triggers; some models | Phase 2: state store + holdouts |
| 3 | Decisioned | Global policy engine chooses offer × channel × timing; uplift-driven discounts | Phase 3 |
| 4 | Experimental autonomy | Programs autonomous within guardrails; everything holdout-measured | Phase 4 |
| 5 | Compounding | Precedent store drives planning; incremental margin rising QoQ at falling discount cost | Defend the moat |

**Adoption plan (the human side — here the "reps" are marketers):**
1. **Start with the readout, not the takeover.** The daily incrementality readout (report-only) builds trust before the Brain touches a single send.
2. **Migrate one program at a time** to Brain control, with the ESP's native logic explicitly retired for that program — publish the before/after vs. holdout.
3. **Marketers keep creative and brand authority.** The Brain decides *who/when/what offer*; humans own *voice and story*. Blur this and you lose the team.
4. **Never grade marketers on Brain metrics they can't influence.** Traces improve the system, not the scorecard.
5. **Celebrate suppression.** Publicize the "sends we didn't make" margin — it reframes silence as a win and inoculates against volume culture.
6. **Graduate autonomy publicly, per program, with the experiment evidence attached.** Autonomy is a promotion with a paper trail.

---

## Appendix A — Glossary
- **Uplift model:** predicts the *incremental* effect of an action on an individual (vs. a response model, which predicts the outcome regardless of cause).
- **Persistent holdout:** a standing control group excluded from a program to measure its true lift.
- **Incrementality:** outcome lift over control — the only accepted ground truth here.
- **Contact/frequency budget:** the global per-customer allotment of touches across all channels per window.
- **Discount conditioning:** trained-to-wait behavior induced by predictable promotions; modeled as a fact.
- **Minimum effective offer:** the smallest incentive (often zero) that converts a persuadable customer.
- **Customer-state store:** the compact, low-latency per-customer record all rails read.
- **Event clock / State clock, decision trace, bi-temporal, OODA+L:** as in the SaaS variant.

## Appendix B — Starter ontology (fill in)
- **Entities:** `{{Customer, Household, Product, Category, Order, Subscription, Cohort/Segment, Campaign, Offer, Channel, Experiment/Holdout, Review}}`
- **Relationships:** `{{purchased, browsed, member_of, substitutes, complements, gift_buyer_for, subscribed_to, exposed_to, held_out_of}}`
- **Fact predicates (first 20):** `{{lifecycle_stage, replenishment_window, discount_sensitivity_band, discount_conditioned, channel_preference, consent_state, fatigue_budget, holdout_membership, predicted_next_purchase, at_risk, vip_tier, size_fit_issue, promo_abuser_flag, inventory_cover_band, margin_band, …}}`

## Appendix C — Reference tech stack (one opinionated default)
Events `{{Segment/RudderStack}}` → Warehouse `{{Snowflake/BigQuery}}` → Transform `{{dbt}}` → Real-time `{{CDP computed traits / streaming transforms}}` → Entities+Facts `{{warehouse tables, bi-temporal pattern}}` → State store `{{Redis/DynamoDB}}` → Models `{{LightGBM + uplift libs + BTYD + MLflow}}` → Experimentation `{{Eppo/Statsig or in-house}}` → Activation `{{Hightouch/Census}}` → Rails `{{Klaviyo/Attentive/Meta/Google}}` → Orchestration `{{Dagster/Temporal}}` → Agents `{{LangGraph + Claude/GPT}}` (copy/planning) → Control plane `{{internal app}}` → Observability `{{OpenTelemetry + Evidently}}`.

## Appendix D — Changelog

| Version | Changes |
|---|---|
| v0.2-EC | Initial Ecommerce variant, derived from SaaS template v0.2: consumer-scale identity (consent-aware, household, deterministic-for-messaging); compact customer-state store replacing per-account prose summaries; uplift-modeled discount allocation as the flagship decision; margin + inventory + global frequency budget as hard constraints; incrementality/persistent holdouts as ground truth; TCPA/GDPR/deliverability as blocking controls; activation-sync write-back contract with one-decision-maker rule; ecommerce-specific worked example, cost model, risks, maturity, and adoption plan. |

---
*Template v0.2-EC — adapt all `{{placeholders}}` to your business. Deterministic computation (models) stays separate from probabilistic narration (LLMs) and persistent memory (stores) — and in this variant, prices, discounts, and product claims are always rendered from stores, never generated.*
