# Localization and transcreation

Use this reference to adapt product positioning, App Store metadata, keywords,
screenshots, ads, and communications for a locale and storefront.

## Contents

- Separate the localization layers
- Prepare source content
- Research the market
- Transcreate
- Build governance
- Validate

## Separate the localization layers

Keep these distinct:

- **Product internationalization**: engineering support for languages, scripts,
  formats, layouts, and locale behavior.
- **Binary localization**: user-facing strings and resources shipped in the
  app.
- **App Store localization**: localized metadata, screenshots, previews, and
  other product-page content.
- **Marketing transcreation**: adaptation of meaning, tone, evidence, and
  response for a market and channel.
- **Keyword research**: market-specific discovery research, not translation.

Record locale, storefront, primary language, fallback behavior, device,
supported binary languages, and publication status. Never imply that localized
App Store metadata means the in-app experience is localized.

## Prepare source content

Before adaptation:

1. Lock the intended audience, promise, evidence, CTA, tone, and character
   limits or visual context.
2. Remove idioms, wordplay, unexplained abbreviations, ambiguous pronouns,
   fragments, and avoidable culture-specific references unless they are
   deliberately transcreated.
3. Use stable terminology, active voice, complete thoughts, and
   translator-controlled placeholders.
4. Mark product names, trademarks, feature names, protected terms, variables,
   and text that must not be translated.
5. Provide screenshots or layouts showing where each string appears.
6. Preserve an approved source version and change history.

Do not make English unnaturally generic merely to simplify translation. Keep
the meaning vivid and supply context.

## Research the market

For each target storefront:

- identify local user jobs, alternatives, trust signals, objections, category
  language, formality, and channel conventions;
- mine product research, local reviews, support language, competitor pages,
  search terms, and native-speaker input;
- research local search intent independently;
- record demand and competition estimates with tool, market, date, and
  uncertainty;
- check local rights, regulated claims, pricing display, subscription
  expectations, privacy expectations, and cultural sensitivities;
- decide whether the global positioning fits or requires a market-specific
  frame.

Do not invent search volume, import another storefront's volume, or translate a
keyword list literally.

## Transcreate

Adapt in this order:

1. Preserve the intended customer value and emotional response.
2. Choose natural local terminology and formality.
3. Rebuild headline, subtitle, caption, proof, and CTA for the channel.
4. Adapt screenshot sequence and visual examples, not copy alone.
5. Allocate locally researched search concepts to current App Store fields and
   surfaces.
6. Recheck message continuity through destination and in-app experience.
7. Record substantive departures from the global source and why they improve
   local understanding or trust.

Prefer native, specific language over structural fidelity. Keep brand voice
recognizable while allowing tone and syntax to change.

## Build governance

Maintain:

- source and target locale;
- glossary with approved term, definition, context, variants, and prohibited
  translations;
- style guide with voice, formality, punctuation, capitalization, numerals,
  date, time, currency, measurement, and address conventions;
- non-translatable product and legal terms;
- claim ledger and evidence by market;
- screenshot and creative context;
- owner, translator, reviewer, approval status, and review date.

Use Unicode CLDR and locale-aware formatters for plural categories and formats.
Do not create manual `one/other` assumptions across languages.

## Validate

Run three distinct gates:

1. **Linguistic QA**: meaning, naturalness, grammar, spelling, terminology,
   tone, idiom, and cultural fit by a qualified reviewer.
2. **Functional and visual QA**: field limits, truncation, line breaks,
   directionality, dynamic values, device presentation, screenshots, links,
   and destination behavior.
3. **Marketing QA**: intent relevance, claim evidence, message continuity,
   policy, rights, CTA, and measurement.

Test the real storefront or preview where possible. Use back translation only
as a diagnostic tool, not as proof of quality. Do not claim a locale ready
without qualified human review of public-facing claims and the actual visual
context.
