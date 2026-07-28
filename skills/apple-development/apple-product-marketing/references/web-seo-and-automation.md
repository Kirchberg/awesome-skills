# Web-to-app SEO and metadata automation

Use this reference for an app website, international web discovery,
web-to-app journeys, source-controlled App Store metadata, and repeatable
creative delivery.

## Contents

- Keep ASO and web SEO separate
- Design international app-site discovery
- Build the web-to-app journey
- Treat metadata as code
- Automate safely

## Keep ASO and web SEO separate

App Store search and web search use different indexes, surfaces, metadata,
measurement, and user intent. Do not transfer keyword volume, ranking theories,
field rules, or conversion benchmarks between them.

Keep the positioning and terminology coherent while creating separate:

- App Store intent and metadata maps;
- website information architecture and query-to-page map;
- measurement contracts for App Store and web acquisition.

## Design international app-site discovery

For each language or region:

1. Use stable, crawlable, locale-specific URLs.
2. Avoid mandatory IP or language redirects that prevent users and crawlers
   from reaching another version; offer a visible selector.
3. Use correct canonical URLs for equivalent pages without collapsing valid
   localized pages into one language.
4. Add reciprocal `hreflang` annotations, self-references, valid
   language-region codes, and an intentional `x-default` where appropriate.
5. Keep primary content, titles, descriptions, structured data, image
   alternatives, and links available on the mobile version.
6. Render substantive content without requiring an animation or interaction.
7. Provide useful, localized content beyond a thin App Store link page.
8. Validate indexing, status codes, sitemaps, Search Console evidence, and
   Core Web Vitals.

Use `SoftwareApplication` structured data only with visible, accurate
properties supported by the page. Treat eligibility as separate from a
guarantee that Google will show a rich result.

## Build the web-to-app journey

Map:

```text
Web query or referring channel
Landing page and locale
Promise and proof
CTA
Installed-user destination
New-user App Store destination
Fallback
Campaign measurement
Activation event
```

- Use Universal Links for eligible installed-user deep linking and preserve a
  useful web fallback.
- Use Smart App Banners where appropriate instead of intrusive, inaccessible
  custom overlays.
- Use a default or Custom Product Page that matches the web intent.
- Add campaign links or approved parameters before launch.
- Test installed, not installed, first launch, signed out, unsupported OS,
  wrong locale, and broken destination states.

If implementation is requested, inspect the application's Associated Domains,
`apple-app-site-association`, routing, hosting, caching, and tests with the
appropriate engineering workflow. This marketing skill defines the journey and
acceptance contract; it does not certify code it has not inspected or run.

## Treat metadata as code

Store reviewable, locale-scoped source files for:

- app name, subtitle, description, promotional text, and keywords;
- release notes and support or marketing URLs;
- screenshots, previews, captions, device and locale mappings;
- Custom Product Pages and In-App Events where supported;
- glossary, claim evidence, owner, approval, and review date.

Use clear naming, UTF-8, deterministic ordering, and diffs that separate source
copy from generated or delivered artifacts. Protect secrets and account
identifiers from the repository.

Validate before delivery:

- current field availability and limits;
- required localizations and fallback;
- empty, duplicated, or stale values;
- prohibited template markers and tracking parameters;
- spelling, terminology, claims, rights, and policy;
- screenshot dimensions, device, locale, content, and ordering;
- link reachability and destination behavior;
- diff scope and human approval.

## Automate safely

Choose App Store Connect API or fastlane only after verifying that the current
endpoint or action supports the exact resource and operation. A general API
overview is not proof that every field or asset is writable.

Use a safe delivery sequence:

1. Export or snapshot the current remote state.
2. Generate a dry-run or explicit diff.
3. Validate files, locales, assets, rights, and policy.
4. Require human approval for the intended app, version, storefront, and
   operation.
5. Upload without automatic release unless explicitly authorized.
6. Capture response IDs and statuses without exposing credentials.
7. Verify App Store Connect state and review status.
8. Keep a rollback or restoration path for metadata and assets.

Automate screenshot capture only with deterministic app state, approved sample
data, stable devices and locales, and visual QA. Never place real user or
production account data in captured assets.
