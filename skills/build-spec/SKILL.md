---
name: build-spec
description: Phase 3 of the GTM Brain interview. Drafts the full technical Build Spec from the confirmed Strategy Readout — mapping the owner's business layer onto the universal GTM-Brain skeleton, provenance-tagging every decision, and refining by having the owner react to proposals rather than authoring anything. Runs after strategy-readout confirms; hands off to finalize.
---

# Phase 3 — Build Spec (draft, then confirm)

Produce the builder-ready technical body. The owner **cannot author this** — you draft it and they react. The method is draft-then-confirm, not layer-by-layer interrogation: generate a complete draft first, then walk the owner through the parts that matter, highest-risk first.

## Order guard (run first)

Read `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` and its marker (contract: `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md`). If the working doc doesn't exist yet, don't run — route to `gtm-brain` first. Otherwise only run if `phase:` is `build-spec` **and** the marker shows the Strategy Readout was confirmed. If not confirmed, route back to `strategy-readout` — do not draft on an unconfirmed picture. Resume at `last_completed_step`.

## Step 1 — Draft the full body

Load the skeleton (`${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md`), the capability map (`${CLAUDE_PLUGIN_ROOT}/reference/capability-map.md`), and the active lens resolved from the marker's `lens:` — a single lens loads `${CLAUDE_PLUGIN_ROOT}/reference/lenses/<lens>.md`; a `blend:<a>+<b>` loads **both** `reference/lenses/<a>.md` and `reference/lenses/<b>.md` and merges their emphasis; `universal` loads no lens file and derives directly from the skeleton (per `${CLAUDE_PLUGIN_ROOT}/reference/lens-guide.md`).

**Hold to the skeleton's layer structure — do not invent your own layer taxonomy.** Fill the layers as the skeleton names them. Three elements are load-bearing and separate a GTM Brain from a scoring pipeline; each must appear (org-specific), or be flagged `[Open — needs your team]` with what's required — never silently collapsed:
- the **context graph's fact layer / event clock** — time-bounded, sourced assertions (`valid_from`/`valid_to`, `confidence`, source), not just event names or computed features. This is *why* it's a Brain, not a nightly scoring job.
- a **distinct models layer** — the deterministic scores the decisions consume, named separately from the policy that uses them (**models compute; LLMs narrate**). Do not fold the models into the policy layer.
- the **summary / state stores** the agents read at decision time.

**Apply the active lens's flagship mechanisms — don't just borrow its vocabulary:**
- *e-commerce:* **uplift modeling (not response modeling)** for any discount/offer sizing (the margin engine), a **global cross-channel frequency budget** (not per-tool caps), margin floors + inventory as hard constraints, and household/gift-buyer where the catalog warrants.
- *professional services:* relationship-strength facts (with decay), bid/no-bid expected value, conflict/independence as a blocking gate.
- *SaaS:* buying-committee mapping, intent facts, expected-value prioritization.

**Build on what they already run.** Check the captured tools and automations for existing internal primitives — a hiring-signal watcher, an autonomous drafter with a no-send gate, outreach/deal-review commands — and map the architecture, *especially the L8 agent roster and the L7 policy*, onto them: extend and connect what exists rather than proposing parallel new agents. If they already run a trigger subagent, the trigger-watch agent **is** that one — say so, tag it, and note what to change, not what to rebuild. For a lean team, "extend the tools you have" is a completely different (cheaper, faster) build than "stand up new agents."

Fill **Part 2 — Build Spec** of the template for *this* org:

- **2.1 Architecture body (L0–L10 + spines)** — the org-specific fill for each skeleton layer, driven by the priority decisions. Anchor the whole body on the org's **unit of decision**.
- **2.2 Capability → tool mapping** — resolve each required capability to the org's actual named tool; build/buy note per row.
- **2.3 Data contracts** — the org's entity, fact, and decision-trace shapes.
- **2.4 Worked example** — one priority decision traced Observe → Orient → Decide → Act → Learn. Always include it; it's the clearest build-credibility artifact.

**Tag every material decision** with `[Stated]`, `[Proposed — confirmed]` (mark as `[Proposed]` until the owner ratifies), or `[Open — needs your team]`. Anything the org hasn't supplied and you can't safely infer is `[Open]` — never fabricate a value. Anything a chosen decision needs but the org lacks (a data source, a capability, a tool) is `[Open]`, with what's required stated.

## Step 1b — Feasibility research (system-architect agent)

Before walking the owner through the draft, pressure-test whether it's actually buildable on their stack — don't assume the integrations exist. Spawn the **system-architect agent** (`${CLAUDE_PLUGIN_ROOT}/skills/build-spec/agents/system-architect.md`), passing the draft's capability→tool pairings, the priority decisions, and the unit of decision. It researches each tool's real integration surface (APIs, webhooks, official MCP servers, reverse-ETL support) and returns a feasibility verdict per capability plus a recommended home for the decision logic.

