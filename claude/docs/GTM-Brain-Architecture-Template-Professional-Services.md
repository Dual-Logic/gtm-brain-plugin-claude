# GTM Brain — Reference Architecture Template: Professional Services Variant
### A buildable blueprint for a self-learning go-to-market decision system at a mid-market professional services firm

> **How to use this document.** This is a *template*, not a finished design — adapted for a mid-market professional services firm (consulting, agency, accounting, legal, IT services; roughly `{{$10M–$150M revenue}}`, `{{50–500 professionals}}`, partner-led selling, an underused CRM, and a PSA/time-tracking system that knows more about clients than the CRM does). Substitute every `{{PLACEHOLDER}}`. The goal is a system that decides *which relationships and pursuits deserve scarce partner time — and when to do nothing* — executes through agents, and gets smarter from every outcome, while keeping your CRM/PSA as systems of record for *state*.

> **What's different from the SaaS variant.** In services GTM: (1) the **relationship graph is the asset** — deals come from people who know people, not anonymous intent surges; (2) the **scarcest resource is partner/senior time**, not inbox space or ad budget; (3) **delivery *is* marketing** — project health and client satisfaction are your strongest expansion and referral signals; (4) the highest-value decisions are **bid/no-bid** and **who makes the introduction**, not "which sequence to send"; and (5) **conflict-of-interest and independence rules** are hard constraints, not nice-to-haves.

---

## 0. Document control

| Field | Value |
|---|---|
| Owner | `{{BD/Growth Ops lead / Firm CTO}}` |
| Sponsor | `{{Managing Partner / CGO / Head of BD}}` |
| Version | `v0.2-PS (template)` — see Appendix D changelog |
| Status | Draft |
| Review cadence | Quarterly, or on major stack change |
| Related docs | Ideal Client Profile, practice-area strategy, conflict-check policy, data-governance policy, pursuit playbook library |

---

## 1. First principles

1. **Own the decision, not just the data.** The CRM says "Pursuit: Lost." It doesn't say the incumbent's audit partner golfs with their CFO, that your proposal was strongest on approach but 20% high on fees, or that the procurement lead joins `{{TargetCo}}` next quarter. The Brain stores the **event clock** — the reasoning and relationship context behind every pursuit — and that trace compounds.
2. **Two clocks.** The **State Clock** (pipeline stage, engagement status, WIP, utilization) lives in CRM/PSA. The **Event Clock** — how the relationship warmed, why the bid was won or lost, what was promised in the room — barely exists today. The Brain adds it.
3. **Relationship graph over RAG.** Services context is *who knows whom, how well, and since when*. Model the world as **people, organizations, relationships with strength and recency, and time-bounded facts** — not document chunks. *(A semantic index over proposals, SOWs, and meeting notes has a supporting role for grounding narration — it serves the graph, never replaces it.)*
4. **Pre-compute, store, serve.** Relationship warmth, follow-on probability, and pursuit context are computed and summarized *ahead of time*, so when a partner asks "should we bid?" or a trigger fires ("their GC just resigned"), the answer is ready in milliseconds — not assembled by an LLM rummaging through email at inference time.
5. **Separation of concerns.** **Models compute** (relationship strength, win probability, engagement EV, capacity fit — deterministic). **LLMs narrate** (pursuit briefs, meeting prep, proposal angles, introduction drafts). **Summary stores remember** ("Client X's follow-on pattern looks like Client Y's; historically, propose the diagnostic first").
6. **Precision compounds — and the stakes are relational.** A wrong-person email in SaaS costs a lead; in services it can cost a decade-old relationship. Every primitive (identity, relationship inference, conflict check, trigger detection, personalization) must clear its precision bar *independently* before composition — and the bar for anything touching a named senior contact is near-perfect.
7. **Close the loop or it isn't a Brain.** Every bid/no-bid, introduction, and pursuit emits a **decision trace**; every win, loss, follow-on, and referral is fed back. Otherwise you've built a fancier pipeline report.
8. **Human-in-the-loop by default; autonomy by graduation.** In a partner-led model, the Brain's default posture is **chief of staff, not rainmaker**: it briefs, drafts, flags, and recommends. Autonomy is earned play by play — and client-facing communication from senior relationships may *never* graduate past assisted, by policy.

---

## 2. Reference architecture at a glance

The system is a closed **OODA+L** loop: **Observe → Orient → Decide → Act → Learn.**

```
                            ┌───────────────────────────────────────────────┐
                            │              HUMAN STRATEGY LAYER               │
                            │  Ideal Client Profile, practice priorities,     │
                            │  bid thresholds, partner-time budgets,          │
                            │  conflict/independence rules, approval queue    │
                            └───────────────┬───────────────────────────────┘
                                            │ steer / approve / override
   OBSERVE            ORIENT                ▼            DECIDE           ACT
┌──────────┐   ┌──────────────────────────────────┐  ┌───────────┐  ┌──────────────┐
│ Sources  │   │  Identity + RELATIONSHIP Graph    │  │  Policy / │  │  Agent        │
│ email &  │──▶│   (who knows whom, how well,      │  │  Decision │─▶│  Execution    │
│ calendar,│   │    since when, decaying)          │  │  Engine   │  │  Layer        │
│ CRM, PSA,│   │           ▼                       │  │           │  │ (research,    │
│ time &   │   │  Context Graph (3 layers)         │  │ allocates │  │  brief, intro │
│ billing, │   │   • Content (evidence, immutable) │  │ PARTNER   │  │  draft, RFP   │
│ proposals│   │   • Entity (resolved identities)  │  │ TIME &    │  │  qual, prep,  │
│ & RFPs,  │   │   • Fact (temporal assertions)    │  │ pursuit   │  │  alumni watch)│
│ delivery │   │           ▼                       │  │ capacity  │  └──────┬───────┘
│ signals, │   │  Feature & Signal Computation     │  │ under     │         │ execute
│ events,  │   │  (warmth, triggers, follow-on)    │  │ conflict/ │         ▼
│ news &   │   │           ▼                       │  │ independ. │  CRM / PSA / email
│ filings  │   │  Model Layer (deterministic:      │  │ rules;    │  drafts / calendar /
└────┬─────┘   │   win prob, engagement EV,        │  │ incl. "do │  proposal system /
     │         │   follow-on, attrition risk)      │  │ nothing") │  Slack briefs
     │ stream  │           ▼                       │  └─────▲─────┘         │
     ▼         │  Summary / Primitive Stores       │        │               │
┌──────────┐   │  (relationship, pursuit, client   │────────┘               │
│ Ingestion│──▶│   health, trigger, outcome)       │   ranked pursuits      │
│ & CDC    │   └──────────────────────────────────┘   & actions            │
└──────────┘                                                                │
     ▲                         LEARN                                        │
     └──────────────────────────────────────────────────────────────────────
        Win/loss + follow-on + referral capture → decision traces →
        backtesting / shadow eval → model retraining → policy updates
```

