# The Universal GTM Brain Skeleton

This is the **fixed backbone** every GTM Brain spec this plugin produces rests on. It is the shared spine of the three archetype templates (SaaS, professional services, e-commerce), with the variant-specific emphasis stripped out — that emphasis is added per org by a **lens** (see `lens-guide.md`).

**How the skills use this file.** The interview *discovers* the org-specific fill for each layer; it never reads this skeleton aloud to the owner or asks them to fill it directly. The `build-spec` skill maps the owner's business-layer answers onto these layers and proposes the fill. Nothing here is a menu shown to the owner.

Every layer below is **fixed in name and purpose**. What is *discovered per org* is the fill: which sources, which identities, which facts, which decisions, which tools. Placeholders read `{{like this}}`.

---

## First principles (the design tenets every spec inherits)

1. **Own the decision, not just the data.** The org's existing systems (CRM, commerce platform, ESP, PSA) store *state*. The Brain stores the **event clock** — what happened, in what order, and *why* a choice was made. That reasoning trace is the compounding asset.
2. **Two clocks.** The **State Clock** (what is true now) already lives in the org's systems of record. The Brain adds the **Event Clock** (the causal record of how/why).
3. **Context graph over RAG.** Model the world as **entities, relationships, and time-bounded facts** — not document chunks. A semantic/vector index over free text is a supporting actor (grounding narration), never the reasoning substrate.
4. **Pre-compute, store, serve.** Compute and summarize state *ahead of time* so agents read ready context in milliseconds. Rebuilding context inside every model call is the "inference-time trap."
5. **Separation of concerns.** **Models compute** (deterministic: scores, readiness, expected value). **LLMs narrate** (probabilistic: recommendations, copy, chat). **Stores remember** (persistent: "X looks like Y; historically do Z").
6. **Precision compounds — build primitives, not pipelines.** A five-step pipeline at 80%/step is ~33% correct end-to-end. Each primitive must hit production-grade precision independently before composition.
7. **Close the loop or it isn't a Brain.** Every decision emits a trace; every outcome feeds back. No feedback = a dashboard, not a Brain.
8. **Human-in-the-loop by default; autonomy by graduation.** New plays run shadow → assisted → autonomous. Precision earns autonomy.

---

## The loop: Observe → Orient → Decide → Act → Learn (OODA+L)

Every layer below maps to a stage of this loop. A spec is complete when all five stages are addressed for the org's priority decisions.

```
OBSERVE  →  ORIENT  →  DECIDE  →  ACT  →  LEARN
(sources,   (identity,  (policy /  (agents)  (outcomes →
 ingest)     graph,      decision            traces →
             features,    engine)             retrain)
             models,
             summaries)
```

---

## The layered spine (fixed; fill discovered per org)

### L0 — Sources (OBSERVE)
Every signal that informs a decision. **Fill:** `{{the org's 1st/2nd/3rd-party sources — site/app, system of record, messaging, ads, product/usage, conversations, enrichment, support, billing, inventory/PSA, consent}}`. Each event needs `source`, `event_type`, `occurred_at` (event time), and a raw identifier.

### L1 — Ingestion & streaming (OBSERVE)
Move signals into the Brain reliably. **Fill:** `{{two-speed plan — real-time path for latency-critical signals, batch/CDC for the rest; immutable raw landing zone; event-time + idempotency}}`.

### L2 — Identity resolution (ORIENT)
Resolve fragmented identifiers into canonical people/companies/customers — the substrate everything downstream inherits. **Fill:** `{{the org's identity strategy, confidence tiers, and what each tier may be used for}}`. This is a near-100%-precision primitive; track precision and recall separately.

### L3 — Context graph (ORIENT — the core), three strict sub-layers
- **L3a Content (evidence, immutable):** the append-only record of what was actually captured. **Fill:** `{{raw sources retained}}`.
- **L3b Entity (identity, resolved):** the people/orgs/products/segments/events content mentions, resolved to canonical IDs, with typed relationships. **Fill:** `{{the org's entities and relationships}}`.
- **L3c Fact (assertions, temporal / bi-temporal):** time-bounded, sourced assertions — the event clock. Every fact carries `subject`, `predicate`, `value`, `valid_from`/`valid_to`, `knowledge_time`, `status`, `confidence`, `source_content_ids[]`. **Fill:** `{{the org's first ~15 fact predicates}}`.

