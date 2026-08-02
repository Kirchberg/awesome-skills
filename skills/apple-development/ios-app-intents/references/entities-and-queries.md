# Entities and queries

Build a narrow, durable system-facing model. An `AppEntity` represents content
the system must identify, display, resolve, search, or pass between actions; it
is not an automatic projection of the app's entire data model.

## Contents

- Define entity identity
- Keep representations narrow
- Select the query by corpus and task
- Implement lookup at the data source
- Support Find actions responsibly
- Test entity durability

## Define entity identity

- Choose a stable identifier derived from durable domain identity, not an array
  offset, localized title, mutable slug, transient object ID, or memory address.
- Namespace identifiers when multiple stores or account scopes can collide.
- Keep the same identifier for the same logical object across launches,
  indexing, shortcuts, widgets, and supported sync boundaries.
- Preserve persistent type identity when renaming a published entity type; use
  the selected SDK's `PersistentlyIdentifiable` contract and verify restoration.
- Treat account changes and deleted data explicitly. Never resolve an old ID to
  a different user's or different logical object.

Return entities corresponding to requested identifiers in the contract the
selected SDK defines. Omit missing entities where Apple directs; do not create
fabricated placeholders that can later receive a destructive action.

## Keep representations narrow

Include:

- the stable ID;
- a clear localized `DisplayRepresentation`;
- only properties required for display, search, filtering, or another intent;
- lightweight image or artwork representation when it improves recognition;
- synonyms that are real user vocabulary.

Do not serialize full Core Data, SwiftData, Realm, or backend object graphs.
Avoid secrets, private metadata, unrelated relationships, large blobs, and
properties the system never needs.

Use `AppEnum` for a small fixed set such as a mode, sort order, visibility, or
status. Use an entity when values are dynamic, user-created, remotely sourced,
or require stable per-instance identity.

## Select the query by corpus and task

Start with `EntityQuery` to restore entities by ID. Add only the capability the
use case needs:

- `suggestedEntities()` for a small, ranked configuration list;
- `EntityStringQuery` for direct text search;
- `EnumerableEntityQuery` only when returning every entity is predictably small
  in time and memory;
- `EntityPropertyQuery` for system-generated Find actions over filterable,
  potentially large data;
- `IndexedEntityQuery` and Spotlight integration when system indexing and
  scalable discovery are required;
- a unique-entity query only when the domain truly has one possible entity.

Inspect the selected SDK for available protocols and requirements. New query
APIs may be prerelease even when the base `EntityQuery` is stable.

## Implement lookup at the data source

- Batch identifier reads instead of issuing one request per value.
- Translate string and property comparators into repository, database, or API
  queries instead of loading an unbounded corpus into memory.
- Bound suggestion count, latency, payload size, and image work.
- Rank suggestions by stable product relevance, not accidental storage order.
- Preserve authorization and account scope in every lookup.
- Handle offline caches, deleted content, stale indexes, and partial batch
  results deliberately.
- Keep query types and returned values safe for the concurrency contract of the
  selected Swift and SDK versions.

Do not rely on the main UI's current in-memory array as the sole restoration
path. Saved shortcuts and Spotlight results must continue to resolve when the
app is not already displaying the object.

## Support Find actions responsibly

Property-query support can expose powerful Shortcuts actions. Provide only
properties and comparators the data source can execute predictably. Define:

- supported properties and sort orders;
- comparator-to-domain translation;
- pagination or result bounds where the framework allows them;
- authorization and privacy behavior;
- deterministic ordering for equal values;
- empty and partial result behavior.

Do not advertise a filter that degrades into an unbounded client-side scan.

## Test entity durability

Verify:

1. a saved ID resolves after relaunch;
2. batch lookup handles reordered input and missing values correctly;
3. suggestions are bounded, localized, and account-correct;
4. string search handles case, diacritics, empty input, and locale as intended;
5. property filters and sort order match repository semantics;
6. deleted and inaccessible entities fail safely;
7. renamed types preserve published identity where required;
8. Spotlight records and shortcuts open the same logical object;
9. large representative data does not require full-corpus loading;
10. entity output contains no unintended private fields.