**Cross-cutting spines:** Observability & lineage · Data quality / ground-truth · Security, privacy, **confidentiality & ethical walls** · Orchestration & jobs.

---

## 3. Layer-by-layer specification

Each layer: **Purpose → What it must do → Build/Buy → Precision bar / SLO → Failure modes.**

### Layer 0 — Sources: the services GTM surface (OBSERVE)

**Purpose.** Capture every signal that informs *who to pursue, through whom, and when* — most of which lives outside the CRM.

**Source inventory (template):**

| Category | Example sources | Signal type | Priority |
|---|---|---|---|
| **Email & calendar** | `{{Microsoft 365 / Google Workspace}}` | Who talks to whom, frequency, recency, meeting patterns — **the richest relationship source in the firm** | **P0** |
| CRM | `{{Salesforce / Dynamics / HubSpot / Intapp}}` | Clients, contacts, pursuits, stages | P0 |
| PSA / time & billing | `{{Kantata / Kimble / BigTime / Elite / Aderant}}` | Engagements, WIP, utilization, budget vs. actual, realization | **P0** |
| Proposals & RFPs | `{{Proposal tool / SharePoint / RFP portals}}` | Bids, pricing, win/loss, requirements | P0 |
| Delivery signals | Project health, milestone status, `{{NPS/CSAT}}`, QA reviews | Expansion + referral + attrition predictors | P1 |
| Events & marketing | Webinars, roundtables, conference attendance, content downloads | Warm-audience signals | P1 |
| People-move tracking | `{{LinkedIn / news / UserGems-style alumni tracking}}` | Client contacts and **firm alumni** changing jobs — warm doors | **P1** |
| News, filings & triggers | `{{8-K/M&A feeds, funding, leadership changes, litigation dockets, regulatory changes}}` | Demand triggers by practice area | P1 |
| Referral tracking | Source-of-introduction records | The dominant channel — must be captured, not remembered | P1 |
| 1st-party web | Site, insights/thought-leadership pages | Content engagement, de-anon visitors | P2 |
| Finance | `{{ERP}}` | Realized revenue, margin by client/engagement | P1 |

**Build/Buy.** *Buy* connectors; email/calendar relationship mining is buy-first (`{{Introhive / 4Degrees / Affinity-style}}`). *Build* only trigger-feed curation per practice area.

**Precision bar.** Every event: `source`, `event_type`, `occurred_at` (event time), raw identifier. Email/calendar ingestion respects privacy scope (§4.3) — metadata first, content only where policy allows.

**Failure modes.** Mining email content without a governance decision (partner revolt); missing the PSA (delivery blindness); referral source never recorded, so your best channel is invisible to the learning loop.

---

### Layer 1 — Ingestion & streaming (OBSERVE)

**Purpose.** Reliable movement of signals into the Brain. Services cadence is slower than SaaS — but **trigger events** (leadership change at a target, RFP drop, alumni move) still reward hours-not-days latency.

**What it must do.** Two-speed ingestion: near-real-time for triggers and web; batch/CDC for CRM/PSA/finance. Preserve event time; enforce idempotency; land an immutable raw copy.

**Reference stack.** `{{Fivetran/Airbyte}}` ELT → `{{Snowflake/BigQuery}}` → `{{dbt}}` → `{{Dagster/Temporal}}`. A CDP is usually unnecessary here; a webhook/polling path for trigger feeds is enough.

> **Mid-market reality check:** you don't need streaming infrastructure. Batch freshness of `{{≤ 1h}}` for triggers and `{{≤ 24h}}` for CRM/PSA covers virtually every services decision.

**SLO.** Trigger-to-available-context `{{< 1h}}`; PSA/CRM freshness `{{< 24h}}`.

**Failure modes.** Weekly batch that surfaces a trigger after the competitor's partner already called; double-ingested time entries inflating client-health features.

---

### Layer 2 — Identity + relationship graph (ORIENT — the defining primitive)

**Purpose.** Resolve people and organizations to canonical entities **and quantify the relationships between them**. In services, this layer *is* the moat: the firm's collective network, made explicit, current, and queryable.

**What it must do.**
- Collapse `J. Alvarez`, `jalvarez@client.com`, the LinkedIn profile, and the conference badge scan into **one canonical person** at **one canonical organization** — with employment history (people move; the relationship follows the person, not the domain).
- Compute **relationship strength** per (firm person ↔ external person) edge from email/calendar/meeting/deal history: frequency, recency, reciprocity, seniority — with **decay** (a strong 2019 relationship is a weak 2026 one).
- Track **firm alumni** and **client-contact job changes** as first-class graph events (the warm-door engine).
- Maintain org relationships: parent/subsidiary, `{{auditor_of / counsel_to / agency_of_record}}`, incumbent providers, and **conflict-relevant** ties.
- Never hard-merge on low confidence; links reversible; provenance kept.

**Build/Buy.** Relationship intelligence: *Buy-first* (`{{Introhive / 4Degrees / Affinity}}`). Alumni/job-change tracking: *Buy* (`{{UserGems-style}}`). Canonical entity + org graph: *Build* on `{{Neo4j / Neptune / Postgres}}` — the ontology is proprietary.

