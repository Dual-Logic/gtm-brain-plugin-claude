<!-- PHASE-PROGRESS:START — the resume marker. Every skill reads this first and rewrites it as it works. Keep it accurate. -->
```yaml
# RESUME MARKER — read this first, always.
org_name: Meridian
created: 2026-07-15
last_updated: 2026-07-22
current_phase: complete   # profile-and-plays | strategy-readout | architecture-and-stack | build-spec | complete
last_completed_step: "Build Spec completeness pass + sequencing recommendation"
status: complete          # in_progress | phase_complete | complete
resonance_confirmed: true # set true only after the operator confirms the Strategy Readout (gate for build-tier phases)
phases:
  profile-and-plays:      complete   # not_started | in_progress | complete
  strategy-readout:       complete
  architecture-and-stack: complete
  build-spec:             complete
next_action: "Spec complete. Hand the Build Spec to RevOps + eng. Before building the churn play, close the two flagged gaps (support-ticket source; Gong→Snowflake path)."
```
<!-- PHASE-PROGRESS:END -->

---

# GTM Brain — Meridian

> Draft spec produced through the GTM-Brain interview. Two linked tiers:
> the **Strategy Readout** (for the operator — is this your business?) sits above the fold;
> the **Build Spec** (for the builder — can you stand up a v1?) sits below it.

## Raw capture

### Org profile (Phase 1)
- **Industry / business model:** B2B SaaS — a horizontal workflow-automation platform (connect your apps, build automated multi-step workflows, no-code). ~$28M ARR, ~180 employees, Series B. Founded 2018.
- **Motion (PLG / sales-led / hybrid; inbound vs outbound weight):** *"Hybrid, and honestly that's our whole problem. Anyone can start a free 14-day trial and self-serve onto a paid Team plan — that's most of our logo count. But the deals that actually move ARR are the 500-plus-seat companies, and those need a human. So we run product-led on top with a sales-assist layer. Inbound-heavy — trials and content — with light outbound from SDRs, mostly following up on product signals rather than cold."*
- **Who they sell to (segments, ICP in their words):** *"RevOps and operations leaders — the person who owns the tools stack and is drowning in manual handoffs between systems. Companies between 200 and 2,000 employees. Below 200 they self-serve and we never talk to them; above 2,000 it turns into a procurement slog we're not staffed for yet. Sweet spot is a 500–1,200-person company with a RevOps team of 3–8 people."*
- **GTM team shape & who runs plays:** RevOps team of 3 (owns HubSpot + Snowflake + the reporting layer). 8 AEs (sales-assist / expansion). 5 SDRs (work product-qualified signals, not cold lists). 6 CSMs (post-sale, own renewals + expansion jointly with AEs). A 2-person growth/PLG team owns the trial funnel and in-product activation. *"RevOps is the team that would actually own a 'brain' — they already live in Snowflake."*
- **Stated GTM goals (this quarter / this year), in the operator's words:**
  - *"Stop leaking sales-ready trials. We have thousands of trials a month and the SDRs are guessing which ones to touch. We know we're leaving good accounts to expire quietly."*
  - *"Turn our install base into a growth engine. Net revenue retention is 108% and it should be 120%+ for a product like ours — expansion is right there in the usage data and we're not systematically catching it."*
  - *"See churn coming. We got surprised by two mid-five-figure logos last quarter that looked fine in HubSpot right up until they didn't renew. Usage had been dying for weeks and nobody was watching the right number."*
- **The decisions they most wish were automatic / made better:**
  - *"Which trial accounts are worth a human this week — and who takes them — without an SDR eyeballing a dashboard."*
  - *"Which existing accounts are ready for an expansion conversation, and the specific reason why, handed to the AE."*
  - *"Which accounts are quietly dying before renewal — ranked, so CS works the biggest risks first, not whoever emailed last."*

