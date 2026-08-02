# Spotlight and donations

Distinguish action discovery, content indexing, and behavioral donations. They
share App Intents concepts but have different data lifecycles and proof.

## Choose the integration

- Use App Shortcuts to surface a curated action in Shortcuts, Siri, and
  supported Spotlight experiences.
- Use `IndexedEntity` and the selected SDK's Spotlight integration to make app
  content searchable by entity.
- Use intent or entity donations to teach the system about relevant actions and
  content the person actually used.
- Use Core Spotlight directly where the required content lifecycle or attribute
  control is outside the App Intents abstraction.

Do not claim content is searchable because an App Shortcut exists. Do not claim
an action is donated because an entity was indexed.

## Index durable content

For each indexed entity type:

- use the same stable ID as shortcuts, queries, and routing;
- provide concise localized title, subtitle, keywords, and artwork as needed;
- index only content the current account is allowed to expose;
- implement initial indexing, incremental update, deletion, logout cleanup, and
  full reindexing;
- keep indexing off latency-sensitive UI paths where practical;
- bound batch size, image work, memory, and retry behavior;
- provide an `OpenIntent` or current supported opening contract so a result
  reaches the precise entity.

Use a named `CSSearchableIndex` or App Intents indexing mechanism consistently
with the app's reindexing contract. Do not create duplicate records for the same
logical entity through two unsynchronized pipelines.

## Keep index lifecycle consistent

Update or remove the Spotlight representation when source data changes. Define
behavior for:

- entity rename, move, merge, and deletion;
- account switch, logout, and revoked access;
- database migration and identifier migration;
- remote change while the app is not active;
- partial indexing failure and retry;
- app restore, reinstall, and system-requested reindexing;
- locale change and display-representation update.

Never leave private content in Spotlight after logout or permission revocation.
Never reuse an old searchable identifier for a different logical object.

## Donate direct user behavior

Donate an intent when the person performs the equivalent action directly in the
app and the donation is useful for future discovery or prediction. Do not
re-donate an action merely because Siri, Shortcuts, or another App Intent already
invoked it.

Donate only after the action's meaningful success point. Include the correct
entities and parameters, then delete or invalidate donations when account,
privacy, or domain state requires it.

Avoid donating:

- failed, cancelled, preview-only, or accidental interactions;
- high-frequency low-value noise;
- sensitive activity without a clear product and privacy basis;
- internal maintenance actions;
- duplicates created by both UI and intent execution paths.

## Validate discovery and privacy

Verify with an installed build and representative data:

1. App Shortcut actions appear and invoke the intended action;
2. indexed entities appear for expected searches;
3. each result opens the exact current entity;
4. updates change displayed metadata without duplicate records;
5. deletion, logout, and revoked access remove private records;
6. a full reindex recovers from a cleared or stale index;
7. donations occur only after direct successful UI actions;
8. Siri or Shortcuts execution does not create duplicate donations;
9. indexing remains bounded for a production-size corpus;
10. localization and account scoping remain correct after upgrade.

Record which search terms, locale, data state, app lifecycle, OS, and device
produced the evidence. Search appearance is system-controlled and may not be
immediate; distinguish correct indexing evidence from ranking claims.
