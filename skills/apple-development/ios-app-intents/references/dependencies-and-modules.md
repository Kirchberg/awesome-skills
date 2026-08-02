# Dependencies, modules, and process boundaries

Keep intent declarations lightweight and reuse the app's real domain services.
Choose packaging and execution boundaries from lifecycle and data ownership, not
from folder aesthetics.

## Contents

- Inject dependencies
- Keep `perform()` thin
- Choose module placement
- Design separate processes explicitly
- Register early without hiding failures
- Verify packaging

## Inject dependencies

Register dependencies with `AppDependencyManager` as early as the app or
extension lifecycle permits, then resolve them through `AppDependency` in
intents and queries. Prefer interfaces that expose a narrow domain operation.

Design each dependency for:

- initialization before the system can execute the intent;
- the process in which it may be resolved;
- account and authorization state;
- actor isolation and `Sendable` requirements in the selected SDK;
- test substitution without production singletons;
- deterministic failure when registration or required state is unavailable.

Do not inject an `NSManagedObject`, `ModelContext`, mutable `ObservableObject`,
view model, or navigation object across isolation or process boundaries without
an explicit supported ownership contract. Prefer immutable IDs and values plus
an actor-isolated or otherwise safe service.

## Keep `perform()` thin

Use dependency injection to call an existing application service:

```text
AppIntent / EntityQuery
  -> injected use case or repository interface
  -> domain and persistence implementation
```

Keep business rules, authorization, idempotency, transactions, and network
policy in the domain layer. Keep system parameter translation, confirmation,
execution-mode handling, and `IntentResult` mapping in the intent layer.

Do not initialize a parallel persistence or networking stack in every
`perform()` call. Do not access UI-owned mutable state from a background intent.

## Choose module placement

Leave declarations in the app target when one app owns them and no extension or
shared framework needs them.

Use `AppIntentsPackage` when declarations live in a framework or Swift package.
Declare included packages at the application boundary so the system can extract
their metadata. Verify the package and every intent dependency are linked by
the required app and extension targets.

Use `AppIntentsExtension` when intents must be discovered or performed without
launching the main app and the extension can satisfy their dependencies. Do not
make an extension the default solely to reduce app launch time.

## Design separate processes explicitly

The main app, widget extension, and App Intents extension may run concurrently
as separate processes. Define:

- which process owns each write;
- shared-container or App Group access;
- database journaling, locking, and migration behavior;
- credential and keychain access;
- authorization refresh and logout propagation;
- cache invalidation and notification mechanisms;
- memory, launch-time, and background-execution limits;
- which target contains every resource and localization.

Never assume an in-process singleton, notification, task, actor, or memory cache
is shared with an extension. Avoid simultaneous writers unless the persistence
technology and application protocol explicitly support them.

Treat WWDC26 `ExecutionTargets` and related target-selection APIs as
prerelease/2027 work until the selected shipping SDK says otherwise. See
`beta-and-version-boundaries.md` before using them.

## Register early without hiding failures

Register dependencies and refresh App Shortcut parameters at a deterministic
application boundary. Avoid ordering that depends on a screen appearing first.

When state is unavailable:

- return an actionable logged-out, locked, or unavailable result;
- request foreground only when UI can resolve the condition;
- do not fall back to a different account or stale mutable singleton;
- do not crash because the system invoked the intent before optional app setup.

## Verify packaging

Build and inspect every affected target. Verify:

1. metadata extraction discovers declarations in packages or frameworks;
2. target membership includes code, localization, and required resources;
3. dependency registration runs in every eligible process;
4. a cold out-of-process invocation can reach the domain service;
5. app and extensions see consistent migrated storage;
6. concurrent invocations cannot corrupt or duplicate writes;
7. strict-concurrency diagnostics remain clean;
8. test dependencies replace production services without global leakage;
9. release configuration matches debug discovery;
10. old deployment targets exclude or fall back from unavailable APIs.
