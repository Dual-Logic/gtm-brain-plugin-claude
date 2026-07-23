# GTM Brain — Reference Architecture Template
### A buildable blueprint for a self-learning go-to-market decision system at a mid-market SaaS company

> **How to use this document.** This is a *template*, not a finished design. Anywhere you see `{{PLACEHOLDER}}`, substitute your own value. Anywhere you see a **Build / Buy / Defer** call, treat it as a default recommendation for a mid-market company (roughly `{{$10M–$100M ARR}}`, `{{50–500 employees}}`, an existing CRM + MAP, a small data/RevOps team) — not a mandate. The goal is a system that decides *what to do and when to do nothing*, executes through agents, and gets smarter from every outcome — while keeping your CRM as the system of record for *state*.

---

## 0. Document control

| Field | Value |
|---|---|
| Owner | `{{RevOps / GTM Eng lead}}` |
| Sponsor | `{{VP RevOps / CRO}}` |
| Version | `v0.2 (template)` — see Appendix D changelog |
| Status | Draft |
| Review cadence | Quarterly, or on major stack change |
| Related docs | ICP definition, data-governance policy, security review, agent playbook library |

---

## 1. First principles

These are the design tenets the whole system is accountable to. Every component below traces back to one of them.

1. **Own the decision, not just the data.** The CRM already stores *state* ("Closed Lost, $150K"). The Brain stores the **event clock** — what happened, in what order, and *why* a choice was made. That reasoning trace is the asset that compounds and can't be ripped out.
2. **Two clocks.** Maintain both the **State Clock** (what is true now) and the **Event Clock** (the temporal, causal record of how we got here). Your CRM/warehouse already do the former; the Brain must add the latter.
3. **Context graph over RAG.** GTM context can't be solved by retrieving document chunks. It requires resolved identities, typed relationships, and time-bounded facts. Model your world as **entities, relationships, and temporal facts** — not tables and joins, and not a vector index of raw text. *(A semantic/vector index still has a legitimate supporting role — searching call transcripts and emails to ground an agent's narration — but it serves the graph; it never replaces it as the reasoning substrate.)*
4. **Pre-compute, store, serve — never assemble at inference time.** Rebuilding context inside every LLM call is the "inference-time trap": slow, expensive, inconsistent, and prone to hallucination. Compute and summarize state *ahead of time* so agents query ready-made context in milliseconds.
5. **Separation of concerns.**
   - **Models compute** (deterministic): identity, scores, weights, readiness, priority, expected value.
   - **LLMs narrate** (probabilistic): recommendations, messaging angles, next best action, chat.
   - **Summary stores remember** (persistent): "Account X looks like Y; historically, do Z."
