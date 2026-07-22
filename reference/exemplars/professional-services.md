<!-- PHASE-PROGRESS:START — the resume marker. Every skill reads this first and rewrites it as it works. Keep it accurate. -->
```yaml
# RESUME MARKER — read this first, always.
org_name: Aldertree Advisory
created: 2026-07-15
last_updated: 2026-07-22
current_phase: complete            # profile-and-plays | strategy-readout | architecture-and-stack | build-spec | complete
last_completed_step: completeness-pass + sequencing
status: complete                   # in_progress | phase_complete | complete
resonance_confirmed: true          # set true only after the operator confirms the Strategy Readout (gate for build-tier phases)
phases:
  profile-and-plays:      complete
  strategy-readout:       complete
  architecture-and-stack: complete
  build-spec:             complete
next_action: "None — spec complete. Hand the Build Spec to the builder; start v1 at the sequencing recommendation."
```
<!-- PHASE-PROGRESS:END -->

---

# GTM Brain — Aldertree Advisory

> Draft spec produced through the GTM-Brain interview. Two linked tiers:
> the **Strategy Readout** (for the operator — is this your business?) sits above the fold;
> the **Build Spec** (for the builder — can you stand up a v1?) sits below it.

## Raw capture (internal)

*The operator's actual answers, captured across sittings. Retained as the source the tiers are
synthesized from; not part of the operator/builder-facing deliverable. Interview run by the Director
of Practice Development (delegate), with a founding partner joining Phase 1.*

### Org profile (Phase 1)
- **Industry / business model:** Boutique management-consulting firm. Operational transformation and
  value creation for mid-market and PE-backed companies — post-merger integration, operating-model
  redesign, org design, cost transformation. ~120 people, 14 partners, HQ Chicago + a NYC office,
  founded 2011. Engagements are high-value and long — *"a real one is six to eighteen months from
  first coffee to signed, and it's almost never a competitive RFP. Someone we know decides it's time,
  and they call the partner they trust."*
- **Motion (PLG / sales-led / hybrid; inbound vs outbound weight):** Relationship- and referral-led.
  Zero PLG, no marketing funnel, no SDR/BDR. Partners carry books of relationships and sell
  personally; a 3-person Practice Development team supports all 14 partners. Thought leadership
  (a biweekly Beehiiv newsletter, ~4,000 subscribers, plus partner LinkedIn posts) is top-of-funnel
  air cover, not a lead engine. *"Our pipeline is our partners' relationships. Full stop."*
- **Who they sell to (segments, ICP in their words):** The buyer is a COO, CFO, or CEO at a
  $100M–$1B-revenue company, very often a PE portfolio company. *"The buyer isn't a company, it's a
  person who trusts us — and the trigger is usually that person taking a new seat or their company
  hitting a moment where the operating model has to change."* Referral ecosystem: PE operating
  partners and deal partners, M&A investment bankers, transaction counsel, executive-search firms,
  and alumni/former clients who move to new companies.
- **GTM team shape & who runs plays:** Partners own relationships and do all the actual outreach —
  *"a touch from us has to come from the partner personally, in their voice; if it looks automated
  we've lost."* Practice Development curates, researches, and preps; it never sends on a partner's
  behalf. So the brain must **decide and draft, never send**.
- **Stated GTM goals (this quarter / this year):**
  1. Grow off the channel that actually works — more repeat and referral work — rather than chasing
     cold logos.
  2. *"Stop letting good relationships go cold. We have partners with 400 people in their network and
     no system watching the clock. Dozens of valuable relationships lapse every year purely because
     nobody noticed."*
  3. Catch timing windows — a former client becomes a new COO, a portfolio company gets acquired.
     *"Those are our highest-conversion openings and we miss most of them. By the time we hear, they've
     already hired someone."*
  4. Systematize what the best two or three partners do on instinct so the whole firm does it.
- **The decisions they most wish were automatic / made better:**
  - *"Who in my network haven't I talked to in too long who actually matters — and what do I say?"*
  - *"Which of my referral sources have gone quiet, and is now the moment to re-warm them?"*
  - *"When did something happen at a company I care about that means I should pick up the phone?"*

