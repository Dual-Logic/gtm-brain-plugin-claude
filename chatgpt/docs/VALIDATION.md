# Validation

Validation status for the OpenAI/ChatGPT build of GTM Brain (`chatgpt/`). Conversion completed **2026-07-23** from the Claude `main` build (v0.3.0). Legend: **PASS** (checked and holds), **PENDING** (not yet run — needs the OpenAI validator scripts and/or a live ChatGPT/Codex session).

## Static Checks

- **PASS — `.codex-plugin/plugin.json` exists** with all required baseline fields (`name`, `version`, `description`, `author.name`, `skills`, and the `interface.*` set). `skills` is `./skills/`. Version `0.3.0` matches the content it was converted from.
- **PASS — `.claude-plugin/` is absent** from `chatgpt/`. The Claude manifest stays only under the sibling `claude/` package.
- **PASS — no Claude-specific variables or product names in active instructions.** Swept `skills/` and `reference/` for `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `Claude`, `Cowork`, `.claude-plugin`, `.plugin bundle` — none remain. (The only surviving occurrences of "Claude" in `chatgpt/` are the intentional migration notes inside `docs/`, e.g. the conventions doc's "Do not use Claude-specific variables" rule.)
- **PASS — provenance tags use ASCII hyphens.** `[Proposed - confirmed]` and `[Open - needs your team]` throughout; no em-dash tag forms remain.
- **PASS — no `apps` / `mcpServers` / `hooks` manifest fields** (this is a skills-only, no-connector plugin) and no icon/logo/screenshot references without matching files.
- **PASS — reference paths resolve relatively.** Skills point at `../../reference/<file>` (shared) and `references/<file>` (skill-specific); no environment variable is relied on.
- **PASS — the three v0.3.0 research subagents were folded into inline per-skill `references/` procedures** (`profile-and-goals/references/org-research.md`, `build-spec/references/feasibility-research.md`, `finalize/references/coherence-check.md`). No subagent-spawn mechanism is assumed; each SKILL.md performs the research itself. (This is a v0.3.0 concern the conversion plan — written against v0.2.0 — did not cover; handled per the conventions doc's "`agents/` is metadata, not a subagent" rule.)
- **PENDING — OpenAI validator scripts.** The `plugin-creator` / `skill-creator` validators referenced by the conventions doc live under a `.codex` install path (`/Users/peterdudka/.codex/skills/.system/...`) that must be run on a machine where those system skills exist:

  ```bash
  python3 <path>/plugin-creator/scripts/validate_plugin.py chatgpt
  for d in chatgpt/skills/*; do
    python3 <path>/skill-creator/scripts/quick_validate.py "$d"
  done
  ```

## Workflow Checks

All **PENDING** — require a live ChatGPT Work-mode or Codex session with the plugin installed. Verify:

- Fresh start creates or begins a GTM Brain spec.
- Resume reads the marker and does not restart.
- Out-of-order phase invocation routes back to `gtm-brain`.
- Strategy Readout correction loop revises in place (no stacked versions).
- Build Spec does not run until the resonance confirmation is recorded in the marker.
- Finalize derives Open Items from tags (never hand-maintained).

## Surface Checks

All **PENDING** — require live sessions on each surface:

- Codex / local workspace: writes `gtm-brain-spec.md` as a real file at the workspace root.
- ChatGPT Work mode with an uploaded or active spec document: marker stays at the top of that document.
- ChatGPT Work mode without a durable file: interview continues in-chat and the resume-limitation message is shown (owner must re-provide the latest `gtm-brain-spec.md` next session).

## Golden Prompt Set

All **PENDING** live confirmation. Expected behavior:

Should trigger `gtm-brain`:

- "Start my GTM Brain spec."
- "Help me design a go-to-market decision system for my business."
- "Resume the GTM Brain interview in this project."
- "Create a builder-ready GTM Brain spec from an owner interview."

Should NOT trigger the plugin:

- "Write a generic GTM strategy memo."
- "Connect to HubSpot and pull my pipeline."
- "Build an MCP server for Salesforce."
- "Make a landing page for my consulting firm."

Should NOT trigger directly (must route through `gtm-brain`, not fire on their own): any phase skill (`profile-and-goals`, `strategy-readout`, `build-spec`, `finalize`). If testing shows a phase skill self-triggering, set `allow_implicit_invocation: false` for it via `skills/<name>/agents/openai.yaml` (see the conventions doc).

## Notes

The live workflow/surface/golden-prompt testing above is the same acceptance gate the Claude build still carries (see the root README) — neither platform build has been exercised end-to-end in its host runtime yet. Record results here as they are run.
