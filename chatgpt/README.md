# GTM Brain — OpenAI / ChatGPT build

A tool-agnostic **OpenAI plugin for ChatGPT Work mode and Codex** that interviews a business owner and produces one tiered, org-specific **GTM Brain** spec:

- a **Strategy Readout** — plain-language, the part you read and confirm ("yes, this is my business"), and
- a **Build Spec** — a builder-ready technical body your engineer or vendor can execute from,

plus an **Open Items / Next Steps** list that becomes the agenda for the hand-off conversation with your technical team.

You drive the business layer (your goals, the decisions you most want automated, your actual tools). The plugin does the technical lifting — it *proposes* the architecture and you confirm or correct it in plain language, never authoring technical content yourself. Every technical claim is tagged so a builder can tell what you decided (`[Stated]`) from what the plugin inferred (`[Proposed - confirmed]`) from what still needs your team (`[Open - needs your team]`). Takes ~30–60 minutes. Works for any business type — the three shipped archetype *lenses* (SaaS, professional services, e-commerce) only shape emphasis on top of a universal GTM-Brain skeleton.

> This is the OpenAI build. The Claude Cowork build of the same product lives in the sibling [`../claude/`](../claude/) package. See the [root README](../README.md) for how the two relate.

## Supported surfaces

- ChatGPT **Work mode** on web
- ChatGPT **desktop app** in Work mode
- **Codex** in the ChatGPT desktop app
- **Codex CLI** when installed from a configured plugin marketplace

Ordinary ChatGPT Chat mode is not a claimed surface.

## What it creates

One working document — the GTM Brain spec — that fills in as the interview proceeds:

- In **Codex / any writable workspace**, it's a real file at `<workspace-root>/gtm-brain-spec.md`.
- In **ChatGPT Work mode with an uploaded or generated document**, it's that active document, with a progress marker kept at the top.
- In **ChatGPT Work mode with no durable file**, the interview continues in the current chat — but resuming in a later session then requires you to re-attach or paste the latest `gtm-brain-spec.md` (see [Resume](#resume-behavior)).

## How to start

1. **Install** the plugin from Plugins, or from a configured marketplace (see [`docs/plans/openai-chatgpt-work-conversion-plan.md`](docs/plans/openai-chatgpt-work-conversion-plan.md) for a local/personal marketplace entry).
2. **Start a new chat/session**, then ask to start or resume — e.g. *"Start my GTM Brain spec."* The `gtm-brain` skill creates your working document and walks you through four short phases:
   1. **Profile & goals** — it researches your website first (public web only), then runs a real discovery conversation about your business, GTM motions and channels, the decisions you want automated, and your tools.
   2. **Strategy Readout** — a plain-language picture of your GTM Brain; you confirm it's really your business before anything technical is finalized.
   3. **Build Spec** — the plugin drafts the full technical body, researches whether your named tools can actually be integrated (APIs / MCPs), and you refine it by reacting to proposals.
   4. **Finalize** — meta-sections (roadmap, cost, risk, team, maturity), a coherence-check QA pass, and your Open Items hand-off list.
3. **Hand off** — give the finished `gtm-brain-spec.md` to your technical person or vendor and walk the Open Items list together.

## What's inside

```
skills/     gtm-brain (entry/resume) + profile-and-goals, strategy-readout, build-spec, finalize
            each phase skill performs its own research inline via skills/<name>/references/
reference/  gtm-brain-skeleton.md, output-template.md, working-doc-convention.md,
            capability-map.md, lens-guide.md, lenses/{saas,professional-services,e-commerce}.md
```

`gtm-brain` is the only normal entry point. The four phase skills are **internal** — they guard against out-of-order invocation and route back to `gtm-brain` if the working marker doesn't name their phase.

## No connectors / no external tool calls

This plugin **connects to none of your internal systems** and sends nothing on your behalf. It ships no connectors, no MCP server, no Apps SDK UI, and no hooks. It **does** use **public web research** — your public website, and public API/MCP docs for the tools you name — to ground the spec, and it degrades gracefully (asks you directly, flags what it couldn't verify) if no web-research tool is available. See [`CONNECTORS.md`](CONNECTORS.md).

## Resume behavior

The interview persists as it goes, in the working document. On a new session, `gtm-brain` reads the progress marker and picks up where you left off — even mid-phase — without re-asking answered questions.

- In **Codex / a writable workspace**, resume is automatic from `gtm-brain-spec.md`.
- In **ChatGPT Work mode without a durable file**, the current chat can continue the interview, but to resume in a *later* session you must provide the latest `gtm-brain-spec.md` (upload it or paste it) so the marker and captured inputs are available.

## Validation status

Static structural checks pass (manifest, no Claude-specific terms in active instructions, ASCII provenance tags, relative reference paths). The OpenAI validator scripts and live ChatGPT/Codex workflow, surface, and golden-prompt testing are still pending. See [`docs/VALIDATION.md`](docs/VALIDATION.md) for the full checklist and current status, and [`docs/openai-chatgpt-plugin-conventions.md`](docs/openai-chatgpt-plugin-conventions.md) for the conventions any future extension must follow.