**Precision bar / SLO.** Identity high-confidence tier `{{≥ 99%}}` precision before any named outreach. Relationship-strength scores are **calibrated and explainable** ("strength 0.8 = 14 meetings, 60 emails, last touch 3 weeks ago") — partners will not trust a black-box number about *their* relationships.

**Failure modes.** Treating domain as identity (person changes jobs, you email the old company); relationship scores without decay; alumni invisible to the graph; a partner discovers the system "scored" their relationship wrong and evangelizes against the whole program.

---

### Layer 3 — The Context Graph (ORIENT — the core)

#### 3a. Content layer — *Evidence* (immutable)
Emails (per privacy scope), meeting notes, call/meeting transcripts, proposals, SOWs, RFP documents, pursuit debriefs, engagement QA reports. Append-only; everything downstream traces back to a content item. Store: `{{object storage + warehouse}}`.

#### 3b. Entity layer — *Identity + relationships* (resolved)
People, organizations, engagements, pursuits, practice areas, events, **relationships with strength/recency attributes** (from Layer 2). Store: graph DB.

#### 3c. Fact layer — *Assertions* (temporal, bi-temporal)
Time-bounded, sourced assertions — the services event clock:

> *"`{{TargetCo}}` issued an RFP for `{{tax advisory}}` on 2026-03-02; incumbent is `{{RivalFirm}}` (fact since 2021); their CFO (our alumna, strength 0.7) started 2026-01-15; budget authority moved to procurement on 2026-04-01."*

Every fact carries: `subject_entity_id`, `predicate`, `value`, `valid_from/valid_to`, `knowledge_time`, `status`, `confidence`, `source_content_ids[]`. **Bi-temporal** — you must be able to reconstruct "what did we know when we decided to bid?" for honest win/loss learning.

**Services-specific predicates to model early:** `incumbent_provider`, `contract_renewal_window`, `decision_maker`, `procurement_led`, `budget_cycle`, `alumni_at`, `referral_source`, `engagement_health`, `fee_sensitivity`, `conflict_flag`.

**Failure modes.** Mutable facts; facts without validity; win/loss "lessons" recorded as vibes in a debrief deck instead of queryable facts.

---

### Layer 4 — Feature & signal computation (ORIENT)

**Purpose.** Compute the features decisions need — computed, not retrieved.

**Services feature set (starter):**
- **Relationship coverage:** # of strong (≥ `{{0.6}}`) firm relationships into the account's decision group; single-threaded flag.
- **Warmth velocity:** relationship strength trend over `{{90d}}`.
- **Trigger recency/severity:** weighted trigger score by practice area (leadership change > funding > office move…).
- **Follow-on posture:** current engagement health × historical follow-on pattern of similar clients.
- **Wallet share:** our fees ÷ estimated external spend in our categories.
- **Client attrition risk:** delivery health + relationship decay + champion movement.
- **Capacity fit:** does the practice have staffable, qualified capacity in the pursuit's window? (PSA-derived — a pursuit you can't staff is a liability, not an opportunity.)

**Build/Buy.** *Build* in `{{dbt}}` + thin serving cache. Point-in-time correctness enforced for training.

**SLO.** Trigger features `{{< 1h}}`; relationship/health features daily.

---

### Layer 5 — Model layer (ORIENT — deterministic compute)

**Purpose.** Compute the numbers that anchor pursuit and relationship decisions. **Models compute; LLMs narrate.**

| Model | Output | Notes |
|---|---|---|
| **Ideal Client fit / tiering** | How much does this org look like our best clients (by practice)? | Segment by practice area |
| **Win probability** | P(win \| pursuit state, relationship coverage, incumbent, fee posture) | Calibrated — feeds bid/no-bid |
| **Engagement EV** | `P(win) × fee × margin × (1 + follow-on multiplier) − pursuit cost` | Pursuit cost includes **partner hours** at loaded rates |
| **Follow-on / expansion propensity** | P(next engagement \| delivery health, relationship, budget cycle) | The compounding revenue engine |
| **Client attrition risk** | P(losing the client in `{{12m}}`) | Delivery + relationship decay driven |
| **Referral likelihood** | Which satisfied contacts are likely referrers? | Feeds the advocacy plays |
| **Lookalike targets** | Orgs resembling best clients, reachable via existing relationships | "Reachable-warmth-weighted" lookalikes |

**Build/Buy.** *Build.* Interpretable baselines first (`{{logistic regression / GBTs}}`); **calibration over AUC** — a bid/no-bid threshold sits directly on these probabilities. Caveat: services firms have *small N* (hundreds of pursuits, not millions of events) — prefer simple models + strong priors + partner-elicited features over deep anything; report uncertainty honestly.

**Precision bar.** Every prediction logged with features + model version. Win-probability calibration reviewed with partners quarterly — trust is the product.

---

### Layer 6 — Summary / primitive stores (ORIENT → serve)

**Purpose.** Pre-compute, store, serve. Compress each client's and pursuit's history into ready context (~500 tokens) so briefs and agents never rebuild the world at runtime.

| Store | Contents | Consumed by |
|---|---|---|
| **Relationship Store** | Strength-scored edges, best-path-to-target, decay alerts | Intro agent, pursuit briefs |
| **Pursuit Store** | Bid state, requirements, incumbent, fee posture, win-prob, precedent pursuits | Bid/no-bid, proposal agent |
| **Client Health Store** | Delivery health, follow-on posture, attrition risk, wallet share | Account plans, QBR briefs |
| **Trigger Store** | Active triggers per target org, severity, freshness | Prioritization, alerting |
| **Outcome/Precedent Store** | Win/loss reasons, fee outcomes, follow-on patterns — searchable precedent | Learning loop, narration |
| **Client/Pursuit Summary Store** | The ~500-token compaction per client and per pursuit | Every agent, partner morning brief |

Example compaction:

