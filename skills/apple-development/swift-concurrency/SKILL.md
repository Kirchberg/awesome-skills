---
name: swift-concurrency
description: Use when designing, implementing, reviewing, debugging, profiling, testing, or migrating Swift concurrency code for Swift 6.2+ and Swift 6.3, including async/await, tasks and task groups, cancellation, actors and reentrancy, Sendable and sending, global actors and MainActor, continuations, AsyncSequence, SwiftUI concurrency, bounded parallelism, data-race diagnostics, strict concurrency, or staged Swift 6 language-mode adoption in Xcode, Tuist, XcodeGen, or SwiftPM projects. Trigger for requests to fix concurrency diagnostics, remove races, reason about task lifetime or actor isolation, modernize GCD or callbacks, improve concurrent performance or memory use, review concurrency safety, or migrate targets to Swift 6.
---

# Engineer safe Swift concurrency

## Define the outcome

Produce code whose mutable-state owner, isolation boundaries, task lifetime,
cancellation and error propagation, workload bounds, and verification evidence
are explicit.

Treat compilation as necessary but insufficient. Actor isolation prevents data
races; it does not prevent stale state, duplicate work, invalid ordering,
unbounded tasks, leaked streams, cancellation bugs, or executor starvation.

## Read references selectively

- Read `references/mental-model.md` before reasoning about executors, threads,
  actor hops, Swift 6.2 caller-context execution, or `@concurrent`.
- Read `references/structured-concurrency.md` before choosing sequential
  `await`, `async let`, a task group, `Task {}`, `Task.detached`, or a
  cancellation and back-pressure design.
- Read `references/isolation-and-sendability.md` for actors, reentrancy,
  `Sendable`, `sending`, regions, global actors, protocol isolation, or an
  unsafe escape hatch.
- Read `references/streams-and-bridges.md` before adapting callbacks, delegates,
  GCD, continuations, `AsyncSequence`, `AsyncStream`, channels, or streaming
  Foundation APIs.
- Read `references/swiftui-and-mainactor.md` for SwiftUI task lifetime,
  observable UI state, `MainActor`, and moving expensive work away from UI
  isolation.
- Read `references/performance-and-memory.md` before changing task granularity,
  actor traffic, synchronization, scheduling, responsiveness, or retained
  memory.
- Read `references/testing-and-review.md` for reviews, diagnostics, race tests,
  cancellation tests, or completion evidence.
