# Connectors & data access

**This plugin connects to none of your internal systems.** It never touches your CRM, ESP, ad accounts, warehouse, or any other business system; it stores nothing outside your own project; and it sends nothing on your behalf. There are no credentials to provide, no OAuth scopes, and no `.mcp.json` with vendor defaults.

**It does use public web research to ground the spec** — read-only lookups of *public* information, never your private data:

- an **org-researcher** reads your public website and public news at the start of the interview, so it questions you from evidence instead of a blank slate;
- a **system-architect** researches public API / MCP documentation for the tools you name, to judge whether the proposed build is actually feasible.

If web-research tools aren't available in your environment, the plugin **degrades gracefully** — it just asks you directly instead of researching, and flags anything it couldn't verify.

The GTM Brain spec it produces is **tool-agnostic**: it describes the *capabilities* your Brain needs (a system of record, a messaging rail, a warehouse, enrichment, …) and maps them onto **the tools you name during the interview**. Building the actual integrations is your (or your vendor's) job, downstream, from the spec.

For how capabilities map to named tools inside the spec, see [`reference/capability-map.md`](reference/capability-map.md).