```
Client: {{MeridianCo}} — PE-backed industrials, $400M rev, client since 2021
Relationships: CFO (strength 0.8, Partner {{A}}), Controller (0.6, Sr Mgr {{B}}) — GC relationship NONE (gap)
Engagements: {{Audit FY24-25}} (health: green), {{Tax diagnostic}} (completed, NPS 9)
Triggers: acquired {{SubCo}} 2026-05 → integration + {{purchase accounting}} need (severity: high)
Wallet share: ~35% — {{RivalFirm}} holds advisory
Follow-on model: 0.72 for {{transaction advisory}} in 2 quarters (basis: 14 precedent clients)
Risks: single-threaded on CFO; fee sensitivity flagged in FY25 renewal
Recommended play: partner-led intro to GC via {{alumnus C}}; propose integration diagnostic
```

**SLO.** Pursuit summaries refresh `{{< 1h}}` after material change; client summaries daily.

---

### Layer 7 — Policy / decision engine (DECIDE)

**Purpose.** Allocate the firm's scarcest resources — **partner/senior time and pursuit capacity** — to the highest-EV relationships and pursuits, under hard constraints, *including doing nothing*.

**Decision types (services-specific):**
1. **Bid / no-bid** — the flagship decision. EV net of pursuit cost, win probability vs. threshold `{{by practice}}`, capacity fit, strategic weight, conflict check. A disciplined *no-bid* is the single highest-ROI output of the whole system.
2. **Pursuit prioritization** — rank active pursuits for partner attention this week.
3. **Relationship investment** — which decaying strategic relationships get proactive touches; which warm doors (alumni moves) get an introduction request now.
4. **Trigger response** — act / prepare / watch / ignore, per trigger.
5. **Client protection** — attrition-risk interventions before renewal windows.
6. **Do nothing / wait** — first-class: "their fiscal year closes in 6 weeks; hold until budget cycle opens."

**Hard constraints:** partner-hour budgets per period; **conflict-of-interest and independence rules** (accounting/legal — a compliance gate, not a preference); relationship-fatigue caps (one coordinated ask per contact per `{{quarter}}`); proposal-team capacity; suppression (active litigation counterparties, procurement blackout windows).

**Design pattern.** Rules + calibrated scores first, transparent to partners; a learned policy only after `{{2+ years}}` of logged decision→outcome traces — small-N services data will not support bandits early, and pretending otherwise burns trust.

**Precision bar.** 100% of decisions traced and reproducible; conflict check is a blocking gate with an audit log.

