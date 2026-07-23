---
name: finalize
description: Phase 4 (final) of the GTM Brain interview. Derives the meta-sections (roadmap, cost, risk, team, maturity) from the Build Spec, runs a provenance-coverage pass, and auto-assembles the Open Items / Next Steps hand-off list. Runs after build-spec; completes the spec.
---

# Phase 4 — Finalize

Complete the document: derive the meta-sections, enforce provenance coverage, and assemble the Open Items hand-off list. The owner is not interrogated here — these are propose-derived from what's already captured.

## Order guard (run first)

Read `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` and its marker (contract: `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md`). If the working doc doesn't exist yet, don't run — route to `gtm-brain` first. Otherwise only run if `phase:` is `finalize`. If earlier, route back to `build-spec`. Resume at `last_completed_step`.

## Step 1 — Derive the meta-sections (Part 2.5)

From the business layer and the Build Spec, derive and write each meta-section, provenance-tagged, from inputs + sensible defaults (don't interrogate the owner):

- **Phased roadmap** — foundations → identity/graph → compute/summaries → decide/act (assisted) → learn/graduate, sized to this org.
- **Cost model** — order-of-magnitude categories (data infra, vendors, LLM inference, serving, team), flagged as estimates.
- **Risk register** — the org's top risks + mitigations (identity error, deliverability, consent/compliance, adoption, drift, write-back loops), tilted by the lens.
- **Team & operating model** — roles to build and run it, lean start.
- **Maturity self-assessment** — where the org is today (fragmented → unified → scored → recommended → governed autonomy → compounding) and its next move.

Default meta-section content is `[Proposed]`; higher-risk assumptions in it flow to Open Items.

## Step 2 — Provenance-coverage pass

Scan the whole Build Spec body. Every **material technical statement** must carry a tag. Flag any untagged material statement and tag it — reusing the same tag-parsing you use for Open Items. This enforces the provenance requirement structurally, not by drafting discipline alone.

## Step 3 — Assemble Open Items / Next Steps (Part 3)

Build the Open Items table by aggregating from the tags (do not maintain it separately):

- every `[Open — needs your team]` item, and
- every remaining `[Proposed]` item — inferred but never ratified, so plausible but unverified.

`[Stated]` and `[Proposed — confirmed]` items are settled; they do not go to Open Items.

For each: the item, its type, why it's open, and the specific question or decision to close it with their technical person or vendor. This section is the hand-off agenda.

## Step 4 — Complete

Set the marker to `phase: complete`, `last_completed_step: finalized`. Tell the owner plainly: the spec is done; it has three parts — the Strategy Readout they confirmed, the Build Spec for their team, and the Open Items list to walk through together. Point them to the file and offer to revise any section.

## Guardrails

- Don't interrogate the owner for meta-sections — derive and tag them.
- Open Items is derived from the tags; never hand-maintained.
- No material technical statement ships untagged.
- Mark `phase: complete` so a re-run reports done rather than restarting.
