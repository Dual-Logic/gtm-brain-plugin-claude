---
name: finalize
description: Internal Phase 4 (final) of the GTM Brain interview — not a user entry point. Use only when the marker says phase: finalize. Derives the meta-sections (roadmap, cost, risk, team, maturity), runs a coherence + provenance-coverage pass, and auto-assembles the Open Items / Next Steps hand-off list. Completes the spec.
---

# Phase 4 — Finalize

Complete the document: derive the meta-sections, enforce provenance coverage, and assemble the Open Items hand-off list. The owner is not interrogated here — these are propose-derived from what's already captured.

> **This is a phase skill.** If invoked directly and the GTM Brain working marker does not name this phase, stop and route to `gtm-brain`.

## Order guard (run first)

Read the working document and its marker (contract: `../../reference/working-doc-convention.md` — resolve the plugin root from this skill file's installed path). If the working doc doesn't exist yet, don't run — route to `gtm-brain` first. Otherwise only run if `phase:` is `finalize`. If earlier, route back to `build-spec`. Resume at `last_completed_step`.

## Step 1 — Derive the meta-sections (Part 2.5)

From the business layer and the Build Spec, derive and write each meta-section, provenance-tagged, from inputs + sensible defaults (don't interrogate the owner):

- **Phased roadmap** — foundations → identity/graph → compute/summaries → decide/act (assisted) → learn/graduate, sized to this org.
- **Cost model** — order-of-magnitude categories (data infra, vendors, LLM inference, serving, team), flagged as estimates.
- **Risk register** — the org's top risks + mitigations (identity error, deliverability, consent/compliance, adoption, drift, write-back loops), tilted by the lens.
- **Team & operating model** — roles to build and run it, lean start.
- **Maturity self-assessment** — where the org is today (fragmented → unified → scored → recommended → governed autonomy → compounding) and its next move.

Default meta-section content is `[Proposed]`; higher-risk assumptions in it flow to Open Items.

## Step 2 — Coherence check (do it yourself, inline)

Run a coherence check over the assembled working doc, following `references/coherence-check.md` — the last quality gate before the owner walks away with it. Reviewing the doc against itself and against the marker's `captured_inputs`, check: Strategy-Readout ↔ Build-Spec alignment, provenance coverage (every material statement tagged; Open Items aggregating the right tags), cross-reference integrity, the load-bearing architecture (fact layer, models layer, decision trace with alternatives + explanation, coexistence / one-decision-maker, autonomy gates), internal consistency (contradictions, mismatched figures, superseded text), and — highest-value — ungrounded specifics (any named account/date/event that doesn't trace to `captured_inputs` or a cited source). That reference gives the full checklist and the structured findings shape. No web access is needed for this pass; it is a review of the document against itself.

Apply the findings:
- Fix the inconsistencies, highest-severity first, **preserving provenance tags** (never launder a `[Proposed]` into `[Stated]`).
- Any finding that needs the owner's judgment — a genuine contradiction only the owner can settle — is routed to Open Items as `[Open]`, not silently resolved.

At minimum, always complete the provenance-coverage pass: every material technical statement carries a tag, reusing the Open-Items tag-parsing.

## Step 3 — Assemble Open Items / Next Steps (Part 3)

Build the Open Items table by aggregating from the tags (do not maintain it separately):

- every `[Open - needs your team]` item, and
- every remaining `[Proposed]` item — inferred but never ratified, so plausible but unverified.

`[Stated]` and `[Proposed - confirmed]` items are settled; they do not go to Open Items.

For each: the item, its type, why it's open, and the specific question or decision to close it with their technical person or vendor. This section is the hand-off agenda.

## Step 4 — Polish & complete

**Polish the markdown first — first impressions matter.** Make the document render cleanly: consistent heading levels, well-formed tables (aligned pipes, no broken rows), tidy spacing, no stray artifacts or half-finished lines.

**Relocate the progress marker to the bottom.** During the interview it lives at the top so each phase can resume; the finished deliverable should open straight into the title, so move the whole HTML-comment block (marker + captured inputs) to the very end of the document. It stays an invisible comment and the captured record is fully preserved — just out of the reader's way.

Then, in the relocated marker, set `phase: complete`, `last_completed_step: finalized`. Tell the owner plainly: the spec is done; it has three parts — the Strategy Readout they confirmed, the Build Spec for their team, and the Open Items list to walk through together. Point them to the file and offer to revise any section.

## Guardrails

- Don't interrogate the owner for meta-sections — derive and tag them.
- Open Items is derived from the tags; never hand-maintained.
- No material technical statement ships untagged.
- Run the coherence check (per `references/coherence-check.md`) as the final QA gate; apply its fixes and route owner-input findings to Open Items — never ship a spec that disagrees with itself.
- The delivered markdown must render cleanly — it's the owner's first impression of the whole thing.
- Mark `phase: complete` so a re-run reports done rather than restarting.