**Failure modes.** EV without pursuit-cost (you bid on everything); no capacity fit (you win work you can't staff — a profitability and reputation disaster); conflict checking done socially instead of systemically.

---

### Layer 8 — Agent execution layer (ACT)

**Purpose.** Execute through specialized agents on pre-computed context. Default posture: **chief of staff to the partners.**

| Agent | Job | Autonomy default |
|---|---|---|
| Target Research Agent | Org/stakeholder research, trigger context | Autonomous (read-only) |
| Relationship Path Agent | Best warm path to a target person; drafts the internal "can you introduce me?" ask | Autonomous (internal only) |
| Alumni/People-Move Agent | Watch moves; open plays when a warm door appears | Autonomous (flagging) |
| RFP Qualification Agent | Parse RFP, extract requirements, score fit, draft bid/no-bid memo | Assisted |
| Pursuit Brief Agent | Pre-meeting brief: attendees, history, precedent, talking angles | Autonomous (internal) |
| Proposal Assist Agent | First-draft sections grounded in precedent store + qualifications database | Assisted |
| Outreach Draft Agent | Drafts client-facing emails **for the relationship owner to send** | Assisted — *client-facing sends by senior relationships never graduate past assisted, by policy* |
| Client Health Agent | Synthesize delivery + relationship signals; flag attrition risk | Autonomous (flagging) |
| Event Follow-up Agent | Post-event warm-list, draft follow-ups per attendee | Assisted |

**Guardrails (mandatory).** Every external side effect gated by policy + autonomy level; approval queue; per-agent and global kill-switch; **conflict gate before any pursuit action**; relationship-fatigue enforcement before send; drafts grounded 100% in summary/fact stores with citations; **the relationship owner is always the sender of record** for client-facing communication — the Brain drafts, the human owns. Deliverability hygiene (warmed domains, caps, spam-rate circuit-breaker) applies to any at-scale outreach (events, newsletters), though volumes are far lower than SaaS.

**Failure modes.** An agent emailing a Managing Director's 15-year client contact "on their behalf" without them knowing (program-ending); hallucinated credentials in a proposal (compliance/reputation event); internal intro requests spamming partners (fatigue caps apply internally too).

---

### Layer 9 — Learning loop (LEARN)

**Purpose.** Turn every pursuit and engagement outcome into model/policy improvement.

- **Outcome capture:** win/loss with structured reasons (fee, relationship, capability, incumbent advantage, timing), fee realized vs. proposed, follow-on materialization, referral generation, client attrition — with timestamps. **Institutionalize the win/loss debrief as structured facts**, not a slide.
- **Decision-trace store:** inputs, features, model versions, policy version, action, approver, outcome — for every bid/no-bid, prioritization, and introduction.
- **Backtesting:** point-in-time replay of bid/no-bid policy against historical pursuits (would the threshold have skipped losers and kept winners?).
- **Shadow mode:** the Brain's bid/no-bid recommendation runs silently alongside the partners' calls for `{{2 quarters}}`; compare.
- **Delayed ground truth:** follow-on and referral outcomes land 6–24 months later — build for late-arriving labels.
- **Small-N honesty:** report confidence intervals; resist over-updating on a handful of pursuits.

**Precision bar.** No model/policy promotion without backtest + shadow evidence; all promotions logged and reversible.

---

### Layer 10 — Human Strategy Layer (STEER)

**What leaders control:** Ideal Client Profile per practice; bid thresholds and pursuit-cost budgets; partner-time budgets; conflict/independence rule configuration; play approval/retirement; the assisted-action approval queue; autonomy levels.

**The three cadences:**
- **Daily (partner/BD):** "Your 5 highest-value actions today: `{{MeridianCo}}` integration trigger (draft intro via alumnus ready); `{{Pursuit X}}` proposal due Friday (win-prob 0.61, single-threaded — brief attached); relationship with `{{Key Contact}}` decaying (last touch 94 days)."
- **Weekly (practice leads):** pursuit pipeline by EV, bid/no-bid decisions + rationale, relationship-coverage gaps on strategic targets, at-risk clients.
- **Quarterly (management committee):** win-rate and fee-realization trends by practice; simulation: "What if we raised the bid threshold to `{{0.4}}` win-prob? Entered `{{healthcare}}`? Shifted two partners' time from delivery to BD?"

**Build/Buy.** *Build* a thin control plane: partner daily brief (email/Slack/Teams — meet partners where they live), pursuit board, play/guardrail admin, approval queue. Explainability on every recommendation.

---

## 4. Cross-cutting spines

**4.1 Observability & lineage.** Trace any recommendation back through action → policy → scores → features → facts → content. Monitor freshness, drift, calibration, agent volumes, guardrail hits.

**4.2 Data quality / ground-truth.** Contact data decays fastest exactly where it matters (people move); every bounce, "she left last year" reply, and closed pursuit's actual stakeholder list feeds identity correction. Relationship scores re-validated against partner feedback ("does 0.8 feel right?") — elicited ground truth is legitimate data here.

**4.3 Security, privacy, confidentiality & ethical walls.** This variant carries obligations SaaS doesn't: **client confidentiality and privilege** (legal), **independence** (audit), **ethical walls** between conflicting engagements — the graph must enforce *who may see which client's context*, not just row-level security as hygiene. Email/calendar mining runs under an explicit, communicated governance policy (metadata-first; content opt-in per policy). GDPR/CCPA and outreach consent handled in the policy layer. Insider-information handling rules where firms touch MNPI.

**4.4 Orchestration & jobs.** Durable orchestrator (`{{Temporal/Dagster}}`) with retries, idempotency, dead-letter handling.

---

## 5. Canonical data contracts

### 5.1 Entity (node) — note the relationship edge attributes
```json
{
  "entity_id": "ent_person_7ab2…",
  "type": "person",
  "canonical_name": "Jordan Alvarez",
  "identifiers": [
    {"kind": "email", "value": "jalvarez@meridianco.com", "confidence": 0.99},
    {"kind": "linkedin", "value": "/in/jalvarez", "confidence": 0.95}
  ],
  "employment_history": [
    {"org": "ent_org_meridian", "title": "CFO", "valid_from": "2026-01-15"},
    {"org": "ent_org_priorco", "title": "VP Finance", "valid_from": "2020-03-01", "valid_to": "2026-01-10"}
  ],
  "relationships": [
    {"predicate": "knows", "target": "ent_person_partnerA",
     "strength": 0.8, "last_interaction": "2026-06-30",
     "basis": {"meetings_24m": 14, "emails_24m": 60, "reciprocity": 0.9},
     "decay_model": "half_life_180d"},
    {"predicate": "alumni_of_firm", "target": "ent_org_ourfirm", "valid_to": "2024-08-01"}
  ],
  "provenance": ["content_cal_991", "content_email_1204"]
}
```

### 5.2 Fact (temporal assertion)
```json
{
  "fact_id": "fact_00871",
  "subject_entity_id": "ent_org_meridian",
  "predicate": "incumbent_provider",
  "value": {"category": "transaction_advisory", "provider": "ent_org_rivalfirm"},
  "valid_from": "2021-04-01",
  "valid_to": null,
  "knowledge_time": "2026-02-10T14:00:00Z",
  "status": "active",
  "confidence": 0.9,
  "source_content_ids": ["content_note_5521"]
}
```

### 5.3 Decision trace (bid/no-bid example — the compounding asset)
```json
{
  "decision_id": "dec_20114",
  "occurred_at": "2026-03-05T16:00:00Z",
  "subject_entity_id": "pursuit_meridian_tas",
  "decision_type": "bid_no_bid",
  "inputs": {"fact_ids": ["fact_00871", "…"], "summary_version": "pursuit_sum_v31"},
  "features": {"relationship_coverage": 2, "win_prob": 0.61, "capacity_fit": 0.9,
               "incumbent_present": true, "trigger_severity": "high"},
  "model_versions": {"win_prob": "wp_v6", "ev": "ev_v3"},
  "predictions": {"engagement_ev": 310000, "pursuit_cost": 42000, "follow_on_multiplier": 1.6},
  "policy_version": "policy_v4",
  "constraints_applied": ["conflict_check_pass", "partner_hours_available", "independence_ok"],
  "action": {"type": "bid", "pursuit_team": ["partnerA", "srmgrB"], "autonomy": "assisted",
             "approved_by": "practice_lead_02"},
  "alternatives_considered": [{"action": "no_bid", "reason_rejected": "warm path via alumnus + high-severity trigger offsets incumbent advantage"}],
  "explanation": "Win-prob 0.61 vs practice threshold 0.35; EV $310K net $42K pursuit cost; CFO relationship 0.8; integration trigger 6 weeks old; incumbent weak in {{purchase accounting}} per precedent P-88.",
  "outcome": {"label": "won", "fee_realized": 285000, "observed_at": "2026-05-20", "follow_on": {"label": "pending"}}
}
```

---

## 6. Build vs. buy summary (mid-market services defaults)

| Component | Recommendation | Rationale |
|---|---|---|
| Connectors / ELT | **Buy** | Commodity |
| Warehouse | **Buy** | `{{Snowflake/BigQuery}}` |
| Email/calendar relationship mining | **Buy** | `{{Introhive / 4Degrees / Affinity}}` — mature category |
| Alumni / people-move tracking | **Buy** | `{{UserGems-style}}` |
| Trigger/news feeds | **Buy + curate** | Curated per practice area |
| Enrichment data | **Buy (multi-source)** | Blend + validate |
| Canonical entity + org graph | **Build** | Your ontology (incumbents, conflicts, warm paths) is proprietary |
| Bi-temporal fact store | **Build** | Core IP |
| Feature layer | **Build (lightweight)** | dbt + cache |
| Models (win-prob, EV, follow-on, attrition) | **Build** | Small-N, firm-specific, the moat |
| Summary / primitive stores | **Build** | Pre-compute-store-serve core |
| Policy engine (bid/no-bid, allocation, conflict gate) | **Build** | Encodes firm strategy + compliance |
| Agents | **Build harness + Buy LLMs** | — |
| Learning / backtest / shadow | **Build** | Non-negotiable |
| Control plane / partner brief | **Build (thin)** | Meet partners in email/Teams |

> **Fastest path:** buy relationship intelligence + alumni tracking + ELT, and build only the proprietary layers — the ontology (incumbents, conflicts, warm paths), the EV/win-prob models, and the decision traces. The moat is the firm's explicit relationship graph plus accumulated pursuit intelligence.

---

## 7. Phased implementation roadmap

### Phase 0 — Foundations (weeks `{{1–6}}`)
Warehouse + ELT; connect CRM, PSA, email/calendar (metadata-first under governance policy), proposals archive. Define Ideal Client Profile per practice + starter ontology. **Exit:** P0 sources flowing; email/calendar governance signed off by `{{GC / risk}}`.

### Phase 1 — Identity + relationship graph (weeks `{{5–14}}`)
Canonical identity with confidence tiers; relationship strength with decay; alumni tracking live; org graph with incumbents + conflict-relevant ties. **Exit:** identity `{{≥ 99%}}` (high tier); partners validate relationship scores as directionally right; conflict data queryable.

### Phase 2 — Compute + summaries + the partner brief (weeks `{{12–20}}`)
Feature layer; first models (client fit, win-prob, follow-on) — calibrated, uncertainty reported; summary stores; ship the **partner daily brief** (recommend-only). **Exit:** partners open the brief unprompted; at least one warm-door play converts to a meeting.

### Phase 3 — Decide + act (assisted) (weeks `{{18–28}}`)
Policy engine with bid/no-bid, capacity fit, conflict gate, "do nothing"; RFP qualification, pursuit brief, relationship-path, and outreach-draft agents in assisted mode; full decision traces. **Exit:** bid/no-bid memos in shadow beat the historical hit rate on backtest; zero conflict-gate misses.

### Phase 4 — Learn + graduate (from week `{{26}}`, ongoing)
Backtesting + shadow eval; structured win/loss capture institutionalized; graduate internal-facing agents to autonomous; client-facing drafting stays assisted by policy. Quarterly simulation for the management committee. **Exit:** measurable win-rate or no-bid-savings lift attributable to the Brain.

---

## 8. Team & operating model

| Role | Responsibility | Sizing |
|---|---|---|
| GTM/BD architect (owner) | Ontology, strategy layer, partner adoption | `{{1}}` |
| Data engineer | Ingestion, warehouse, features | `{{1}}` |
| ML/DS (part-time OK early) | Models, calibration, backtesting | `{{0.5–1}}` |
| Platform eng | Graph, stores, policy engine, agents | `{{1}}` |
| BD/Marketing ops analyst | Data quality, win/loss capture, play config | `{{1}}` |
| Practice-area champions | Ontology input, trust building | `{{1 per practice, fractional}}` |

> Services firms can start at **2–3 FTE** by buying relationship intelligence and building only the proprietary layers. The practice-champion role is not optional — it's the adoption mechanism.

---

## 9. KPIs, SLOs & the precision ladder

**System KPIs**
- Win rate by practice (and **no-bid savings**: partner hours not spent on low-probability pursuits).
- Follow-on/expansion revenue rate; referral-sourced pipeline.
- Relationship coverage on strategic targets (strong paths per target).
- Speed-to-trigger (trigger → partner action, P95).
- Client attrition caught early (interventions before renewal window).

**Precision ladder (autonomy gates)**

| Primitive | Bar |
|---|---|
| Identity (high-conf, named outreach) | `{{≥ 99%}}` |
| Employment currency (right company today) | `{{≥ 97%}}` |
| Relationship strength (partner-validated) | Directionally endorsed by `{{≥ 80%}}` of sampled owners |
| Conflict check | **100% — blocking gate, audited** |
| Trigger relevance | `{{≥ 90%}}` precision per practice |
| Draft grounding (proposals, outreach) | 100% grounded; zero hallucinated credentials/experience |

**Operational SLOs.** Trigger context `{{< 1h}}`; pursuit summary staleness `{{< 1h}}` on material change; 100% decisions traced; 100% external side effects gated.

---

## 10. Anti-patterns (services edition)

1. **The inference-time trap.** Assembling pursuit context inside every LLM call. Pre-compute.
2. **RAG-as-architecture.** A vector index over proposals is not a relationship graph.
3. **Domain-as-identity.** People move; the relationship follows the person. Model employment history.
4. **Relationship scores without decay or explainability.** Partners will test the number against their gut once — fail that test and adoption is over.
5. **LLMs doing math.** Win probability and EV are computed, never narrated into existence.
6. **Autonomy before precision — with relational stakes.** One agent-sent email to a partner's marquee contact can end the program.
7. **No decision traces / debrief-as-slideware.** Win/loss lessons that aren't structured facts don't compound.
8. **No "no-bid."** A policy that always says bid burns the firm's scarcest asset on 15%-probability RFPs.
9. **Ignoring capacity fit.** Winning unstaffable work is a profitability and reputation failure, not a victory.
10. **Conflict checking as a social process.** It must be a systemic, blocking, audited gate.
11. **Email mining without governance.** Do the privacy/confidentiality work *first*, publicly — or lose the partners on day one.
12. **Building for BD ops, not partners.** If the daily brief doesn't save a partner visible time in two weeks, the flywheel never starts.
13. **Write-back loops.** Tag Brain-originated CRM/PSA writes; exclude from ingestion (§12).
14. **Over-updating on small N.** Ten pursuits is an anecdote, not a distribution — report uncertainty.

---

## 11. Coexistence statement

The Brain replaces neither CRM nor PSA. The **CRM remains the record of pursuits and contacts**; the **PSA remains the record of engagements, time, and billing**; the **warehouse remains for analytics**. The Brain is the **system of record for relationships, events, and decisions** — the firm's explicit network and pursuit intelligence — sitting on top of, and writing selectively back into, the existing stack.

---

## 12. CRM/PSA write-back contract

| Object | Fields written | Cadence | Conflict rule |
|---|---|---|---|
| Account/Client | `brain__client_tier`, `brain__attrition_risk`, `brain__wallet_share`, `brain__summary_url` | Daily / on change | Brain wins (namespaced) |
| Contact | `brain__relationship_strength_max`, `brain__employment_current`, `brain__alumni_flag` | On change | Brain wins |
| Pursuit/Opportunity | `brain__win_prob`, `brain__ev`, `brain__recommended_action`, `brain__capacity_fit` | Daily | Brain wins |
| Activity/Task | Recommended actions; completed agent actions | Real-time | Append-only |
| Notes | Decision explanations (bid/no-bid memos, trigger rationale) | On decision | Append-only |

**Rules:** namespaced `brain__*` fields only; every write tagged (`brain_source=true`) and **excluded from ingestion** (loop prevention); human/partner fields read-only to the Brain; deep links to summaries, not data dumps; writes keyed on `decision_id` (idempotent). PSA write-back is minimal and read-mostly — the Brain reads delivery signals, it does not touch time or billing records.

---

## 13. Worked example — one play, end to end

**Play: alumni warm door + acquisition trigger → assisted pursuit.**

| T | Layer | What happens |
|---|---|---|
| T0 | **Observe** | News feed: `{{MeridianCo}}` acquires `{{SubCo}}` ($60M). People-move agent had logged (T-60d): firm alumna `{{Dana K.}}` is now Meridian's Corp Dev lead. |
| T0+20m | **Orient — graph** | Content logged. Facts written: `acquired(SubCo)`, trigger severity high for `{{transaction advisory + integration}}`. Graph shows: CFO relationship 0.8 (Partner A), alumna Dana (warm, 0.7 via two former colleagues), **no GC relationship** (gap). Incumbent: RivalFirm (advisory). |
| T0+30m | **Orient — compute** | Features refresh: trigger score high; relationship coverage 2; capacity fit 0.9 (PSA shows staffable bench in `{{8 weeks}}`). Win-prob model: 0.61. EV $310K net $42K pursuit cost, follow-on multiplier 1.6. |
| T0+35m | **Orient — summarize** | Pursuit summary generated (~500 tokens) incl. precedent P-88: "incumbent weak in purchase accounting — we won 3 of 4 similar displacement pursuits post-acquisition." |
| T0+40m | **Decide** | Policy evaluates: `open_pursuit` beats `watch` and `do_nothing` (trigger is time-boxed). Constraints: conflict check **pass**, partner hours available, fatigue OK (no coordinated ask to Meridian in 2 quarters). Decision trace `dec_20114` written; autonomy = assisted → practice lead approval queue. |
| T0+2h | **Act — human gate** | Practice lead approves with the *why* attached. Relationship-path agent drafts the internal ask to the two colleagues who know Dana; outreach-draft agent prepares Partner A's note to the CFO referencing the integration (grounded in facts only). **Partner A sends personally.** Pursuit brief scheduled for the first meeting. CRM write-back: pursuit created, `brain__win_prob=0.61`. |
| T0+10w | **Learn** | Won at $285K realized. Outcome + structured loss-avoidance notes appended to `dec_20114`; precedent store updated ("post-acquisition displacement, warm alumna path"). Follow-on watch opens for `{{integration phase 2}}`, label pending. |

**Notice:** the warm door was *pre-computed* months earlier; the conflict gate ran before anything moved; the LLM only drafted; the partner owned every client-facing touch; the win became queryable precedent.

---

## 14. Simulation engine (the quarterly "what if")

- **Bid-threshold simulation:** replay last `{{2 years}}` of pursuits under a different win-prob threshold → projected win rate, revenue, and partner hours saved.
- **Practice-entry / ICP shift:** re-run fit + EV over the graph for a new sector — weighted by *reachable warmth* (targets you can actually get to through existing relationships), not just firmographics.
- **Partner-time reallocation:** "shift `{{Partner A}}` 20% from delivery to BD" → projected pursuit capacity and EV delta vs. delivery margin impact (PSA-informed).
- **Relationship-investment scenarios:** which decaying strategic relationships, if re-warmed, unlock the most gated EV?

**Mechanism:** bi-temporal snapshot → counterfactual parameters → replay decision engine (no side effects) → score with calibrated models → deltas **with confidence intervals** (small-N: intervals will be wide — show them anyway). Build after the backtesting harness; it's the same machinery pointed forward.

---

## 15. Cost model (template)

| Category | Line items | Annual estimate |
|---|---|---|
| Data infrastructure | Warehouse, ELT, orchestration | `{{$40–100K}}` |
| Relationship intelligence + alumni tracking | `{{Introhive/4Degrees + UserGems-style}}` | `{{$40–120K}}` |
| Trigger/news/enrichment feeds | Curated per practice | `{{$20–60K}}` |
| LLM inference | Briefs, drafts, summaries (pre-computed on change) | `{{$5–30K}}` |
| Graph & serving infra | Graph DB, fact store, cache | `{{$15–40K}}` |
| Team (§8) | `{{2–4 FTE}}` blended | `{{$350K–900K}}` |
| **Total** | | `{{~$470K–1.25M/yr}}` |

**Justification math to track from day one:** partner hours saved on no-bids × loaded rate; win-rate lift × average engagement value; attrition saves; referral pipeline attributed. In services, **no-bid savings alone** often pays for the program.

---

## 16. Risk register (template)

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Agent contacts a partner's client without them (relationship damage) | Med | **Severe** | Relationship-owner-as-sender policy; assisted-only for client-facing; kill-switch |
| R2 | Conflict/independence miss | Low | **Severe** | Blocking systemic gate; audit log; risk-team sign-off on rules |
| R3 | Email/calendar mining privacy backlash | Med | High | Governance-first (§4.3); metadata-first; transparent comms; opt-outs |
| R4 | Confidentiality/ethical-wall breach via the graph | Low | Severe | Wall-aware access control in the graph itself; access audits |
| R5 | Partner adoption failure | High | High | §17; brief must save visible time in 2 weeks; practice champions |
| R6 | Hallucinated credentials in proposals | Med | High | 100% grounding to qualifications DB; assisted review; citation checks |
| R7 | Small-N overfitting (win-prob model looks great, isn't) | Med | Med | Simple models, priors, intervals, quarterly partner calibration review |
| R8 | Employment-data staleness (wrong-company outreach) | Med | High | People-move tracking; currency bar `{{≥ 97%}}`; bounce feedback loop |
| R9 | Write-back loops | Med | Med | §12 tagging + ingestion exclusion |
| R10 | Scope creep / boiling the ocean | High | High | Phase gates; ship the partner brief before any agent |

---

## 17. Maturity model & adoption

**Self-assessment:**

| Level | Name | You have… | Next move |
|---|---|---|---|
| 0 | Tribal | Relationships in partners' heads; CRM is a graveyard | Phase 0 |
| 1 | Connected | Warehouse + CRM/PSA/email flowing | Phase 1: relationship graph |
| 2 | Mapped | Explicit, scored, decaying relationship graph; alumni tracked | Phase 2: brief + models |
| 3 | Advised | Bid/no-bid memos, pursuit briefs, warm-door alerts — humans decide | Phase 3: policy + traces |
| 4 | Governed autonomy | Internal agents autonomous; client-facing assisted by policy | Phase 4 |
| 5 | Compounding | Pursuit intelligence measurably lifting win rate & no-bid savings QoQ | Defend the moat |

**Adoption plan (partner-led firms live or die here):**
1. **Ship the partner daily brief first** — recommend-only, in email/Teams where partners already live. It must save visible time in `{{2 weeks}}`.
2. **Explanation on everything.** Partners extend trust to reasoning they can check ("strength 0.8 = 14 meetings…"), never to a bare score — especially about *their* relationships.
3. **Practice champions co-design** the ontology and plays; their wins become the internal case study.
4. **Never grade partners with the data.** The moment traces feed compensation reviews, partners starve the system (they'll stop logging, stop syncing calendars, stop debriefing honestly).
5. **Do the privacy governance publicly and first.** A signed, communicated email/calendar policy converts the biggest objection into a trust asset.
6. **Publish wins and misses weekly.** Calibrated trust beats a perfect-seeming black box.
7. **Graduate autonomy with a paper trail** — and codify that client-facing sends by senior relationships stay assisted forever. Saying it out loud removes the fear.

---

## Appendix A — Glossary
- **Relationship graph:** people + orgs + strength/recency-scored edges + employment history — the firm's explicit network.
- **Warm door:** a path to a target created by an alumni move, client-contact job change, or existing strong relationship.
- **Bid/no-bid:** the gated decision to pursue or pass on an opportunity; the flagship policy decision in services.
- **Pursuit cost:** fully loaded cost to chase a deal, dominated by partner/senior hours.
- **Follow-on multiplier:** expected downstream engagement value conditional on winning and delivering well.
- **Ethical wall:** access barrier between teams serving conflicting clients — enforced in the graph.
- **Event clock / State clock, decision trace, bi-temporal, ontological compaction, OODA+L:** as in the SaaS variant.

## Appendix B — Starter ontology (fill in)
- **Entities:** `{{Client, Prospect, Person, Pursuit, Engagement, PracticeArea, Event, Alumni, Referral, Competitor/Incumbent, Play, Trigger}}`
- **Relationships:** `{{knows(strength, recency), works_at(history), alumni_of, referred, incumbent_provider, counsel_to/auditor_of, member_of_decision_group, conflict_with}}`
- **Fact predicates (first 20):** `{{incumbent_provider, contract_renewal_window, decision_maker, procurement_led, budget_cycle, trigger_active, engagement_health, fee_sensitivity, wallet_share_band, attrition_risk_band, alumni_at, referral_source, conflict_flag, single_threaded, …}}`

## Appendix C — Reference tech stack (one opinionated default)
ELT `{{Fivetran}}` → Warehouse `{{Snowflake}}` → Transform `{{dbt}}` → Relationship intel `{{Introhive/4Degrees}}` + moves `{{UserGems-style}}` → Graph `{{Neo4j}}` → Fact store `{{bi-temporal Postgres}}` → Features `{{dbt + Redis}}` → Models `{{scikit-learn/GBTs + MLflow}}` → Serving `{{FastAPI + Redis}}` → Orchestration `{{Temporal}}` → Agents `{{LangGraph + Claude/GPT}}` → Partner brief `{{email/Teams delivery + thin internal app}}` → Observability `{{OpenTelemetry + Evidently}}`.

## Appendix D — Changelog

| Version | Changes |
|---|---|
| v0.2-PS | Initial Professional Services variant, derived from SaaS template v0.2: relationship graph as the defining Layer 2; bid/no-bid as the flagship policy decision; partner-time as the allocated resource; conflict/independence as blocking gates; delivery-as-marketing signals via PSA; alumni/warm-door plays; small-N modeling honesty; confidentiality/ethical-wall spine; services-specific worked example, cost model, risks, maturity, and adoption plan. |

---
*Template v0.2-PS — adapt all `{{placeholders}}` to your firm. Deterministic computation (models), probabilistic narration (LLMs), and persistent memory (stores) stay separated; and in this variant, the human relationship owner stays the sender of record.*
