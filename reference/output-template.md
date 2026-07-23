# The Working Document Template

This is the scaffold for the **one document** the interview produces and continuously fills. It is created in the owner's project at the start (see `working-doc-convention.md` for location and resume mechanics) and every phase reads it and updates its own section.

The document has three parts, in this order:

1. **Strategy Readout** — business language, the part the owner reads and confirms.
2. **Build Spec** — the technical body a builder or vendor executes, resting on the universal skeleton.
3. **Open Items / Next Steps** — the auto-assembled handoff punch list.

A **phase-progress marker** sits at the very top so any phase can resume mid-stream.

---

## The provenance convention (used throughout the Build Spec)

Every **material technical decision** in the Build Spec carries exactly one tag:

- `[Stated]` — the owner said this directly. Load-bearing intent.
- `[Proposed]` — the plugin inferred and drafted it, but the owner has not yet ratified it. The working state during drafting; low-risk items may ship in this state (build-spec bounds the confirm loop to protect the time budget).
- `[Proposed — confirmed]` — a `[Proposed]` item the owner ratified in plain language. Settled.
- `[Open — needs your team]` — a gap or assumption the owner could not resolve. Never fabricate a value to avoid this tag; tag it Open and route it to Open Items.

The `finalize` phase aggregates every `[Open]` item plus every remaining `[Proposed]` item (inferred but never ratified — plausible but unverified) into the **Open Items / Next Steps** section, and runs a coverage pass flagging any material technical statement left untagged. `[Stated]` and `[Proposed — confirmed]` items are settled and do not go to Open Items. A builder reads the tags to tell owner intent from plugin inference from open gaps.

---

## Phase-progress marker (top of the working doc — the resume anchor)

```
<!-- GTM-BRAIN-PROGRESS
phase: <profile-and-goals | strategy-readout | build-spec | finalize | complete>
last_completed_step: <short label of the last finished step within the phase>
lens: <(undetermined) | saas | professional-services | e-commerce | blend:<a>+<b> | universal>   # (undetermined) until profile-and-goals classifies
captured_inputs:
  business: <raw goals, priority decisions, constraints as the owner said them>
  tools: <named tools by capability category>
  <phase-specific raw inputs, verbatim — not only synthesized output>
-->
```

Keep the marker current at each step, not only at phase boundaries. Store **raw captured inputs**, not just synthesized output, so a mid-phase resume never re-asks a question the owner already answered. On completion, `finalize` moves this whole block to the **bottom** of the document so the finished spec opens straight into the title (see `working-doc-convention.md`); it stays an invisible HTML comment, record intact.

---

## Part 1 — Strategy Readout (business language)

> Written by `strategy-readout`. The owner confirms this ("is this my business?") before the Build Spec is finalized.

- **What your GTM Brain is** — 2–4 sentences, plainly: the stateful decision system this org is building and the end-state picture (what changes once it runs).
- **The decisions it makes for you** — the priority decisions the owner most wants automated, in their words, each with the plain-language outcome ("when X happens, the Brain decides Y so your team can Z").
- **What it watches and remembers** — the org's signals and the "memory" (the event clock) in business terms.
- **How it earns trust** — shadow → assisted → autonomous, in one paragraph: it recommends first, acts only once proven.
- **What you'll hand your team** — one line pointing to the Build Spec below and the Open Items list.

---

## Part 2 — Build Spec (technical body — rests on the universal skeleton)

> Written by `build-spec`. Every material decision is provenance-tagged. Fill each layer from `gtm-brain-skeleton.md`; the lens (`lens-guide.md`) sets emphasis. Capability names map to the org's actual tools per `capability-map.md`.

### 2.1 Architecture body (per the skeleton, L0–L10)

For each layer, state the org-specific fill with provenance tags:

