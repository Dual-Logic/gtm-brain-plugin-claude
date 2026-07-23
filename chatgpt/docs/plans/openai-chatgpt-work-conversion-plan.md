# OpenAI / ChatGPT Work Conversion Plan

This plan converts the existing GTM Brain plugin files into an OpenAI-compatible, skills-only plugin for ChatGPT Work mode and Codex. It is written for an implementation agent that will copy the current package into a new target package, update the copied files, and validate the result.

## Goal

Produce an installable OpenAI plugin named `gtm-brain` that distributes the existing guided GTM Brain interview as reusable skills. The converted plugin should:

- install through ChatGPT/Codex plugin mechanisms;
- work in ChatGPT Work mode and Codex where skills are available;
- preserve the current business workflow, provenance tags, lenses, and one-spec output model;
- avoid introducing connectors, MCP servers, Apps SDK UI, hooks, or network access unless a later product decision explicitly adds them;
- document the conventions future agents must follow when extending the plugin.

## Current Source Package

Source root:

```text
/Users/peterdudka/Downloads/gtm-brain-plugin-0.2.0
```

Important current files:

```text
.claude-plugin/plugin.json
README.md
CONNECTORS.md
skills/gtm-brain/SKILL.md
skills/profile-and-goals/SKILL.md
skills/strategy-readout/SKILL.md
skills/build-spec/SKILL.md
skills/finalize/SKILL.md
reference/capability-map.md
reference/gtm-brain-skeleton.md
reference/lens-guide.md
reference/lenses/e-commerce.md
reference/lenses/professional-services.md
reference/lenses/saas.md
reference/output-template.md
reference/working-doc-convention.md
```

Known source issues to repair during conversion:

- The OpenAI/Codex plugin manifest is missing. Validation currently fails with `missing .codex-plugin/plugin.json`.
- The current manifest lives at `.claude-plugin/plugin.json`.
- README and reference copy still mention Claude Cowork.
- Skills and references use Claude-specific path variables such as `${CLAUDE_PROJECT_DIR}` and `${CLAUDE_PLUGIN_ROOT}`.
- README references `docs/plans/2026-07-22-002-feat-gtm-brain-plugin-plan.md`, which is not present in this folder.

## Target Package Shape

Create a clean converted package, keeping the existing package untouched until the converted copy validates:

```text
gtm-brain-openai/
  .codex-plugin/
    plugin.json
  README.md
  CONNECTORS.md
  docs/
    VALIDATION.md
    openai-chatgpt-plugin-conventions.md
    plans/
      openai-chatgpt-work-conversion-plan.md
  skills/
    gtm-brain/
      SKILL.md
    profile-and-goals/
      SKILL.md
    strategy-readout/
      SKILL.md
    build-spec/
      SKILL.md
    finalize/
      SKILL.md
  reference/
    capability-map.md
    gtm-brain-skeleton.md
    lens-guide.md
    output-template.md
    working-doc-convention.md
    lenses/
      e-commerce.md
      professional-services.md
      saas.md
```

Do not copy `.claude-plugin/` into the final converted package unless preserving it in a separate migration archive outside the plugin root.

## Phase 1: Copy And Establish The OpenAI Plugin Wrapper

1. Create the target package directory.
2. Copy `skills/`, `reference/`, `README.md`, and `CONNECTORS.md` from the source package into the target package.
3. Create `.codex-plugin/plugin.json`.
4. Do not create `.app.json`, `.mcp.json`, `hooks/`, or `assets/` unless this same conversion effort adds real corresponding functionality.

Use this manifest as the starting point:

```json
{
  "name": "gtm-brain",
  "version": "0.2.0",
  "description": "Guided interview that creates an org-specific GTM Brain spec with a Strategy Readout, Build Spec, and Open Items list.",
  "author": {
    "name": "Dual Logic",
    "url": "https://duallogic.ai"
  },
  "homepage": "https://github.com/Dual-Logic/gtm-brain-plugin",
  "repository": "https://github.com/Dual-Logic/gtm-brain-plugin",
  "license": "UNLICENSED",
  "keywords": ["gtm", "go-to-market", "revops", "strategy", "interview"],
  "skills": "./skills/",
  "interface": {
    "displayName": "GTM Brain",
    "shortDescription": "Create a GTM Brain spec through a guided interview.",
    "longDescription": "GTM Brain interviews a business owner and produces a plain-language Strategy Readout, a builder-ready Build Spec, and an Open Items handoff list. It is tool-agnostic and ships no connectors.",
    "developerName": "Dual Logic",
    "category": "Productivity",
    "capabilities": ["Interactive", "Write"],
    "websiteURL": "https://duallogic.ai/",
    "defaultPrompt": [
      "Start my GTM Brain spec.",
      "Resume my GTM Brain interview.",
      "Review my GTM Brain open items."
    ],
    "brandColor": "#2563EB"
  }
}
```