### Discovered plays (Phase 1) — no menu was shown; these emerged from the conversation
- **Play 1: Relationship-cadence / warm-network nurture** — the "watch the clock on the relationships
  that matter" problem. Decide which dormant-but-valuable relationships need a partner touch this
  month, and hand the partner a reason to reach out. *Why it matters:* directly attacks goal #2, the
  one the founding partner got most animated about.
- **Play 2: Referral-source activation** — the "our best channel is quietly decaying" problem. Detect
  which referral sources have gone quiet or just had a relevant event (closed a new fund, added a
  portfolio company, changed roles) and prompt a re-activation. *Why it matters:* goal #1 — referrals
  are the highest-yield pipeline and nobody systematically tends the sources.
- **Play 3: Buying-signal / proposal-timing detection** — the "we hear about it too late" problem.
  Detect when a target org or known contact hits a trigger event (leadership change, acquisition, new
  PE investment, regulatory shift, expansion) that opens a partner-led conversation. *Why it matters:*
  goal #3 — the highest-conversion openings the firm currently misses.
- **Priority order the operator gave:** 1 → 3 → 2. *"Cadence first because it's the daily bleed.
  Timing second because it's the biggest upside. Referral activation third — honestly because our
  referral data is the messiest and I know it."*

### Architecture inputs per play (Phase 3)
- **Entity across all three plays is a *person / relationship*, not an account funnel.** The firm
  thinks in people, and the same person recurs across plays (a former client is a relationship to
  nurture, a referral source, *and* the subject of a job-change trigger). The hard problem is
  resolving one human across Copper, Outlook, and LinkedIn — especially when they change jobs and
  their email address dies.
- **Play 1 evidence discussed:** Copper activity timeline + owner + custom "tier/type" tags; Outlook
  sent/received + calendar history for true last-touch (partners email far more than they log in
  Copper); LinkedIn Sales Nav for recent activity / job change to seed a hook; Fathom for last-call
  topic; Beehiiv opens as a soft warmth signal. Facts: last touch, value tier, relationship type,
  owner, cadence target, whether a follow-up is already scheduled.
- **Play 3 evidence discussed:** LinkedIn Sales Nav job-change and saved-account alerts (the primary
  trigger feed), news for acquisitions / PE investment / regulatory shifts, Copper target-account
  list, and the identity layer to answer "do we know anyone there, and which partner is closest?"
- **Play 2 evidence discussed:** Copper referral-tagged deals/notes (acknowledged as inconsistently
  tagged), LinkedIn Sales Nav for the source's recent events, Beehiiv re-engagement, Fathom mentions
  of a source's name. Facts: referral-source status, last referral date, source type, recent event.
- **The non-negotiable across all three:** the Act step drafts a partner-ready touch and routes it to
  the partner; it never sends. Trust can't be automated at the send.

### Named tool stack (Phase 3)
- `~~CRM` → **Copper CRM** (system of record for relationships + pipeline; Google-Workspace-native
  edition; owned by Practice Development). Confidence: high.
