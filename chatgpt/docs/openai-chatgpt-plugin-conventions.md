# OpenAI / ChatGPT Plugin Conventions

Use this companion document when converting, maintaining, or extending the GTM Brain plugin after the initial OpenAI migration.

## Product Positioning

GTM Brain is a skills-only OpenAI plugin unless a future plan explicitly adds connectors, MCP servers, or Apps SDK UI.

The core job is:

```text
Interview a business owner and create one org-specific GTM Brain spec:
1. Strategy Readout
2. Build Spec
3. Open Items / Next Steps
```

The plugin must stay tool-agnostic. It can ask the user what systems they use and record named tools, but it must not claim to connect to those systems unless a real connector or MCP server has been added.

## Surface Rules

Supported target surfaces:

- ChatGPT Work mode on web.
- ChatGPT desktop app in Work mode.
- Codex in the ChatGPT desktop app.
- Codex CLI when installed from a configured plugin marketplace.

Avoid claiming ordinary Chat mode support.

Persistence rules:

- In Codex or any writable local workspace, use `<workspace-root>/gtm-brain-spec.md`.
- In ChatGPT Work mode with an uploaded, generated, or active document, keep the marker at the top of that document.
- In ChatGPT Work mode without durable file/document context, continue within the current chat but tell the user that future resume requires the latest spec document.
- Never store the user's working spec inside the installed plugin directory.

## Plugin Manifest Rules

The plugin manifest lives at:

```text
.codex-plugin/plugin.json
```

Required baseline fields:

- `name`
- `version`
- `description`
- `author.name`
- `skills`
- `interface.displayName`
- `interface.shortDescription`
- `interface.longDescription`
- `interface.developerName`
- `interface.category`
- `interface.capabilities`

Path fields must be relative to the plugin root and start with `./`.

Allowed for this skills-only plugin:

```json
{
  "skills": "./skills/"
}
```

Do not add these fields unless the referenced files or config really exist:

- `apps`
- `mcpServers`
- `hooks`
- `interface.logo`
- `interface.logoDark`
- `interface.composerIcon`
- `interface.screenshots`

Starter prompts:

- Include at most three.
- Keep each under 128 characters.
- Prefer short user outcomes, not implementation jargon.

Good examples:

```text
Start my GTM Brain spec.
Resume my GTM Brain interview.
Review my GTM Brain open items.
```

## Skill Authoring Rules

Each skill must have:

```yaml
---
name: skill-name
description: Clear trigger and boundary.
---
```

Descriptions drive discovery. Write them as concise routing metadata, not marketing copy.

Skill structure:

- `gtm-brain` is the entry and resume skill.
- Phase skills must guard against direct, out-of-order invocation.
- Shared reference docs live in `reference/`, not copied into each skill.
- Each phase skill should read only the references it needs for that phase.

Supported per-skill structure:

```text
skills/
  example-skill/
    SKILL.md
    scripts/
    references/
    assets/
    agents/
      openai.yaml
```

Use these folders deliberately:

- `SKILL.md`: required. Contains the skill frontmatter and the workflow instructions.
- `references/`: optional. Use for long background, templates, schemas, examples, checklists, or decision rules that the skill should read only when needed.
- `scripts/`: optional. Use for deterministic helpers, validators, formatters, file converters, or repeatable transformations. Prefer instructions over scripts unless the step benefits from exact execution.
- `assets/`: optional. Use for templates, images, icons, seed files, or other resources needed by that specific skill.
- `agents/openai.yaml`: optional. Use for skill-level UI metadata, invocation policy, and declared tool dependencies.

Important naming note:

- The `agents/` folder inside a skill is not the same thing as creating a separate workspace agent or subagent workflow. In this context, `agents/openai.yaml` is optional metadata for how OpenAI surfaces and invokes the skill.

Use per-skill `references/`, `scripts/`, and `assets/` when the material belongs to one skill only. Use plugin-level `reference/` when multiple GTM Brain skills share the same material, as this plugin currently does.

Recommended phase-skill guard:

