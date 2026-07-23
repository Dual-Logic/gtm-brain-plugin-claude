---
name: build-spec
description: Phase 3 of the GTM Brain interview. Drafts the full technical Build Spec from the confirmed Strategy Readout — mapping the owner's business layer onto the universal GTM-Brain skeleton, provenance-tagging every decision, and refining by having the owner react to proposals rather than authoring anything. Runs after strategy-readout confirms; hands off to finalize.
---

# Phase 3 — Build Spec (draft, then confirm)

Produce the builder-ready technical body. The owner **cannot author this** — you draft it and they react. The method is draft-then-confirm, not layer-by-layer interrogation: generate a complete draft first, then walk the owner through the parts that matter, highest-risk first.

## Order guard (run first)

Read `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` and its marker (contract: `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md`). If the working doc doesn't exist yet, don't run — route to `gtm-brain` first. Otherwise only run if `phase:` is `build-spec` **and** the marker shows the Strategy Readout was confirmed. If not confirmed, route back to `strategy-readout` — do not draft on an unconfirmed picture. Resume at `last_completed_step`.

## Step 1 — Draft the full body

Load the skeleton (`${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md`), the capability map (`${CLAUDE_PLUGIN_ROOT}/reference/capability-map.md`), and the active lens resolved from the marker's `lens:` — a single lens loads `${CLAUDE_PLUGIN_ROOT}/reference/lenses/<lens>.md`; a `blend:<a>+<b>` loads **both** `reference/lenses/<a>.md` and `reference/lenses/<b>.md` and merges their emphasis; `universal` loads no lens file and derives directly from the skeleton (per `${CLAUDE_PLUGIN_ROOT}/reference/lens-guide.md`). Fill **Part 2 — Build Spec** of the template for *this* org:

- **2.1 Architecture body (L0–L10 + spines)** — the org-specific fill for each skeleton layer, driven by the priority decisions. Anchor the whole body on the org's **unit of decision**.
- **2.2 Capability → tool mapping** — resolve each required capability to the org's actual named tool; build/buy note per row.
- **2.3 Data contracts** — the org's entity, fact, and decision-trace shapes.
- **2.4 Worked example** — one priority decision traced Observe → Orient → Decide → Act → Learn. Always include it; it's the clearest build-credibility artifact.

**Tag every material decision** with `[Stated]`, `[Proposed — confirmed]` (mark as `[Proposed]` until the owner ratifies), or `[Open — needs your team]`. Anything the org hasn't supplied and you can't safely infer is `[Open]` — never fabricate a value. Anything a chosen decision needs but the org lacks (a data source, a capability, a tool) is `[Open]`, with what's required stated.

## Step 2 — Refine by reacting (bounded, risk-ordered)

Walk the owner through the draft's **highest-risk `[Proposed]` items first** — the ones where being wrong costs the most (identity approach, a decision policy, a key data source, a tool mapping). For each, play it back in plain language and ask them to confirm or correct.

- On confirm → flip `[Proposed]` to `[Proposed — confirmed]`.
- On correct → revise in place (per the working-doc convention — no stacked versions), reflect it, re-confirm; if it becomes their stated intent, tag `[Stated]`.
- **Bound the loop to protect the ~30–60 min budget:** stop once the remaining `[Proposed]` items are low-risk — leave those as `[Proposed]` (they surface in Open Items) rather than confirming every line. Don't interrogate the owner through the whole body.

Keep the marker current as you go (`last_completed_step: body-confirmed-through-<area>`), storing raw corrections.

## Finishing

When the high-risk items are confirmed and the body is drafted end to end, update the marker — set `phase: finalize` and `last_completed_step: build-spec-drafted` — and hand off to `finalize`: "Last step — I'll add the roadmap, cost, risk, team, and maturity sections, then assemble your hand-off list."

## Guardrails

- Never ask the owner to author technical content — they only react to your proposals.
- Every material decision carries a provenance tag; gaps are `[Open]`, never fabricated.
- Map capabilities to the org's *named* tools; assume no vendor path (`capability-map.md`).
- Revise in place; don't leave superseded draft beside corrected text.
- Bound the confirm loop by risk and time; low-risk `[Proposed]` items ride to Open Items rather than a full interrogation.