6. **Precision compounds, so build primitives, not pipelines.** A five-step pipeline at 80% per step is ~33% correct end-to-end. Each primitive (identity resolution, enrichment, ICP match, intent scoring, personalization) must hit production-grade precision *independently* before it's composed into an autonomous workflow.
7. **Close the loop or it isn't a Brain.** Every decision emits a **decision trace**; every outcome is fed back. If outcomes don't update models and policies, you've built a dashboard, not a Brain.
8. **Human-in-the-loop by default; autonomy by graduation.** New plays run in **shadow mode** (recommend, don't act), then **assisted** (human approves), then **autonomous** (act within guardrails). Precision earns autonomy.

---

## 2. Reference architecture at a glance

The system is a closed **OODA+L** loop: **Observe → Orient → Decide → Act → Learn.**

```
                            ┌───────────────────────────────────────────────┐
                            │              HUMAN STRATEGY LAYER               │
                            │  ICP, guardrails, budgets, play approvals,      │
                            │  segment targets, kill-switches, review queue   │
                            └───────────────┬───────────────────────────────┘
                                            │ steer / approve / override
   OBSERVE            ORIENT                ▼            DECIDE           ACT
┌──────────┐   ┌──────────────────────────────────┐  ┌───────────┐  ┌──────────────┐
│ Sources  │   │  Identity Resolution Graph        │  │  Policy / │  │  Agent        │
│ (GTM     │──▶│           │                       │  │  Decision │─▶│  Execution    │
│ surface) │   │           ▼                       │  │  Engine   │  │  Layer        │
│          │   │  Context Graph (3 layers)         │  │           │  │  (specialized │
│ web, CRM │   │   • Content (evidence, immutable) │  │ maps state│  │   agents)     │
│ MAP, prod│   │   • Entity (resolved identities)  │  │ → action  │  └──────┬───────┘
│ calls,   │   │   • Fact (temporal assertions)    │  │ under     │         │ execute
│ intent,  │   │           │                       │  │ constraints│        ▼
│ enrich   │   │           ▼                       │  │ (incl.    │  CRM / MAP / email /
└────┬─────┘   │  Feature & Signal Computation     │  │ "do       │  LinkedIn / chat /
     │         │           │                       │  │ nothing") │  slack / ads
     │ stream  │           ▼                       │  └─────▲─────┘         │
     ▼         │  Model Layer (deterministic:      │        │               │
┌──────────┐   │   scoring, propensity, EV, tiers) │        │ ranked        │
│ Ingestion│──▶│           │                       │        │ actions       │
│ & Stream │   │           ▼                       │        │               │
│ (bus,    │   │  Summary / Primitive Stores       │────────┘               │
│  CDC,    │   │  (buying committee, intent,       │                        │
│  ETL)    │   │   lookalike, enrichment, outcome) │                        │
└──────────┘   └──────────────────────────────────┘                        │
     ▲                                                                      │
     │                         LEARN                                        │
     └──────────────────────────────────────────────────────────────────────
        Outcome capture → decision-trace store → backtesting / shadow eval →
        model retraining → policy updates → data-quality validation loop
```

**Cross-cutting spines** run through every layer: **Observability & lineage**, **Data quality / ground-truth**, **Security, privacy & compliance**, and **Orchestration & job scheduling.**

---

## 3. Layer-by-layer specification

Each layer below follows the same shape: **Purpose → What it must do → Inputs/Outputs → Build/Buy → Reference implementation → Precision bar / SLO → Failure modes.**

### Layer 0 — Sources: your GTM surface area (OBSERVE)

**Purpose.** Capture *every* signal across the GTM surface so nothing that informs a decision is lost.

**What it must do.** Instrument and connect all first-, second-, and third-party signal sources; guarantee each event is timestamped and attributable to a source.

**Source inventory (template — check what applies):**

| Category | Example sources | Signal type | Priority |
|---|---|---|---|
| 1st-party web | `{{Website, docs, pricing page, app}}` | Page views, sessions, form fills, de-anon visitors | P0 |
| CRM | `{{Salesforce / HubSpot}}` | Accounts, contacts, opps, stages, activities | P0 |
| MAP / email | `{{Marketo / HubSpot / Customer.io}}` | Sends, opens, clicks, replies, unsubscribes | P0 |
| Product usage | `{{Amplitude / Mixpanel / Snowplow}}` | Feature adoption, activation, PQL signals | P1 |
| Conversations | `{{Gong / Fireflies / Chorus}}` | Call transcripts, deal risk, competitor mentions | P1 |
| Intent (3rd party) | `{{Bombora / G2 / 6sense}}` | Research/surge topics | P1 |
| Social (2nd party) | `{{LinkedIn}}` | Job changes, posts, engagement | P2 |
| Enrichment | `{{Clearbit / Apollo / ZoomInfo / Coldly}}` | Firmographic, technographic, contact | P0 |
| Support | `{{Zendesk / Intercom}}` | Tickets, sentiment, churn signals | P2 |
| Billing | `{{Stripe / NetSuite}}` | ARR, seats, payment health | P1 |

**Build/Buy.** *Buy* the connectors. *Build* only your own web/app instrumentation.

**Precision bar.** Every event has: `source`, `event_type`, `occurred_at` (event time, not ingest time), and a raw identifier you can later resolve.

**Failure modes.** Silent connector breakage; event-time vs ingest-time confusion; PII captured without consent basis.

---

### Layer 1 — Ingestion & streaming (OBSERVE)

**Purpose.** Move signals from sources into the Brain reliably, in near-real-time where it matters (speed-to-lead) and in batch where it doesn't.

**What it must do.**
- **Two-speed ingestion.** Real-time streaming for latency-critical signals (a visitor is *on the pricing page right now*); batch/CDC for the rest.
- Preserve **event time** and enforce idempotency (no double-counting).
- Land an immutable raw copy before any transformation (feeds the Content layer).

**Inputs/Outputs.** In: source events. Out: validated, deduplicated event streams + a raw immutable landing zone.

**Build/Buy — reference stack (mid-market defaults):**

| Concern | Buy (default) | Build/OSS alternative |
|---|---|---|
| ELT connectors | `{{Fivetran / Airbyte}}` | Custom connectors |
| Event streaming | `{{Segment / RudderStack}}` → warehouse | `{{Kafka / Redpanda}}` if you have the team |
| CDC from CRM | Native connector | `{{Debezium}}` |
| Warehouse/lakehouse | `{{Snowflake / BigQuery / Databricks}}` | — |
| Transform | `{{dbt}}` | — |
| Orchestration | `{{Dagster / Airflow / Temporal}}` | — |

> **Mid-market reality check:** you almost certainly do **not** need Kafka on day one. A managed CDP (Segment/RudderStack) feeding a warehouse, plus a real-time path for web signals, covers 90% of cases. Add a true event bus only when volume or latency forces it.

**Precision bar / SLO.** Real-time path P95 latency `{{< 2s}}` from event to available context. Batch freshness `{{< 1h}}` for P1 sources.

**Failure modes.** Batch-only architecture kills speed-to-lead; missing idempotency inflates intent scores; no raw landing zone means you can't replay or audit.

---

### Layer 2 — Identity resolution graph (ORIENT — the hard, expensive primitive)

**Purpose.** Resolve fragmented identifiers into canonical people and companies. This is the substrate that makes everything downstream possible — and it's the primitive most likely to sink the project if under-built.

**What it must do.**
- Collapse `Mike Torres`, `M. Torres`, `@miket`, `mtorres@acme.com`, cookie IDs, and an anonymous IP into **one canonical person** at **one canonical company.**
- De-anonymize website visitors (probabilistic: IP ranges, reverse-IP, cookie/behavioral fingerprints, firmographic patterns) with **calibrated confidence scores**.
- Maintain the account/contact/opportunity **relationship graph**, including the **buying committee**.
- Never hard-merge on low confidence; keep candidate links reversible.

**Inputs/Outputs.** In: raw identifiers from every source. Out: `canonical_entity_id` for every observed identifier + confidence + provenance.

**Build/Buy.**
- Website **de-anonymization**: *Buy* (`{{RB2B / Vector / 6sense / Clearbit}}`) — the accuracy is a data-scale network effect you can't replicate.
- **Entity resolution engine**: *Build or Buy.* Buy (`{{a CDP identity graph, or a dedicated ER vendor}}`) for mid-market; build only if identity is a differentiator.
- **Relationship graph store**: *Build* on `{{Neo4j / Amazon Neptune / Postgres + ltree / TigerGraph}}`.

**Data quality dependency.** B2B contact data has a ~2-year half-life. Identity is not "solved once" — it decays. See the ground-truth validation loop (§7.2).

**Precision bar / SLO.** This is a **100% precision primitive.** Track precision *and recall* separately, with confidence tiers:
- **High-confidence** links (auto-usable for outbound): target `{{≥ 99% precision}}`.
- **Medium-confidence**: usable for scoring/prioritization, *not* for a cold email to a named person.
- **Low-confidence**: retained, not acted upon.

**Failure modes.** Wrong-person outbound (brand damage); over-merging distinct people; treating a probabilistic de-anon as ground truth for a 1:1 email; no confidence tiering, so everything is used at the accuracy of your worst guess.

---

### Layer 3 — The Context Graph (ORIENT — the core)

The heart of the system. Three sub-layers, strictly separated.

#### 3a. Content layer — *Evidence* (immutable)

- **What.** The canonical, append-only record of what was actually captured: emails, call transcripts, web sessions, CRM activities, form fills.
- **Rules.** Never edited, merged, or deleted. Everything downstream must be traceable back to a content item (lineage/provenance).
- **Store.** Object storage + warehouse (`{{S3/GCS + Snowflake/BigQuery}}`). Cheap, immutable, replayable.

#### 3b. Entity layer — *Identity* (resolved)

- **What.** The people, organizations, products, segments, and events that content *mentions*, resolved to canonical IDs by Layer 2.
- **Store.** Graph database (see Layer 2). Nodes = entities; edges = typed relationships (`works_at`, `member_of_buying_committee`, `reports_to`, `competitor_of`).

#### 3c. Fact layer — *Assertions* (temporal)

This is what most tools lack and what makes simulation possible. A fact is not "the account is in-market." A fact is a **time-bounded, sourced assertion**:

> *"Acme started showing intent on 2026-03-15; the signal weakened on 2026-08-03 when their budget froze."*

**Every fact carries:**

| Field | Meaning |
|---|---|
| `fact_id` | Unique ID |
| `subject_entity_id` | Who/what the fact is about |
| `predicate` | The assertion type (e.g., `in_market`, `champion_of`, `budget_status`) |
| `object` / `value` | The value |
| `valid_from` / `valid_to` | **Validity period** (bi-temporal: distinguish *event time* from *knowledge time*) |
| `status` | `active` / `superseded` / `retracted` |
| `confidence` | Calibrated score |
| `source_content_ids[]` | Links back to the evidence |

**Why bi-temporal matters.** You must be able to answer *"what did we know, and when did we know it?"* — both to reconstruct decision context and to backtest honestly (no look-ahead leakage).

**Store.** A **bi-temporal fact store** — `{{a temporal table pattern in Postgres/Snowflake, or a purpose-built store like XTDB/Datomic}}`.

**Precision bar.** No fact without a source content ID. No fact without a validity period.

**Failure modes.** Mutable facts (you lose the event clock); facts without validity (you can't reason about *when*); look-ahead leakage in backtests (models look brilliant offline, fail live).

---

### Layer 4 — Feature & signal computation (ORIENT)

**Purpose.** Turn the graph into the *computed* features decisions need. Features are **computed, not retrieved** — "3+ buying-committee members visited pricing in the last 7 days" is a computation over structured facts, not a document.

**What it must do.**
- Compute account/contact-level features on a schedule and on-event: intent velocity, engagement recency/frequency, buying-committee coverage, tech-stack match, ICP-fit components.
- Guarantee **train/serve parity** (offline features used to train == online features used to serve).
- Version features; enforce point-in-time correctness for training.

**Build/Buy.** *Build* the feature definitions in `{{dbt + a feature store}}`. Feature store: `{{Feast (OSS) / Tecton}}` — or, for many mid-market teams, warehouse tables + a thin serving cache (`{{Redis}}`) is enough. Don't over-engineer this early.

**Precision bar / SLO.** Feature freshness matched to use: real-time features `{{< 5s}}`; daily features by `{{6am local}}`. Zero train/serve skew tolerated on production models.

**Failure modes.** Training on features that leak the future; serving stale features; hidden train/serve skew that silently degrades models.

---

### Layer 5 — Model layer (ORIENT — deterministic compute)

**Purpose.** Compute the numbers that anchor every decision. **Models compute; they do not narrate.**

**What it must do.**
- **ICP fit / tiering** — how much does this account look like your best customers?
- **Intent / readiness scoring** — probability the account/contact is in an active buying window.
- **Propensity / conversion probability** — P(convert | current state), calibrated.
- **Expected value (EV)** — `P(win) × deal_size × strategic_weight`, the currency the policy layer allocates against.
- **Lookalike** — nearest-neighbor to closed-won cohorts.
- **Churn/expansion risk** for the installed base.

**Build/Buy.** *Build* the models; they are proprietary and improve with *your* outcomes. Start with **interpretable baselines** (logistic regression, gradient-boosted trees — `{{XGBoost/LightGBM}}`) before anything fancy. Calibration (Platt/isotonic) matters more than raw AUC for a policy layer that needs trustworthy probabilities.

**Registry & serving.** `{{MLflow}}` for tracking/registry; batch scoring in the warehouse + `{{a lightweight serving endpoint}}` for real-time.

**Precision bar / SLO.** Report **calibration**, not just accuracy (a 70% score should win ~70% of the time). Version every model; log every prediction with the feature vector and model version (this feeds decision traces).

**Failure modes.** Uncalibrated scores feeding an EV-maximizing policy (garbage allocation); using an LLM to "score" (non-deterministic, unauditable); no prediction logging (can't learn).

---

### Layer 6 — Summary / primitive stores (ORIENT → serve)

**Purpose.** This is **pre-compute, store, serve** made concrete. Compress years of history into small, ready-to-use context blocks so agents never rebuild the world at runtime. The article's example: 100,000 raw events → a ~500-token ontological summary.

**The stores (template):**

| Store | Contents | Consumed by |
|---|---|---|
| **Buying Committee Store** | Who's involved, roles, engagement, single-threaded risk | Committee agent, copy agent |
| **Intent Store** | Temporal signal patterns, page-level behavior, velocity | Scoring, prioritization, chat |
| **Lookalike Store** | Which accounts match best-customer cohorts | Prioritization, audience building |
| **Enrichment Store** | Firmo/techno/contact data, validated + freshness-stamped | All agents |
| **Outcome Store** | What happened + what we learned (precedent) | Learning loop, policy, narration |
| **Account Summary Store** | The ~500-token ontological compaction per account | Every agent, rep morning brief |

**Build/Buy.** *Build.* Materialize as warehouse tables refreshed by jobs, cached in `{{Redis / a low-latency KV store}}` for serving. Summaries are generated by a **summarization job** (LLM-assisted) that runs on change, *not* at query time.

**Precision bar / SLO.** Summary staleness `{{< 15 min}}` after a material change for hot accounts. Every summary carries the timestamp and source facts it was built from.

**Failure modes.** Generating summaries at query time (the inference-time trap you were trying to avoid); summaries that drift from underlying facts; unbounded summary size.

---

### Layer 7 — Policy / decision engine (DECIDE)

**Purpose.** Map current state → the *right action* (**including doing nothing**) under **real constraints**. This is where the Brain earns its name.

**What it must do.**
- Rank candidate actions per entity by **expected value net of cost**.
- Enforce **hard constraints**: AE capacity, inbox/send limits, ad budget, brand-fatigue caps (don't touch the same person 5 ways in a week), suppression lists, legal/consent, contractual do-not-contact.
- Explicitly support **"do nothing / wait"** as a first-class action (e.g., "champion OOO until Thursday — hold").
- Respect the **Human Strategy Layer**: segment priorities, play eligibility, autonomy level.
- Emit a **decision trace** for *every* decision (see §5.3).

**Design pattern.** Start **rules + scores** (transparent, debuggable), evolve toward a **learned policy** (contextual bandit / constrained optimization) *only once* you have enough logged decision→outcome data to train and backtest one. A learned policy without a backtest harness is a liability.

**Build/Buy.** *Build.* Reference: a constrained optimizer / assignment step over the ranked candidate actions, wrapped in a service that reads scores + constraints + guardrails and writes decisions + traces.

**Precision bar / SLO.** Every decision is reproducible: given the logged state + policy version, you can replay it. 100% of decisions emit a trace.

**Failure modes.** Optimizing EV with no cost/constraint model (spam); no "do nothing" action (over-action, brand fatigue); non-reproducible decisions (can't learn or audit); jumping to a learned policy with no backtest.

---

### Layer 8 — Agent execution layer (ACT)

**Purpose.** Execute the decided action through **specialized agents**, each operating on **pre-computed context** from the summary stores. Agents don't reason from scratch; they act on ready context. **LLMs narrate here.**

**Reference agent roster (template):**

| Agent | Job | Autonomy default |
|---|---|---|
| Web Research Agent | Gather account/persona context, trigger events | Autonomous (read-only) |
| Enrichment Agent | Fill/validate firmo/techno/contact data | Autonomous |
| Buying Committee Agent | Map stakeholders, roles, single-threaded risk | Autonomous (read-only) |
| Scoring Agent | Invoke models, write scores | Autonomous |
| Lookalike Agent | Build/refresh audiences | Assisted |
| Inbound Chat Agent | Real-time on-site chat w/ full context | Assisted → Autonomous |
| Email / LinkedIn Copy Agent | Draft personalized outreach | Assisted (human approves) → Autonomous once precision proven |
| Response / Reply Agent | Handle inbound replies, book meetings | Assisted |
| Routing Agent | Route lead to the right rep, instantly | Autonomous within rules |

**Build/Buy.** *Build* the orchestration and the context-injection contracts; *buy/adopt* an agent framework (`{{LangGraph / your own thin harness}}`) and models (`{{Claude / GPT / Gemini}}` via API). Keep agents **stateless** — all state lives in the stores.

**Guardrails (mandatory).**
- Every side-effecting action (send, post, book, route) is **gated by the policy layer + autonomy level**.
- **Human approval queue** for anything below "autonomous."
- **Kill-switch** per agent and global.
- Rate limits + suppression enforced *before* execution, not after.
- **Deliverability infrastructure** for any email-sending agent: dedicated/warmed sending domains separate from the corporate domain, per-domain daily send caps `{{≤ 30–50/mailbox/day for cold}}`, SPF/DKIM/DMARC enforced, bounce + spam-complaint monitoring wired to an automatic circuit-breaker (spam rate `{{> 0.1%}}` pauses the play). An autonomous copy agent that torches sender reputation does damage that takes *months* to undo — treat domain health as a hard constraint in the policy layer, same as consent.

**Precision bar / SLO.** No agent invents facts — narration is grounded in the summary/fact stores, with citations back to content IDs. Composition rule: an autonomous end-to-end play is only allowed when every primitive it depends on has independently cleared its precision bar.

**Failure modes.** Agents rebuilding context at runtime (cost/latency/hallucination); ungated side effects; hallucinated personalization; autonomy granted before precision earned.

---

### Layer 9 — Learning loop (LEARN)

**Purpose.** Turn every outcome into a model/policy improvement. Without this, it's not a Brain.

**What it must do.**
- **Outcome capture.** Link every action to its result: reply/no-reply, open, click, meeting booked, stage change, win/loss, expansion, churn — with the outcome's own timestamps.
- **Decision-trace store.** Persist, for every decision: inputs gathered, features computed, model versions + predictions, policy version, action taken, and eventual outcome. This is the **context graph of decisions** — the compounding moat.
- **Backtesting harness.** Replay historical state (point-in-time correct, no look-ahead) to evaluate policy/model changes *before* shipping.
- **Shadow mode.** New models/policies run in parallel, recommending but not acting; compare against human/incumbent decisions; measure lift.
- **Retraining & promotion.** Scheduled retraining; promote only on backtest + shadow win; roll back on regression.
- **Delayed ground truth.** Many labels arrive months later (was that de-anon right? did the deal close?). Build for late-arriving labels updating confidence and models.

**Build/Buy.** *Build.* Reference: decision traces in the warehouse; `{{MLflow}}` for experiments; a scheduled backtest job; a shadow-eval service; a promotion gate in CI.

**Precision bar / SLO.** No model/policy reaches production without a passing backtest *and* a shadow-mode period. Every promotion is logged and reversible.

**Failure modes.** Look-ahead leakage (offline hero, online zero); no shadow mode (you learn in production, on customers); discarding decision traces (nothing compounds).

---

### Layer 10 — Human Strategy Layer (STEER)

**Purpose.** Let leaders steer the system without touching code, and keep humans accountable for the objectives the Brain optimizes.

**What it must do.**
- Define/edit **ICP, segments, and segment priorities.**
- Set **guardrails & budgets**: send caps, ad spend, brand-fatigue rules, autonomy levels per play.
- **Approve/retire plays**; review the **approval queue** for assisted actions.
- View **why**: every recommendation is explainable back to features and precedent.
- Answer the three cadences the Brain exists to serve:
  - **Daily (rep):** "Here are the 5 accounts to focus on, ranked by EV, and why."
  - **Weekly (leadership):** "What's working, what's underperforming, what's at risk."
  - **Quarterly (strategy):** "Simulate: what happens if we move up-market / double outbound to healthcare / widen ICP to 200+ employees?" — run against the graph.

**Build/Buy.** *Build* a thin control-plane UI + config store; *buy* nothing critical here. Surfaces: a rep daily brief, a leadership dashboard, a play/guardrail admin, an approval queue.

**Failure modes.** A black box leaders can't steer (they turn it off); guardrails that live in code instead of config (ops can't move fast); no explainability (no trust, no adoption).

---

## 4. Cross-cutting spines

These run through *every* layer, not beside them.

### 4.1 Observability & lineage
Trace any decision back through action → policy → scores → features → facts → content. Monitor: pipeline freshness, feature drift, model calibration drift, agent action volumes, and guardrail hits. Tools: `{{OpenTelemetry + your metrics stack}}`, dbt lineage, model monitoring (`{{Evidently / WhyLabs}}`).

### 4.2 Data quality / ground-truth (the unglamorous moat)
- Treat data quality as a **daily discipline**, not a one-time cleanup.
- **Freshness stamps + decay models** on all enrichment (2-year half-life assumption).
- **Validation loops**: every bounce, "wrong person" reply, and closed-won stakeholder list feeds back to correct identity + enrichment confidence.
- Source-reliability scoring: learn *which providers lie, and when.*

### 4.3 Security, privacy & compliance
- Consent basis tracked per contact/source; honor GDPR/CCPA, CAN-SPAM, and regional rules in the **policy layer** (suppression before send).
- PII minimization, encryption at rest/in transit, access controls, audit logs.
- Data residency and vendor DPAs for every connected source and LLM provider.
- Human review gate for any autonomous outbound in regulated segments.

### 4.4 Orchestration & jobs
Async, multi-step workflows (research → enrich → score → summarize → decide) run on a durable orchestrator (`{{Temporal / Dagster}}`) with retries, idempotency, and dead-letter handling. Real-time paths bypass batch orchestration.

---

## 5. Canonical data contracts

Three schemas hold the system together. Adapt field names to your stack.

### 5.1 Entity (node)
```json
{
  "entity_id": "ent_person_9f83…",
  "type": "person | organization | product | segment | event",
  "canonical_name": "Sarah Chen",
  "identifiers": [
    {"kind": "email", "value": "schen@acme.com", "confidence": 0.99},
    {"kind": "linkedin", "value": "@sarahchen", "confidence": 0.9},
    {"kind": "cookie", "value": "…", "confidence": 0.6}
  ],
  "relationships": [
    {"predicate": "works_at", "target": "ent_org_acme", "valid_from": "2024-06-01"}
  ],
  "provenance": ["content_email_123", "content_call_456"]
}
```

### 5.2 Fact (temporal assertion)
```json
{
  "fact_id": "fact_00123",
  "subject_entity_id": "ent_org_acme",
  "predicate": "in_market",
  "value": true,
  "valid_from": "2026-03-15T00:00:00Z",
  "valid_to": null,
  "knowledge_time": "2026-03-15T09:12:00Z",
  "status": "active",
  "confidence": 0.82,
  "source_content_ids": ["content_web_988", "content_intent_771"]
}
```

### 5.3 Decision trace (the compounding asset)
```json
{
  "decision_id": "dec_55421",
  "occurred_at": "2026-03-16T13:04:00Z",
  "subject_entity_id": "ent_org_acme",
  "inputs": {"fact_ids": ["fact_00123", "…"], "summary_store_version": "acct_sum_v88"},
  "features": {"intent_velocity": 0.34, "committee_coverage": 3, "icp_fit": 0.91},
  "model_versions": {"propensity": "prop_v12", "ev": "ev_v4"},
  "predictions": {"p_convert": 0.61, "expected_value": 42000},
  "policy_version": "policy_v7",
  "action": {"type": "outbound_sequence", "play": "roi_close", "agent": "copy_agent",
             "autonomy": "assisted", "approved_by": "user_88"},
  "constraints_applied": ["send_cap", "brand_fatigue", "consent_ok"],
  "alternatives_considered": [{"action": "wait", "reason_rejected": "committee active now"}],
  "explanation": "3 committee members hit pricing this week; pattern matches Omega Inc pre-close cohort (73% conv/45d)",
  "outcome": {"label": "meeting_booked", "observed_at": "2026-03-19T10:00:00Z"}
}
```
> The `alternatives_considered` and `outcome` fields are what later let you ask: *"Given what we knew then, was this the right call?"* — the question that makes learning possible.

---

## 6. Build vs. buy summary (mid-market defaults)

| Component | Recommendation | Rationale |
|---|---|---|
| Source connectors / ELT | **Buy** | Commodity; don't build |
| CDP / event collection | **Buy** | Segment/RudderStack are mature |
| Warehouse / lakehouse | **Buy** | Snowflake/BigQuery/Databricks |
| Website de-anonymization | **Buy** | Data-scale network effect |
| Enrichment data | **Buy (multi-source)** | Blend + validate; no single provider is enough |
| Identity resolution engine | **Buy → Build** | Buy first; build if it's a differentiator |
| Relationship / entity graph | **Build** | Your ontology is proprietary |
| Bi-temporal fact store | **Build** | Core IP; not a product you can buy off-shelf |
| Feature store | **Build (lightweight)** | dbt + KV cache before Feast/Tecton |
| Models (scoring/EV/propensity) | **Build** | Improve on *your* outcomes; the moat |
| Summary / primitive stores | **Build** | The pre-compute-store-serve core |
| Policy / decision engine | **Build** | Encodes your GTM strategy |
| Agents | **Build harness + Buy LLMs** | Orchestration is yours; models are rented |
| Learning / backtest / shadow | **Build** | Non-negotiable, not buyable |
| Human Strategy control plane | **Build (thin)** | Must fit your operating model |

> **Fastest path for a mid-market team that doesn't want to build the whole thing:** adopt an integrated GTM Brain platform for identity + signals + agents, and build *only* the proprietary layers — your ontology, your models, your decision traces — on top. The moat is the accumulated decision intelligence, not the plumbing.

---

## 7. Phased implementation roadmap

Sequence for compounding value; don't boil the ocean. Precision at each phase gates the next.

### Phase 0 — Foundations (weeks `{{1–6}}`)
- Stand up warehouse + ELT + CDP; land raw immutable content.
- Instrument web/app; connect CRM, MAP, enrichment.
- Define the **starter ontology** (entities, relationships, first 20 facts) and ICP.
- **Exit criterion:** every P0 source flowing, event-time preserved, raw landing zone intact.

### Phase 1 — Identity + graph (weeks `{{5–12}}`)
- Identity resolution with confidence tiers; buy de-anonymization.
- Build entity + bi-temporal fact stores.
- **Exit criterion:** high-confidence identity `{{≥ 99%}}` precision; buying committee reconstructable for top accounts.

### Phase 2 — Compute + summaries (weeks `{{10–18}}`)
- Feature layer + first models (ICP fit, intent, propensity) — calibrated.
- Build summary/primitive stores + the ~500-token account summary.
- Ship the **rep daily brief** (recommend only — shadow mode).
- **Exit criterion:** reps trust the daily brief; models calibrated; summaries fresh.

### Phase 3 — Decide + act (assisted) (weeks `{{16–26}}`)
- Policy engine (rules + scores) with constraints + "do nothing."
- First agents (research, enrichment, committee, copy) in **assisted** mode with approval queue.
- Full decision-trace logging.
- **Exit criterion:** decisions reproducible; assisted actions beating baseline in shadow comparison.

### Phase 4 — Learn + graduate to autonomy (ongoing, from week `{{24}}`)
- Backtest harness + shadow mode; retraining + promotion gates.
- Graduate proven plays to **autonomous** within guardrails, one primitive at a time.
- Ship leadership weekly + quarterly simulation views.
- **Exit criterion:** closed-loop learning demonstrably improving conversion; autonomy expanding on evidence.

---

## 8. Team & operating model

| Role | Responsibility | Mid-market sizing |
|---|---|---|
| GTM/RevOps architect (owner) | Ontology, strategy layer, KPIs | `{{1}}` |
| Data engineer(s) | Ingestion, warehouse, feature layer | `{{1–2}}` |
| ML engineer / DS | Models, calibration, backtesting | `{{1}}` |
| Platform/backend eng | Graph, stores, policy engine, agent harness | `{{1–2}}` |
| RevOps analyst | Data quality, ground-truth loops, play config | `{{1}}` |
| Forward-deployed / GTM eng | Wire plays to reality, onboarding | `{{0.5–1}}` |

> Many mid-market teams start with **2–3 people** by buying the plumbing and building only the proprietary layers. Scale the team as autonomy (and stakes) grow.

---

## 9. KPIs, SLOs & the precision ladder

**System KPIs**
- Pipeline created / influenced by the Brain; win-rate lift vs. baseline.
- Speed-to-lead (P95 signal → first touch).
- Rep time reallocated: research → conversations.
- Decision quality: shadow-mode agreement + realized lift.

**Precision ladder (per primitive — autonomy gates on these)**

| Primitive | Precision bar for autonomy |
|---|---|
| Email validity | `{{≥ 98%}}` deliverable |
| Identity resolution (high-conf) | `{{≥ 99%}}` |
| Enrichment currency | `{{≥ 95%}}` current-at-use |
| ICP match | `{{≥ 95%}}` |
| Intent (de-anon → right person) | `{{≥ 99%}}` for 1:1 outbound |
| Personalization grounding | 100% grounded in facts (no hallucinated claims) |

**Operational SLOs**
- Real-time context P95 `{{< 2s}}`; summary staleness `{{< 15 min}}` (hot accounts).
- Model calibration checked `{{weekly}}`; drift alerts on.
- 100% of decisions traced; 100% of side effects gated.

---

## 10. Anti-patterns (things that kill these projects)

1. **The inference-time trap.** Assembling context inside every LLM call. Pre-compute instead.
2. **RAG-as-architecture.** A vector index over raw GTM text is not a context graph. You need resolved identity + temporal facts + computed features.
3. **Skipping identity precision.** Everything downstream inherits your worst identity guess. Tier by confidence.
4. **LLMs doing math.** Let models compute deterministically; let LLMs narrate. Never score with an LLM.
5. **Autonomy before precision.** Composing 80% primitives into an autonomous pipeline yields ~33% correctness at scale — delivered confidently.
6. **No decision traces.** If you don't log inputs→decision→outcome, nothing compounds and you can't backtest.
7. **Look-ahead leakage.** Backtests without point-in-time correctness produce models that shine offline and fail live.
8. **No "do nothing."** A policy that must always act produces brand fatigue and burns your best accounts.
9. **Guardrails in code, not config.** Ops can't steer; leadership loses trust; the system gets switched off.
10. **One-and-done data quality.** Data rots at ~2-year half-life; the moat is *keeping* it correct.
11. **Deliverability as an afterthought.** Autonomous sending from your corporate domain with no warmup, caps, or spam-rate circuit-breaker. One bad week of agent outbound can blacklist domains for months.
12. **Building for the system, not the rep.** If the daily brief isn't visibly better than the rep's own judgment in the first two weeks, adoption dies and the data flywheel never starts. Ship trust before autonomy.
13. **Write-back loops.** The Brain writes a score to the CRM, the CRM syncs it back as a "signal," the score reinforces itself. Tag all Brain-originated writes and exclude them from ingestion (see §12).

---

## 11. Coexistence statement

The Brain does **not** replace your CRM or warehouse. The **CRM remains the system of record for state** (the canonical customer record, pipeline, contacts). The **warehouse remains for analytics**. The Brain is the **system of record for events and decisions** — the layer that captures the event clock, builds the world model, and makes every other tool in the stack actually intelligent. It sits *on top of*, and writes back into, the existing stack.

---

## 12. CRM write-back contract

The Brain reads from everything but writes back *selectively*. Uncontrolled write-back is how these systems corrupt the CRM and create self-reinforcing signal loops.

**What the Brain writes to the CRM (template):**

| Object | Fields written | Cadence | Conflict rule |
|---|---|---|---|
| Account | `icp_tier`, `intent_score`, `ev_estimate`, `brain_summary_url` | On change, `{{≤ 1h}}` | Brain wins (system-owned fields) |
| Contact | `committee_role`, `engagement_band` | On change | Brain wins |
| Opportunity | `risk_flags[]`, `single_threaded`, `recommended_play` | Daily | Brain wins |
| Activity/Task | Recommended actions, completed agent actions | Real-time | Append-only |
| Notes | Decision explanation (human-readable) | On decision | Append-only |

**Rules of the contract:**
1. **Namespaced fields.** All Brain-owned fields live in a dedicated namespace/prefix (`{{brain__*}}`) so ownership is unambiguous and reps' fields are never overwritten.
2. **Loop prevention.** Every Brain-originated write carries a source tag (`{{integration user / brain_source=true}}`); the ingestion layer **excludes** these from the signal stream. A score must never become its own input.
3. **Human fields are read-only to the Brain.** Rep-entered notes, stages, and amounts are signals *in*, never targets *out* (stage changes are recommended, not executed, below full autonomy).
4. **Deep links, not data dumps.** Write the ~500-token summary URL and the explanation, not the whole context — the CRM stays the state record, the Brain stays the event record.
5. **Idempotent + replayable.** Write-backs keyed on `decision_id` so retries never duplicate.

---

## 13. Worked example — one play, end to end

A concrete trace of the "committee surge → assisted outbound" play, to make the layers tangible.

| T | Layer | What happens |
|---|---|---|
| T0 | **Observe** | Anonymous visitor hits `/pricing` 3x in one session. De-anon resolves to *Mike Torres, CTO @ Acme* at confidence 0.94 (high tier). |
| T0+2s | **Orient — graph** | Content item logged (immutable). Entity link `mike → acme` confirmed. Fact written: `{subject: acme, predicate: pricing_engagement, valid_from: T0, confidence: 0.94}`. |
| T0+5s | **Orient — compute** | Feature job recomputes: `committee_pricing_visitors_7d: 2 → 3`, `intent_velocity: +0.18`. Propensity model (v12) rescores: `p_convert 0.44 → 0.61`. EV: `$42K`. |
| T0+10s | **Orient — summarize** | Account summary regenerated (~500 tokens): committee, signals, risks (`single-threaded on Sarah — expand to Mike`), recommended play. |
| T0+12s | **Decide** | Policy (v7) evaluates candidates: `outbound_sequence(roi_close)` EV-net-of-cost beats `wait` and `ad_retarget`. Constraints pass: consent ✓, send cap ✓, fatigue ✓ (last touch 9 days ago). Decision trace `dec_55421` written with alternatives + explanation. Autonomy = **assisted** → queued for approval. |
| T0+15s | **Act — human gate** | AE sees the recommendation in the approval queue with the *why*; approves. Copy Agent drafts from summary-store facts only (grounded, cited); Routing Agent routes; email sends from warmed domain. Write-back: task logged to CRM, `brain__recommended_play` updated. |
| T0+3d | **Learn** | Reply received → outcome `meeting_booked` appended to `dec_55421`. Label flows to the outcome store; next retraining cycle sees one more positive for this feature pattern. Precedent is now queryable: *"accounts with 3+ committee pricing visitors in 7d → 73% conv."* |

**What to notice:** context was ready *before* the decision (pre-compute), the LLM only touched the final drafting step, "wait" was genuinely considered, a human gated the side effect, and the outcome closed the loop — all in one auditable trace.

---

## 14. Simulation engine (the quarterly "what if")

The three-layer graph makes counterfactuals possible; this is the mechanism.

**What it must do.**
- **ICP/what-if simulation:** re-run tiering + EV models over the graph with modified parameters ("widen ICP to 200+ employees") and report the delta in addressable EV, expected pipeline, and capacity load.
- **Policy replay:** re-run a candidate policy over the last `{{2–4 quarters}}` of point-in-time state (from the bi-temporal fact store) and compare chosen actions + projected outcomes vs. what actually happened.
- **Capacity/budget scenarios:** "double outbound to healthcare" → project constraint violations (AE capacity, send caps, budget) before committing.

**How it works.** Snapshot the graph *as of* a date (bi-temporality makes this a query, not an archaeology project) → apply the counterfactual (changed ICP, policy version, budget) → replay the decision engine in simulation mode (no side effects) → score outcomes with the calibrated models → report deltas with confidence intervals.

**Honesty constraints.** Simulations inherit model error — always report them as *model-projected*, with the calibration stats attached. Never present a simulation as a forecast without the assumption list. Off-policy estimates degrade the further the counterfactual sits from observed behavior; flag extrapolation.

**Build/Buy.** *Build* — it's ~80% shared machinery with the backtesting harness (§ Layer 9). Ship backtesting first; simulation is backtesting pointed at the future.

---

## 15. Cost model (template)

Order-of-magnitude annual estimates for a mid-market deployment; replace with quotes.

| Category | Line items | Annual estimate |
|---|---|---|
| Data infrastructure | Warehouse, ELT/CDP, orchestration | `{{$60–150K}}` |
| Data & enrichment vendors | De-anon, intent, enrichment (2–3 sources), conversation intelligence | `{{$50–150K}}` |
| LLM inference | Summarization jobs, agents, chat (pre-compute keeps this *low* — summaries are generated on change, not per query) | `{{$10–60K}}` |
| Graph & serving infra | Graph DB, fact store, cache, compute | `{{$20–60K}}` |
| Team (see §8) | `{{2–5 FTE}}` blended | `{{$400K–1.1M}}` |
| **Total** | | `{{~$550K–1.5M/yr}}` |

**Cost discipline notes.**
- The pre-compute architecture is itself the LLM cost control: if inference spend is growing linearly with queries, you've fallen into the inference-time trap.
- Track **cost per decision** and **cost per outcome** (meeting, opp, win) from day one; they're the numbers that justify (or kill) the program.
- Benchmark against the alternative: the fully-loaded cost of the SDR/research/ops capacity the Brain absorbs, and the pipeline lift it produces.

---

## 16. Risk register (template)

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Wrong-person autonomous outreach (identity error) | Med | High (brand) | Confidence tiers; 99% bar; assisted mode until proven |
| R2 | Sender-domain blacklisting | Med | High | §Layer 8 deliverability guardrails; circuit-breaker |
| R3 | Consent/privacy violation (GDPR/CCPA/CAN-SPAM) | Low | Severe | Suppression-before-send in policy layer; audit logs; legal review per play |
| R4 | Rep adoption failure | High | High | §17; shadow-mode trust building; explanation on every rec |
| R5 | LLM provider dependency / price shift | Med | Med | Provider-agnostic agent harness; narration is swappable by design |
| R6 | Model drift silently degrading decisions | Med | High | Calibration monitoring; drift alerts; shadow eval; rollback |
| R7 | Key-person dependency (ontology lives in one head) | Med | Med | Ontology as versioned config; docs; pair ownership |
| R8 | Data breach of the context graph (it's a PII-dense target) | Low | Severe | §4.3 controls; encryption; least-privilege; vendor DPAs |
| R9 | Write-back loop corrupts signals | Med | Med | §12 loop prevention; source tagging |
| R10 | Scope creep → nothing ships | High | High | Phase gates (§7); exit criteria enforced; "do less, precisely" |

---

## 17. Maturity model & adoption

**Self-assessment — where are you today?**

| Level | Name | You have… | Next move |
|---|---|---|---|
| 0 | Fragmented | 30 tools, human integration layer, tribal knowledge | Phase 0: land the data |
| 1 | Unified state | Warehouse + connected sources, dashboards | Phase 1: identity + graph |
| 2 | Scored | ICP/intent scores in the CRM, still human-decided | Phase 2: summaries + daily brief |
| 3 | Recommended | Brain suggests, humans decide (assisted) | Phase 3: policy + traces |
| 4 | Governed autonomy | Proven plays run autonomously in guardrails | Phase 4: expand play by play |
| 5 | Compounding | Closed-loop learning measurably improving quarter over quarter; simulation informs strategy | Defend the moat |

**Adoption plan (the part that actually determines success).**
1. **Start with the daily brief, not the agents.** Recommend-only for `{{2–4 weeks}}`; the brief must beat the rep's own account picks visibly and quickly.
2. **Explanation is non-negotiable.** Every recommendation carries the *why* (the `explanation` field) — reps extend trust to reasoning they can check, never to scores they can't.
3. **Recruit design partners.** `{{2–3}}` respected reps co-design the brief and plays; their wins become the internal case study.
4. **Never punish with the data.** The moment decision traces are used to grade reps, they'll starve the system. Traces improve the *system*, not the scorecard.
5. **Publish the wins and the misses.** A weekly "what the Brain got right / wrong" note builds calibrated trust faster than a perfect-seeming black box.
6. **Graduate autonomy publicly.** When a play moves from assisted → autonomous, announce the precision evidence that earned it. Autonomy is a promotion with a paper trail.

---

## Appendix A — Glossary
- **Context graph:** entities + typed relationships + temporal facts + decision traces, stitched across sources and time.
- **Event clock / State clock:** the causal record of *how/why* vs. *what is true now.*
- **Decision trace:** the logged reasoning connecting inputs → decision → outcome.
- **100% precision primitive:** a component that must hit near-perfect precision independently before composition into an autonomous workflow.
- **Ontological compaction:** compressing raw events into a small, structured summary an agent can act on.
- **OODA+L:** Observe, Orient, Decide, Act, Learn.
- **Bi-temporal:** tracking both when something was true (event time) and when we learned it (knowledge time).

## Appendix B — Starter ontology (fill in)
- **Entities:** `{{Account, Contact, Opportunity, BuyingCommittee, Segment, Product, Competitor, Play, Signal}}`
- **Relationships:** `{{works_at, member_of, reports_to, champion_of, competitor_of, evaluated, owns_opp}}`
- **Fact predicates (first 20):** `{{in_market, intent_score_band, budget_status, champion_status, stage, tech_stack_has, icp_tier, engaged_channel, single_threaded, renewal_window, …}}`

## Appendix C — Reference tech stack (one opinionated default)
Ingestion `{{RudderStack}}` → Warehouse `{{Snowflake}}` → Transform `{{dbt}}` → Graph `{{Neo4j}}` → Fact store `{{bi-temporal Postgres}}` → Features `{{dbt + Redis}}` → Models `{{XGBoost + MLflow}}` → Serving `{{FastAPI + Redis}}` → Orchestration `{{Temporal}}` → Agents `{{LangGraph + Claude/GPT}}` → Control plane `{{internal Next.js app}}` → Observability `{{OpenTelemetry + Evidently}}`.

## Appendix D — Changelog

| Version | Changes |
|---|---|
| v0.1 | Initial template: principles, OODA+L layers, data contracts, build/buy, roadmap, KPIs, anti-patterns. |
| v0.2 | Added §12 CRM write-back contract (incl. loop prevention); §13 worked end-to-end play example; §14 simulation engine spec; §15 cost model; §16 risk register; §17 maturity model + adoption plan. Added deliverability guardrails to the agent layer; added `explanation` field to the decision trace; clarified the supporting role of a semantic index; anti-patterns 11–13. |

---
*Template v0.2 — adapt all `{{placeholders}}` to your organization. This document intentionally separates deterministic computation (models), probabilistic narration (LLMs), and persistent memory (stores); preserve that separation as you implement.*
