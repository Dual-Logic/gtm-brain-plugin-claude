# Org research procedure (Phase 1)

> Read by `profile-and-goals`. This is the research step the skill performs **itself**, inline, before it starts interviewing — it is **not** a separate subagent or subprocess. Do the research silently, record the findings, then open the conversation from them.

Research one organization from its public web presence so the Phase 1 interview starts from evidence instead of a blank slate. Aggregate what's findable, infer carefully, cite sources, and produce the structured findings below.

## Purpose

One job: from the owner's website URL (and any names they give), build a grounded picture of the business so you can *confirm and pressure-test* in the interview rather than ask from zero. This step does not interview the owner — it produces structured findings that the rest of `profile-and-goals` drives the conversation from.

## Inputs

You work from the owner's first answer:

- **website_url**: the org's primary URL (required — it's the first thing Phase 1 asks for).
- **org_name**: the company name, if the owner gave one (else infer from the site).
- **hints**: anything the owner already said (industry, what they sell) — optional.

## Process

**Web-access check first.** If no web/fetch/search/browsing tool is available in this surface, do not guess — treat the result as `status: no_web_access` and fall back to asking the owner to describe the business directly (Phase 1 handles the fallback). Otherwise:

1. **Read the site.** Fetch the homepage, then the highest-signal pages you can find: product/features, pricing, about, customers/case studies, "partners", careers, contact. Note which pages exist — their *presence* is signal (a "Partners" page, a "Book a demo" CTA, an add-to-cart flow, a "Contact sales" path each imply a different GTM motion).
2. **Search the web** for the company: what it does, category, recent news, funding/traction, rough size (headcount/revenue signals), notable customers, main competitors.
3. **Infer GTM signals** from the evidence: business model (one-time / recurring / subscription / marketplace / services), who they appear to sell to, and the **motions/channels visible** (self-serve vs. sales-led vs. partner/channel-led vs. product-led; paid/content/events/outbound cues).
4. **Form a working hypothesis** of the archetype lens (SaaS / professional-services / e-commerce / blend / universal) — as a *starting guess the interview will confirm*, never a verdict.
5. **Mark confidence and gaps.** Separate what you *found* (cited) from what you *inferred*, and list the things only the owner can confirm.

## Findings to produce

Produce findings in this shape and record them in the working marker's `captured_inputs` (tagged as research, cited). This is a working record for the interview, not a value returned to a caller:

```json
{
  "status": "ok",
  "org_name": "...",
  "one_liner": "what they do, in one sentence",
  "offering": "products/services observed",
  "apparent_customers": "who they seem to sell to (segment/size)",
  "business_model": "one-time | recurring | subscription | marketplace | services | blended | unclear",
  "size_signals": "headcount/revenue/traction cues, with source",
  "visible_gtm": {
    "motions": ["e.g. sales-led", "partner/channel", "self-serve"],
    "channels": ["e.g. paid search", "content/SEO", "events", "outbound"],
    "evidence": "the site/search cues these are based on"
  },
  "recent_news": ["dated, cited items that might be GTM-relevant"],
  "competitors": ["named, if found"],
  "hypothesized_lens": "saas | professional-services | e-commerce | blend:<a>+<b> | universal",
  "confidence": "high | medium | low",
  "confirm_with_owner": ["the specific things the interview should verify or dig into"],
  "sources": ["URLs used"]
}
```

If the site is thin or search returns little, return partial findings with `confidence: "low"` and a fuller `confirm_with_owner` list — partial grounding still beats none.

## Guidelines

- **Cite every found claim** (URL). Keep inferred-vs-found separate — never present an inference as a fact.
- **Do not fabricate** numbers, customers, or news. "Not found" is a valid, useful result.
- **Flag surprises for the interview**, don't resolve them silently — e.g. a headcount that looks large for the apparent revenue is exactly the kind of thing the interviewer should pressure-test, so put it in `confirm_with_owner`.
- **Time budget ~30–60s.** If a source hangs, move on; partial output beats total failure.
- **No owner interaction during this step.** Research silently first, then open the interview from the findings — don't narrate the research to the owner as you go.
