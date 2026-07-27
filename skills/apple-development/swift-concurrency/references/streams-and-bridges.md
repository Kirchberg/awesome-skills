# Continuations, async sequences, and legacy bridges

## Contents

- [Prefer native asynchronous APIs](#prefer-native-asynchronous-apis)
- [Prove continuation invariants](#prove-continuation-invariants)
- [Bridge cancellation without races](#bridge-cancellation-without-races)
- [Design AsyncStream lifetime and buffering](#design-asyncstream-lifetime-and-buffering)
- [Choose sequence and channel semantics](#choose-sequence-and-channel-semantics)
- [Integrate Foundation and delegates](#integrate-foundation-and-delegates)
- [Contain GCD and Objective-C boundaries](#contain-gcd-and-objective-c-boundaries)

## Prefer native asynchronous APIs

Use a native async API when one exists. A custom bridge adds ownership,
cancellation, multiplicity, buffering, and executor assumptions that the caller
must maintain.

Before adapting an API, record:

- whether completion occurs exactly once, at most once, or repeatedly;
- whether completion can be synchronous;
- the documented callback queue or actor;
- success and failure paths;
- the cancellation mechanism;
- whether the producer can outlive the consumer;
- event ordering and buffering requirements.

Use a continuation for one terminal value. Use an async sequence for zero or
more values over time.

## Prove continuation invariants

Prefer checked continuations while developing and for ordinary bridges.

Guarantee:

1. Resume exactly once.
2. Resume on every terminal success and failure path.
3. Do not retain the continuation indefinitely.
4. Protect against APIs that can call completion both synchronously and later.
5. Preserve the callback's result and error semantics.

`withCheckedContinuation` detects some misuse but does not prove cancellation,
thread safety, callback ordering, or lifetime correctness.

Do not hold an actor invariant open while waiting for a legacy callback. Store a
small explicit pending-state record or place the adapter behind a dedicated
isolation boundary.

## Bridge cancellation without races

Connecting `withTaskCancellationHandler` to a callback API creates at least two
races:

- cancellation can happen before the underlying operation or token is stored;
- completion and cancellation can happen concurrently.

Use one synchronized state machine to coordinate:

- `pending`;
- `started(token)`;
- `completed`;
- `cancelled`.

Make completion and cancellation idempotent at the adapter boundary even if the
underlying API is not. Resume the continuation once, cancel the underlying token
once, and release both after reaching a terminal state.

Keep the cancellation handler synchronous. It may signal a thread-safe token or
update synchronized adapter state; it cannot `await`.

Do not promise cancellation if the underlying API cannot stop and the wrapper
has no defined policy for ignoring a late result.

## Design AsyncStream lifetime and buffering

For every `AsyncStream` or `AsyncThrowingStream`, define:

- the buffering policy and why it fits the producer and consumer rates;
- what happens when the buffer drops a value;
- which object owns the continuation;
- who calls `finish` and on which terminal paths;
- how `onTermination` disconnects observers, delegates, or producers;
- whether multiple iterators are supported;
- how consumer cancellation reaches the producer.

An unbounded buffer turns a slow or abandoned consumer into retained memory.
Newest- or oldest-value buffering changes semantics and must be explicit.

Install termination handling before exposing a producer that can emit. Make
observer removal and finishing safe when they race.

## Choose sequence and channel semantics

Prefer `AsyncSequence` for pull-oriented consumption with `for await`. Use Swift
Async Algorithms for established operations such as merge, combineLatest,
debounce, throttle, chunks, and channels rather than creating task-based
infrastructure from scratch.

Use a channel when producer progress should wait for consumer capacity. Use a
buffered stream when temporary decoupling or event coalescing is part of the
contract.

Review:

- element ordering;
- failure and completion;
- buffering and back-pressure;
- cancellation latency;
- number of producers and consumers;
- retained elements and captures;
- where transformation code executes.

## Integrate Foundation and delegates

Use URLSession async APIs for ordinary requests. Use byte streams for large or
incremental responses when retaining the full body is unnecessary. Process
chunks with a bounded parser and preserve request cancellation.

For delegate-based APIs:

- keep the delegate alive for the producer lifetime;
- isolate mutable adapter state;
- model repeated events as a sequence;
- finish on terminal delegate callbacks;
- detach the delegate or observer on termination;
- document queue and reentrancy guarantees.

Respect framework-specific ownership domains such as Core Data contexts. Do not
send managed objects or other thread-confined references across isolation
boundaries; transfer stable identifiers or value snapshots when required.

## Contain GCD and Objective-C boundaries

Keep legacy queue assumptions in one adapter. Do not scatter
`DispatchQueue.main.async` or `@preconcurrency` through feature code.

Never turn async work into synchronous work with a semaphore, condition, or
`DispatchQueue.sync`. This can block the cooperative executor and deadlock when
the awaited work needs the blocked executor or queue.

When wrapping Objective-C completion handlers:

- account for imported `@Sendable` annotations in current SDKs;
- capture only safely transferable values;
- preserve nullable and error conventions;
- verify callback multiplicity and queue documentation;
- use a typed actor adapter instead of an unchecked assertion where possible.

Keep `OperationQueue` when its dependency, readiness, or bounded-operation model
is still valuable and a rewrite is not justified. Modernization does not require
replacing every working queue with unstructured tasks.
