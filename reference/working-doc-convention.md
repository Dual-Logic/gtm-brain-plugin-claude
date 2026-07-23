# Working-document & resume convention

Every phase skill reads this file. It defines where the one working document lives, how phases read and write it, and how the interview resumes across sittings — including mid-phase.

## Location

The working document lives in the **owner's project**, not inside the plugin, so it survives plugin updates and is the durable record between sittings:

```
${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md
```

If `${CLAUDE_PROJECT_DIR}` is not resolvable in the runtime, fall back to the current working directory root. Create the file once (in the `gtm-brain` entry skill) from `reference/output-template.md`. There is exactly one working doc per project; do not create per-phase files.

Shared reference files inside the plugin are loaded with the plugin-root variable (confirm the exact token against the installed runtime at build; `${CLAUDE_PLUGIN_ROOT}` is the current convention), e.g. `${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md`.

## Read-then-write contract

1. **Read first, always.** Before doing anything, a phase reads the whole working doc and the phase-progress marker at its top.
2. **Sections accrete across phases; a phase owns its own section.** `strategy-readout` writes Part 1, `build-spec` writes Part 2, `finalize` writes Part 3 and the Open Items aggregation. A completed phase's section is not rewritten by a later phase.
3. **Within a phase, revise in place.** "Append" is section-level accretion, not forward-only writing. The resonance-correction loop (`strategy-readout`) and the draft-then-confirm loops (`build-spec`) **rewrite the active phase's own draft in place** as the owner corrects it. Do not leave superseded draft text sitting next to corrected text — replace it, so the doc never carries two versions of the same answer.
4. **Keep the phase-progress marker current at every step**, not only at phase boundaries. Store **raw captured inputs verbatim** (what the owner actually said), not only synthesized output — this is what makes a mid-phase resume lossless.

## Resume behavior

On any new session, the `gtm-brain` entry skill:

1. Checks for `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`.
2. If absent → fresh start: create it from the template, orient the owner, route to `profile-and-goals`.
3. If present → read the phase-progress marker (at the **top** of the doc while the interview is in progress; at the **bottom** if the doc is already `complete`), report to the owner what is captured and what is next in plain language, and route to the phase named by `phase:`, resuming at `last_completed_step` — **mid-phase, not at the top of the phase**. The captured raw inputs mean no already-answered question is re-asked.

## Out-of-order guard (against description-match auto-triggering)

Cowork may auto-select a skill by description match. Each phase skill must **check the marker before running** and decline to run out of sequence:

- If the marker's `phase:` is *earlier* than this skill's phase, this skill politely defers: it tells the owner which phase is current and routes back to `gtm-brain` (or the correct phase) rather than running.
- If the marker's `phase:` is *this* skill's phase, run (resuming at `last_completed_step`).
- If the marker's `phase:` is *later* (this phase already completed), do not redo it — report that it's done and point to the current phase.

Phase order: `profile-and-goals` → `strategy-readout` → `build-spec` → `finalize` → `complete`. The resonance gate sits at the end of `strategy-readout`: `build-spec` must not run until `strategy-readout` recorded owner confirmation in the marker.

## What "done" looks like

When `finalize` completes, it sets `phase: complete` and **relocates the marker (and its captured inputs) from the top to the bottom of the document**, so the finished spec opens straight into the title. The record is preserved, just moved. A re-run then reports the spec is finished and points the owner to the Strategy Readout, Build Spec, and Open Items — offering to revise rather than restarting.
