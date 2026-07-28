# Analytics and attribution

Use this reference to define measurement, diagnose a funnel, compare product
pages or channels, and interpret App Store Connect or Apple Ads data.

## Contents

- Build the measurement contract
- Use the App Store acquisition funnel
- Segment responsibly
- Reconcile attribution systems
- Diagnose changes
- Report evidence

## Build the measurement contract

Before launch or analysis, record:

```text
Decision
Primary metric
Exact source definition
Numerator and denominator
Population and cohort
Storefronts, locales, devices, sources, and product pages
App version and user state
Attribution model and window
Baseline and comparison period
Expected delay and privacy threshold
Activation, retention, proceeds, and quality guardrails
Decision rule and owner
```

Prefer the metric as defined and reported by the source system. If computing a
custom metric, name it differently and show the formula.

## Use the App Store acquisition funnel

Keep these concepts distinct:

- unique impressions or other current visibility measures;
- product page views;
- total downloads, first-time downloads, and redownloads;
- Apple's reported conversion rate;
- installs or first opens in another analytics system;
- activation events;
- engagement and retention;
- paying users, proceeds, refunds, and subscription outcomes;
- crashes, hangs, support burden, review themes, and other quality signals.

As reviewed on 2026-07-28, App Store Connect Acquisition conversion rate uses
unique impressions and total downloads, not product page views and downloads.
Recheck the current definition before analysis. If the team also uses
page-view-to-first-time-download conversion, label it as a custom funnel rate.

Do not infer organic search performance from the App Store search source alone
when current source definitions may include search-results ads. Use campaign
and Apple Ads evidence to separate what the available data actually supports.

## Segment responsibly

Use segmentation only when the resulting sample and privacy rules support a
decision:

- storefront and locale;
- device and platform;
- acquisition source and campaign;
- default versus Custom Product Page;
- app version;
- first-time versus returning or redownloading user;
- lifecycle, subscription, or payer cohort;
- experiment control and treatment.

Compare like with like. Check traffic mix, seasonality, release timing, featuring,
pricing, availability, campaign, review, and instrumentation changes before
claiming an effect.

Conversion without downstream quality is incomplete. Pair acquisition with the
activation event implied by the promise and with retention or proceeds at an
appropriate horizon.

## Reconcile attribution systems

Expect legitimate differences between App Store Connect, Apple Ads,
AdServices, product analytics, and a mobile measurement provider. Investigate:

- download versus install or first open;
- first-time download versus redownload;
- attribution model and lookback window;
- time zone, currency, and reporting delay;
- campaign-link eligibility and minimum reporting thresholds;
- privacy protections, consent, modeled or unavailable data;
- cross-device, reinstall, and re-engagement handling;
- late events, duplicate suppression, and SDK version.

Do not call the difference “lost users” or force the systems to match. Choose
the source that answers the decision, document limitations, and triangulate
direction where exact reconciliation is impossible.

Create campaign links before launch where appropriate. Verify current link
format, attribution window, minimum first-time-download threshold, data delay,
and eligible destination in App Store Connect Help.

## Diagnose changes

1. Validate the metric definition, query, permissions, ingestion, and date
   boundary.
2. Quantify the change and uncertainty against an appropriate baseline.
3. Decompose by funnel stage, then by the smallest decision-relevant segments.
4. Check mix shifts and concurrent product, store, campaign, price, review, and
   market changes.
5. Form alternative explanations, including instrumentation.
6. Identify evidence that would distinguish them.
7. Recommend the smallest reversible test or correction.

Do not reverse-engineer a ranking factor from a metric change. Do not present a
correlation as causation.

## Report evidence

Report:

- source and export or query date;
- exact metric definitions and custom calculations;
- filters, cohorts, windows, delays, and privacy limitations;
- baseline, observed values, uncertainty, and practical magnitude;
- downstream quality and guardrail outcomes;
- supported conclusion, competing explanations, and confidence;
- decision, owner, and next checkpoint.

Say “directional” when sample, attribution, or confounding limits the result.
Say “insufficient evidence” when the decision rule cannot be applied.
