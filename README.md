# GTM Brain — Claude plugin

A tool-agnostic **Claude Cowork plugin** that interviews a business operator and produces a tiered,
org-specific **GTM Brain** spec: a **Strategy Readout** (operator-facing — *is this my business?*)
over a **Build Spec** (technical-team-facing — *can we stand up a v1?*). It's a **self-serve build
kit** — run a guided, resumable, multi-phase interview and walk out with a spec your own team can
build a credible v1 from, without a Dual Logic follow-on.

Built as a take-home companion to the on-stage runtime demo,
[`Dual-Logic/brainRoadshow`](https://github.com/Dual-Logic/brainRoadshow), for the **YPO MarTech
Forum**. This repo does not modify brainRoadshow.

---

## What a "GTM Brain" is

A GTM Brain is a *stateful decision system* for go-to-market: it turns raw signals into trustworthy
**facts**, and facts into **decisions** that drive **plays** — and it learns from what worked. The
bottleneck in modern GTM has moved from *execution* (which is now effectively unlimited) to *decision
quality* — and the brain is where decision quality lives. Full model in
[`reference/gtm-brain-skeleton.md`](reference/gtm-brain-skeleton.md). (Framing follows warmly.ai's
"GTM Brain": evidence → identity → fact layers, plus an OODA+L loop.)

## What the plugin produces

One working doc — `gtm-brain-spec.md`, created in your project — in two linked tiers:

- **Strategy Readout** (above the fold): your GTM Brain in business language — its purpose, your
  priority plays, and the decisions it makes for you. Written so you recognize your own business.
- **Build Spec** (below the fold): for each play, the *how* — the data it needs, its decision logic,
  how it's built and run, and how each required capability maps to **your** actual named tools.
  Credible enough that a builder starts a v1 without coming back with basic questions.

## How the interview works

Play-first and resumable, across as many sittings as you need. Each phase is its own skill; they read
and append the one working doc, so you can stop and resume without losing work.

```text
gtm-brain (entry)  ──creates/resumes──▶  gtm-brain-spec.md
      │
      ├─ 1. profile-and-plays        profile the org + discover the plays that matter (no menu)
      ├─ 2. strategy-readout         write the Strategy Readout → "is this your business?" gate
      ├─ 3. architecture-and-stack   derive the layers each play needs + capture your named tools
      └─ 4. build-spec               write the per-play "how" + run the completeness pass (flag gaps)
```

The interview **discovers** the plays relevant to your org — it never shows a preset catalog. It
captures your **actual tools** and maps capabilities onto them, so the output is stack-neutral in
shape yet specific to your environment. It ships **no connectors** and never calls your tools — see
[`CONNECTORS.md`](CONNECTORS.md).

## Repository layout

```text
gtm-brain-plugin/
├── .claude-plugin/plugin.json      # manifest (skills auto-discovered from skills/)
├── README.md                       # this file
├── CONNECTORS.md                   # why it ships no connectors + the ~~category convention
├── skills/
│   ├── gtm-brain/                  # entry / orchestrator + resume
│   ├── profile-and-plays/          # Phase 1: profile + discover plays
│   ├── strategy-readout/           # Phase 2: produce + validate the readout
│   ├── architecture-and-stack/     # Phase 3: derive layers + capture tools
│   └── build-spec/                 # Phase 4: Build Spec + completeness pass
└── reference/                      # docs the skills load on demand
    ├── gtm-brain-skeleton.md       # the fixed architecture (3 layers + OODA+L loop)
    ├── working-doc-template.md     # the tiered output doc scaffold + resume marker
    ├── working-doc-convention.md   # read/append + resume protocol every skill follows
    ├── category-map.md             # the ~~category capability vocabulary
    └── exemplars/                  # three filled reference specs (the "definition of done")
        ├── mid-market-saas.md
        ├── professional-services.md
        └── e-commerce.md
```

## Install

This is a standard Claude plugin (`.claude-plugin/`-rooted). It reaches Cowork the way Claude plugins
do today — through the plugin **marketplace** or a **repo-declared** settings entry. There is
currently **no drag-and-drop `.plugin` upload** in Cowork; the marketplace path below is the
supported route. (A reproducible zip is available via `scripts/package-plugin.sh` for archival or any
future manual-upload path.)

### Install guide (non-developer)

The plugin installs the same way in **Cowork** (type the commands in chat; pickers open in the
sidebar) and the **Claude Code CLI** (type them in the terminal).

**1. One-time — add the Dual Logic marketplace:**

```text
/plugin marketplace add Dual-Logic/gtm-brain-plugin
```

**2. Install the plugin, then reload:**

```text
/plugin install gtm-brain@dual-logic
/reload-plugins
```

Choose the scope when prompted (user / project).

**3. Start the interview** — invoke the entry skill and follow the prompts:

```text
/gtm-brain
```

It creates `gtm-brain-spec.md` in your current project and walks you through the four phases. Stop
anytime; run `/gtm-brain` again to resume where you left off.

> **Private repo note.** `Dual-Logic/gtm-brain-plugin` is private, so your machine must be able to
> reach it over git first — sign in once with `gh auth login` (or have SSH access to the repo). Claude
> then uses your existing git credentials automatically; no extra flag is needed.

### Repo-declared (auto-load in a project / cloud session)

To auto-load the plugin for anyone who opens a given project, commit this to that project's
`.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "dual-logic": {
      "source": { "source": "github", "repo": "Dual-Logic/gtm-brain-plugin" }
    }
  },
  "enabledPlugins": {
    "gtm-brain@dual-logic": true
  }
}
```

The marketplace registers and the plugin enables at session start — no manual `/plugin marketplace
add` needed.

## Status

Active build against
[`docs/plans/2026-07-22-001-feat-gtm-brain-plugin-plan.md`](docs/plans/2026-07-22-001-feat-gtm-brain-plugin-plan.md).

## License

UNLICENSED — © Dual Logic. Internal / client-distribution use.
