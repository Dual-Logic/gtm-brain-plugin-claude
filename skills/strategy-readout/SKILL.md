---
name: strategy-readout
description: Phase 2 of the GTM Brain interview — synthesize the operator-facing Strategy Readout from what Phase 1 captured, then run the resonance checkpoint ("is this your business?"). Runs after profile-and-plays. This is the gate: no build-tier phase proceeds until the operator confirms the readout. Loops back on correction.
---

# strategy-readout — Phase 2 (produce + validate the readout)

You turn Phase 1's raw capture into the **Strategy Readout** — the operator-facing tier — and then run
the **resonance checkpoint** that gates the whole build tier. Your success test is emotional as much as
factual: the operator should read it and feel *"yes, that's my business,"* not *"that's generic AI
copy."*

**Before anything, read these:**
- `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md` — read/append + marker + the resonance gate (§5).
- `${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md` — for the single plain-English "shape underneath" paragraph.
- One matching exemplar's Strategy Readout as a **tone/quality reference** (not to copy): pick by the org's motion —
  `${CLAUDE_PLUGIN_ROOT}/reference/exemplars/mid-market-saas.md`, `professional-services.md`, or `e-commerce.md`.

Working doc: `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`.

## Guard

1. Read the marker. If `phases.profile-and-plays` is **not** `complete`, don't run — route back to `profile-and-plays` (you have no raw capture to synthesize yet).
2. If `resonance_confirmed` is already `true` and the operator isn't asking for changes, the readout is done — route forward to `architecture-and-stack`.

## Step 1 — Synthesize the Strategy Readout
From RAW CAPTURE, write the four Strategy Readout sub-sections into the working doc (see the template's
structure), in **business language only**:

- **What your GTM Brain is for** — 2–4 sentences naming the go-to-market decisions this brain will own
  for *this* org and why, grounded in their stated goals. Use their words and specifics; no layer jargon.
- **The priority plays it runs** — one block per discovered play, business framing. For each, lead with
  ***the decision it makes for you*** (the judgment owned — not the mechanics) and ***why it's a
  priority*** (tie to a stated goal). This is where resonance is won.
- **What it will feel like when it's working** — 2–3 concrete sentences: what the team stops doing
  manually, what gets decided faster/better, what stops slipping. Specific to this org.
- **The shape underneath (plain-English)** — the *only* place the three-layer/loop idea surfaces to the
  operator, in one accessible paragraph (watches signals → resolves them to the right accounts/people →
  turns them into trustworthy facts → decides which play → learns from outcomes). No jargon.

Write per sub-section and update `last_completed_step` as you go (mid-phase resume).

**Resonance craft:** name their actual numbers, tools-of-pain, segments, and quotes from RAW CAPTURE.
Ban generic AI-marketing language ("leverage AI," "unlock efficiencies," "human-centric transformation").
If a sentence could appear in any org's readout, rewrite it until it couldn't.

## Step 2 — The resonance checkpoint (the gate)
Present the readout and ask plainly: **"Read this and tell me — is this your business?"**

- **Confirmed** → record the confirmation (date + the operator's words) in the checkpoint block, set
  `resonance_confirmed: true`, mark `phases.strategy-readout: complete`, `current_phase:
  architecture-and-stack`, and offer to continue: *"Now I'll go one level deeper — the data and tools
  each play needs. Want to keep going, or pick this up later?"* On yes, invoke `architecture-and-stack`.
- **Needs correction** → capture exactly what's off in the checkpoint block, and:
  - If the *framing/emphasis* is wrong → revise the readout here and re-present.
  - If a *play or goal itself* is wrong or missing → route back to `profile-and-plays` to fix the raw
    capture (set its phase back to `in_progress`), then re-synthesize.
  - **Leave `resonance_confirmed: false`.** Loop until the operator confirms.

## Never
- Never set `resonance_confirmed: true` without an explicit operator confirmation.
- Never let architecture/build-tier work proceed while the gate is false — that's the point of Phase 2 (AE4).
- Never fill the readout with generic boilerplate; if it isn't unmistakably this org, it isn't done.
- Never introduce facts/plays not in RAW CAPTURE — synthesize what's there; if a gap shows, ask, don't invent.
