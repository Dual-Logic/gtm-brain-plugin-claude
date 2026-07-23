---
name: profile-and-goals
description: Phase 1 of the GTM Brain interview. Elicits the business layer a non-technical owner can drive — their business, GTM goals, the decisions they most want automated, their actual named tools, and key constraints — and records them in gtm-brain-spec.md. Runs after gtm-brain creates the working doc; hands off to strategy-readout.
---

# Phase 1 — Profile & goals

This is the phase the owner **drives**, and it is the heart of the whole interview. Everything else the plugin proposes; here you elicit the raw material only they can supply. Run it like a sharp consultant on a discovery call who is genuinely trying to understand this business — not like a form to get through. Take real time here: this phase should be the bulk of the session (roughly 20–30 minutes of the hour), and a rushed Phase 1 produces a generic, forgettable spec. Never use skeleton/architecture vocabulary with the owner.

## Order guard (run first)

Read `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md` and its phase-progress marker (contract: `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md`). If the working doc doesn't exist yet, don't run — route to `gtm-brain` to create it and orient the owner first. Otherwise only run if `phase:` is `profile-and-goals`. If it's a later phase, this phase is done — report that and route to the current phase. If somehow earlier, route back to `gtm-brain`. Resume at `last_completed_step`; never re-ask an answered question.

## How to run this phase (pacing & depth)

- **One question at a time.** Never batch questions. Ask, listen, react to what they said, then ask the next. This is the single most important rule for this phase.
- **Follow up on shallow answers.** If an answer is one line or generic, don't move on — ask a follow-up: "say more about that", "can you give me a recent example?", "how often does that happen?", "what makes that hard today?", "who's involved when that happens?". Two or three exchanges per thread is normal and good.
- **Reflect back.** Every so often, summarize what you're hearing so the owner feels understood and can correct you.
- **Breadth over leverage.** Ask more than the final document strictly needs. Genuinely understanding the business — and earning the owner's trust that you get it — matters as much as filling fields. It is fine, and expected, that some of what you learn never appears verbatim in the spec.

Capture raw answers verbatim into the marker's `captured_inputs` as you go; append synthesized notes to the working doc.

## What to elicit (each area is a thread of several questions, not one)

Work through these six areas in order. Each is a short conversation with follow-ups — not a single question. Don't advance to the next area until the current one is genuinely explored.

### 1. The business
- What do you sell, and to whom?
- How do you actually make money — one-time, recurring, projects, subscription, blended?
- Roughly how big — revenue range, customer or account count, growth stage?
- Walk me through the journey from a stranger to a paying customer.
- Follow up until you could describe their GTM shape back to them accurately.

### 2. The team & how they work
- Who's on the go-to-market side today — sales, marketing, success, ops? Rough headcount and roles.
- Who owns the decisions you'll eventually want this system to help with?
- How does work actually flow between people day to day? Where are the handoffs, and where do they break down?
- Is there anyone technical — in-house or a vendor — who would build or run something like this?
- Follow up on who does what, so the eventual team/operating-model section is grounded in reality.

### 3. GTM goals
- What are you trying to move most right now?
- Why that, and why now? What happens if it doesn't move?
- How do you measure it today — what's the number, and where does it live?
- Follow up until each goal is concrete, not a slogan.

### 4. The decisions you'd most want automated (the crux)
- What repetitive or high-stakes go-to-market judgment calls would you most like a system to make or recommend for you?
- For each one they name, go deep: How do you make that call today? Who makes it? How often? What does getting it wrong cost you?
- Probe for a handful of concrete decisions and go deep on each — a few well-understood decisions beat a long shallow list.
- Do **not** present a preset catalog or menu — discover these from their business. Use the lens hints (below) to probe well, never to prescribe.

### 5. Your tools — and how you actually use each one
- First, get the real names across the GTM surface: system of record, messaging (email/SMS/push), ads, analytics, data warehouse, enrichment, support, billing (see `${CLAUDE_PLUGIN_ROOT}/reference/capability-map.md` for the categories to cover).
- Then, **for each named tool, go one level deeper — one tool at a time:** What do you use it for? What's working well? What's painful or missing? How central is it to your day? Who administers it? Does your data actually live there, or somewhere else?
- Note any capability they have **no** tool for explicitly — those gaps matter later.

### 6. Constraints (ask each as its own question — do not bundle them)
Ask these one at a time with follow-ups; never collapse them into a single "any constraints?":
- **Budget** — what can you realistically spend to build and run this? Is there a hard ceiling?
- **Team capacity** — can you add people this year, or does this have to live within the current team?
- **Compliance / regulatory** — anything that limits how you can contact people or use their data (privacy law, SMS rules, industry regulation)?
- **Brand & channel rules** — anything you'd never do (discount a flagship product, use a particular channel, a tone)?
- **Data limits** — anything you can't touch, don't have, or can't move between systems?

## Classify the lens silently

From their answers, infer the archetype lens per `${CLAUDE_PLUGIN_ROOT}/reference/lens-guide.md` (`saas` / `professional-services` / `e-commerce` / `blend:<a>+<b>` / `universal`). Record it in the marker's `lens:`. **Do not ask "which are you?"** The lens sharpens your probing and later proposals; it is never surfaced to the owner. If the org matches none of the three, set `universal` and anchor on their **unit of decision** (per lead / account / customer / pursuit / order / patient / member…).

## Finishing

Don't rush to finish. Only wrap this phase when all six areas above have been explored with follow-ups and you could confidently describe this business, its team, its goals, its priority decisions, and its stack to a colleague. If it felt quick, you moved too fast — go back and deepen.

When the business layer is genuinely captured (business, team, goals, priority decisions, tools with per-tool detail, constraints, lens set), update the marker — set `phase: strategy-readout` and `last_completed_step: business-layer-captured` — then hand off to `strategy-readout`. Tell the owner what's next in a sentence: "Next I'll play back a plain-language picture of your GTM Brain so you can tell me if it's really your business."

## Guardrails

- One question at a time; business language only. Never batch questions.
- Depth over speed. Follow up on shallow answers; a fast Phase 1 is a failed Phase 1. This is meant to be a real discovery conversation, not a checklist sprint.
- Breadth is fine — ask more than the doc needs to genuinely understand the business and build trust; not everything you learn has to land in the spec.
- Discover decisions; never show a catalog/menu (violates the discovery principle and the org-specific bar).
- Capture raw words, not only your paraphrase — resume depends on it.
- Don't propose architecture here. That's `build-spec`. This phase is about *their* business.
