# Connectors & data access

OpenAI plugins can bundle skills, connectors, and MCP servers. **This plugin intentionally includes skills only.** It ships no connector, no MCP server, no Apps SDK UI, and no hooks.

**It connects to none of your internal systems.** It never touches your CRM, ESP, ad accounts, warehouse, or any other business system; it does not authenticate to any outside system; it stores nothing outside your own workspace/document; and it sends nothing on your behalf. There are no credentials to provide and no OAuth scopes.

**It does use public web research to ground the spec** — read-only lookups of *public* information, performed inline by the skills themselves (there is no separate research subagent), never of your private data:

- during **Profile & goals**, the plugin researches your public website and public news before interviewing, so it questions you from evidence instead of a blank slate (procedure: `skills/profile-and-goals/references/org-research.md`);
- during **Build Spec**, it researches public API / MCP documentation for the tools you name, to judge whether the proposed build is actually feasible (procedure: `skills/build-spec/references/feasibility-research.md`).

If web-research tools aren't available in your surface, the plugin **degrades gracefully** — it just asks you directly instead of researching, and flags anything it couldn't verify.

The GTM Brain spec it produces is **tool-agnostic**: it describes the *capabilities* your Brain needs (a system of record, a messaging rail, a warehouse, enrichment, …) and maps them onto **the tools you name during the interview** — it does not imply that any named-tool mapping has been verified live. Building the actual integrations is your (or your vendor's) job, downstream, from the spec.

For how capabilities map to named tools inside the spec, see [`reference/capability-map.md`](reference/capability-map.md). If a future product decision adds a real connector, MCP server, or Apps SDK UI, follow the OpenAI/ChatGPT plugin conventions (kept locally in `docs/openai-chatgpt-plugin-conventions.md`) before defining any tools.