```text
This is a phase skill. If invoked directly and the GTM Brain working marker does not name this phase, stop and route to `gtm-brain`.
```

Progressive disclosure rule:

- Keep frontmatter descriptions compact.
- Put detailed workflow steps in `SKILL.md`.
- Put long shared reusable material in plugin-level `reference/`.
- Put long skill-specific reusable material in that skill's `references/`.
- Do not load every reference in every phase.

## Skill References And Scripts

References:

- Prefer Markdown for human-readable instructions and JSON/YAML for schemas or structured examples.
- Name files by purpose, for example `output-template.md`, `open-items-schema.json`, or `sample-saas-spec.md`.
- At the top of each reference, state which skill reads it and why.
- Keep references authoritative and source-neutral. Do not bury runtime instructions in examples that can drift from `SKILL.md`.
- When references get large, route explicitly: tell the skill which reference to read for each phase or scenario.

Scripts:

- Scripts must be deterministic, narrow, and safe to rerun where possible.
- Put skill-specific scripts under `skills/<skill-name>/scripts/`.
- Put plugin-wide scripts under `scripts/` only if more than one skill uses them or they support packaging/validation.
- Include a short usage block in the script header or a nearby `README.md` when arguments are not obvious.
- Do not require network access, credentials, or external services unless the plugin has explicitly added MCP/connectors and documented the data flow.
- Scripts that mutate files should write only the expected working document or generated artifacts, never installed plugin source files during a user interview.

Good script candidates for this plugin:

- validate the GTM Brain progress marker;
- normalize provenance tags;
- derive Open Items from `[Open - needs your team]` and `[Proposed]` tags;
- check that no material Build Spec section lacks a provenance tag.

Avoid scripts for:

- conversational interviewing;
- subjective Strategy Readout writing;
- speculative architecture generation;
- anything that would silently call a third-party business system.

## Skill Metadata With agents/openai.yaml

Use `skills/<skill-name>/agents/openai.yaml` only when skill-level metadata improves discovery, UI presentation, invocation policy, or dependency declaration.

Typical fields:

```yaml
interface:
  display_name: "GTM Brain"
  short_description: "Create a GTM Brain spec."
  icon_small: "./assets/small-logo.svg"
  icon_large: "./assets/large-logo.png"
  brand_color: "#2563EB"
  default_prompt: "Start my GTM Brain spec."

policy:
  allow_implicit_invocation: false

dependencies:
  tools:
    - type: "mcp"
      value: "exampleToolServer"
      description: "Only include real required tool dependencies."
      transport: "streamable_http"
      url: "https://example.com/mcp"
```

GTM Brain guidance:

- Leave `agents/openai.yaml` out unless there is a clear benefit.
- Consider `allow_implicit_invocation: false` for internal phase skills if testing shows they trigger directly when only `gtm-brain` should route.
- Do not declare tool dependencies for this plugin while it remains skills-only and no-connector.
- Do not reference icon files unless they exist under that skill's `assets/` folder.

## Runtime Reference Rules

Do not use Claude-specific variables.

Avoid:

```text
${CLAUDE_PROJECT_DIR}
${CLAUDE_PLUGIN_ROOT}
```

Use wording like:

```text
Resolve the installed plugin root from this skill file's path. Shared references live at ../../reference/ from each phase skill directory.
```

For the working document:

```text
Use <workspace-root>/gtm-brain-spec.md when a writable workspace is available. Otherwise use the active ChatGPT Work document or current chat artifact.
```

## GTM Brain Workflow Rules

The workflow order is fixed:

```text
gtm-brain -> profile-and-goals -> strategy-readout -> build-spec -> finalize -> complete
```

Do not skip the Strategy Readout resonance gate.

The marker must stay at the top of the working document:

```text
<!-- GTM-BRAIN-PROGRESS
phase: <profile-and-goals | strategy-readout | build-spec | finalize | complete>
last_completed_step: <short label>
lens: <(undetermined) | saas | professional-services | e-commerce | blend:<a>+<b> | universal>
captured_inputs:
  business: <raw owner inputs>
  tools: <named tools by capability category>
-->
```