Fold its findings back into the body:
- **§2.2 capability → tool table** — add each pairing's feasibility note with a citation, tagged `[Proposed]` (the builder verifies exact endpoints), or `[Open — needs your team]` where the agent found a genuine gap.
- **Open Items** — route every `gap` it reports (a capability with no tool, or a tool with no viable integration for what a decision needs) to `[Open]`, with what's required.
- **Decision-engine home** — use its recommendation to ground how and where the Brain runs (skeleton L7/L8), tagged `[Proposed]`.

**If the agent returns `no_web_access`** (or no research tool exists): don't block — keep the capability→tool mappings as prose-level `[Proposed]`, and add one Open Item noting that integration feasibility (APIs/MCPs) still needs a builder to confirm.

## Step 2 — Refine by reacting (one item at a time, with a recommendation)

Rank the draft's `[Proposed]` items by risk — the ones where being wrong costs the most (identity approach, a decision policy, a key data source, a tool mapping) — and walk the owner through the **highest-risk items first, strictly one at a time.** Present a single item, get their response, resolve it, and only then move to the next. **Never present two or three at once** — batching them makes the owner rubber-stamp things they can't weigh.

For each item, in order:

1. **Explain it** in plain language — what it is and why it matters for their business.
2. **Make a recommendation.** Say what you think the right choice is and *why*, in a sentence or two. Do not ask a neutral "what do you think?" — give the owner a concrete recommendation to accept or push back on, since they're not equipped to originate the answer.
3. **Ask them to confirm or correct.**
   - On confirm → flip `[Proposed]` to `[Proposed — confirmed]`.
   - On correct → revise in place (per the working-doc convention — no stacked versions), reflect it, re-confirm; if it becomes their stated intent, tag `[Stated]`.

**Bound the loop to protect the time budget:** once the remaining `[Proposed]` items are low-risk, stop — leave those as `[Proposed]` (they surface in Open Items) rather than confirming every line one at a time. Keep the marker current as you go (`last_completed_step: body-confirmed-through-<area>`), storing raw corrections.

## Step 3 — Completeness check (before finishing)

Before handing off, verify the body carries the load-bearing elements — the ones that separate a GTM Brain from a scoring pipeline. For each, confirm it's present and org-specific, **or flag it `[Open — needs your team]` with what's required — never silently omit it.** This is a coverage check, not a new interview; resolve it from what's already captured.

1. **Fact layer / event clock** — the decisions rest on time-bounded, sourced facts, not just live state or event names.
2. **Models layer** — the deterministic scores are named and distinct from the policy that consumes them, and the lens's flagship model is present (e.g. **uplift** for e-commerce — not a response/likelihood model).
3. **Decision trace** — the trace records `alternatives_considered` + `explanation` (why this action, why not the runner-up), not just the chosen action and outcome. This is what makes outcomes learnable.
4. **Coexistence & write-back** — where the Brain sits on top of an existing rail (e.g. the org's ESP/CRM flows), the **one-decision-maker rule** is stated: turn off the rail's native automation for any program the Brain now decides (two decision-makers on one channel = frequency chaos), and tag Brain-originated writes so they're excluded from ingestion (loop prevention).
5. **Autonomy gates** — the shadow → assisted → autonomous graduation is tied to what each decision must *prove* (a precision or holdout-lift bar), not just elapsed time.
6. **Global frequency budget** — if the org messages on more than one channel, the contact cap is a single global budget across channels, not a separate cap per tool.

## Finishing

When the high-risk items are confirmed and the body is drafted end to end, update the marker — set `phase: finalize` and `last_completed_step: build-spec-drafted` — and hand off to `finalize`: "Last step — I'll add the roadmap, cost, risk, team, and maturity sections, then assemble your hand-off list."

## Guardrails

- Never ask the owner to author technical content — they only react to your proposals.
- Every material decision carries a provenance tag; gaps are `[Open]`, never fabricated.
- Map capabilities to the org's *named* tools; assume no vendor path (`capability-map.md`).
- Revise in place; don't leave superseded draft beside corrected text.
- Confirm high-risk items strictly one at a time, each with a clear recommendation the owner reacts to — never batch two or three together.
- Bound the confirm loop by risk and time; low-risk `[Proposed]` items ride to Open Items rather than a full interrogation.
- Hold to the skeleton's layers — never collapse the fact layer or the models layer into events/features/policy. The event clock and the models-compute / LLMs-narrate split are non-negotiable; Step 3 checks for them.
- Feasibility is researched, not assumed — the system-architect agent's findings enter the spec as `[Proposed]` with citations; genuine integration gaps become `[Open]`, never hand-waved.
- Build on the org's existing internal tools — map the agent roster onto what they already run (extend, don't reinvent); a parallel new agent where they already have one is waste.
- Ground specifics — illustrate the worked example with a real captured account or a clearly-generic archetype ("a 250-person Series-B SaaS company"), never an invented named account/date/event.
