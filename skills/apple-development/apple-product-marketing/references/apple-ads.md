# Apple Ads

Use this reference to plan, audit, or diagnose paid acquisition on the App
Store. Verify current Apple Ads naming, placements, policies, storefront
availability, account roles, and measurement behavior before execution.

## Contents

- Establish the paid-acquisition contract
- Structure campaigns by decision
- Match intent to destination
- Manage keywords, bids, and budgets
- Measure user quality
- Apply execution guardrails

## Establish the paid-acquisition contract

Record:

- business objective and marginal value of an acquired user;
- storefronts, locales, devices, app state, and eligible placements;
- budget, currency, schedule, owner, and authorization boundary;
- current campaigns, ad groups, search terms, keywords, match types, Search
  Match, bids, caps, and creative variants;
- default and Custom Product Pages, deep links, and onboarding destinations;
- attribution source, privacy thresholds, activation, retention, proceeds,
  refund, and quality data.

Do not recommend a bid or budget as universally correct without product
economics, market, historical data, and a controlled learning plan.

## Structure campaigns by decision

For search-results acquisition, use Apple's Brand, Category, Competitor, and Discovery
themes as a useful starting framework:

- **Brand**: protect and measure explicit branded intent.
- **Category**: reach non-branded users describing the product category,
  problem, feature, or use case.
- **Competitor**: isolate alternative-seeking intent and its distinct economics
  and policy exposure.
- **Discovery**: learn through broad match and Search Match, then mine relevant
  search terms into controlled ad groups.

Treat this as a recommended structure, not a mandatory architecture for every
placement, budget, or market. Separate campaigns or ad groups when budget,
intent, bid control, locale, destination, creative, or reporting decisions
require it. Avoid fragmentation that leaves each unit unable to learn.

## Match intent to destination

For each ad group define:

```text
Audience and search intent
Keyword or placement logic
Promise
Creative or ad variation
Default or Custom Product Page
Deep-linked destination and fallback
Activation event
Primary paid metric
Retention, proceeds, and quality guardrails
```

Use a Custom Product Page when the intent merits distinct, truthful creative.
Keep search term, ad, product page, and deep-linked content semantically
continuous. Verify the minimum OS and fallback behavior for deep links.

Do not place a competitor trademark in App Store metadata because competitor
intent is isolated in an ads framework. Check current Apple Ads and legal
policies for keyword and creative use.

## Manage keywords, bids, and budgets

- Start from relevant general and specific terms tied to user intent.
- Separate exact control from broad discovery where the decision requires it.
- Use Search Match deliberately for learning, with budget and search-term
  review boundaries.
- Add negatives to prevent overlap or irrelevant spend after confirming the
  effect on discovery.
- Move proven search terms into controlled structures without assuming past
  performance transfers across storefronts or destinations.
- Change one major lever at a time when causal learning matters.
- Allocate learning budget explicitly and set pause criteria for irrelevance,
  poor conversion, poor activation, or unacceptable unit economics.

Evaluate bid and budget changes against impression share or reach opportunity,
tap-through, conversion, cost, volume, downstream value, and uncertainty.
Do not optimize CPI while ignoring user quality.

## Measure user quality

Use current Apple Ads definitions for impressions, taps, tap-through rate,
downloads or conversions, cost, average cost per tap, and cost per acquisition.
Reconcile them with App Store Connect, AdServices, and any mobile measurement
provider without assuming identical events or windows.

Investigate differences such as:

- App Store download versus first app open;
- first-time download versus redownload;
- attribution and re-engagement windows;
- timezone, currency, and reporting delay;
- consent, privacy threshold, and unavailable user-level data;
- source, campaign, product page, storefront, app version, and cohort mix.

Report activation, retention, proceeds, refunds, crashes, review sentiment, and
support burden by campaign or intent where available and privacy-safe.

## Apply execution guardrails

- Do not create, edit, activate, pause, or fund a campaign without explicit
  authorization.
- Do not expose credentials, tokens, customer lists, or user-level identifiers.
- Do not invent keyword volume, attribution, or lifetime value.
- Do not circumvent privacy protections or recommend fingerprinting.
- Do not use misleading, unavailable, rights-infringing, or unapproved claims
  in ad creative or destinations.
- Preserve an audit trail of owner, change, time, hypothesis, expected effect,
  guardrails, and rollback decision.
