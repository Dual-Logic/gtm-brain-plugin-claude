---
name: profile-and-plays
description: Phase 1 of the GTM Brain interview — profile the operator's go-to-market and discover the plays that matter to them (no preset menu). Runs after the gtm-brain entry skill creates the working doc. Captures the org profile, GTM goals, and the decisions the operator most wants automated, then discovers 2–4 priority plays and appends them to the working doc.
---

# profile-and-plays — Phase 1 (profile + play discovery)

You run the **play-first** opening of the interview: understand the operator's go-to-market, then
**discover** the handful of plays that matter to *this* org — never from a menu. Everything you learn
is appended to the working doc as RAW CAPTURE for later phases to synthesize from.

**Before anything, read these:**
- `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md` — read/append + marker + out-of-order guard.
- `${CLAUDE_PLUGIN_ROOT}/reference/play-probing-hints.md` — **your internal probing palette. Never read it aloud or show it as a menu (R3).**
- `${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md` — so you capture plays in a shape the later phases can build on.

Working doc: `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`.

## Guard (out-of-order protection)

1. If the working doc does **not** exist → route the operator to the `gtm-brain` entry skill (it creates the doc). Don't start cold.
2. Read the PHASE-PROGRESS marker. If a **later** phase is already in progress/complete and you were triggered by description-match, don't redo Phase 1 — report state and route to `current_phase`.
3. If `profile-and-plays` is `in_progress`, **resume** at the step after `last_completed_step` (see below) rather than restarting.

## The play-first rule (do not violate)

Surface the operator's **goals and the decisions they most want automated FIRST.** Do **not** ask
about data, tools, or architecture in this phase — that's Phase 3. If the operator volunteers tools,
capture them in RAW CAPTURE and move back to goals. Resonance leads; architecture follows.

## Steps (update the marker + append RAW CAPTURE after EACH step)

Per the convention's cadence rule, after each step append what you captured and set
`last_completed_step` — so a mid-phase interruption resumes cleanly.

### Step 1 — Org profile
Interview conversationally for: industry / business model; **motion** (product-led / sales-led /
relationship-led / marketing-led / hybrid; inbound vs. outbound weight); who they sell to (segments /
ICP, in their words); GTM team shape and who would own the brain. Capture in the operator's own
language into RAW CAPTURE → *Org profile*. Set `last_completed_step: org-profile`.

### Step 2 — Goals & the decisions they want automated
Ask what they're trying to move this quarter/year, and — the money question — **"which go-to-market
decisions do you most wish were automatic or made better?"** Push for specifics and the pain behind
each. Capture into RAW CAPTURE → *Org profile* (goals + decisions). Set `last_completed_step: goals`.

### Step 3 — Discover the plays (no menu)
Using `play-probing-hints.md` **only as your internal ear**, probe the goals/decisions from Step 2 into
concrete plays. For each candidate play the operator recognizes, pin down **the decision it automates**
(the judgment the brain owns), not the mechanics. Discover **2–4** plays. Never present a catalog or
ask them to pick from a list — the plays must emerge from *their* goals. Capture into RAW CAPTURE →
*Discovered plays*, each with why it matters in their words. Set `last_completed_step: plays-discovered`.

### Step 4 — Prioritize
Ask the operator to rank the discovered plays, and note the driver for each rank (revenue leaking now?
biggest upside? highest stakes per miss? evidence already in hand?). This priority order drives
sequencing later. Capture into RAW CAPTURE → *Discovered plays* (priority order). Set
`last_completed_step: prioritized`.

## Finish

- Mark `phases.profile-and-plays: complete`, set `current_phase: strategy-readout`, `status: phase_complete`,
  and `next_action` to point at the Strategy Readout phase.
- Tell the operator what you captured (a quick recap of profile + the priority plays) and offer to
  continue to the Strategy Readout: *"Next I'll write this up as a Strategy Readout and you tell me
  whether it reads like your business. Ready?"* On yes, invoke the `strategy-readout` skill.

## Never

- Never show a play menu or ask them to pick from a list (R3).
- Never ask about tools/data/architecture here (that's Phase 3).
- Never invent goals, plays, or answers the operator didn't give — if unsure, ask.
- Never skip updating the marker between steps (it's what makes resume work).
