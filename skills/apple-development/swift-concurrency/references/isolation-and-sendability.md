# Isolation, transfer, and actor reentrancy

## Contents

- [Find the owner before fixing syntax](#find-the-owner-before-fixing-syntax)
- [Use Sendable as a transfer contract](#use-sendable-as-a-transfer-contract)
- [Use sending and region-based isolation precisely](#use-sending-and-region-based-isolation-precisely)
- [Design actor state transitions](#design-actor-state-transitions)
- [Control isolation explicitly](#control-isolation-explicitly)
- [Review global actors and protocols](#review-global-actors-and-protocols)
- [Protect synchronous state deliberately](#protect-synchronous-state-deliberately)
- [Constrain escape hatches](#constrain-escape-hatches)

## Find the owner before fixing syntax

For every diagnostic or race:

1. Identify the mutable state.
2. List every alias that can reach it.
3. Identify the isolation domain or synchronization primitive that owns it.
4. Identify the value or closure crossing out of that domain.
5. Repair the contract at the narrowest point where the invariant is known.
6. Inspect public API, conformances, callbacks, and consumers affected by the
   change.

Prefer local immutable snapshots over shared references. Prefer one ownership
fix over many call-site hops or assertions.

## Use Sendable as a transfer contract

`Sendable` states that values of a type can cross concurrency domains without
introducing unsafe shared mutation. It does not schedule work or make methods
atomic.

Conform a value type when all stored values and invariants are `Sendable`.
Conform a class only when its complete design supports the contract, commonly
because it is `final`, immutable after initialization, and contains only
`Sendable` state.

Treat public `Sendable` and `@Sendable` annotations as API changes. Inspect:

- generic constraints and existential consumers;
- stored non-`Sendable` references;
- lazy and cached mutation;
- closure captures;
- subclassing;
- Objective-C exposure;
- downstream compilation modes.

An `@Sendable` closure must capture only values that can be transferred safely.
A weak capture does not make the referenced object `Sendable`, and a mutable
unchecked box does not protect its contents.

## Use sending and region-based isolation precisely

Use `sending` parameters and results when an API transfers a value out of its
current isolation region. After transfer, the source context must not continue
using aliases that could conflict with the destination.

Region-based isolation can prove that some non-`Sendable` values are disconnected
from other live aliases and therefore safe to transfer. Do not interpret one
accepted transfer as a global `Sendable` guarantee for the type.

When diagnosing a `sending ... risks causing data races` message:

1. Locate all aliases in the source region.
2. Find the access that remains possible after transfer.
3. Remove the alias, take an immutable `Sendable` snapshot, keep the operation
   in one isolation domain, or redesign the API to transfer ownership clearly.
4. Avoid wrapping the value in `@unchecked Sendable`.

Check the compiler version and proposal availability before publishing `sending`
in a library's public source.

## Design actor state transitions

Actors serialize isolated access but are reentrant at suspension points.

Before an actor method awaits:

- snapshot immutable inputs;
- record a generation, request ID, phase, or expected state;
- decide whether duplicate work should coalesce, replace, or coexist.

After it resumes:

- revalidate assumptions;
- ignore or cancel stale results;
- avoid overwriting newer state;
- complete or clear any in-flight bookkeeping on success, error, and
  cancellation.

Use single-flight task caching only after choosing its cancellation semantics.
If multiple callers share one task, canceling one waiter must not accidentally
cancel work still required by other waiters unless that is the documented
contract.

Do not call an arbitrary callback while actor invariants are half-updated.
Prefer returning a value, completing the transition, and invoking external work
outside the critical actor operation.

## Control isolation explicitly

Use:

- an `isolated` parameter to borrow one actor's isolation for a synchronous
  batch of operations;
- `nonisolated` for immutable or otherwise safe members that do not access
  actor-isolated state;
- a global actor for a domain-wide serial ownership contract;
- `await` at genuine cross-actor calls.

Do not mark a mutable member `nonisolated` merely for protocol conformance.
Expose an immutable snapshot, isolate the conformance where supported, change
the protocol contract deliberately, or redesign the boundary.

Treat `nonisolated(unsafe)` as disabled compiler checking, not synchronization.

## Review global actors and protocols

Use `MainActor` for state and operations semantically owned by the UI/main
executor. Do not add it only because a call currently happens on the main
thread.

Before applying default `MainActor` isolation to a module, inventory:

- synchronous CPU-heavy functions that would inherit isolation;
- protocol conformances and callbacks;
- initializers and static state;
- tests and mocks;
- public APIs and external consumers;
- code that intentionally runs on other actors.

Protocol isolation is an API design decision. If all conformers share one actor,
express that contract. If only one conformer is isolated, use an isolated
conformance where the supported language model allows it, expose a snapshot, or
separate the protocols rather than forcing unrelated conformers onto one actor.

Do not equate `@MainActor @Sendable` callbacks with arbitrary main-queue
callbacks. Preserve whether invocation is synchronous or asynchronous and
whether ordering or reentrancy changes.

## Protect synchronous state deliberately

Use an actor when callers can suspend and state naturally belongs to an async
domain. Use `Synchronization.Mutex` when a small state value must be accessed
synchronously and the deployment/toolchain constraints permit it.

For any mutex or lock:

- guard every access with the same primitive;
- keep the critical region small;
- never suspend or await while holding it;
- do not invoke unknown callbacks while holding it;
- do not return mutable references that escape protection;
- review deinitialization and reentrancy;
- stress the invariant and use Thread Sanitizer where applicable.

Use atomics only when a measured low-level case requires them and reviewers can
verify memory ordering. Atomics do not make a compound invariant atomic by
default.

## Constrain escape hatches

Require all of the following for `@unchecked Sendable`,
`nonisolated(unsafe)`, `@preconcurrency`, or `MainActor.assumeIsolated`:

- the exact compiler limitation or legacy boundary;
- the real ownership or synchronization invariant;
- the narrowest declaration or adapter scope;
- a focused compile-time or runtime test;
- an owner and removal condition;
- a public API compatibility review when applicable.

`@preconcurrency` defers checking at a dependency boundary; it does not prove
that the dependency is thread-safe. `MainActor.assumeIsolated` dynamically
asserts an externally guaranteed synchronous boundary and can fail at runtime.

Reject a class with unprotected mutable state marked `@unchecked Sendable`,
broad suppression imports, unchecked mutable boxes, and isolation assertions
whose executor guarantee is merely assumed from current call sites.
