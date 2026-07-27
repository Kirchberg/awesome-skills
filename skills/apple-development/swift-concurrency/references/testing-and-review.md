# Concurrency diagnostics, testing, and review

## Contents

- [Group diagnostics by root cause](#group-diagnostics-by-root-cause)
- [Build an evidence ladder](#build-an-evidence-ladder)
- [Test interleavings without time guesses](#test-interleavings-without-time-guesses)
- [Test cancellation and lifetime](#test-cancellation-and-lifetime)
- [Test bridges and streams](#test-bridges-and-streams)
- [Exercise unchecked boundaries](#exercise-unchecked-boundaries)
- [Perform a concurrency review](#perform-a-concurrency-review)
- [Report findings and completion](#report-findings-and-completion)

## Group diagnostics by root cause

One incorrect ownership or isolation contract can produce many compiler
messages. Before editing each site:

1. Group diagnostics by symbol and isolation boundary.
2. Find the original value, alias, closure, conformance, or global state.
3. Determine whether the correct fix is immutability, transfer, actor ownership,
   synchronous synchronization, a protocol/API change, or a narrow legacy
   adapter.
4. Rebuild after the root fix before treating downstream messages separately.

Common diagnostic families:

- mutable global or static state;
- non-`Sendable` capture in an `@Sendable` closure;
- sending a value that remains aliased;
- crossing a global-actor boundary synchronously;
- isolated conformance used from a nonisolated context;
- mutable state in a `Sendable` class;
- legacy declarations imported without concurrency annotations.

Use diagnostics matching the selected compiler. Do not paste a workaround from
another Swift version without verifying its semantics and availability.

## Build an evidence ladder

Choose evidence proportionate to the boundary:

1. compiler isolation and `Sendable` checking;
2. focused unit tests for values and state transitions;
3. deterministic async tests for ordering and cancellation;
4. consumer and integration builds for public isolation changes;
5. load or stress tests for boundedness and race-sensitive state;
6. Thread Sanitizer for legacy, Objective-C, C/C++, unchecked, lock-based, or
   preconcurrency boundaries;
7. Instruments for responsiveness, task behavior, contention, and memory;
8. device tests for framework and lifecycle behavior.

Compile-time data-race safety cannot inspect all external and unchecked code.
Runtime tools cannot prove the absence of every race. Use both where the
boundary warrants it.

## Test interleavings without time guesses

Avoid arbitrary sleeps as synchronization. They create slow, flaky tests and do
not guarantee an ordering.

Use controllable test seams:

- a suspended continuation or test gate;
- a fake async service whose completion the test controls;
- a test clock where the repository supports one;
- an actor-owned recorder;
- explicit confirmations or expectations for observable events.

For actor reentrancy:

1. start operation A;
2. hold it at a known suspension;
3. run operation B and mutate the relevant actor state;
4. resume A;
5. assert the intended stale-result, retry, coalescing, or rejection behavior.

Test ordering separately from data-race safety.

## Test cancellation and lifetime

Verify:

- cancellation before an operation starts;
- cancellation during each meaningful suspension or batch;
- parent cancellation reaching structured children;
- an unstructured task being canceled by its owner;
- an underlying request or token receiving cancellation;
- cleanup running exactly once;
- cancellation not becoming an unrelated domain failure;
- a canceled or replaced request not applying stale state.

Prove that task and owner lifetimes end. Use deinitialization probes or weak
references where appropriate, but avoid relying on nondeterministic timing.

For a long-lived consumer, finish or cancel the source, await the consuming task
where possible, release owners, and assert that retained resources disappear.

## Test bridges and streams

For a continuation adapter, cover:

- synchronous completion;
- asynchronous completion;
- success and failure;
- cancellation before token installation;
- cancellation racing with completion;
- duplicate callback defense when the legacy API permits it;
- a path that otherwise never completes.

For an async stream, cover:

- normal finish and throwing finish;
- consumer cancellation;
- observer or delegate removal;
- buffer overflow policy;
- event ordering;
- slow consumer behavior;
- producer completion before iteration begins.

Checked continuations can expose a double resume during tests. They cannot
replace the adapter's own state-machine tests.

## Exercise unchecked boundaries

Every `@unchecked Sendable`, `nonisolated(unsafe)`, mutex, atomics use,
`@preconcurrency` adapter, or dynamic isolation assertion requires:

- a written invariant;
- a focused correctness test;
- a stress or sanitizer test when practical;
- coverage of initialization, teardown, and callbacks;
- an owner and removal condition if temporary.

Run Thread Sanitizer on a representative simulator or supported target. Record
unsupported configurations and do not claim sanitizer evidence when the run did
not execute.

## Perform a concurrency review

Ask:

1. Who owns each mutable value?
2. Which values and closures cross isolation domains?
3. Is each transfer `Sendable`, `sending`, or otherwise proven disconnected?
4. Can any `await` invalidate state read before suspension?
5. Is structured concurrency used wherever lifetime is scoped?
6. Who owns, observes errors from, and cancels each unstructured task?
7. Do cancellation and errors preserve the API contract?
8. Is fan-out bounded by the actual downstream resource?
9. Can any executor job block or hold a lock across suspension?
10. Can a task, stream, continuation, observer, or buffer outlive its owner?
11. Did public isolation, conformance, callback, or ordering semantics change?
12. Which build, test, sanitizer, trace, or device evidence proves the result?

## Report findings and completion

For each review finding, include:

- source location and affected symbol;
- triggering execution sequence;
- violated invariant;
- user-visible or correctness impact;
- narrow repair;
- verification needed;
- confidence and any toolchain dependency.

Prioritize exploitable data races, deadlocks, continuation misuse, executor
blocking, lost cancellation, stale UI state, unbounded work, and leaks before
style or speculative micro-optimization.

For implemented work, report changed ownership and isolation, task and stream
lifetime, cancellation behavior, public API effects, checks actually run,
unsafe boundaries, and unresolved risks. Do not infer a pass from a build
artifact, a warning-free editor, or a test that did not run.
