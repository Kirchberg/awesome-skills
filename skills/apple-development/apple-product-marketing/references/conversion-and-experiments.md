# Product-page conversion and experiments

Use this reference to create or evaluate product-page creative, screenshot
narratives, previews, icons, and Product Page Optimization experiments.

## Contents

- Conversion diagnosis
- Creative narrative
- Screenshot and preview checks
- Native Product Page Optimization
- Experiment contract
- Interpretation and rollout

## Conversion diagnosis

Do not start by redesigning assets. First:

1. Confirm the storefront, locale, device, source, product page, app version,
   cohort, and comparison period.
2. Use current App Store Connect metric definitions. Keep Apple's reported
   conversion rate distinct from any custom page-view-to-download rate.
3. Check visibility, product page views, downloads, redownload mix, ratings,
   app quality, activation, retention, and proceeds together.
4. Inspect traffic-mix, seasonality, campaign, featuring, pricing, product,
   review, and instrumentation changes.
5. Identify the intent and promise of the affected traffic.
6. Form one evidence-backed hypothesis about the page element preventing that
   audience from understanding, trusting, or choosing the product.

Use qualitative evidence such as interviews, usability sessions, review
language, support themes, and five-second or comprehension tests to explain why
a creative may fail. Do not infer the cause from conversion movement alone.

## Creative narrative

Build a sequence around user progress:

1. Lead with the primary outcome and a recognizable product state.
2. Establish who the app is for or the situation it resolves.
3. Show the smallest set of differentiated benefits needed to support choice.
4. Connect each benefit to visible, real product behavior.
5. Address the highest-impact uncertainty such as setup, privacy, offline use,
   collaboration, compatibility, or subscription value.
6. End with relevant depth, ecosystem support, content, or proof rather than a
   feature inventory.

Treat “the first three screenshots” as a useful design focus, not a universal
visibility rule. Verify the actual presentation on target devices,
storefronts, and current App Store surfaces.

## Screenshot and preview checks

For every asset:

- show the submitted and available app accurately;
- use the correct device family, orientation, and specifications;
- keep captions legible at product-page size and within safe areas;
- preserve a clear order without requiring decorative numbering;
- avoid real personal, account, health, financial, or confidential data;
- verify rights for imagery, fonts, characters, testimonials, ratings, and
  comparative claims;
- localize both copy and visual context;
- check VoiceOver-relevant claims and other accessibility statements against
  audited common tasks;
- follow current App Review and App Store marketing identity guidance.

Use an App Preview only when motion and interaction explain value better than a
static sequence. Plan the opening seconds for silent viewing, show real
in-app experience under current rules, and verify specifications before
production.

## Native Product Page Optimization

Before planning a native test, verify current supported treatment assets,
localizations, traffic controls, concurrency limits, maximum duration, app-icon
requirements, and confidence reporting in Apple documentation.

As of the reviewed source set, native treatments support app icons,
screenshots, and App Previews. Do not describe subtitle, description,
promotional text, or keyword changes as a native treatment unless current Apple
documentation explicitly adds them.

Keep native Product Page Optimization separate from:

- pre-launch concept or landing-page tests;
- sequential metadata changes;
- Custom Product Page comparisons;
- Apple Ads creative or audience tests;
- external store-page simulations.

Name the method because each has different traffic, review, bias, and
interpretation constraints.

## Experiment contract

Write the plan before launch:

```text
Decision to make
Problem and evidence
Hypothesis
Audience and intent
Storefronts, locales, devices, and sources
Changed variable
Control
Treatment
Primary metric and exact definition
Activation, retention, proceeds, and quality guardrails
Traffic allocation
Minimum exposure or sample rationale
Expected duration and seasonality risks
Decision threshold
Early-stop rule for harm
Follow-up for win, loss, and inconclusive result
Owner and approval status
```

Change one interpretable concept at a time. If several assets must change to
express one coherent narrative, state that the experiment tests the bundled
concept and cannot attribute impact to an individual asset.

Choose the metric from the decision. Use conversion for product-page choice,
but preserve activation, retention, monetization, refunds, crashes, review
sentiment, and support burden as applicable guardrails.

## Interpretation and rollout

- Do not declare a winner from a small absolute lift, an underpowered sample,
  an incomplete confidence signal, or a few days of volatile traffic.
- Do not repeatedly inspect and stop at the first favorable result.
- Check allocation, locale and source mix, novelty, seasonality, campaign
  changes, and product releases.
- Distinguish statistical evidence, practical value, and downstream user
  quality.
- Apply a winning treatment only after confirming that its promise remains
  accurate and the affected localizations and icon binary are ready.
- Treat inconclusive results as learning about the tested contrast, not proof
  that product-page optimization cannot help.
- Record the artifact, dates, audience, exposure, result, limitations,
  decision, and next hypothesis in an experiment log.
