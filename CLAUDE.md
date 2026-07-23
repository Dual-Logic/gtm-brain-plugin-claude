# gtm-brain-plugin — project orientation

A tool-agnostic **Claude Cowork plugin** that interviews a business owner (~30–60 min) and produces one org-specific **GTM Brain** spec: a plain-language **Strategy Readout** over a builder-ready **Build Spec**, plus an **Open Items** hand-off list. Built as a self-serve build kit for the **YPO MarTech Forum**; companion to the on-stage runtime demo `Dual-Logic/brainRoadshow` (not modified here).

**Status (2026-07-23): v0.3.0 on `main`.** Structurally complete and reviewed. **Not yet validated live in Cowork** — that end-to-end run (see "Open / next") is the remaining acceptance gate before it's demo-ready.

## How it works

The owner drives only the **business layer**; the plugin does the technical lifting via **propose-and-confirm** (it proposes, the owner reacts — never authors technical content). Five skills over a resumable phase pipeline, plus three research/QA subagents:

1. **`gtm-brain`** — entry/orchestrator; creates or resumes the working doc, routes to phases.
2. **`profile-and-goals`** (Phase 1) — asks for the website URL, spawns **`org-researcher`** to research the org first, then runs a paced, pressure-testing discovery conversation (business, team, goals, GTM motions/channels, decisions-to-automate, tools with per-tool depth, constraints). Classifies the archetype lens silently.
3. **`strategy-readout`** (Phase 2) — plain-language readout + **resonance gate** ("is this your business?") that blocks the technical work until confirmed.
4. **`build-spec`** (Phase 3) — drafts the full technical body on the universal skeleton, spawns **`system-architect`** to research real API/MCP feasibility for the named tools, then refines via one-at-a-time confirm loops (each with a recommendation). A completeness check enforces the load-bearing elements.
5. **`finalize`** (Phase 4) — derives meta-sections, spawns **`coherence-checker`** (QA: alignment, provenance, ungrounded-specifics, load-bearing architecture, consistency), aggregates Open Items, polishes markdown, and relocates the progress marker to the doc bottom.

The interview persists to a **working doc** (`${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`) in the owner's project, resumable across sittings (incl. mid-phase). Agents need web-research tools at runtime and **degrade gracefully** (ask + flag) if absent.

## Repo layout

```
.claude-plugin/plugin.json     manifest (v0.3.0)
skills/<name>/SKILL.md          the five skills; agents live in skills/<name>/agents/*.md
reference/                      gtm-brain-skeleton, output-template, working-doc-convention,
                                capability-map, lens-guide, lenses/{saas,professional-services,e-commerce}
CONNECTORS.md                   data-access posture (public web research; no internal-system access)
docs/plans/2026-07-22-002-…     implementation plan of record (also a superseded -001-)
docs/GTM-Brain-Architecture-*   the 3 source architecture templates + base (quality bar / lens source)
dist/                           gitignored; the built .plugin bundle is force-added as a tracked release asset
```

## Design rules (hold these)

- **Universal skeleton, archetypes as lenses** — one shared GTM-Brain skeleton (sources→identity→facts→models→policy→agents→learning + OODA); the 3 templates are *emphasis lenses*, not molds. Any business type is coverable; off-archetype falls back to `universal`.
- **Provenance tags** on every material technical claim: `[Stated]` / `[Proposed]` / `[Proposed — confirmed]` / `[Open — needs your team]`. Open Items = `[Open]` + unconfirmed `[Proposed]`.
- **Load-bearing architecture** (build-spec must include or flag `[Open]`): bi-temporal fact layer / event clock; distinct models layer (models compute, LLMs narrate); decision trace with `alternatives_considered` + `explanation`; coexistence + one-decision-maker rule; autonomy gates tied to precision/lift, not time; global cross-channel frequency budget.
- **Ground specifics** — never invent a named account/date/event; illustrate with captured accounts. The coherence-checker hunts ungrounded specifics (this was a real defect in a live run).
- **Build on the org's existing tools** — map the agent roster onto what they already run; extend, don't reinvent.
- **Tool-agnostic** — names capabilities and maps them to the owner's named tools; ships no vendor connectors; uses only public web research (no internal-system access).

## Versions & git workflow

- Tags: **`v0.1.0`** (the original "capable-operator" build — deliberately *superseded and archived*; do not resurrect its `profile-and-plays`/`architecture-and-stack`/exemplars design), **`v0.2.0`** (owner-first rebuild), **`v0.3.0`** (research agents + rigorous Phase 1, current).
- All `main` changes go **branch → PR → merge** (main is not committed to directly). Never push without an explicit ask.
- Commit-message trailer: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`; PR-body footer: the Claude Code generated-with line.

## Build & distribute

The uploadable Cowork bundle is built by zipping the plugin surface (dist/ is gitignored; the release zip is force-added as tracked):

```bash
zip -r dist/gtm-brain-plugin-<ver>.zip .claude-plugin skills reference README.md CONNECTORS.md
```

Install: add/upload the `.plugin` bundle in Cowork; invoke the `gtm-brain` skill to start.

## Open / next

- **Live Cowork validation (the acceptance gate):** run the full interview end-to-end, confirm mid-phase resume, ~30–60 min timing, builder-credibility on an uncommon stack, and non-generic output across two org profiles (AE1–AE7 in the plan). Needs a human in Cowork + web-research tools available.
- **HTML visual (agreed fast-follow):** a secondary, self-contained `gtm-brain-diagram.html` — an org-specific visual of the Brain (decisions → layers → tools over the OODA loop). Not yet built.
