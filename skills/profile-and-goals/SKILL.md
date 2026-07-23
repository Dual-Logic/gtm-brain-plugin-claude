---
name: profile-and-goals
description: Phase 1 of the GTM Brain interview. Elicits the business layer a non-technical owner can drive — their business, GTM goals, the decisions they most want automated, their actual named tools, and key constraints — and records them in gtm-brain-spec.md. Runs after gtm-brain creates the working doc; hands off to strategy-readout.
---

# Phase 1 — Profile & goals

This is the phase the owner **drives**. Everything else the plugin proposes; here you elicit the raw material only they can supply. Ask like a curious advisor, one thing at a time, in business language. Never use skeleton/architecture vocabulary with the owner.

## Order guard (run first)

Read `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` and its phase-progress marker (contract: `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md`). If the working doc doesn't exist yet, don't run — route to `gtm-brain` to create it and orient the owner first. Otherwise only run if `phase:` is `profile-and-goals`. If it's a later phase, this phase is done — report that and route to the current phase. If somehow earlier, route back to `gtm-brain`. Resume at `last_completed_step`; never re-ask an answered question.

## What to elicit (the business layer)

Cover these, conversationally and in the owner's terms. Capture raw answers verbatim into the marker's `captured_inputs` as you go, and append synthesized notes to the working doc.

1. **The business** — what they sell, to whom, how they make money, roughly how big. Enough to understand the shape of their GTM.
2. **GTM goals** — what they're trying to move (more pipeline, higher win rate, better retention, lower acquisition cost, more referrals…). In their words.
3. **The decisions they most want automated** — the heart of Phase 1. What repetitive or high-stakes go-to-market judgment calls would they most like a system to make or recommend? Probe for a handful of concrete ones ("who to follow up with and when", "which deals to chase", "what offer to send whom", "which pursuits to bid on"). Do **not** present a preset catalog or menu — discover these from their business. Use the lens hints (below) to probe well, not to prescribe.
4. **Their tools** — the actual named systems they use, by capability (see `${CLAUDE_PLUGIN_ROOT}/reference/capability-map.md`): their system of record, messaging/rails, analytics, ads, warehouse, enrichment, etc. Capture real names ("we use Pipedrive and Klaviyo"), not categories. It's fine if they don't have one in a category — note the gap.
5. **Constraints** — anything that bounds action: budget, team size, compliance/regulatory realities, brand rules, channels they won't use, data they can't touch.

## Classify the lens silently

From their answers, infer the archetype lens per `${CLAUDE_PLUGIN_ROOT}/reference/lens-guide.md` (`saas` / `professional-services` / `e-commerce` / `blend:<a>+<b>` / `universal`). Record it in the marker's `lens:`. **Do not ask "which are you?"** The lens sharpens your probing and later proposals; it is never surfaced to the owner. If the org matches none of the three, set `universal` and anchor on their **unit of decision** (per lead / account / customer / pursuit / order / patient / member…).

## Finishing

When the business layer is captured (goals, priority decisions, tools, constraints, lens set), update the marker — set `phase: strategy-readout` and `last_completed_step: business-layer-captured` — then hand off to `strategy-readout`. Tell the owner what's next in a sentence: "Next I'll play back a plain-language picture of your GTM Brain so you can tell me if it's really your business."

## Guardrails

- One question at a time; business language only.
- Discover decisions; never show a catalog/menu (violates the discovery principle and the org-specific bar).
- Capture raw words, not only your paraphrase — resume depends on it.
- Don't propose architecture here. That's `build-spec`. This phase is about *their* business.
