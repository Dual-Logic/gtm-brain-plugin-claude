---
name: strategy-readout
description: Phase 2 of the GTM Brain interview. Synthesizes the business layer into a plain-language Strategy Readout the owner reads, and runs the resonance check ("is this your business?") that gates all technical work. Runs after profile-and-goals; hands off to build-spec only once the owner confirms.
---

# Phase 2 — Strategy Readout & resonance gate

Turn the business layer into a picture the owner recognizes as *their* business, in language they'd use — no architecture, no jargon. Then get their explicit confirmation before any technical work begins. This is the resonance gate.

## Order guard (run first)

Read `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` and its marker (contract: `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md`). If the working doc doesn't exist yet, don't run — route to `gtm-brain` first. Otherwise only run if `phase:` is `strategy-readout`. If earlier (`profile-and-goals` not done), route back. If later, this phase is done — route forward. Resume at `last_completed_step`.

## Write the Strategy Readout (Part 1 of the working doc)

Using the captured business layer and the lens, fill **Part 1 — Strategy Readout** of the template (`${CLAUDE_PLUGIN_ROOT}/reference/output-template.md`). Business language throughout:

- **What your GTM Brain is** — 2–4 sentences painting the end-state: the decision system this org is building and what changes once it runs.
- **The decisions it makes for you** — the priority decisions from Phase 1, in the owner's words, each with its plain outcome ("when X, the Brain decides Y so your team can Z").
- **What it watches and remembers** — their signals and the "memory" (the event clock) in business terms.
- **How it earns trust** — recommends first, acts only once proven (shadow → assisted → autonomous), one paragraph.
- **What you'll hand your team** — one line pointing ahead to the Build Spec and Open Items.

Use the lens's flagship framing (e.g. SaaS "5 accounts to focus on today"; services "your highest-value moves — which pursuit to bid, which warm door opened"; e-commerce "the minimum effective offer, often nothing") to make it vivid — adapted to *this* org, not copied.

## The resonance check (the gate)

Present the readout and ask plainly: **"Does this read like your business? What's wrong or missing?"**

- **On correction** — revise Part 1 in place (do not stack a second version), re-present, ask again. Loop until they confirm. Update the marker's captured inputs with any new facts they surface.
- **On confirmation** — record it in the marker (set `phase: build-spec` and `last_completed_step: readout-confirmed`) and only then hand off to `build-spec`.

**Do not proceed to build-spec until the owner confirms.** The whole technical body is built on this picture; if it's wrong, everything downstream inherits the error.

## Guardrails

- Business language only — if the owner needs a term explained, explain it in one clause, don't lecture.
- Ground every specific. When you make the readout vivid, illustrate with a **real captured account** (from `captured_inputs`) — never invent a named account, date, or investor/event to sell the point. An ungrounded specific ("you touched Acme on the 8th") reads as real and breaks the owner's trust the moment they notice it isn't.
- Revise in place on correction; never leave superseded readout text beside the corrected version.
- The gate is real: no technical phase runs until confirmation is recorded.
- Hand off to `build-spec` on confirmation; tell the owner what's next: "Now I'll draft the technical spec your team can build from — you'll confirm or correct what I propose."
