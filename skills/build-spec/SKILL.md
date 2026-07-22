---
name: build-spec
description: Phase 4 (final) of the GTM Brain interview — write the per-play "how" (capability contract, decision logic, build/run notes, capability-to-named-tool mapping) and run the completeness pass that flags data gaps and integration-knowledge gaps rather than omitting them. Runs after architecture-and-stack. Produces the below-the-fold Build Spec a builder can stand up a v1 from.
---

# build-spec — Phase 4 (Build Spec + completeness pass)

You write the **Build Spec** — the below-the-fold, builder-facing tier — and then run the
**completeness pass**. Your success test is a real builder (eng or technical marketer) reading it and
starting a v1 **without coming back with basic questions** (AE6). Credibility here is everything; where
you can't be credible, you **flag a gap** rather than paper over it.

**Before anything, read these:**
- `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md` — marker, append cadence, the gate.
- `${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md` — the per-play template + the fact primitive (typed/sourced/dated) + invariants.
- `${CLAUDE_PLUGIN_ROOT}/reference/category-map.md` — capability → tool mapping rules; the gap-not-hand-wave rule.
- The matching-motion exemplar as a **quality/depth reference** (the bar to match, not to copy):
  `${CLAUDE_PLUGIN_ROOT}/reference/exemplars/{mid-market-saas|professional-services|e-commerce}.md`.

Working doc: `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`.

## Guard
1. Read the marker. **If `resonance_confirmed` is `false` OR `phases.architecture-and-stack` is not `complete`, do not run** — route back to the right phase.
2. If Phase 4 is `in_progress`, resume at the step after `last_completed_step` (e.g. finish the play you were mid-way through).

## Step 1 — Write each play's "how"
For **each** play, using RAW CAPTURE → *Architecture inputs* and the *Named tool stack*, fill the
per-play Build Spec block (see the template + skeleton per-play template). Every block must have:

- **Capability contract** — typed **Inputs**, **Outputs** (a fact / routed record / drafted action /
  alert), and the **Trigger** (schedule / event / threshold / on-demand).
- **Observe** — the evidence, each mapped to `~~category → named tool`.
- **Orient** — the entity acted on + the resolution/stitching required.
- **Decide** — the **facts** consumed, each written as the precision primitive
  `«FACT» = «type/value» · derived from «evidence» on «entity» · as of «date» · confidence «…»`, and the
  explicit **decision policy** as `IF «facts hold» THEN «action»` (include precedence when policies can
  co-fire).
- **Act** — what fires and *where it writes/sends* (which named tool).
- **Learn** — the outcome signal + the feedback path (the loop must close — invariant).
- **Build notes for v1** — concrete: where the logic runs (warehouse + reverse-ETL / workflow tool /
  scripts / agent — matched to the org's *actual* infrastructure, not an assumed warehouse), what to
  build first, and any known integration specifics for the named tool.

Write one play at a time; update `last_completed_step` after each (e.g. `buildspec-play-1`).

**Match the org's infrastructure.** A warehouse-rich SaaS gets dbt/reverse-ETL notes; a
warehouse-less services firm gets workflow-tool + CRM-automation + scheduled-script notes. Do not
prescribe infrastructure the org doesn't have — that's how a spec loses credibility.

## Step 2 — Completeness pass (flag, never omit)
Walk the fixed skeleton **play by play** and surface every under-specified layer into the Build Spec's
completeness-pass section, in two classes:

- **Data gaps** — a chosen play needs evidence the org has **not** described (no source named for a
  required signal). State what's missing and what's required to close it. The play may still ship
  *without* that signal (say so) — but the gap is named, never silently dropped (AE1).
- **Integration-knowledge gaps** — a named tool whose concrete how-to (API / export / native
  automation) you **cannot credibly specify**. Name the open question for the builder. **Do not
  hand-wave it as vague "capability" talk** (AE6) — an honest "confirm this path" beats false confidence.

If a play has a gap-driven staged build (ship the ungapped signals now, add the rest when a gap
closes), note that in the play's build notes *and* here. Set `last_completed_step: completeness-pass`.

## Step 3 — Sequencing recommendation
Write the sequencing paragraph: which play to build first (usually the operator's top priority whose
evidence + tools are already in place with **no open gaps**), what shared substrate it establishes that
later plays inherit (e.g. the identity join), and the order for the rest — deferring gap-blocked plays
behind their fixes. Set `last_completed_step: sequencing`.

## Finish
- Mark `phases.build-spec: complete`, `current_phase: complete`, `status: complete`, and set
  `next_action` (hand off to the team; close any flagged gaps before building the affected play).
- Optionally suggest tidying RAW CAPTURE into an appendix so the deliverable reads clean above the fold.
- Tell the operator the spec is complete, recap the flagged gaps (the honest "here's what your builder
  needs to confirm/acquire"), and point them at the finished `gtm-brain-spec.md`.

## Never
- Never omit a gap to make the spec look finished — an unflagged gap that surfaces at build time is the failure this phase exists to prevent.
- Never invent an integration path you're unsure of; flag it for confirmation instead.
- Never map a capability to a vendor the org didn't name, or assume a default stack (R10).
- Never leave a fact untyped/unsourced/undated, or a play's loop unclosed (skeleton invariants).
- Never run while the resonance gate is false or Phase 3 is incomplete.
