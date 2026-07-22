# Validation — GTM Brain plugin

Verification for a prompt/skill plugin is **behavioral**, run in Claude Cowork — there is no automated
test suite (Verification Contract, plan §Verification). This file records two things honestly:

- **A — Static validation** performed at build time in this environment (what a build machine *can*
  check without a live Cowork session).
- **B — Manual end-to-end checklist** that requires a live Cowork session and, for one gate, a real
  builder who is not the spec's author. **Brady runs Part B** before the YPO MarTech Forum; each item
  maps to a Verification-Contract gate.

---

## A. Static validation (done at build time)

| Check | Result |
|---|---|
| `plugin.json` is valid JSON; `name: gtm-brain`; skills auto-discovered from `skills/` | ✅ |
| **R10 — no connectors ship:** no `mcpServers` key in `plugin.json`; no `.mcp.json` anywhere in the repo | ✅ |
| `marketplace.json` valid; lists `gtm-brain` at `source: "./"`; install string `/plugin install gtm-brain@dual-logic` | ✅ |
| All five skills present with valid `name` + `description` frontmatter | ✅ |
| **Cross-reference integrity:** every `${CLAUDE_PLUGIN_ROOT}/reference/…` path in every skill resolves to a real file | ✅ |
| Working-doc path consistent everywhere (`${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`) | ✅ |
| Each skill reads `working-doc-convention.md` and references the working doc | ✅ |
| Resonance gate (`resonance_confirmed`) enforced in both build-tier skills | ✅ |
| **R3 — no play menu:** `profile-and-plays` carries explicit no-menu/no-catalog guards; the play palette is an internal reference only | ✅ |
| **Exemplar conformance:** all three exemplars follow the U1 template structure (PHASE-PROGRESS → Raw capture → Strategy Readout → FOLD → Build Spec → completeness pass → sequencing); zero leftover `«placeholders»` | ✅ |
| **Non-generic (static read):** the three exemplars diverge *structurally* — SaaS resolves accounts + warehouse facts; professional-services resolves people/relationships on a warehouse-less stack and never auto-sends; e-commerce resolves stitched customers + closes the ad-audience loop | ✅ |
| Each exemplar's completeness pass flags ≥1 data gap **and** ≥1 integration-knowledge gap (AE1/AE6 behavior demonstrated) | ✅ |
| Distributable bundle (`scripts/package-plugin.sh`) contains only the plugin surface — no `docs/plans`, `.git`, or `scripts` leak in | ✅ |

### Resume-logic dry-run trace (internal-consistency check)

Walking the `working-doc-convention.md` contract against the skills confirms the state machine is
internally consistent:

```text
fresh run → gtm-brain: no doc → copy template → marker{current_phase: profile-and-plays} → route P1
P1 profile-and-plays: fills Raw capture, marker step-by-step → phases.profile-and-plays: complete → route P2
P2 strategy-readout: writes readout → resonance checkpoint
        confirmed  → resonance_confirmed: true  → route P3
        correction → resonance_confirmed stays false → loop (edit readout, or back to P1)
[gate] architecture-and-stack & build-spec both refuse to run while resonance_confirmed == false → route back to P2
P3 architecture-and-stack: derive layers + capture named stack → phases.…: complete → route P4
P4 build-spec: per-play how + completeness pass + sequencing → current_phase: complete
resume at any point → gtm-brain reads marker → reports done/next → routes to current_phase,
        mid-phase via last_completed_step (AE5)
out-of-order trigger → each phase skill checks marker, declines + routes if a prerequisite phase is incomplete
```

No dead ends, no way past the resonance gate without confirmation, and every phase has a defined
predecessor check. (This is a logic trace, not a substitute for the live dry-run in Part B.)

---

## B. Manual end-to-end checklist (Brady, in a live Cowork session)

Static checks can't exercise the actual conversation. Run these in Cowork once installed. Each maps to
a Verification-Contract gate / acceptance example.

- [ ] **Install smoke** *(gate: Install smoke)* — Install per the README (`/plugin marketplace add` →
      `/plugin install gtm-brain@dual-logic` → `/reload-plugins`). Plugin loads with no manifest error;
      `/gtm-brain` and the four phase skills are discoverable.
- [ ] **Fresh start** *(AE-none / dry-run)* — `/gtm-brain` in an empty project creates
      `gtm-brain-spec.md` from the template and routes to Phase 1.
- [ ] **Play-first + no menu** *(R2, R3)* — Phase 1 asks goals/decisions before any tool/architecture
      question, and never presents a play menu; plays emerge from your answers.
- [ ] **Resonance checkpoint gates progression** *(AE4)* — After Phase 2, decline to confirm ("not
      quite") and verify the plugin will **not** advance to architecture/build; it revises or loops.
      Then confirm and verify it proceeds.
- [ ] **Resume at a phase boundary** *(AE2)* — End the session after Phase 2; restart `/gtm-brain`;
      it resumes at Phase 3, not the top.
- [ ] **Mid-phase resume** *(AE5)* — Interrupt partway through Phase 3 (after capturing some but not
      all plays' architecture); restart; it resumes at the next step via `last_completed_step` without
      re-asking captured answers.
- [ ] **Tool-agnostic mapping on an uncommon stack** *(AE3)* — Run with a deliberately non-default
      stack (e.g. name an obscure CRM); the Build Spec maps capabilities to *that* named tool with no
      HubSpot/Salesforce assumption.
- [ ] **Play-gap flagged, not omitted** *(AE1)* — Deliberately withhold a data source a chosen play
      needs; confirm the completeness pass flags the gap rather than silently dropping the signal.
- [ ] **Exemplar-grade output** *(gate: End-to-end)* — Run the full interview against a mid-market
      SaaS-like org; compare the output to `reference/exemplars/mid-market-saas.md`. It should reach
      comparable completeness and specificity.
- [ ] **Builder credibility** *(gate: Builder credibility, AE6)* — Hand a produced Build Spec (ideally
      the uncommon-stack one) to a **real builder who did not author it** (an eng or technical
      marketer). They attempt to start a v1. Record whether they can begin without coming back with
      basic questions, and whether every capability they hit is either specified or explicitly flagged
      as a gap.
- [ ] **Non-generic across two orgs** *(gate: Non-generic)* — Run against a second, distinct org
      profile; confirm the two specs diverge on plays, tools, and decision policies.
- [ ] **No brainRoadshow changes** *(DoD)* — Confirm nothing in this work touched the `brainRoadshow`
      repo (it doesn't — this repo is standalone).

### Open follow-ups surfaced during build

- **Packaging divergence (for product owner):** the plan (KTD7/R11/Sources) assumed a `.plugin` bundle
  upload into Cowork. Current Cowork has **no such upload**; distribution is the marketplace /
  repo-declared path documented in the README. No functional impact — the plugin surface is identical
  — but KTD7's wording should be reconciled in the plan. (The zip artifact remains available for any
  future manual-upload path.)
- **Play-probing-hints provenance:** `reference/play-probing-hints.md` is authored from common GTM play
  patterns as the interviewer's internal palette (KTD5). It should be periodically reconciled/augmented
  against `brainRoadshow`'s actual demonstrated play surfaces by the owner — it is a refreshable
  snapshot, not canon, and is never shown to the operator.