### Discovered plays (Phase 1) — no menu was shown; these emerged from the conversation
- **Play 1: PQL routing** — the trial-leak problem. Product-usage + trial + firmographic-fit signals decide which self-serve accounts get a sales touch this week and who takes them (SDR vs. straight-to-AE), and which stay fully self-serve. *"This is the one that's bleeding money today."*
- **Play 2: Expansion-ready detection** — the NRR problem. Seat growth + feature adoption + usage-ceiling signals flag install-base accounts ready for an expansion conversation, each with the specific basis (more seats vs. tier upgrade vs. overage), routed to the account owner.
- **Play 3: Churn-risk early warning** — the surprise-churn problem. Usage decline + support-ticket + call-sentiment signals surface silently-at-risk accounts before renewal, ranked by what's at stake, routed to CS with a reason.
- **(Priority order the operator gave):** 1 → PQL routing (revenue leaking now, evidence already in hand), 2 → Expansion (biggest upside, evidence mostly in hand), 3 → Churn (highest stakes per miss, but needs a signal we don't fully have wired yet).

### Architecture inputs per play (Phase 3)
- **PQL routing:** Evidence = in-product events (workflows created, workflow runs, integrations connected, active users) via Segment→Amplitude and landed raw in Snowflake; trial metadata (start/end, plan) from the product DB + HubSpot; firmographic fit from Clearbit (employee count, industry, tech stack). Entity = the *account* (workspace), stitched to a HubSpot company and any HubSpot contacts from the same domain. Facts = a composite `pql_score`, `icp_fit`, `activation_reached`. Decision = route to SDR queue / straight-to-AE / stay self-serve. Owner of the decision: RevOps; action taken by SDRs then AEs.
- **Expansion-ready detection:** Evidence = seat counts + feature adoption (Amplitude / Snowflake), plan quota consumption (product DB), current tier + renewal date (HubSpot). Entity = the customer *account* + its open renewal/expansion opportunity. Facts = `seat_growth_30d`, `usage_ceiling_pct`, `feature_adoption_breadth`, a typed `expansion_signal`. Decision = flag expansion with a typed basis, route to the account's AE/CSM. Action: create expansion opp + notify.
- **Churn-risk early warning:** Evidence = usage decline (Snowflake event tables), login recency, **support-ticket sentiment (source system TBD — see gap)**, call sentiment from Gong, renewal date + contract value from HubSpot. Entity = customer *account* + renewal opp + primary champion contact. Facts = `usage_trend_30d`, `login_gap_days`, `call_sentiment_30d`, `support_ticket_sentiment`, composite `churn_risk_score`. Decision = flag + rank + route to CSM with the driving reason.

### Named tool stack (Phase 3)
- `~~CRM` → **HubSpot** (Sales Hub Enterprise). System of record for companies, contacts, deals, renewals. Owned by RevOps. Confidence: high.
- `~~web/product analytics` → **Segment** (CDP; event collection + identity + destinations) **+ Amplitude** (product analytics / behavioral cohorts + feature adoption). Segment already has a Snowflake warehouse destination live. Confidence: high.
- `~~sales engagement` → **Outreach** (SDR/AE sequences + task cadence). Confidence: high.
- `~~data warehouse` → **Snowflake** (RevOps' analytics warehouse; Segment lands events here; dbt in use for modeling). Confidence: high.
- `~~enrichment` → **Clearbit** (firmographic + technographic enrichment on domain/email). Confidence: high; *note operator flagged the HubSpot/Breeze-Intelligence transition — confirm the live API surface (see gap).*
- `~~conversation intelligence` → **Gong** (records + transcribes AE/CSM calls; sentiment + topic tracking). Confidence: high for the product; the *data-out* path is the open question (see gap).
- **Tools mentioned that don't map cleanly to a category:** a helpdesk/ticketing tool for support tickets was referenced ("our support queue") but **not named** — no ticketing system appears in the confirmed stack (see data gap). No reverse-ETL / activation tool is owned today — flagged as a v1 build dependency, not an existing capability.

## Strategy Readout

*Read this and tell me: is this your business?*

### What your GTM Brain is for
Meridian sells a product anyone can start using in fourteen minutes, but the deals that move real ARR still need a human at the right moment — and today that moment is decided by an SDR scanning a dashboard or a CSM reacting to whoever emailed last. This brain owns those "who and when" calls across your whole funnel: which self-serve trials have earned a sales touch, which paying accounts are sitting on an expansion you haven't asked for, and which customers are quietly dying before a renewal you assume is safe. It's the judgment layer between your product-usage data and your revenue team — so the signals you already collect actually decide who your team talks to next, instead of piling up in Amplitude and Snowflake unread.

### The priority plays it runs
1. **PQL routing** — your product-led-plus-sales-assist handoff, made automatic.
   - *The decision it makes for you:* which trial accounts are sales-ready this week, who takes them (an SDR touch, straight to an AE for the big-fit ones, or left fully self-serve), and it does that on the usage and fit signals rather than an SDR's gut.
   - *Why it's a priority:* it's the leak you named first — thousands of trials a month, good accounts expiring quietly because no one flagged them in time.
2. **Expansion-ready detection** — your install base as a growth engine.
   - *The decision it makes for you:* which existing accounts are ready for an expansion conversation and *on what specific basis* — they've outgrown their seats, they've hit their usage ceiling, or they're leaning on features their tier doesn't cover — handed to the account owner with the reason already attached.
   - *Why it's a priority:* it's your path from 108% net revenue retention to the 120%+ a product like yours should hold — the expansion is already visible in the usage data.
3. **Churn-risk early warning** — no more surprise non-renewals.
   - *The decision it makes for you:* which accounts are silently at risk before renewal, ranked by what's at stake, routed to the right CSM with the reason they're slipping — usage falling off, a champion gone dark, sour call sentiment.
   - *Why it's a priority:* it's the highest-stakes miss you described — two mid-five-figure logos lost last quarter that looked healthy in the CRM until they didn't renew.

### What it will feel like when it's working
Your SDRs stop guessing — Monday morning they get a ranked, already-owned queue of trials worth a human, and the rest genuinely stay hands-off. Your AEs and CSMs get expansion flags with the reason pre-written ("this account is at 90% of its run quota and added 11 seats this month"), so the conversation opens itself. And the churn conversation happens six weeks before the renewal call instead of after it — CS works the biggest at-risk dollars first, with a why, not a wall of green health scores that lie.

### The shape underneath (one paragraph, plain-English)
Under the readout there's a real system, not a set of dashboards. It continuously *watches* the signals you already generate — product usage, trial activity, enrichment, calls — and first does the unglamorous work of tying every stray signal back to the right *account* (the same company shows up as a dozen trial signups, a HubSpot record, and a Snowflake row — it stitches them into one). From there it turns those resolved signals into a handful of trustworthy, dated *facts* about each account ("sales-ready," "at 90% of quota," "usage down 40% in 30 days"), applies clear rules to decide *which play to run on whom*, and hands your team the action. Then it watches what happened — did the touch convert, did the account renew — and tunes itself, so next month's calls are sharper than this month's. That last part is what makes it a brain and not just another report.

> **Resonance checkpoint.** Operator confirms: ☑ *"Yes, this is my business."*  |  ☐ *Needs correction:*
> Operator (Dana Reyes, VP RevOps) confirmed 2026-07-18: *"This is exactly it — especially the churn framing. The one thing I'd underline is PQL first; that's the one I want built while we're still talking."* No corrections to scope. `resonance_confirmed: true`.

<!-- — — — — — — — — — — — —  FOLD  — — — — — — — — — — — — -->

## Build Spec

*For the eng team / technical marketer standing up v1. Every play below is specified against the
fixed GTM-Brain skeleton (evidence → identity → fact/decision + OODA+L loop). See
`gtm-brain-skeleton.md` for the model; `category-map.md` for the capability vocabulary.*

### System overview
- **Brain purpose (technical restatement):** maintain a per-account fact store in Snowflake that continuously classifies every Meridian account (trial or customer) on three decision axes — *sales-readiness*, *expansion-readiness*, and *churn-risk* — and routes accounts that cross a policy threshold to the correct human queue (SDR/AE/CSM) in HubSpot + Outreach + Slack, with the driving reason attached, then reconciles outcomes back into the facts.
- **The fixed skeleton, instantiated for Meridian:**
  - *Evidence layer:* product-usage/behavioral events (workflows created, workflow runs, integrations connected, active seats, logins) collected by **Segment** and landed raw in **Snowflake** via Segment's warehouse destination, with **Amplitude** as the analyst-facing behavioral surface; trial + subscription metadata (plan, quota, seats, renewal date) from the product DB and **HubSpot**; firmographic/technographic enrichment from **Clearbit**; conversational sentiment from **Gong**; CRM history + owner + contract value from HubSpot. (Support-ticket sentiment is a fourth churn signal with **no confirmed source** — see gaps.)
  - *Identity layer:* the canonical entity is the **account** (product `workspace_id`). Every play resolves `workspace_id ↔ email-domain ↔ HubSpot company_id`, folds multiple trial signups / contacts from one domain into that single account, and attaches the open HubSpot deal/renewal (`deal_id`) and the primary champion `contact_id`. Segment's identity resolution stitches anonymous→known at the user level; the account-level stitch (domain → company) is a Snowflake join, with Clearbit resolving free-mail / ambiguous domains. This join is the precision chokepoint for all three plays.
  - *Fact/Decision layer:* a `account_facts` table in Snowflake (one row per `workspace_id`, refreshed on the loop cadence), holding the typed facts each play consumes (`pql_score`, `icp_fit`, `activation_reached`, `seat_growth_30d`, `usage_ceiling_pct`, `expansion_signal`, `usage_trend_30d`, `churn_risk_score`, …), each carrying `derived_from`, `as_of` timestamp, and `confidence`. Decision policies run as versioned dbt models / SQL on top of `account_facts`, emitting a `play_routing` table (account, play, decision, reason, target_owner).
  - *Loop:* **batch, scheduled, with an event-triggered fast path for high-value accounts.** A nightly dbt run rebuilds `account_facts` from the previous day's events. PQL routing evaluates **weekly (Mon 06:00 ET)**; expansion **weekly (Mon)**; churn **daily**. A same-day event trigger fires for named-account trials (Clearbit fit `strong` + employee_count ≥ 500) so a hot enterprise trial isn't held for the Monday batch. **Act** writes back to HubSpot/Outreach/Slack via a reverse-ETL sync (see build dependency). **Learn** re-ingests outcomes (opp created, meeting booked, closed-won expansion, renewed/churned) from HubSpot nightly and tunes fact weights + thresholds.

- **v1 build dependency (not an owned tool):** writing facts *back out* of Snowflake into HubSpot/Outreach/Slack needs a **reverse-ETL / activation** capability (`~~reverse-ETL`). Meridian does not own one today. Recommend **Census** or **Hightouch** (both have first-class Snowflake→HubSpot + Snowflake→Slack + Snowflake→Outreach syncs). This is a required v1 procurement, called out here so the builder budgets for it rather than discovering it mid-build.

### The tool stack (capability → named tool)
| Capability (`~~category`) | Meridian's tool | Tier/notes | Confidence |
|---|---|---|---|
| `~~CRM` | HubSpot | Sales Hub Enterprise; system of record for company/contact/deal/renewal; RevOps-owned | high |
| `~~web/product analytics` | Segment + Amplitude | Segment = CDP + identity + **live Snowflake warehouse destination**; Amplitude = behavioral cohorts / feature adoption | high |
| `~~sales engagement` | Outreach | SDR + AE sequences and task cadence; PQL + expansion actions land here | high |
| `~~data warehouse` | Snowflake | RevOps analytics warehouse; dbt in use; **the brain's fact store lives here** | high |
| `~~enrichment` | Clearbit | firmographic + technographic on domain/email; feeds `icp_fit` | med — confirm live API surface post-HubSpot/Breeze transition (see gap) |
| `~~conversation intelligence` | Gong | records/transcribes AE + CSM calls; sentiment + topic; feeds `call_sentiment_30d` | high (product) / med (data-out path — see gap) |
| `~~reverse-ETL` *(not yet owned)* | — (recommend Census or Hightouch) | required v1 dependency to sync facts → HubSpot/Outreach/Slack; not in current stack | n/a — build decision |

### Plays — the "how", one per play

#### Play: PQL routing
- **Capability contract**
  - *Inputs:* per-account product-usage aggregates (7d + trial-to-date), trial metadata (plan, `trial_start`, `trial_end`), Clearbit firmographics, current HubSpot ownership state.
  - *Outputs:* a routing decision fact per active-trial account — `{route: sdr_queue | direct_ae | stay_self_serve, target_owner, reason}` — written as a HubSpot company property + task/deal, and an Outreach sequence enrollment for routed accounts.
  - *Trigger:* weekly batch (Mon 06:00 ET) over all accounts with `trial_status = active`; plus same-day event trigger when a new trial resolves to Clearbit fit `strong` + employee_count ≥ 500.
- **Observe — evidence needed:** workflows created, workflow_runs_7d, integrations_connected, active_seats_7d, distinct login days → from `~~web/product analytics → Segment→Snowflake` (raw events) / Amplitude (adoption cohorts); trial plan + dates → product DB + `~~CRM → HubSpot`; employee_count, industry, installed-tech → `~~enrichment → Clearbit`.
- **Orient — entity + resolution:** acts on the **account** (`workspace_id`); must resolve `workspace_id → email-domain → HubSpot company_id`, collapse multiple trial signups from one domain into that account, and detect whether the company already has an owner/open deal (do not re-route an owned account).
- **Decide — facts + policy:**
  - Facts consumed:
    - `pql_score` = number 0–100 · derived from a weighted blend of {activation depth, usage velocity 7d, seat count, icp_fit} on the account · as of 2026-07-22 · confidence high
    - `icp_fit` = enum {strong, moderate, weak} · derived from Clearbit {employee_count 200–2,000, target industries, RevOps-tech present} · as of 2026-07-22 · confidence high
    - `activation_reached` = boolean · true when account has ≥3 live workflows AND ≥2 connected integrations AND ≥1 successful workflow_run in last 7d · as of 2026-07-22 · confidence high
    - `account_owned` = boolean · from HubSpot (owner set OR open deal exists) · as of 2026-07-22 · confidence high
  - Decision policy:
    - `IF pql_score ≥ 85 AND icp_fit = strong AND employee_count ≥ 500 AND NOT account_owned THEN route = direct_ae` (skip SDR; assign to the enterprise AE round-robin).
    - `IF pql_score ≥ 70 AND icp_fit IN {strong, moderate} AND NOT account_owned THEN route = sdr_queue` (assign via SDR round-robin; enroll in the "PQL — product-signal" Outreach sequence).
    - `IF pql_score < 40 OR icp_fit = weak THEN route = stay_self_serve` (no human; leave to in-product growth nurture).
    - `ELSE hold` (40 ≤ score < 70, or moderate fit unowned) → surfaced to RevOps for weekly review, not auto-routed.
- **Act — the action:** write `pql_route` + `pql_reason` to the HubSpot company; create the SDR/AE task and (for routed accounts) an open deal at stage *Product Qualified*; enroll routed contacts in the matching Outreach sequence; post the ranked Monday queue to the `#pql-queue` Slack channel. All writes flow Snowflake→destination via reverse-ETL.
- **Learn — outcome + feedback:** outcome signal = meeting booked / opp advanced past *Product Qualified* / self-serve conversion without touch. Nightly, join routed accounts to their HubSpot outcome; feed conversion-by-`pql_score`-band back to re-weight the `pql_score` model quarterly, and demote signals that routed accounts which never converted (e.g. if `workflow_runs_7d` over-predicts).
- **Build notes for v1:** all four facts are computable **today** from data already in Snowflake (Segment events) + HubSpot + Clearbit — no new evidence needed, which is why this play is first. Build order: (1) the `workspace_id ↔ company_id` identity join as a reusable dbt model (every play depends on it); (2) `pql_score` as a transparent weighted-sum dbt model (not ML v1 — keep it inspectable so RevOps trusts it); (3) the `pql_route` decision model; (4) reverse-ETL syncs to HubSpot + Outreach + Slack. Start `pql_score` weights hand-set with RevOps; move to fitted weights only after 1–2 quarters of labeled outcomes.

#### Play: Expansion-ready detection
- **Capability contract**
  - *Inputs:* per-account seat counts (licensed vs. active), plan quota consumption, premium-feature usage, current tier + renewal date, account owner.
  - *Outputs:* an `expansion_signal` fact with a typed basis per customer account, an expansion opportunity in HubSpot, and an owner notification carrying the specific reason.
  - *Trigger:* weekly batch (Mon) over all `subscription_status = active` accounts.
- **Observe — evidence needed:** active_seats_30d vs. licensed_seats, workflow_runs_mtd vs. plan_run_quota, count of distinct premium features used → from `~~web/product analytics → Segment→Snowflake` / Amplitude + product DB; current tier, MRR, renewal date, owner → `~~CRM → HubSpot`.
- **Orient — entity + resolution:** acts on the customer **account** (`workspace_id`) and its open **renewal/expansion opportunity** (`deal_id`); must resolve seats to *active distinct users* (dedupe shared logins / service accounts) so seat growth is real, and attach the current AE/CSM owner.
- **Decide — facts + policy:**
  - Facts consumed:
    - `seat_growth_30d` = number · net new active distinct seats over trailing 30d, and as % of licensed_seats · derived from event logins on the account · as of 2026-07-22 · confidence med (depends on the seat-dedupe resolution)
    - `usage_ceiling_pct` = number · workflow_runs_mtd ÷ plan_run_quota · as of 2026-07-22 · confidence high
    - `feature_adoption_breadth` = number · count of premium/next-tier-gated features used in trailing 30d · as of 2026-07-22 · confidence high
    - `plan_tier` = enum {team, business, enterprise} · from HubSpot/product DB · as of 2026-07-22 · confidence high
    - `expansion_signal` = enum {none, seat_expansion, tier_upgrade, usage_overage} · derived (composite of the above) · as of 2026-07-22 · confidence med
  - Decision policy:
    - `IF usage_ceiling_pct ≥ 1.0 THEN expansion_signal = usage_overage` (already over quota — highest-intent; route immediately with an overage-to-upgrade motion).
    - `IF usage_ceiling_pct ≥ 0.80 AND plan_tier != enterprise THEN expansion_signal = tier_upgrade`.
    - `IF feature_adoption_breadth ≥ 1 for features gated above plan_tier THEN expansion_signal = tier_upgrade` (using what they haven't paid for).
    - `IF seat_growth_30d ≥ 20% of licensed_seats OR ≥ 5 net new active seats THEN expansion_signal = seat_expansion`.
    - Precedence when multiple fire: `usage_overage > tier_upgrade > seat_expansion`. `ELSE expansion_signal = none`.
- **Act — the action:** for any account with `expansion_signal != none`, create/update a HubSpot expansion deal tagged with the typed basis; write `expansion_signal` + a templated `expansion_reason` string ("at 92% of monthly run quota on Team; 11 net new active seats in 30d") to the company; notify the account owner in `#expansion-signals` Slack and via an Outreach task. Do **not** auto-send anything to the customer — this play routes a human, it doesn't email the account.
- **Learn — outcome + feedback:** outcome signal = expansion opp created → closed-won expansion (seats or tier) / no action taken after N days. Feed win-rate by `expansion_signal` type back to reorder which basis the brain surfaces first, and tune thresholds (e.g. if `seat_growth_30d ≥ 5` produces low-conversion flags, raise the floor).
- **Build notes for v1:** `usage_ceiling_pct`, `feature_adoption_breadth`, `plan_tier` are computable today. The one soft spot is `seat_growth_30d` — it's only trustworthy if "active seat" is defined cleanly (distinct authenticated users with ≥1 session in the window, excluding service accounts / SSO test users); build that definition as a dbt model with RevOps sign-off before the play ships, or seat growth will produce false expansion flags. Reuse the identity join from the PQL play. This play shares the reverse-ETL syncs; incremental cost over Play 1 is low, which is why it's second.

#### Play: Churn-risk early warning
- **Capability contract**
  - *Inputs:* usage-trend aggregates, login recency, call sentiment, support-ticket sentiment, renewal date + contract value, champion engagement.
  - *Outputs:* a ranked at-risk list — `churn_risk_score` + the driving reason per account — a CS task in HubSpot, and a Slack alert to the owning CSM.
  - *Trigger:* daily batch over all `subscription_status = active` accounts with `days_to_renewal ≤ 120`; hard escalation path for `contract_value ≥ $50k`.
- **Observe — evidence needed:** weekly active workflow_runs trend, active_seats trend, last-session recency → `~~web/product analytics → Segment→Snowflake`; call sentiment + risk topics ("pricing," "competitor," "deprioritize") → `~~conversation intelligence → Gong`; support-ticket volume + sentiment → **support/ticketing system (unconfirmed — see gap)**; renewal date, contract_value, champion contact + last activity → `~~CRM → HubSpot`.
- **Orient — entity + resolution:** acts on the customer **account** (`workspace_id`), its **renewal opportunity** (`deal_id`), and the **primary champion** `contact_id`; must resolve Gong calls and support tickets to the right account (Gong calls key off attendee email domains; tickets off requester domain) and detect champion departure (champion contact goes inactive / bounces).
- **Decide — facts + policy:**
  - Facts consumed:
    - `usage_trend_30d` = enum {rising, flat, declining, cliff} · derived from % change in weekly active workflow_runs, trailing 30d vs. prior 30d (cliff = >50% drop) · as of 2026-07-22 · confidence high
    - `login_gap_days` = number · days since any active session on the account · as of 2026-07-22 · confidence high
    - `call_sentiment_30d` = enum {positive, neutral, negative, none} · derived from Gong call sentiment + risk-topic hits in trailing 30d · as of 2026-07-22 · confidence med (**pending Gong data-out path — see gap**)
    - `support_ticket_sentiment` = enum {positive, neutral, negative, none} · **derived from an unconfirmed ticketing source — see data gap** · as of — · confidence low
    - `champion_engaged` = boolean · champion contact had a login OR a logged HubSpot activity in trailing 30d · as of 2026-07-22 · confidence med
    - `days_to_renewal` = number · from HubSpot renewal deal · as of 2026-07-22 · confidence high
    - `churn_risk_score` = number 0–100 · weighted composite of the above · as of 2026-07-22 · confidence med
  - Decision policy:
    - `IF usage_trend_30d IN {declining, cliff} AND days_to_renewal ≤ 90 THEN flag churn_risk` (route to CSM).
    - `IF login_gap_days ≥ 21 AND days_to_renewal ≤ 120 THEN flag churn_risk`.
    - `IF NOT champion_engaged AND days_to_renewal ≤ 90 THEN flag churn_risk` (champion gone dark).
    - `IF call_sentiment_30d = negative OR support_ticket_sentiment = negative THEN raise churn_risk_score one tier`.
    - **Ranking:** among flagged accounts, order by `churn_risk_score × contract_value` (dollars-at-risk first). Attach the highest-weight driver as the `churn_reason`.
- **Act — the action:** write `churn_risk_score` + `churn_reason` + `risk_tier` to the HubSpot company; create a CS "save" task on the renewal deal assigned to the owning CSM; post the daily ranked at-risk list to `#churn-watch` Slack with dollars-at-risk and reason per account. High-value (`contract_value ≥ $50k`) risks additionally @-mention the CS lead.
- **Learn — outcome + feedback:** outcome signal = renewed / churned / downgraded at the renewal date, and whether a save action was logged. Feed renewal outcome vs. `churn_risk_score` back to calibrate the composite weights (which signals actually preceded churn), and specifically validate whether `support_ticket_sentiment` and `call_sentiment_30d` add predictive lift once their sources are wired — drop them from the score if they don't.
- **Build notes for v1:** ship this play in **two stages**. *Stage A (buildable now):* `usage_trend_30d`, `login_gap_days`, `champion_engaged`, `days_to_renewal` are all computable from Snowflake + HubSpot today — that four-signal score alone would have caught both logos lost last quarter (usage was in `cliff` for weeks), so it delivers value before the harder signals land. *Stage B (after gaps close):* add `call_sentiment_30d` (Gong) and `support_ticket_sentiment` (ticketing source) once their integration paths are confirmed. Keep `churn_risk_score` a transparent weighted sum in v1; do not black-box it — CS has to trust the ranking to work it. This is third because Stage B depends on the two open gaps below.

### Completeness pass — gaps (flag, never omit)

**Data gaps** — a chosen play needs evidence the org has not described:
- ⚠️ **Churn-risk play needs support-ticket sentiment, but Meridian named no ticketing/helpdesk system.** The operator referenced "our support queue," but no helpdesk (Zendesk / Intercom / Freshdesk / HubSpot Service Hub) appears in the confirmed stack, so `support_ticket_sentiment` has no source. **Required:** identify the ticketing system of record, confirm it can export ticket volume + text (or a native sentiment field) into Snowflake (most helpdesks offer a Segment source or a native warehouse sync), and instrument it. Until then the churn play ships **without** this signal (Stage A above) rather than blocking — but the fact is defined so it slots in when the source lands.

**Integration-knowledge gaps** — a named tool whose how-to the interviewer cannot credibly specify:
- ⚠️ **`~~conversation intelligence → Gong` is named, but the concrete path to get structured call sentiment/topics into Snowflake is not specified here.** Gong exposes call data via its public API, and separately offers a native data-warehouse export / Snowflake share on some plans. **Builder should confirm:** which is available on Meridian's Gong plan, whether sentiment + risk-topic tags are included (vs. raw transcripts only, which would push sentiment derivation into the brain), and the refresh cadence — this determines whether `call_sentiment_30d` is a direct pull or a derived fact. *(Flagged rather than hand-waved as vague "capability" talk.)*
- ⚠️ **`~~enrichment → Clearbit` API surface, post-HubSpot/Breeze transition.** Clearbit now sits inside HubSpot as Breeze Intelligence; the operator was unsure whether they consume it via the standalone Clearbit enrichment API or through HubSpot-native enrichment properties. **Builder should confirm** the live access path before wiring `icp_fit`, since it changes whether enrichment is a Snowflake API pull or already-present HubSpot company properties (the latter is simpler and preferred if available).

### Sequencing recommendation
Build **PQL routing first**: it's the operator's stated top priority, its four facts are computable today from data already in Snowflake + HubSpot + Clearbit with **no open gaps**, and it establishes the reusable `workspace_id ↔ company_id` identity join and the reverse-ETL syncs that both other plays inherit. Build **Expansion-ready detection second** — it reuses that identity join and the syncs, adds only warehouse-side fact models, and its one soft spot (a clean "active seat" definition) is a modeling task, not a missing tool. Build **Churn-risk early warning third, in two stages**: ship Stage A (usage/login/champion/renewal — enough to have caught last quarter's losses) as soon as PQL's plumbing exists, then add Stage B (Gong + support-ticket sentiment) once the two flagged gaps are closed. Procure the reverse-ETL tool (Census or Hightouch) at the start of Play 1, since all three plays depend on it to act.