- `~~email` + `~~calendar` → **Microsoft 365 / Outlook** (Exchange Online; the firm runs on M365, not
  Google, despite Copper's Google leanings — noted as an integration wrinkle). Confidence: high.
- `~~relationship intelligence` → **LinkedIn Sales Navigator** (Team seats for all partners; the
  primary source of job-change and account-activity signal). Confidence: high on the tool; **low on a
  programmatic path** — flagged.
- `~~newsletter/content` → **Beehiiv** (the "Operating Notes" biweekly newsletter, ~4,000 subs;
  engagement = soft warmth signal). Confidence: high.
- `~~conversation intelligence` → **Fathom** (records/summarizes partner calls; source of last-call
  topic + source mentions). Confidence: high.
- `~~enrichment` → **manual + LinkedIn** (no dedicated enrichment vendor; a partner or PD associate
  looks people up by hand). Confidence: high that this is the state; it is thin.
- `~~data warehouse` → **none.** The firm runs on Copper + a handful of Google Sheets / Excel for
  pipeline reporting. No warehouse, no BI layer. (Confirmed explicitly — the v1 must not assume one.)
- **Tools mentioned that don't map cleanly:** DocuSign (contracting only, out of GTM scope);
  a "master relationship map" the founding partner keeps in a personal spreadsheet (a shadow fact
  store — noted as a data-quality signal, not a system to build on).

## Strategy Readout

*Read this and tell me: is this your business?*

### What your GTM Brain is for
Your pipeline is your partners' relationships, and right now nobody and nothing is watching the clock
on them. Aldertree's GTM Brain is the system that does — it keeps a live read on every relationship
that matters across all fourteen partners' networks, notices when a valuable one is going cold or when
the moment to call has arrived, and hands the owning partner a specific person, a reason, and a
suggested opening. It does not send anything; a touch from Aldertree has to come from the partner, in
the partner's voice. The brain's job is to make sure the right partner reaches out to the right person
at the right moment — the thing your two or three best rainmakers already do on instinct, made
systematic across the whole firm.

### The priority plays it runs
1. **Relationship-cadence / warm-network nurture** — the standing answer to *"who in my network
   haven't I talked to in too long who actually matters?"*
   - *The decision it makes for you:* which dormant-but-valuable relationships each partner should
     touch this month — and the specific hook to open with (a job change, a newsletter they engaged
     with, the topic of your last call) — so a partner opens their monthly list already knowing who to
     call and why, instead of guessing or forgetting.
   - *Why it's a priority:* it's the daily bleed. This is the goal you got most animated about —
     dozens of valuable relationships lapse every year purely because no one noticed the clock.
2. **Buying-signal / proposal-timing detection** — the standing answer to *"when did something happen
   at a company I care about that means I should pick up the phone?"*
   - *The decision it makes for you:* which target organizations or known contacts just became
     *timely* — a former client took a COO seat, a portfolio company got acquired, a target raised a
     new round — routed to the partner with the warmest path in, with the event and a suggested angle
     attached.
   - *Why it's a priority:* these are your highest-conversion openings, and today you hear about them
     too late — after they've already hired someone. Catching the window is the biggest upside on the
     board.
3. **Referral-source activation** — the standing answer to *"which of my referral sources have gone
   quiet, and is now the moment to re-warm them?"*
   - *The decision it makes for you:* which referral partners (PE operating partners, bankers, counsel,
     alumni) have gone dormant *and* just had a relevant event worth re-engaging on — closed a fund,
     added a portfolio company, changed seats — so the partner re-warms the source with a reason, not
     a generic "let's catch up."
   - *Why it's a priority:* referrals are your best-yielding channel, and no one systematically tends
     the sources. Even a modest lift in re-activation compounds into repeat pipeline.

### What it will feel like when it's working
On the first of each month, every partner gets a short, ranked list of specific people to reach out to
— each with a reason already researched and a first line drafted in their voice — instead of a vague
sense that they're "behind on their network." Timing alerts arrive within days of a leadership change
or an acquisition, while the window is still open, routed to whoever knows the account best. And the
relationships that used to quietly lapse simply stop lapsing, because something is finally watching the
clock. Practice Development stops manually reconstructing who's gone cold from three disconnected
systems, and the firm's best rainmaker instinct becomes everyone's default.

### The shape underneath (one paragraph, plain-English)
Underneath, the brain works in three moves. It **watches the signals** you already generate — activity
in Copper, email and meetings in Outlook, job changes and posts in LinkedIn Sales Navigator, newsletter
engagement in Beehiiv, and what was said on your recorded calls. It then **resolves those signals to
the right person** — stitching together the same human across your CRM record, their email address, and
their LinkedIn profile, even when they change jobs and their old email goes dark, so every fact is about
*someone real* and not a stray row. From there it **turns those signals into dated, trustworthy facts**
(when you last touched them, how valuable the relationship is, whether they just hit a trigger), **decides
which play to run on whom**, and hands the partner the call to make. And it **learns** — when a partner
touches someone and it produces a reply, a meeting, or a referral, the brain uses that to sharpen who it
surfaces next month. There's a real architecture below this readout; you don't have to read it to trust
that it's there.

> **Resonance checkpoint.** Operator confirms: ☒ *"Yes, this is my business."*  |  ☐ *Needs correction:*
> — *(Confirmed 2026-07-18 by the Managing Partner and the Director of Practice Development. Verbatim:*
> *"This is exactly the firm. The 'watch the clock' line and the timing play are the two things I'd pay
> for on their own.")* Build-tier phases proceeded (`resonance_confirmed: true`).

---

<!-- — — — — — — — — — — — —  FOLD  — — — — — — — — — — — — -->

## Build Spec

*For the eng team / technical marketer standing up v1. Every play below is specified against the
fixed GTM-Brain skeleton (evidence → identity → fact/decision + OODA+L loop). See
`gtm-brain-skeleton.md` for the model; `category-map.md` for the capability vocabulary.*

### System overview
- **Brain purpose (technical restatement):** Maintain a per-person relationship fact ledger across all
  14 partners' networks, and on a scheduled + event-driven loop decide (a) which dormant-but-valuable
  relationships each partner should touch, (b) which target orgs/contacts just became timely, and (c)
  which referral sources are ripe for re-activation — emitting **drafted, partner-routed touches, never
  auto-sent messages.**
- **The fixed skeleton, instantiated for Aldertree:**
  - *Evidence layer:* Copper activity timelines + owner + tier/type custom fields; Microsoft 365 /
    Outlook sent/received email and calendar meetings (true last-touch — partners email far more than
    they log); LinkedIn Sales Navigator job-change and account-activity alerts; Beehiiv open/click
    engagement; Fathom call transcripts/summaries (last-call topic, source mentions); manual news scans
    for acquisitions / PE investments / regulatory shifts.
  - *Identity layer:* **the entity is a person (a relationship), not an account.** Resolve one canonical
    person across their Copper contact record ↔ one-or-more Outlook email addresses ↔ their LinkedIn
    profile URL. The hard cases: a person with multiple/expired email addresses; matching an Outlook
    thread or a LinkedIn profile to the right Copper contact; and **job changes** — which both break
    email-based matching *and* are themselves a trigger (Play 3). A person is linked to an owning
    partner and, optionally, to a current org.
  - *Fact/Decision layer:* a small set of typed, dated facts per person (last touch, value tier,
    relationship type, cadence target, follow-up-scheduled, referral status, last referral date, recent
    event, detected trigger). Three decision policies (one per play) read these facts. All facts are
    stored in a lightweight fact ledger (there is **no warehouse** — see build notes) and decisions are
    written back to Copper as partner-assigned tasks.
  - *Loop:* **Plays 1 and 2 run as a monthly scheduled batch** (aligned to the partners' first-of-month
    network review). **Play 3 runs weekly on a scan cadence and is additionally event-triggered** by
    LinkedIn Sales Nav alerts and news, because timing decays fast. Learn writes outcomes (touched /
    replied / met / referred) back to the ledger and adjusts tiers, statuses, and cadence.

### The tool stack (capability → named tool)
| Capability (`~~category`) | Aldertree's tool | Tier/notes | Confidence |
|---|---|---|---|
| `~~CRM` | Copper CRM | System of record for relationships + pipeline. Google-Workspace-native edition, but the firm's mail is M365 (wrinkle below). REST API for contacts/activities/tasks/custom fields. | high |
| `~~email` | Microsoft 365 / Outlook (Exchange Online) | True last-touch source (partners under-log in Copper). Read via Microsoft Graph. | high |
| `~~calendar` | Microsoft 365 / Outlook Calendar | Meetings = strongest touch signal + detects already-scheduled follow-ups. Read via Microsoft Graph. | high |
| `~~relationship intelligence` | LinkedIn Sales Navigator (Team seats, all partners) | Primary job-change + account-activity feed for Play 3; recent-activity hook for Play 1. **No supported public API** — path unresolved (gap). | high (tool) / low (integration) |
| `~~newsletter/content` | Beehiiv | Open/click engagement = soft warmth + re-engagement signal. Public API for subscriber engagement. | high |
| `~~conversation intelligence` | Fathom | Last-call topic (Play 1 hook) + source name mentions (Play 2). API/integration for transcripts + summaries — confirm scope. | high (tool) / med (integration) |
| `~~enrichment` | Manual + LinkedIn (no vendor) | People looked up by hand. Thin; no automated firmographic/role enrichment today (gap). | high (that it's manual) |
| `~~data warehouse` | **None** — Copper + Google Sheets / Excel | No warehouse, no BI. v1 must run on a light fact ledger, not a pipeline. Fact history is therefore shallow. | high |

### Plays — the "how", one per play

#### Play: Relationship-cadence / warm-network nurture
- **Capability contract**
  - *Inputs:* a partner's set of owned `person` records; per-person `relationship_value_tier`,
    `relationship_type`, last-touch signals (Copper activity, Outlook mail/calendar), `open_followup`
    state, and hook material (LinkedIn recent activity, Beehiiv engagement, last Fathom call topic).
  - *Outputs:* per partner, a ranked monthly **touch list** — each item a resolved person + the reason
    they surfaced + a drafted opening line in the partner's voice — written to Copper as a partner-assigned
    task. **No message is sent.**
  - *Trigger:* monthly scheduled batch (1st of month), per partner. On-demand re-run supported.
- **Observe — evidence needed:** last-touch across channels → `~~CRM` (Copper activity), `~~email` +
  `~~calendar` (Outlook via Graph); hook material → `~~relationship intelligence` (LinkedIn Sales Nav
  recent activity/job change), `~~newsletter/content` (Beehiiv opens/clicks), `~~conversation
  intelligence` (Fathom last-call topic).
- **Orient — entity + resolution:** acts on `person`; must resolve the Copper contact ↔ Outlook
  address(es) ↔ LinkedIn profile into one canonical person, then compute a **true last-touch** as the
  max across Copper, Outlook mail, and calendar meetings (Copper alone undercounts).
- **Decide — facts + policy:**
  - Facts consumed:
    - `relationship_value_tier = enum{Strategic, Core, Peripheral} · derived from partner tagging (Copper custom field) on person · as of 2026-07-20 · confidence med` *(subjective, partner-assigned)*
    - `relationship_type = enum{former_client, active_client, referral_source, prospect_exec, alumnus, community} · from Copper custom field on person · as of 2026-07-20 · confidence med`
    - `relationship_last_touch = date · derived from max(Copper activity, Outlook sent/received, calendar meeting, Fathom call) on person · as of run date · confidence high`
    - `relationship_owner = enum{partner} · from Copper owner field on person · confidence high`
    - `cadence_target_days = number · derived from (relationship_type × value_tier) policy lookup on person · confidence high` *(e.g., Strategic former_client = 60d; Core referral_source = 90d; Peripheral = 180d)*
    - `open_followup_exists = boolean · derived from Copper open tasks + future calendar events on person · as of run date · confidence high`
  - Decision policy:
    - `IF relationship_value_tier IN {Strategic, Core} AND (run_date − relationship_last_touch) > cadence_target_days AND open_followup_exists = false THEN surface person on the owning partner's monthly touch list, ranked by (days_overdue × tier_weight), with a suggested hook.`
    - Hook selection: `IF a job_change detected in last 90d THEN hook = congratulate-on-new-role; ELSE IF Beehiiv click in last 30d THEN hook = reference-the-piece-they-read; ELSE IF Fathom last-call topic exists THEN hook = follow-up-on-last-conversation; ELSE hook = generic-check-in.`
- **Act — the action:** write a Copper task assigned to `relationship_owner`, titled `[Nurture] Reach out
  to <person> — <hook>`, with the drafted opening line and the reason in the task body; group the tasks
  into that partner's monthly list. Nothing is sent — the partner sends personally.
- **Learn — outcome + feedback:** outcome signal = partner logs a touch / an Outlook reply lands / a
  meeting gets booked (calendar or Fathom). Feeds back: a completed touch resets `relationship_last_touch`;
  a touch that produces no reply across two consecutive cycles nudges `relationship_value_tier` down a
  step (surfaced for partner confirmation, never silently demoted); a reply/meeting confirms the tier.
- **Build notes for v1:** all evidence is already in place (Copper + Outlook + the hook sources) — **no
  data gap**, build this first. Run as a scheduled Python job (monthly) that: reads Copper via its REST
  API, reads Outlook mail/calendar via Microsoft Graph, computes true last-touch and the facts into the
  fact ledger (Airtable or a Google Sheet keyed by canonical person id), applies the policy, and creates
  Copper tasks via the Copper API. Hook drafting = an LLM call over the person's ledger row + last Fathom
  summary, producing a one-line opener in the partner's voice (seed voice from that partner's prior sent
  mail). Start with a single pilot partner's book, then fan out to all 14.

#### Play: Buying-signal / proposal-timing detection
- **Capability contract**
  - *Inputs:* the Copper priority-target-account list; a stream of trigger events (job changes,
    acquisitions, PE investments, regulatory shifts, expansions); the identity graph (who do we know at
    each org, and which partner is closest).
  - *Outputs:* **timing alerts** — a resolved org/contact + the trigger event + the warmest known path in
    + a suggested angle — routed to the best-connected partner as a high-priority Copper task. **No message
    is sent.**
  - *Trigger:* weekly scan **plus** event-triggered on LinkedIn Sales Nav alerts and news detections
    (timing decays fast, so this play does not wait for the monthly batch).
- **Observe — evidence needed:** trigger events → `~~relationship intelligence` (LinkedIn Sales Nav
  job-change + saved-account alerts) and manual/LLM news scan (acquisitions, PE investments, regulatory
  shifts); target membership → `~~CRM` (Copper target list); warm-path evidence → the identity layer over
  Copper + Outlook + LinkedIn.
- **Orient — entity + resolution:** the trigger resolves to an **org**, then to the **best-connected
  person + partner** at that org via the identity graph. The highest-value case couples identity to
  trigger directly: a *known person* (former client / prospect exec) whose LinkedIn shows a **job change
  into a buyer role** — resolve the person first (their old email is now dead; match on name + LinkedIn
  URL), then attach their new org.
- **Decide — facts + policy:**
  - Facts consumed:
    - `trigger_event_detected = enum{leadership_change, acquisition, pe_investment, regulatory_shift, expansion, restructuring} · derived from LinkedIn Sales Nav + news scan on org/person · as of event date · confidence med`
    - `trigger_event_date = date · derived from the source alert/article · confidence med`
    - `target_on_priority_list = boolean · from Copper target-list membership on org · as of run date · confidence high`
    - `relationship_exists_at_target = boolean · derived from identity layer (any resolved Copper/Outlook/LinkedIn contact at the org) · confidence high`
    - `best_connected_partner = enum{partner} · derived from the owner of the warmest resolved contact at the org · confidence med`
    - `known_contact_role_relevance = enum{buyer_role, influencer, peripheral} · derived from title on the resolved contact · confidence med`
  - Decision policy:
    - `IF trigger_event_detected IN {leadership_change(COO/CFO/CEO), acquisition, pe_investment} AND target_on_priority_list = true AND (relationship_exists_at_target = true OR a warm two-hop path exists) THEN surface as a timely partner outreach, routed to best_connected_partner, with the event + warm path + suggested angle.`
    - Highest-value special case (identity × trigger): `IF resolved_person.relationship_type IN {former_client, prospect_exec} AND job_change → known_contact_role_relevance = buyer_role at a new org THEN surface immediately, regardless of target-list membership — a trusted contact just landed in a buying seat.`
- **Act — the action:** create a high-priority Copper task assigned to `best_connected_partner`, titled
  `[Timing] <org> — <event> — reach out`, body carrying the event, the warm path (who we know / how), and
  a drafted angle tied to the event. Surfaced within days of the event, not at month-end.
- **Learn — outcome + feedback:** outcome signal = a conversation opens / meeting booked (calendar,
  Fathom) / opportunity created in Copper / proposal issued. Feeds back: trigger types that repeatedly
  convert get up-weighted in ranking; a surfaced trigger the partner dismisses is logged so the same
  event type at low-relevance orgs is de-prioritized next cycle.
- **Build notes for v1:** highest conversion, but **gated on the LinkedIn Sales Nav feed** (see
  integration-knowledge gap). Interim v1: partners' existing Sales Nav saved-account + lead alerts are
  the trigger source, reviewed weekly by a PD associate and entered to the ledger; the news scan is an
  LLM/Perplexity-style weekly pass over the target list. The identity graph (built for the shared
  substrate) answers the warm-path question. Automate the news scan and the ledger writes first; treat
  the Sales Nav feed as manual-assisted until the integration path is resolved.

#### Play: Referral-source activation
- **Capability contract**
  - *Inputs:* the set of `person` records typed as referral sources; per-source referral history
    (Copper), status, and recent-event signals (LinkedIn, Beehiiv, Fathom).
  - *Outputs:* a **re-activation list** — a resolved referral source + why now (dormancy + a fresh
    event) + a drafted re-warm opener — routed to the source's owning partner as a Copper task. **No
    message is sent.**
  - *Trigger:* monthly scheduled batch (with Play 1); event signals promote a source into the current
    month's list early.
- **Observe — evidence needed:** referral history → `~~CRM` (Copper referral-tagged deals/notes);
  recent events → `~~relationship intelligence` (LinkedIn Sales Nav: new fund, portfolio add, job
  change, published content), `~~newsletter/content` (Beehiiv re-engagement), `~~conversation
  intelligence` (Fathom source mentions).
- **Orient — entity + resolution:** acts on `person` (a referral source); resolve them across Copper ↔
  Outlook ↔ LinkedIn as with the other plays, and additionally **stitch the referrals they have
  historically sent** to the source record (currently only loosely captured — see data gap).
- **Decide — facts + policy:**
  - Facts consumed:
    - `referral_source_status = enum{active, warming, dormant} · derived from last_referral_date + recent touch on person · as of run date · confidence med`
    - `last_referral_date = date · derived from Copper referral-tagged deals/notes on person · confidence low` *(depends on inconsistent tagging discipline)*
    - `referral_source_type = enum{pe_operating_partner, pe_deal_partner, banker, ma_counsel, exec_search, former_client, other} · from Copper custom field on person · confidence med`
    - `source_recent_event = enum{new_fund_closed, portfolio_add, job_change, published_content, event_attended, newsletter_reengaged} · derived from LinkedIn Sales Nav + Beehiiv + news on person · as of event date · confidence med`
    - `referrals_lifetime_count = number · derived from Copper referral tags on person · confidence low` *(thin history; no warehouse to trend it)*
  - Decision policy:
    - `IF referral_source_status = dormant (no referral in 180d AND no touch in 90d) AND source_recent_event detected in last 30d THEN surface for re-activation, routed to the owning partner, with the event as the hook.`
    - Priority boost: `IF source_recent_event IN {new_fund_closed, portfolio_add} THEN rank first — fresh capital deploys into operational needs, the moment a source is most likely to have a referral to give.`
- **Act — the action:** create a Copper task assigned to the source's owning partner, titled
  `[Referral] Re-warm <source> — <event>`, body carrying the dormancy note, the event, and a drafted
  re-warm opener framed around the event (not a generic "let's catch up"). Not sent.
- **Learn — outcome + feedback:** outcome signal = a referral received / a meeting with the source /
  reply. Feeds back: a referral received flips `referral_source_status → active` and increments
  `referrals_lifetime_count`; a re-warm that yields nothing keeps the source dormant but records the
  attempt so it isn't re-surfaced next month on the same event.
- **Build notes for v1:** build last. Mechanically identical plumbing to Play 1 (monthly batch, Copper
  read/write, ledger, LLM opener) — but its core facts (`last_referral_date`, `referrals_lifetime_count`)
  sit on **referral tagging that the firm admits is inconsistent** (data gap). Prerequisite: a light
  Copper referral-tagging convention + a one-time backfill of the last ~18 months of referrals from
  partner memory / the founding partner's shadow spreadsheet. Without that, Play 2's facts are too thin
  to drive a confident decision. Do the tagging cleanup, then this play is a small increment on the Play 1
  engine.

### Completeness pass — gaps (flag, never omit)

**Data gaps** — a chosen play needs evidence the org has not described:
- ⚠️ **Relationship strength is not captured anywhere structured.** All three plays lean on
  `relationship_value_tier`, but the firm has no structured signal for *how strong / warm / reciprocal* a
  relationship actually is — it lives in partners' heads (and the founding partner's private spreadsheet).
  v1 must treat `relationship_value_tier` as a **partner-assigned tag** (subjective, `confidence med`),
  not a derived score. *Required to strengthen:* a one-time partner tagging pass in Copper, and
  optionally a later derived warmth proxy from Outlook reciprocity (two-way email cadence) once Graph
  ingestion is live — but do not present a computed strength as fact until it's validated against partner
  judgment.
- ⚠️ **Referral history is thinly and inconsistently captured** (Play 2). `last_referral_date` and
  `referrals_lifetime_count` depend on Copper referral tagging the firm acknowledges is spotty, and with
  **no data warehouse** there is no historical substrate to reconstruct it from. *Required:* a referral-
  tagging convention + a ~18-month backfill before Play 2's facts are trustworthy (see Play 2 build notes).
- ⚠️ **No warehouse means fact history is shallow across the board.** The fact ledger is a
  point-in-time store (Airtable/Sheet), not a time-series. Facts that would benefit from trend
  (relationship-decay velocity, referral-source yield over years) can only be approximated in v1. Accept
  shallow history for v1; revisit if the firm later adopts a lightweight store that retains fact snapshots.

**Integration-knowledge gaps** — a named tool whose how-to the interviewer cannot credibly specify:
- ⚠️ `~~relationship intelligence → LinkedIn Sales Navigator` is the primary trigger feed for Play 3 and
  a hook source for Play 1, but **Sales Navigator exposes no supported public API** for programmatically
  pulling job-change / saved-account alerts. The concrete path is unresolved. *Builder should confirm:*
  whether to (a) run Play 3 on **manual-assisted** Sales Nav alert review (a PD associate enters alerts
  weekly — the recommended v1), (b) use a compliant partner/enrichment integration that resurfaces
  job-change data, or (c) another sanctioned export. Do **not** assume a direct Sales Nav API exists.
- ⚠️ `~~CRM → Copper` + `~~email/calendar → Microsoft 365`: Copper's Google-Workspace-native edition
  against a firm that runs on **M365/Outlook** is a wrinkle. Copper has a REST API (contacts, activities,
  tasks, custom fields) and Microsoft Graph covers Outlook mail/calendar, so the *read/write* paths are
  known — but the exact Copper API scopes for reading the full activity timeline and writing partner-
  assigned tasks, and whether Copper's native Outlook add-in already logs enough activity to reduce Graph
  load, **need builder confirmation.** *(Flagged rather than hand-waved: the plumbing is standard REST,
  but the specific field/scope mapping is not verified here.)* Fathom's transcript/summary API scope for
  pulling last-call topics likewise needs a quick confirmation.

### Sequencing recommendation
Build the **shared substrate first**: the identity resolver (canonical person across Copper ↔ Outlook ↔
LinkedIn, robust to job changes) and the fact ledger (Airtable/Sheet keyed by person id), fed by Copper
REST + Microsoft Graph ingestion. All three plays sit on this, and it is the single hardest piece — get
it right once. Then ship **Play 1 (cadence nurture)**: its evidence is fully in place with no data gap,
it exercises the whole loop end-to-end, and it delivers visible value to all 14 partners on day one — the
ideal proving ground. Next take **Play 3 (timing detection)** for its conversion upside, but only after
deciding the LinkedIn Sales Nav feed path (manual-assisted is a fine v1); its identity/warm-path logic
already exists from the substrate. Build **Play 2 (referral activation)** last — it is a small increment
on the Play 1 engine but is gated on cleaning up referral tagging first, so it should follow the
data-quality fix rather than block the other two.
