# gtm-brain-plugin

A guided interview that turns a ~30–60 minute conversation with a business owner into **one org-specific GTM Brain spec** — a plain-language **Strategy Readout** over a builder-ready, provenance-tagged **Build Spec**, plus an **Open Items / Next Steps** hand-off list.

The owner drives only the **business layer** (their goals, the decisions they most want automated, their actual tools); the plugin does the technical lifting via **propose-and-confirm**. It's tool-agnostic (names capabilities, maps them onto the owner's named tools, ships no vendor connectors), grounds itself with **public web research only**, and works for any business type — three archetype *lenses* (SaaS, professional services, e-commerce) shape emphasis on top of a universal GTM-Brain skeleton.

Built as a self-serve build kit for the **YPO MarTech Forum**; companion to the on-stage runtime demo [`Dual-Logic/brainRoadshow`](https://github.com/Dual-Logic/brainRoadshow) (not modified here).

## Two builds, one product

This repo ships the **same product for two AI platforms**. Pick the folder for your surface — each is a self-contained, installable plugin with its own README:

| Folder | Platform | Package format | Start here |
|---|---|---|---|
| [`claude/`](claude/) | **Claude Cowork** | `.claude-plugin/plugin.json` + skills/reference; distributed as a zipped `.plugin` bundle | [`claude/README.md`](claude/README.md) |
| [`chatgpt/`](chatgpt/) | **ChatGPT Work mode + Codex** | `.codex-plugin/plugin.json` + skills/reference; installed from Plugins or a marketplace | [`chatgpt/README.md`](chatgpt/README.md) |

Both produce the identical deliverable and hold the identical design rules (universal skeleton + lenses, provenance tags, the load-bearing architecture, ground-every-specific, build-on-existing-tools). They differ only where the *platform* forces it:

- **`claude/` is the source of record.** It is the original build (v0.3.0).
- **`chatgpt/` is the converted, skills-only OpenAI build**, following OpenAI/ChatGPT plugin conventions (skills-only, `.codex-plugin` manifest, no connectors).

> Internal planning material — the source architecture templates, implementation plans, the OpenAI plugin-conventions guide, the conversion plan, and validation tracking — is kept **local only** (under each build's `docs/` folder) and is not shipped in this repo.

### What changed in the ChatGPT build (and why)

| Concern | `claude/` | `chatgpt/` |
|---|---|---|
| Manifest | `.claude-plugin/plugin.json` | `.codex-plugin/plugin.json` (adds an `interface` block for ChatGPT surfacing) |
| Runtime paths | `${CLAUDE_PROJECT_DIR}` / `${CLAUDE_PLUGIN_ROOT}` | surface-aware wording + relative reference paths (`../../reference/…`); no env vars |
| Working doc | `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` | `<workspace-root>/gtm-brain-spec.md` in Codex; the active Work-mode document otherwise; never inside the plugin dir |
| Research steps | three spawned subagents (`org-researcher`, `system-architect`, `coherence-checker`) | the same procedures folded **inline** into each skill, backed by `skills/<name>/references/` — OpenAI's skills model has no subagent-spawn mechanism |
| Provenance tags | em-dash (`[Proposed — confirmed]`) | ASCII hyphen (`[Proposed - confirmed]`) |

Everything else — the interview flow, the resonance gate, the skeleton, the lenses, the Open-Items derivation — is preserved verbatim.

## How to install & start

**Claude Cowork** (from `claude/`):

```bash
cd claude
zip -r dist/gtm-brain-plugin-<ver>.zip .claude-plugin skills reference README.md CONNECTORS.md
```

Add/upload the resulting `.plugin` bundle in Cowork, then invoke the `gtm-brain` skill to start. Full details: [`claude/README.md`](claude/README.md).

**ChatGPT Work mode / Codex** (from `chatgpt/`):

Install the `chatgpt/` package from Plugins or a configured marketplace, start a new chat/session, then ask *"Start my GTM Brain spec."* Full details: [`chatgpt/README.md`](chatgpt/README.md).

## Status

- **`claude/` — v0.3.0**, structurally complete and reviewed; **live Cowork validation is the remaining acceptance gate** (run the full interview end-to-end with a human in Cowork).
- **`chatgpt/` — converted 2026-07-23**; static structural checks pass. The OpenAI validator scripts and live ChatGPT/Codex workflow, surface, and golden-prompt testing are still pending (tracked in the local `chatgpt/docs/VALIDATION.md`).

Neither build has yet been exercised end-to-end in its host runtime; that is the shared next step for both.
