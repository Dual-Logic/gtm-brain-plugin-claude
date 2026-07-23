# Feasibility research procedure (Phase 3)

> Read by `build-spec`. This is the feasibility-research step the skill performs **itself**, inline, after drafting the technical body — it is **not** a separate subagent or subprocess. Research, then fold the findings back into the body yourself.

Assess whether the drafted Build Spec is actually buildable on the org's named tools. Research each tool's real integration surface (APIs, webhooks, official MCP servers, reverse-ETL connectors), judge feasibility, and produce structured findings you fold back into the Build Spec — so it reads "buildable because X" or "gap, needs your team," never a plausible-sounding guess.

## Purpose

Performed after the technical body is drafted. Take the capability→tool mappings and the priority decisions and answer, per pairing: *can this actually be integrated, and how?* This is a research step — it does not talk to the owner; its findings sharpen the capability→tool table and the Open Items list.

## Inputs

You work from the drafted body:

- **capabilities_and_tools**: the draft's capability→named-tool pairings (e.g. "messaging → Klaviyo", "warehouse → BigQuery", "system of record → Shopify").
- **priority_decisions**: the decisions the Brain must make (so you can judge which integrations are load-bearing vs. nice-to-have).
- **unit_of_decision**: the org's unit (per customer / account / pursuit / …), which shapes where the decision logic should live.

## Process

**Web-access check first.** If no web/fetch/search/browsing tool is available in this surface, treat the result as `status: no_web_access` and fall back to prose-level feasibility notes flagged unverified (Phase 3 handles the fallback). Otherwise, for each capability→tool pairing:

1. **Research the integration surface.** Does the tool have a documented public API? Webhooks/events for triggers? An **official MCP server**? Support in reverse-ETL/ELT connectors (Hightouch, Census, Fivetran)? What auth model (API key / OAuth), and any notable rate limits or well-known gotchas?
2. **Judge feasibility** for what the decisions need:
   - `buildable` — a clear, documented path exists for what's required.
   - `buildable_with_caveats` — possible, but with a real constraint (rate limits, no real-time webhook, paid tier required, partial coverage).
   - `gap` — no clean integration for what the decision needs; this is an `[Open]` item.
3. **Locate the decision engine's home.** Given the stack and unit of decision, where should the Brain's logic actually run (e.g. scheduled jobs in the warehouse + a thin service calling the messaging API)? Recommend, with reasoning.
4. **Flag gaps**: capabilities with no named tool, and named tools with no viable integration path for the required decision.

## Findings to produce

Produce findings in this shape, then fold them into §2.2 and the Open Items list. This is a working record, not a value returned to a caller:

```json
{
  "status": "ok",
  "per_capability": [
    {
      "capability": "messaging (email/SMS)",
      "tool": "Klaviyo",
      "integration_found": "documented REST API (profiles, events, campaigns) + webhooks; reverse-ETL support in Hightouch/Census",
      "verdict": "buildable",
      "caveats": "rate limits on bulk calls; SMS requires separate consent handling",
      "sources": ["https://..."]
    }
  ],
  "recommended_decision_engine_home": "scheduled dbt/SQL models in BigQuery + a thin script calling the Klaviyo + Shopify APIs — no new platform needed",
  "gaps": [
    "depletion/usage data: no tool named provides per-SKU usage; recommend deriving from reorder-interval history",
    "experimentation/holdout tracking: no tool named; needs a lightweight holdout table or an Eppo/Statsig-style tool"
  ],
  "overall_feasibility": "buildable | buildable_with_caveats | significant_gaps",
  "notes": "anything the builder should know before starting",
  "sources": ["all URLs used"]
}
```

If research is thin for a tool, say so (`verdict` reflecting uncertainty, `caveats` noting what couldn't be confirmed) rather than asserting a path you didn't verify.

## Guidelines

- **Cite documentation** for every integration claim. No unsourced "it has an API."
- **Distinguish "an API exists" from "I confirmed the exact endpoint/scope."** The builder verifies specifics — your findings enter the spec tagged `[Proposed]`, not `[Stated]`.
- **Never invent** an API, MCP server, or connector. "Couldn't confirm a public API" is a real, useful `gap`.
- **Judge against the decisions, not in the abstract** — a tool may have an API that still can't do what a specific decision needs (e.g. no real-time trigger for an abandonment flow); that's `buildable_with_caveats` or `gap`, and say why.
- **Time budget ~1–2 min.** Prioritize the load-bearing integrations (the ones the priority decisions depend on) over completeness.
- **No owner interaction during this step.** Research first; then fold the findings into the Build Spec.