- **L0 Sources** — `{{sources}}` `[tag]`
- **L1 Ingestion & streaming** — `{{two-speed plan}}` `[tag]`
- **L2 Identity resolution** — `{{strategy + confidence tiers}}` `[tag]`
- **L3 Context graph** — all three sub-layers, explicitly: content (evidence), entity (resolved), and the **bi-temporal fact layer / event clock** — time-bounded, sourced assertions (`valid_from`/`valid_to`, `confidence`, source), incl. the first ~15 fact predicates. Do not collapse the fact layer into event names or features. `[tag]`
- **L4 Features** — `{{computed features}}` `[tag]`
- **L5 Models** — `{{models + calibration note}}` `[tag]`
- **L6 Summary stores** — `{{stores}}` `[tag]`
- **L7 Policy / decision engine** — `{{decision types, hard constraints, "do nothing"}}` `[tag]`
- **L8 Agents** — `{{roster + autonomy defaults + guardrails}}` `[tag]`
- **L9 Learning loop** — `{{outcomes, traces, backtest, shadow, retrain}}` `[tag]`
- **L10 Human strategy layer** — `{{ICP/segments, guardrails, cadences}}` `[tag]`
- **Cross-cutting spines** — observability, data quality, security/privacy/compliance, orchestration `[tag]`
- **Coexistence & write-back** — which existing rails the Brain sits on top of; the **one-decision-maker rule** (turn off a rail's native automation for any program the Brain now decides); Brain-originated writes tagged and excluded from ingestion (loop prevention). `[tag]`

### 2.2 Capability → tool mapping

A table: required capability (generic) → the org's named tool → build/buy note → `[tag]`. Never assume a vendor path; use the org's actual named tools (see `capability-map.md`).

### 2.3 Data contracts

The org's entity, fact, and decision-trace shapes, adapted from the skeleton's canonical contracts to the org's vocabulary. Two things must survive the adaptation — do not simplify them away:

- the **fact** shape is bi-temporal — carries `valid_from`/`valid_to` **and** `knowledge_time` — so the builder can reconstruct *what was known when* (the precondition for honest measurement).
- the **decision trace** retains `alternatives_considered` and `explanation` (why this action, why not the runner-up) alongside the chosen action and outcome. A trace of only chosen-action + outcome is not enough — the alternatives and the reason are the compounding asset that lets you later ask "was that the right call?"

### 2.4 Worked example — one decision, end to end

One of the org's priority decisions traced through Observe → Orient → Decide → Act → Learn, to make the layers concrete for the builder. This is the single clearest build-credibility artifact — always include it.

### 2.5 Meta-sections (derived from inputs + sensible defaults)

Each is propose-derived and provenance-tagged; the owner is not interrogated for these:

- **Phased roadmap** — foundations → identity/graph → compute/summaries → decide/act (assisted) → learn/graduate.
- **Cost model** — order-of-magnitude categories (data infra, vendors, LLM inference, serving, team), flagged as estimates.
- **Risk register** — the org's top risks + mitigations (identity error, deliverability, consent/compliance, adoption, drift, write-back loops).
- **Team & operating model** — the roles needed to build and run it, sized to a lean start.
- **Maturity self-assessment** — where the org is today (fragmented → unified → scored → recommended → governed autonomy → compounding) and the next move.

---

## Part 3 — Open Items / Next Steps (auto-assembled handoff)

> Written by `finalize`. The agenda for the owner's conversation with their technical person or vendor.

A table, grouped by layer/section:

| Item | Type | Why it's open | What to resolve with your team |
|------|------|---------------|-------------------------------|
| `{{item}}` | `[Open]` / high-risk `[Proposed]` | `{{why}}` | `{{the specific question or decision to close it}}` |

Every `[Open]` tag in the Build Spec appears here, along with every remaining `[Proposed]` item (inferred but never ratified — plausible but unverified). `[Proposed — confirmed]` and `[Stated]` items are settled and do not appear. This section is derived from the tags — it is not maintained separately.