Capture raw owner inputs as well as synthesis. Resume depends on the raw wording.

## Provenance Rules

Every material technical decision in the Build Spec must carry exactly one provenance tag:

- `[Stated]`
- `[Proposed]`
- `[Proposed - confirmed]`
- `[Open - needs your team]`

Use ASCII hyphens in tag names after conversion. If preserving existing em dash tags during migration, normalize them in the same edit.

Open Items are derived, never maintained by hand:

- include every `[Open - needs your team]` item;
- include every remaining `[Proposed]` item;
- exclude `[Stated]` and `[Proposed - confirmed]`.

Never invent a tool, data source, integration path, model, or compliance answer to avoid an Open Item.

## No-Connector Rules

This plugin currently ships no connectors, no MCP server, no Apps SDK UI, and no hooks.

Therefore it must not:

- ask for credentials;
- request OAuth scopes;
- read from CRM, ESP, ads, warehouse, email, calendar, or docs systems through a connector;
- send messages or write to external systems;
- imply that named-tool mapping has been verified live.

It may:

- ask the user what tools they use;
- map required capabilities to user-stated named tools;
- flag missing capabilities;
- write a build-ready spec for the user's builder or vendor.

## When To Add MCP Or Apps SDK

Add MCP or Apps SDK only when the product needs live tools, structured data, or custom UI.

Good reasons:

- Fetching records from a CRM or warehouse.
- Writing updates to external systems.
- OAuth-protected user data.
- A custom review UI for Open Items or spec sections.
- Persistent server-side state shared across chats.

Bad reasons:

- Merely improving instructions.
- Packaging skills.
- Naming tools the user already told us about.
- Making the plugin feel more official.

If adding MCP tools:

- one job per tool;
- action-oriented names;
- descriptions that begin with "Use this when...";
- minimal inputs;
- structured outputs;
- correct `readOnlyHint`, `destructiveHint`, and `openWorldHint` annotations;
- explicit human confirmation for irreversible or public actions;
- no hidden side effects.

If adding Apps SDK UI:

- use it to clarify an interaction that is hard to review in plain text;
- keep the conversation authoritative;
- define CSP and data-handling policies;
- test mobile and desktop layouts;
- do not submit screenshots for apps without UI.

## Marketplace And Install Conventions

Use a personal marketplace for solo local testing:

```text
~/.agents/plugins/marketplace.json
```

Use a repo marketplace for team/repo distribution:

```text
<repo-root>/.agents/plugins/marketplace.json
```

Marketplace entries must include:

- `name`
- `source`
- `policy.installation`
- `policy.authentication`
- `category`

Default values:

```json
{
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

After updating an installed local plugin, reinstall or refresh through the appropriate marketplace flow and start a new chat/session before testing.

## Validation Conventions

Run plugin validation before handing off:

```bash
python3 /Users/peterdudka/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py <plugin-root>
```

Run skill validation for every skill:

```bash
for d in <plugin-root>/skills/*; do
  python3 /Users/peterdudka/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d"
done
```

Search for stale migration terms:

```bash
rg -n "Claude|Cowork|CLAUDE_|\\.claude-plugin|\\.plugin bundle" <plugin-root>
```

Test with a golden prompt set:

- direct trigger prompts;
- indirect trigger prompts;
- negative prompts that must not activate the plugin;
- resume prompts with an existing marker;
- out-of-order phase prompts.

Record results in `docs/VALIDATION.md`.

## Official References

- ChatGPT Plugins: https://learn.chatgpt.com/docs/plugins
- Build plugins: https://learn.chatgpt.com/docs/build-plugins
- Build skills: https://learn.chatgpt.com/docs/build-skills
- MCP in ChatGPT: https://learn.chatgpt.com/docs/extend/mcp
- Apps SDK overview: https://developers.openai.com/apps-sdk
- Apps SDK app guidelines: https://developers.openai.com/apps-sdk/app-guidelines
- Apps SDK metadata optimization: https://developers.openai.com/apps-sdk/guides/optimize-metadata
- Apps SDK submission guidance: https://developers.openai.com/apps-sdk/deploy/submission
