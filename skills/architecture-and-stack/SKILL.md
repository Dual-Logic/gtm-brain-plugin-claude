---
name: architecture-and-stack
description: Phase 3 of the GTM Brain interview — for each confirmed play, derive the evidence, identity, and fact/decision needs against the fixed GTM-Brain skeleton, and capture the org's actual named tools (the stack-discovery step). Runs after the Strategy Readout is confirmed. Feeds the Build Spec; does not write the per-play "how" itself (that's Phase 4).
---

# architecture-and-stack — Phase 3 (derive layers + capture tools)

You take each confirmed play and work out **what the GTM-Brain skeleton requires for it** — the
evidence it observes, the entity it resolves, the facts and decision it needs — and you capture the
org's **actual named tools**. This is the bridge from the resonant Strategy Readout to a buildable
Build Spec. You do the *architecture derivation and tool capture*; Phase 4 writes the per-play "how."

**Before anything, read these:**
- `${CLAUDE_PLUGIN_ROOT}/reference/working-doc-convention.md` — marker, append cadence, the resonance gate.
- `${CLAUDE_PLUGIN_ROOT}/reference/gtm-brain-skeleton.md` — the three layers + OODA+L loop you derive against.
- `${CLAUDE_PLUGIN_ROOT}/reference/category-map.md` — the `~~category` vocabulary for capturing tools.

Working doc: `${CLAUDE_PROJECT_DIR}/gtm-brain-spec.md`.

## Guard (resonance gate — hard)

1. Read the marker. **If `resonance_confirmed` is `false`, do not run** — route back to `strategy-readout`
   for the operator's confirmation first (AE4). This is the whole point of the gate.
2. If `phases.strategy-readout` is not `complete`, route back appropriately.
3. If Phase 3 is `in_progress`, resume at the step after `last_completed_step`.

## Step 1 — Derive the skeleton needs, per play
For **each** confirmed play (from RAW CAPTURE → Discovered plays), walk the fixed skeleton and capture,
into RAW CAPTURE → *Architecture inputs per play*:

- **Observe (evidence):** which signals the play needs — behavioral/usage, firmographic, engagement,
  intent, conversational, relationship, purchase, support — described concretely for this org.
- **Orient (identity):** the entity the play acts on (account / person / customer / opportunity) and
  what must be **resolved/stitched** for evidence to attach to it. Name the resolution explicitly — it
  is usually the precision chokepoint.
- **Decide (facts + policy):** the candidate **facts** the play consumes (name them; note the likely
  type — boolean/enum/number/date) and the shape of the **decision** (what it routes/flags/prioritizes).
  You are identifying them here; Phase 4 formalizes them with sources/dates/policies.
- **Learn:** the outcome signal that would close the loop for this play.

Interview to fill gaps — ask where a signal would come from, how an entity is identified today, what
outcome they'd measure. Update `last_completed_step` per play (e.g. `arch-play-2`).

## Step 2 — Capture the named tool stack (stack discovery, R4)
Now — and only now — ask about tools. For each capability the plays touch, capture the org's **actual
named tool** into RAW CAPTURE → *Named tool stack*, as `~~category → <named tool>` with: edition/tier
if it matters, who owns it, and a **confidence** note. Use `category-map.md` categories; if a tool
doesn't fit a listed category, capture it and note the capability it serves.

- Capture what they **have**, not what they should have. A missing capability is data for the
  completeness pass, not a prompt to recommend a purchase here.
- Note explicitly any capability a play needs for which **no tool exists** — flag it in RAW CAPTURE so
  Phase 4's completeness pass picks it up as a data/capability gap.
- Uncommon tools are expected and fine — capture them faithfully (this is what makes the output
  tool-agnostic and org-specific — AE3).

Set `last_completed_step: stack-captured`.

## Step 3 — Seed the Build Spec scaffold
Fill the Build Spec's **System overview** (the fixed skeleton instantiated for this org — evidence /
identity / fact-decision / loop, in one pass across all plays) and the **capability → named tool
table** from what you captured. Leave the per-play "how" blocks and the completeness pass for Phase 4.
Set `last_completed_step: build-spec-seeded`.

## Finish
- Mark `phases.architecture-and-stack: complete`, `current_phase: build-spec`, `status: phase_complete`,
  set `next_action`.
- Recap what you derived and offer to continue: *"I've got the architecture and your stack. Last phase
  is the Build Spec — the per-play how, plus a gap check. Continue?"* On yes, invoke `build-spec`.

## Never
- Never run while the resonance gate is false.
- Never ask about tools before deriving the architecture needs (Step 1 before Step 2 — keeps capture play-driven).
- Never invent a tool the operator didn't name, and never assume a default vendor (R10) — an absent capability is a gap.
- Never write the per-play "how" here — that's Phase 4 (keeps context per-phase lean, KTD2).