Manifest rules:

- Keep `name` kebab-case and aligned with the plugin folder name when installed.
- Keep `version` strict semver unless using a local cachebuster suffix during iterative install testing.
- Keep `skills: "./skills/"`.
- Omit `apps` unless `.app.json` exists.
- Omit `mcpServers` unless `.mcp.json` exists or a real inline MCP server config is added.
- Omit `hooks` during this conversion. Add hooks later only if there is a concrete lifecycle enforcement need.
- Do not reference icon, logo, logoDark, or screenshots unless real files exist under `assets/`.

## Phase 2: Replace Claude-Specific Language And Runtime Assumptions

Sweep all copied files for these terms:

```text
Claude
Cowork
.claude-plugin
.plugin bundle
CLAUDE_PROJECT_DIR
CLAUDE_PLUGIN_ROOT
```

Required replacements:

- "Claude Cowork plugin" -> "OpenAI plugin for ChatGPT Work mode and Codex"
- "Cowork may auto-select" -> "ChatGPT/Codex may select"
- "upload the `.plugin` bundle" -> "install from Plugins or a configured marketplace"
- `${CLAUDE_PROJECT_DIR}` -> "the active project/workspace root when file access is available"
- `${CLAUDE_PLUGIN_ROOT}` -> "the installed plugin root; resolve reference files relative to this `SKILL.md`"

Do not invent undocumented OpenAI environment variables. For references inside skill instructions, prefer explicit relative guidance:

```text
Resolve the plugin root from this skill file's installed path. The shared reference files live at ../../reference/ from each phase skill directory, or at reference/ from the plugin root.
```

For the working document, use surface-aware language:

```text
When a writable project/workspace is available, keep the durable working document at <workspace-root>/gtm-brain-spec.md. In ChatGPT Work mode without a writable local workspace, maintain the spec as the current chat/document artifact and ask the user to attach or provide the existing spec when resuming.
```

## Phase 3: Update Skill Activation Boundaries

The current phase skills are valid, but descriptions should be tuned for OpenAI's progressive-disclosure model. Keep each description concise and front-load trigger terms.

Recommended skill roles:

- `gtm-brain`: the only normal user entry point. Starts/resumes and routes.
- `profile-and-goals`: internal phase skill. Runs only when the working marker says `phase: profile-and-goals`.
- `strategy-readout`: internal phase skill. Runs only after profile capture and owns the resonance gate.
- `build-spec`: internal phase skill. Runs only after the Strategy Readout is confirmed.
- `finalize`: internal phase skill. Runs only after Build Spec draft is ready.

Recommended description pattern:

```yaml
---
name: profile-and-goals
description: Internal Phase 1 for GTM Brain. Use only after gtm-brain creates or resumes the spec and the marker says phase: profile-and-goals. Captures business profile, goals, priority decisions, tools, and constraints.
---
```

Add an explicit line near the top of every phase skill:

```text
This is a phase skill. If invoked directly and the GTM Brain working marker does not name this phase, stop and route to `gtm-brain`.
```

Keep the current out-of-order guards. They are a strength of the package.

## Phase 4: Preserve The Product Workflow While Making It Surface-Aware

Preserve these behaviors exactly:

- one GTM Brain spec per project/workspace;
- raw inputs are stored, not just synthesis;
- Strategy Readout must be confirmed before technical Build Spec work;
- owner reacts to proposals rather than authoring technical content;
- material technical statements use provenance tags;
- Open Items are derived from `[Open - needs your team]` and remaining `[Proposed]` items;
- tool/vendor mappings use named tools the owner provides, not assumed vendors;
- no connectors and no external tool calls.

Make these surface-aware edits:

- In Codex/local workspace, write `gtm-brain-spec.md` as a real file.
- In ChatGPT Work mode with uploaded files or generated documents, treat the spec as the active document artifact and keep the marker at the top.
- If no durable document/file context is available, tell the user the current chat can continue the interview but resuming later requires them to provide the latest `gtm-brain-spec.md`.
- Do not claim the plugin connects to CRM, ESP, ads, warehouse, or calendar systems. It only captures user-stated tool names.

## Phase 5: Refresh README And Connector Documentation

Rewrite `README.md` around these sections:

1. What this plugin does.
2. Supported surfaces: ChatGPT Work mode and Codex.
3. What it creates: `gtm-brain-spec.md` or an equivalent active Work-mode document.
4. How to start: install the plugin, start a new chat/session, ask to start or resume a GTM Brain spec.
5. What is inside: skills and references.
6. No connectors/no external tool calls.
7. Resume behavior and what users must provide in Work mode when no project file is available.
8. Validation status and where to find `docs/VALIDATION.md`.

Update `CONNECTORS.md` to use current terminology:

- Plugins can include skills, connectors, and MCP servers, but this plugin intentionally includes skills only.
- It does not authenticate to outside systems.
- It does not read from or write to business systems.
- Future connector work must follow `docs/openai-chatgpt-plugin-conventions.md`.

Remove or replace missing-plan links.

## Phase 6: Add Validation Documentation

Create `docs/VALIDATION.md` with these sections:

```text
# Validation

## Static Checks
- Plugin manifest validates.
- Every SKILL.md validates.
- No Claude-specific terms remain except in an intentional migration note.
- No apps/mcpServers/hooks manifest fields exist without matching files.

## Workflow Checks
- Fresh start creates or begins a GTM Brain spec.
- Resume reads the marker and does not restart.
- Out-of-order phase invocation routes back to gtm-brain.
- Strategy Readout correction loop revises in place.
- Build Spec does not run until confirmation is recorded.
- Finalize derives Open Items from tags.

## Surface Checks
- Codex/local workspace behavior.
- ChatGPT Work mode with an uploaded or active spec document.
- ChatGPT Work mode without a durable file, including resume limitation message.

## Golden Prompt Set
- Direct prompts that should trigger gtm-brain.
- Indirect prompts that should trigger gtm-brain.
- Negative prompts that should not trigger it.
```

Suggested golden prompts:

Should trigger:

- "Start my GTM Brain spec."
- "Help me design a go-to-market decision system for my business."
- "Resume the GTM Brain interview in this project."
- "Create a builder-ready GTM Brain spec from an owner interview."

Should not trigger:

- "Write a generic GTM strategy memo."
- "Connect to HubSpot and pull my pipeline."
- "Build an MCP server for Salesforce."
- "Make a landing page for my consulting firm."

## Phase 7: Install And Test Locally

Run static validation:

```bash
python3 /Users/peterdudka/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py <target-plugin-root>
for d in <target-plugin-root>/skills/*; do
  python3 /Users/peterdudka/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d"
done
```

If using a personal marketplace:

```json
{
  "name": "personal",
  "interface": {
    "displayName": "Personal"
  },
  "plugins": [
    {
      "name": "gtm-brain",
      "source": {
        "source": "local",
        "path": "./plugins/gtm-brain"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
```

Use a repo marketplace instead only if the goal is repo/team distribution.

After install or reinstall, start a new chat/session before testing the updated skills.

## Phase 8: Defer Apps SDK / MCP Until There Is A Real Integration

Do not build an Apps SDK app or MCP server in this conversion. This plugin is currently a workflow and reference pack, not a connected app.

Only add Apps SDK/MCP when one of these is explicitly required:

- reading or writing CRM, warehouse, ads, calendar, email, or document-system data;
- persistent server-side state outside the chat/project document;
- a custom ChatGPT UI for reviewing the Strategy Readout, Build Spec, or Open Items;
- OAuth or workspace-admin managed access.

If that later happens, create a separate implementation plan. Follow the companion conventions doc before defining tools.

## Acceptance Criteria

The conversion is complete when:

- `.codex-plugin/plugin.json` exists and validates;
- `.claude-plugin/` is absent from the converted plugin root;
- all skills validate;
- no active instructions depend on Claude-specific variables or product names;
- README describes ChatGPT Work mode and Codex behavior accurately;
- `CONNECTORS.md` accurately says this is skills-only and no-auth/no-connectors;
- `docs/openai-chatgpt-plugin-conventions.md` exists;
- `docs/VALIDATION.md` records static and workflow validation;
- the first-run, resume, out-of-order, resonance-gate, build-spec, and finalize flows have been tested with at least one sample business.

## Official References

- ChatGPT Plugins: https://learn.chatgpt.com/docs/plugins
- Build plugins: https://learn.chatgpt.com/docs/build-plugins
- Build skills: https://learn.chatgpt.com/docs/build-skills
- Apps SDK overview: https://developers.openai.com/apps-sdk
- Apps SDK app guidelines: https://developers.openai.com/apps-sdk/app-guidelines
- Apps SDK submission guidance: https://developers.openai.com/apps-sdk/deploy/submission
