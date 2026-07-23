# Lens: e-commerce / DTC

An **emphasis lens**, not a mold. Use it when the org sells to consumers at scale (DTC/e-commerce, subscription retail). The universal skeleton is unchanged; this lens tilts *where the weight goes*.

**Center of gravity:** per-customer economics — the decision is **customer × offer × channel × moment**, made millions of times, so the policy layer is algorithmic from day one, and **margin and inventory are hard constraints**.

**Unit of decision:** for each customer, each day/session — which message, offer, channel, and discount depth **or nothing** maximizes incremental long-term margin.

**Where identity is hard (L2):** cross-device/cookie/email/phone stitching into canonical customers (and households where the catalog warrants), **consent-aware by construction** (per-channel lawful basis; erasure across the whole graph); deterministic tier for messaging (a wrong-person SMS is a legal event).

**Fact predicates to probe for (L3c):** `lifecycle_stage`, `replenishment_window`, `discount_sensitivity_band`, `discount_conditioned`, `channel_preference`, `consent_state(channel)`, `fatigue_budget`, `holdout_membership`, `predicted_next_purchase`, `at_risk`, `vip_tier`, `gift_buyer`, `inventory_cover_band`, `margin_band`.

**Models that usually matter (L5):** predictive CLV (margin-based), churn/lapse, purchase-timing/replenishment, **discount-sensitivity via uplift modeling (not response modeling)** — the margin engine, product affinity (inventory/margin-aware), channel responsiveness, fraud/abuse. Validate uplift against randomized holdouts.

**Summary stores (L6):** a compact per-customer **state store** (lifecycle, propensities, next-best-offer, fatigue budget, consent, holdout flags) served in `<50ms` — not prose per customer; LLM summaries live at the cohort level.

**Hard constraints in the policy layer (L7):** contribution-margin floors, promo-calendar/brand/MAP rules, **inventory availability** (never promote stockouts), **global frequency budget** across channels (not per-tool caps), **per-channel consent (blocking)**, **holdout integrity (inviolable)**, abuse flags.

**Agents that usually matter (L8):** lifecycle messaging (email/SMS/push), offer/discount (within margin floors), audience sync (suppress purchasers/sure-things), onsite personalization, recommendation, copy/creative (prices/claims rendered from the offer store, never generated), campaign planning, review-mining, win-back.

**Ground-truth discipline (L9):** **incrementality is the only accepted truth** — persistent holdouts on every always-on program; measure lift over control, never last-click; canary + progressive rollout on every send.

**Flagship framing for the Strategy Readout:** "the Brain decides, per customer per day, the minimum effective offer — often *nothing* — so you stop discounting people who'd have bought anyway, measured against a real holdout."