- Read `references/patterns.md` before implementing a common adapter or adding
  `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, or
  `MainActor.assumeIsolated`.
- Read `references/migration-methodology.md`,
  `references/migration-tooling.md`, and `references/migration-state.md` only
  for a staged project or target migration.
- Read `references/sources.md` for source research or whenever a claim is
  version-sensitive, disputed, or toolchain-dependent.

Repository instructions, supported toolchains, deployment targets, and the
user's requested scope override generic examples. They never weaken
data-race-safety, lifecycle, cancellation, or evidence requirements.

## Route the request

Choose one lead mode:

- **Explain**: model semantics and tradeoffs; do not edit.
- **Design**: define ownership, isolation, task tree, cancellation, errors,
  ordering, and load bounds before proposing APIs.
- **Review or diagnose**: report root causes and prioritized findings; do not
  implement fixes unless requested.
- **Implement**: make the smallest semantically complete change and validate it.
- **Profile**: for measurement-dependent tuning or a performance claim, measure
  first, change one supported mechanism, then measure again.
- **Migrate**: inventory targets and configuration, establish a baseline, then
  move through dependency-aware stages with persistent evidence.
- **Research**: rank primary sources and distinguish current rules from
  historical context.

In Implement mode, immediately apply a safe correction proved by ownership,
isolation, task-lifetime, cancellation, load-bound, or control-flow evidence.
Do not leave it as a proposal because a profiler, Simulator, physical device,
or performance baseline is unavailable. Preserve semantics, run available
correctness checks, and measure only conditional performance effects and claims.

Lead with `$swiftui-optimization` for view dependencies, Observation, identity,
layout, scrolling, or animation. Lead with `$swift-ios-performance` for a
non-concurrency Swift hot path. Lead with `$app-performance` when the starting
point is a whole-app hang, hitch, CPU, memory, energy, or responsiveness
symptom; return here after evidence identifies a concurrency mechanism.

## Establish the execution contract

1. Read repository instructions and inspect version-control status.
2. Record the Swift and Xcode toolchain, language mode, deployment targets,
   module default isolation, enabled upcoming features, and build-system source
   of truth.
3. Identify the entry point, caller isolation, value crossings, mutable-state
   owner, task creator, task-handle owner, completion condition, cancellation
   source, error contract, ordering requirement, and maximum workload.
4. Preserve public isolation, `Sendable`, callback delivery, ordering,
   multiplicity, and cancellation semantics unless an API change is explicitly
   in scope.
5. Define the focused build, tests, runtime checks, or trace needed to prove the
   requested outcome.

Do not infer executor behavior from source syntax alone. Verify toolchain- and
SDK-sensitive claims against `references/sources.md`.

## Answer five questions before editing

1. **Who owns each mutable value?**
2. **Which isolation boundary does each value cross?**
3. **Who owns and ends every task or stream?**
4. **How do cancellation and errors propagate?**
5. **What evidence proves correctness and any performance claim?**

If any answer is missing, tighten the design before adding tasks or annotations.

## Choose the least concurrency that solves the problem

- Use ordinary synchronous code when no suspension or independent progress is
  needed.
- Use sequential `await` when operations depend on each other or concurrency
  adds no measured value.
- Use `async let` for a small, fixed set of independent child operations.
- Use a task group for a dynamic child set, with an explicit in-flight bound
  when input or downstream capacity is not trivially small.
- Use `Task {}` only for a genuinely unstructured lifetime. Store its handle,
  define who cancels it, and remember that it is not a structured child.
- Use `Task.detached` only when independence from actor context, task-local
  values, and inherited priority is intentional and documented.
- Use `@concurrent` for a deliberate switch from actor isolation to the generic
  executor where the selected toolchain supports it; do not use it as a
  mechanical “background” switch or a promise of parallel execution.

`async` permits suspension; it does not promise parallelism. Under the
Swift 6.2 `NonisolatedNonsendingByDefault` semantics, ordinary nonisolated async
work runs in the caller's isolation context. Detect that setting instead of
assuming every Swift 6.2+ module enables it.

## Enforce ownership and isolation

Prefer, in order:

1. immutable values and local mutation;
2. `Sendable` values transferred between isolation domains;
3. an actor for asynchronously accessed shared mutable state;
4. `Mutex` for a small synchronous critical region that cannot become async;
5. atomics only for a measured low-level requirement with reviewed memory
   ordering.

Treat every `await` inside an actor as a possible interleaving point. Revalidate
state after suspension or encode the operation as a state machine, transaction,
or single-flight operation.

Never use `@unchecked Sendable`, `nonisolated(unsafe)`, `@preconcurrency`, or a
dynamic isolation assertion merely to silence the compiler. Require a named
invariant, narrow boundary, focused verification, owner, and removal condition.

Treat `MainActor` as an isolation domain, not a synonym for
`DispatchQueue.main`. Do not isolate an entire module, protocol, or type to the
main actor without reviewing all work and consumers that inherit that contract.

## Preserve lifetime, cancellation, and load

- Make long-running operations check cancellation at useful intervals.
- Use cancellation handlers to release or signal legacy resources.
- Preserve `CancellationError` semantics; do not relabel cancellation as an
  unknown failure.
- Bound dynamic fan-out through a limited task-group window, batching, a
  channel, or another back-pressure mechanism.
- Give every long-lived task, observation, subscription, and stream one owner
  and an explicit termination path.
- Inspect captures across suspension points. A single `[weak self]` does not
  prevent a task from retaining `self` after it has been strengthened.

Never block the cooperative executor with semaphore waits, condition waits,
thread sleeps, synchronous callback-to-async bridges, long critical sections,
blocking I/O, or risky queue synchronization. Never hold a lock across
`await`.

## Bridge legacy APIs narrowly

Prefer a native async API. Otherwise:

- resume a checked continuation exactly once on every terminal path;
- connect task cancellation to the underlying operation when cancellation is
  part of the contract;
- define `AsyncStream` buffering, termination, producer ownership, and finish
  behavior;
- preserve callback queue, ordering, multiplicity, and error semantics;
- keep GCD, Objective-C, delegate, and preconcurrency assumptions at one
  documented adapter boundary.

## Handle staged Swift 6 migration

Treat each build target and each shared configuration source as a migration
unit. Inventory the target and configuration graphs, establish representative
baselines, migrate one dependency-aware stage, verify its consumers, and
persist evidence before continuing.

Swift 6 language mode already enables complete concurrency checking. Keep
language mode, default actor isolation, and upcoming features as separate,
reviewed configuration decisions.

## Verify and report

Run repository formatting and static analysis, focused tests, and affected
target and consumer builds. Add Thread Sanitizer or stress coverage at legacy,
unchecked, or low-level boundaries where compile-time checking is insufficient.

For measurement-dependent performance work and performance claims, compare
equivalent optimized builds and scenarios. Measure latency, responsiveness,
task count, live tasks, actor contention, executor starvation, retained memory,
CPU, and downstream wait as relevant. Use the loop
**profile → isolate → fix → verify**. For a source-proven correction, implement
first, validate correctness, and report performance verification pending when
no matched capture is available.

Finish with the selected mode, toolchain and scope, ownership and isolation
model, lifecycle and cancellation contract, changes or findings, checks run,
public API effects, measured evidence, unsafe boundaries, and remaining
uncertainty. Never claim a race is fixed, a migration is complete, or a change
is faster without the corresponding evidence. Do not confuse a pending speed
claim with a pending safe implementation.
