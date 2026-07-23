# Choosing and applying a lens

A **lens** tilts emphasis onto the universal skeleton for a family of businesses. It is never a mold and never a menu shown to the owner. The three shipped lenses are `saas`, `professional-services`, and `e-commerce`. Any org is coverable — including one that matches none of them — because the *skeleton* is universal and the lens only shapes emphasis.

## How to classify (silently, from the business layer)

Infer the lens from what the owner tells you in `profile-and-goals` — never ask "which are you?" Signals:

- **SaaS** — recurring software revenue, named-account/committee selling, a CRM + MAP, sales/RevOps roles.
- **Professional services** — expertise sold through relationships, partner/senior time is the scarce resource, a PSA/time-billing system, referrals and word-of-mouth as a dominant channel.
- **E-commerce / DTC** — consumers at scale, an ecommerce platform + ESP/SMS + ad accounts, catalog/inventory/margin as first-class.

Record the chosen lens in the phase-progress marker (`lens:`).

## Blend when the org straddles two

Many orgs are hybrids (a SaaS company with a services arm; a DTC brand that also wholesales; an agency with a productized subscription). Set `lens: blend:<a>+<b>` and borrow emphasis from both — e.g. account-intent facts *and* relationship-strength facts; expected-value that carries both deal size and follow-on. Do not force a single archetype when the org genuinely spans two.

## Off-archetype: fall back to the universal skeleton

When the org matches **none** of the three (a manufacturer, a clinic, a nonprofit, a marketplace, a local-services business), set `lens: universal` and derive everything from the org's own goals, decisions, signals, and tools directly against the skeleton. Do **not** stretch a shipped lens over a business it doesn't fit — that produces boilerplate and breaks the "unmistakably their business" bar (R13).

Practical guidance for `universal`:

- Anchor on the org's **unit of decision** first (per lead? per account? per customer? per pursuit? per shipment? per patient? per member?) — that single choice sets the shape of L7 the way "account × play" or "customer × offer" does for the shipped lenses.
- Derive fact predicates, models, and constraints from *that* unit and the org's stated goals, not from a lens.
- Expect **more `[Open]` tags** here: with no close lens to borrow, more of the technical body is plugin inference the owner can't verify. That is honest — say so, and let the Open Items list carry the extra weight.

## The lens never overrides the skeleton or the owner

If a lens's default emphasis conflicts with something the owner stated, the owner wins and the fact is tagged `[Stated]`. The lens informs proposals (`[Proposed - confirmed]`); it never dictates.
