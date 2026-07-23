# GTM Brain — Claude Cowork plugin

A tool-agnostic **Claude Cowork plugin** that interviews a business owner and produces one tiered, org-specific **GTM Brain** spec:

- a **Strategy Readout** — plain-language, the part you read and confirm ("yes, this is my business"), and
- a **Build Spec** — a builder-ready technical body your engineer or vendor can execute from,

plus an **Open Items / Next Steps** list that becomes the agenda for the hand-off conversation with your technical team.

You drive the business layer (your goals, the decisions you most want automated, your actual tools). The plugin does the technical lifting — it *proposes* the architecture and you confirm or correct it in plain language, never authoring technical content yourself. Every technical claim is tagged so a builder can tell what you decided (`[Stated]`) from what the plugin inferred (`[Proposed — confirmed]`) from what still needs your team (`[Open]`). Takes ~30–60 minutes. Works for any business type — the three shipped archetype *lenses* (SaaS, professional services, e-commerce) only shape emphasis on top of a universal GTM-Brain skeleton.

Built as a self-serve build kit for the **YPO MarTech Forum**, and a companion to the on-stage runtime demo [`Dual-Logic/brainRoadshow`](https://github.com/Dual-Logic/brainRoadshow) (this repo does not modify it).

## How to use it

1. **Install** — in Claude Code / Cowork, add this repo as a plugin marketplace, then install the plugin:

   ```
   /plugin marketplace add Dual-Logic/gtm-brain-plugin-claude
   /plugin install gtm-brain@dual-logic
   ```

   (Or build a `.plugin` bundle locally and upload it directly in Cowork — see [What's inside](#whats-inside).)
2. **Start** — invoke the `gtm-brain` skill. It creates your working document (`gtm-brain-spec.md`) in your project and walks you through four short phases:
   1. **Profile & goals** — it researches your website first, then runs a real discovery conversation about your business, your GTM motions and channels, the decisions you want automated, and your tools.
   2. **Strategy Readout** — a plain-language picture of your GTM Brain; you confirm it's really your business before anything technical is finalized.
   3. **Build Spec** — the plugin drafts the full technical body, researches whether your named tools can actually be integrated (APIs / MCPs), and you refine it by reacting to proposals.
   4. **Finalize** — meta-sections (roadmap, cost, risk, team, maturity), a coherence-check QA pass, and your Open Items hand-off list.
3. **Resume anytime** — the interview persists as it goes. Come back in a new session and `gtm-brain` picks up where you left off, even mid-phase.
4. **Hand off** — give the finished `gtm-brain-spec.md` to your technical person or vendor and walk the Open Items list together.

The plugin **connects to none of your internal systems** and sends nothing on your behalf. It does use **public web research** — your public website, and public API/MCP docs for the tools you name — to ground the spec. See [`CONNECTORS.md`](CONNECTORS.md).

## What's inside

```
skills/     gtm-brain (entry/resume) + profile-and-goals, strategy-readout, build-spec, finalize
            agents: org-researcher (P1) · system-architect (P3) · coherence-checker (P4)
reference/  gtm-brain-skeleton.md, output-template.md, working-doc-convention.md,
            capability-map.md, lens-guide.md, lenses/{saas,professional-services,e-commerce}.md
```

**Direct-upload alternative to the marketplace:** build a `.plugin` bundle locally, then upload the zip in Cowork:

```
zip -r dist/gtm-brain-plugin-0.3.0.zip .claude-plugin/plugin.json skills reference README.md CONNECTORS.md
```

The bundle is a **local build artifact — not tracked in this repo**, because a nested `.zip` inside the repo breaks marketplace install (note `dist/` is gitignored; the zip omits `marketplace.json`). The implementation plan of record is kept locally under `docs/plans/` (internal planning material, not shipped in this repo).
