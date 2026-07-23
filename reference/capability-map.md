# Capability → tool map (tool-agnostic)

The Brain is specified in terms of **capability categories**, and the interview captures the org's **actual named tools** for each. The Build Spec then maps generic capabilities onto those named tools. This keeps the output stack-neutral yet org-specific. **The plugin ships no vendor connectors and calls no tools** — it only names capabilities and records what the owner tells it they use.

## Capability categories (probe for these in `profile-and-goals`)

| Capability | What it does in the Brain | Common examples (do NOT assume — capture the owner's actual tool) |
|---|---|---|
| System of record — state | Canonical customer/account/pursuit record | CRM (Salesforce/HubSpot/Dynamics), commerce platform (Shopify/BigCommerce), PSA (Kantata/Aderant) |
| Site / product analytics | Behavioral signal, de-anon | GA4, Segment, Amplitude, Snowplow, app SDK |
| Messaging / execution rails | Sending email/SMS/push; sequences | Marketo, Klaviyo, Attentive, Outreach, Customer.io |
| Ads | Audience sync, spend, conversions | Meta, Google, TikTok, LinkedIn |
| Data warehouse / lakehouse | Analytics substrate, feature layer home | Snowflake, BigQuery, Databricks, Redshift |
| Enrichment | Firmographic/technographic/contact/consumer data | Clearbit, Apollo, ZoomInfo, ecommerce enrichment |
| Conversations | Call/meeting transcripts, deal/relationship risk | Gong, Fireflies, Chorus |
| Relationship intelligence | Email/calendar mining, relationship strength | Introhive, 4Degrees, Affinity (services) |
| People-move / alumni tracking | Warm-door signals | UserGems-style (services) |
| Inventory / margin | Stock cover, contribution margin | ERP/OMS/PIM (e-commerce) |
| Consent / preferences | Per-channel lawful-basis state | CMP, preference center |
| Support | Tickets, sentiment, churn signals | Zendesk, Intercom, Gorgias |
| Billing / payments | ARR/orders, payment health | Stripe, NetSuite, Signifyd |

## How skills reference this

- In prose, a skill refers to a capability generically (e.g. "the org's **system of record for state**", "the org's **messaging rail**").
- The interview captures the org's named tool per relevant category into the working doc's `captured_inputs.tools`.
- The Build Spec's capability→tool table (template §2.2) resolves each generic capability to the named tool, with a build/buy note, and a provenance tag.
- If the org lacks a capability a chosen decision needs, tag it `[Open — needs your team]` and route it to Open Items — never invent a tool.

## Not every category applies

Only map the categories the org's priority decisions actually exercise. A services firm may have no ad platform; an e-commerce brand may have no PSA. Leave unused categories out of the Build Spec rather than padding.
