# gtm-brain-plugin — project orientation

A guided interview that turns a ~30–60 min conversation with a business owner into one org-specific **GTM Brain** spec: a plain-language **Strategy Readout** over a builder-ready **Build Spec**, plus an **Open Items** hand-off list. Built as a self-serve build kit for the **YPO MarTech Forum**; companion to the on-stage runtime demo `Dual-Logic/brainRoadshow` (not modified here).

**This repo now ships the same product for two platforms** (split 2026-07-23):

- **`claude/`** — the original **Claude Cowork plugin** (`.claude-plugin/plugin.json`). Source of record.
- **`chatgpt/`** — the converted, skills-only **OpenAI plugin for ChatGPT Work mode + Codex** (`.codex-plugin/plugin.json`).

Both hold the identical deliverable and design rules; they differ only where the platform forces it (manifest, runtime paths, working-doc location, provenance-tag dash style, and — since OpenAI's skills model has no subagent-spawn mechanism — the three research subagents are folded **inline** into the ChatGPT skills). The root `README.md` is the router between them.

**Status (2026-07-23): `claude/` v0.3.0; `chatgpt/` converted to parity.** Both structurally complete and reviewed. **Neither validated live in its host runtime yet** — that end-to-end run (see "Open / next") is the remaining acceptance gate for each. ChatGPT status detail: `chatgpt/docs/VALIDATION.md`.

## How it works

The owner drives only the **business layer**; the plugin does the technical lifting via **propose-and-confirm** (it proposes, the owner reacts — never authors technical content). Five skills over a resumable phase pipeline, plus three research/QA subagents:

1. **`gtm-brain`** — entry/orchestrator; creates or resumes the working doc, routes to phases.
2. **`profile-and-goals`** (Phase 1) — asks for the website URL, spawns **`org-researcher`** to research the org first, then runs a paced, pressure-testing discovery conversation (business, team, goals, GTM motions/channels, decisions-to-automate, tools with per-tool depth, constraints). Classifies the archetype lens silently.
3. **`strategy-readout`** (Phase 2) — plain-language readout + **resonance gate** ("is this your business?") that blocks the technical work until confirmed.
4. **`build-spec`** (Phase 3) — drafts the full technical body on the universal skeleton, spawns **`system-architect`** to research real API/MCP feasibility for the named tools, then refines via one-at-a-time confirm loops (each with a recommendation). A completeness check enforces the load-bearing elements.
5. **`finalize`** (Phase 4) — derives meta-sections, spawns **`coherence-checker`** (QA: alignment, provenance, ungrounded-specifics, load-bearing architecture, consistency), aggregates Open Items, polishes markdown, and relocates the progress marker to the doc bottom.

The interview persists to a **working doc** (`gtm-brain-spec.md`) in the owner's project/workspace, resumable across sittings (incl. mid-phase). The two builds locate it differently: `claude/` uses `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`; `chatgpt/` is surface-aware (`<workspace-root>/gtm-brain-spec.md` in Codex, or the active Work-mode document). Research needs web tools at runtime and **degrades gracefully** (ask + flag) if absent. The above describes the shared flow; in `chatgpt/` the three subagents are the same procedures run inline by the skills (see `chatgpt/skills/<name>/references/`).

## Repo layout

```
README.md                       the two-platform router (start here)
claude/                         the Claude Cowork build (source of record)
  .claude-plugin/plugin.json     manifest (v0.3.0)
  skills/<name>/SKILL.md          the five skills; subagents in skills/<name>/agents/*.md
  reference/                      gtm-brain-skeleton, output-template, working-doc-convention,
                                  capability-map, lens-guide, lenses/{saas,professional-services,e-commerce}
  CONNECTORS.md                   data-access posture (public web research; no internal-system access)
  docs/plans/2026-07-22-002-…     implementation plan of record (also a superseded -001-)
  docs/GTM-Brain-Architecture-*   the 3 source architecture templates (quality bar / lens source)
  dist/                           gitignored; built .plugin bundle force-added as a tracked release asset
chatgpt/                        the OpenAI ChatGPT Work + Codex build (converted, skills-only)
  .codex-plugin/plugin.json       manifest (v0.3.0, adds an `interface` block)
  skills/<name>/SKILL.md          same five skills; research folded inline via skills/<name>/references/
  reference/                      same shared references (surface-aware; ASCII provenance tags)
  README.md, CONNECTORS.md        ChatGPT-specific
  docs/                           openai-chatgpt-plugin-conventions.md, VALIDATION.md, plans/…conversion-plan.md
```

## Design rules (hold these)

- **Universal skeleton, archetypes as lenses** — one shared GTM-Brain skeleton (sources→identity→facts→models→policy→agents→learning + OODA); the 3 templates are *emphasis lenses*, not molds. Any business type is coverable; off-archetype falls back to `universal`.
- **Provenance tags** on every material technical claim: `[Stated]` / `[Proposed]` / `[Proposed — confirmed]` / `[Open — needs your team]`. Open Items = `[Open]` + unconfirmed `[Proposed]`. (`claude/` uses em-dash tags; `chatgpt/` uses ASCII-hyphen tags — `[Proposed - confirmed]` / `[Open - needs your team]` — per OpenAI conventions. Keep each build internally consistent.)
- **Load-bearing architecture** (build-spec must include or flag `[Open]`): bi-temporal fact layer / event clock; distinct models layer (models compute, LLMs narrate); decision trace with `alternatives_considered` + `explanation`; coexistence + one-decision-maker rule; autonomy gates tied to precision/lift, not time; global cross-channel frequency budget.
- **Ground specifics** — never invent a named account/date/event; illustrate with captured accounts. The coherence-checker hunts ungrounded specifics (this was a real defect in a live run).
- **Build on the org's existing tools** — map the agent roster onto what they already run; extend, don't reinvent.
- **Tool-agnostic** — names capabilities and maps them to the owner's named tools; ships no vendor connectors; uses only public web research (no internal-system access).

## Versions & git workflow

- Tags: **`v0.1.0`** (the original "capable-operator" build — deliberately *superseded and archived*; do not resurrect its `profile-and-plays`/`architecture-and-stack`/exemplars design), **`v0.2.0`** (owner-first rebuild), **`v0.3.0`** (research agents + rigorous Phase 1, current).
- All `main` changes go **branch → PR → merge** (main is not committed to directly). Never push without an explicit ask.
- Commit-message trailer: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`; PR-body footer: the Claude Code generated-with line.

## Build & distribute

**Claude (`claude/`)** — the uploadable Cowork bundle is built by zipping the plugin surface (dist/ is gitignored; the release zip is force-added as tracked):

```bash
cd claude
zip -r dist/gtm-brain-plugin-<ver>.zip .claude-plugin skills reference README.md CONNECTORS.md
```

Install: add/upload the `.plugin` bundle in Cowork; invoke the `gtm-brain` skill to start.

**ChatGPT (`chatgpt/`)** — no zip step; the package is the `chatgpt/` directory itself. Install from Plugins or a configured marketplace (personal `~/.agents/plugins/marketplace.json` or a repo `.agents/plugins/marketplace.json`), start a new chat/session, then ask *"Start my GTM Brain spec."* Full conventions: `chatgpt/docs/openai-chatgpt-plugin-conventions.md`.

## Open / next

- **Live validation (the acceptance gate, per build):**
  - *Claude:* run the full interview end-to-end in Cowork — mid-phase resume, ~30–60 min timing, builder-credibility on an uncommon stack, non-generic output across two org profiles (AE1–AE7 in the plan).
  - *ChatGPT:* run the OpenAI validator scripts + the workflow/surface/golden-prompt checks in `chatgpt/docs/VALIDATION.md`, on ChatGPT Work mode and Codex.
- **HTML visual (agreed fast-follow):** a secondary, self-contained `gtm-brain-diagram.html` — an org-specific visual of the Brain (decisions → layers → tools over the OODA loop). Not yet built. Applies to both builds.