### L4 — Feature & signal computation (ORIENT)
Turn the graph into computed features decisions need (computed, not retrieved). **Fill:** `{{the org's account/customer/pursuit-level features}}`. Guarantee train/serve parity and point-in-time correctness.

### L5 — Model layer (ORIENT — deterministic compute)
The numbers that anchor every decision. **Models compute; they do not narrate.** **Fill:** `{{the org's scoring/propensity/EV/lookalike/risk models}}`. Report calibration, not just accuracy; log every prediction with features + version.

### L6 — Summary / primitive stores (ORIENT — serve)
Pre-compute, store, serve: compress history into ready-to-use context blocks. **Fill:** `{{the org's summary stores — e.g. account/customer state, intent, lookalike, enrichment, outcome/precedent}}`. Summaries are generated on change, never at query time.

### L7 — Policy / decision engine (DECIDE)
Map current state → the right action **including doing nothing**, under real constraints. **Fill:** `{{the org's decision types, hard constraints (capacity, budget, consent, margin, inventory, conflict/independence, fatigue caps), and how "wait" is a first-class action}}`. Every decision emits a **decision trace**. Start rules+scores; graduate to a learned policy only with a backtest harness.

### L8 — Agent execution (ACT)
Execute the decided action through specialized agents on pre-computed context. **LLMs narrate here.** **Fill:** `{{the org's agent roster and per-agent autonomy default}}`. Every side-effecting action is gated by the policy layer + autonomy level; kill-switch per agent and global; narration grounded in stores with citations.

### L9 — Learning loop (LEARN)
Turn every outcome into a model/policy improvement. **Fill:** `{{how the org captures outcomes, stores decision traces, backtests point-in-time, shadow-evaluates, and retrains}}`. Without this it is not a Brain.

### L10 — Human strategy layer (STEER)
Let leaders steer without touching code, and stay accountable for the objectives the Brain optimizes. **Fill:** `{{the org's ICP/segments, guardrails/budgets, play approvals, and the daily/weekly/quarterly cadences}}`.

---

## Cross-cutting spines (run through every layer)

- **Observability & lineage** — trace any decision back through action → policy → scores → features → facts → content.
- **Data quality / ground-truth** — treat as a daily discipline; freshness stamps + decay; validation loops.
- **Security, privacy & compliance** — consent basis per contact/source; honor applicable law in the policy layer (suppression before send); `{{plus org-specific obligations — e.g. TCPA for SMS, independence/ethical-walls for services, CMMC for regulated}}`.
- **Orchestration & jobs** — durable orchestrator for async multi-step work; real-time paths bypass batch.

---

## Canonical data contracts (adapt field names to the org's stack)

- **Entity (node):** `entity_id`, `type`, `canonical_name`, `identifiers[]` (kind/value/confidence), `relationships[]` (predicate/target/validity), `provenance[]`.
- **Fact (temporal assertion):** `fact_id`, `subject_entity_id`, `predicate`, `value`, `valid_from`/`valid_to`, `knowledge_time`, `status`, `confidence`, `source_content_ids[]`. **Bi-temporal**: distinguish event time from knowledge time so backtests carry no look-ahead leakage.
- **Decision trace (the compounding asset):** `decision_id`, `occurred_at`, `subject_entity_id`, `inputs` (fact_ids, summary version), `features`, `model_versions`, `predictions`, `policy_version`, `action` (type/play/agent/autonomy/approved_by), `constraints_applied[]`, `alternatives_considered[]`, `explanation`, `outcome` (label + observed_at).

---

## Coexistence statement (goes in every spec)

The Brain does **not** replace the org's systems of record. Their **system(s) of record for state** stay canonical (CRM / commerce platform / PSA); the **warehouse stays for analytics**; execution **rails stay the rails** (ESP / ads / email). The Brain is the **system of record for events and decisions** — the layer that captures the event clock and makes the rest of the stack intelligent. It sits on top of, and writes back selectively into, the existing stack.

---

## Anti-patterns to guard against (org-agnostic)

Inference-time trap · RAG-as-architecture · skipping identity precision · LLMs doing math · autonomy before precision · no decision traces · look-ahead leakage · no "do nothing" · guardrails in code not config · one-and-done data quality · write-back loops (tag Brain-originated writes; exclude from ingestion).
