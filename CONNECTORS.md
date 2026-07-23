# Connectors

**This plugin ships no connectors and calls no external tools.** It is a guided interview that reads and writes one working document in your own project — nothing else. It never connects to your CRM, ESP, ads, warehouse, or any other system, and it sends nothing on your behalf.

That is deliberate. The GTM Brain spec this plugin produces is **tool-agnostic**: it describes the *capabilities* your Brain needs (a system of record, a messaging rail, enrichment, a warehouse, and so on) and maps them onto **the tools you already name during the interview** — whatever they are. Building the actual integrations is your (or your vendor's) job, downstream, from the spec.

If you are reviewing this plugin before installing it: there are no credentials to provide, no OAuth scopes, no `.mcp.json` with vendor defaults, and no network calls. The interview simply asks what you use and writes it into your spec.

For how capabilities map to named tools inside the spec, see [`reference/capability-map.md`](reference/capability-map.md).
