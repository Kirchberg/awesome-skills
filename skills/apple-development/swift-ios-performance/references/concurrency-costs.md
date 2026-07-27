# Swift concurrency costs

## Contents

- Correctness and scope
- Cost model
- Task granularity
- Actor and executor crossings
- Structured parallelism
- Continuations and streams
- Main-actor work
- Measurement and review

## Correctness and scope

Optimize concurrency only after preserving:

- actor isolation and data-race safety;
- structured lifetime and parent-child relationships;
- cancellation and error propagation;
- ordering and priority semantics;
- task-local and executor assumptions;
- UI and framework thread affinity.

Use `swift6-migration` for broad isolation or `Sendable` migration. Use
`app-performance` when the starting symptom is a hang, responsiveness, CPU,
energy, or thermal regression. Use this reference for the source-level cost of a
known concurrent pipeline.

## Cost model

Swift tasks are lightweight relative to operating-system threads, not free.
Potential costs include:

- creating and destroying task records and async frames;
- capturing and retaining task inputs;
- enqueuing and scheduling jobs;
- suspending and resuming around `await`;
- hopping between actors or executors;
- synchronization and contention around shared state;
- cancellation checks, task-group bookkeeping, and result collection;
- copying or transferring values across isolation boundaries.

An async function that never suspends may optimize differently from one whose
state must survive suspension. Do not infer an allocation or hop from the
presence of `async` or `await` alone.

Concurrency can reduce wall-clock latency while increasing total CPU, memory,
and energy. Define which outcome matters.

## Task granularity

Prefer one task around a meaningful asynchronous operation. Avoid creating one
task per trivial element when scheduling and result coordination approach or
exceed the useful work.

Estimate:

- useful work per item;
- task count at common and worst input sizes;
- maximum simultaneously active work;
- copied or retained input per task;
- actor hops or synchronization per result;
- cancellation latency;
- downstream resource limits such as network connections, file descriptors,
  database transactions, and memory.

Improve granularity by:

- processing a batch per child task;
- doing synchronous local work inside an existing task;
- coalescing actor updates;
- limiting in-flight work to a justified bound;
- returning one compact result instead of many cross-actor mutations.

Do not hard-code a concurrency count from CPU core count alone. Workload,
executor behavior, I/O limits, memory, energy, and older devices matter.

## Actor and executor crossings

An actor protects isolated state by serializing access. Each cross-actor call may
require an asynchronous job and can interleave at suspension points.

Look for:

- loops that `await` one actor property or method per element;
- “ping-pong” calls between two actors;
- tiny getters exposed as asynchronous boundaries;
- repeated `MainActor.run` calls for one logical UI update;
- work accidentally kept on the main actor because the surrounding type or
  caller is isolated;
- an actor used as a universal container when a local immutable value would do.

Prefer methods that perform one coherent isolated transaction or accept a batch.
Move pure CPU work out of an actor only when inputs can be captured safely and
the result returns through one controlled update.

Do not replace an actor with a lock, unsafe nonisolation, or a dispatch queue
solely to remove hops. That changes the correctness model and requires separate
contention and safety evidence.

Actor reentrancy is semantic, not just a performance detail. Batching must not
silently remove required cancellation, fairness, or intermediate observation.

## Structured parallelism

Use a task group when child work is genuinely independent, the parent owns the
lifetime, and completion or cancellation should be structured.

Guard against:

- adding every input to a group at once when each child retains substantial
  state;
- collecting all results before the caller can consume any;
- assuming result order when the API yields completion order;
- duplicating immutable input graphs in captures;
- swallowing child errors or cancellation;
- parallelizing a memory-bandwidth-bound loop until it runs slower.

For bounded concurrency, keep a deliberate number of children in flight and add
new work as earlier children complete. Test error and cancellation paths, not
only successful throughput.

Parallelism can be slower for small inputs. Keep a synchronous or batched fast
path when a measured crossover justifies it.

## Unstructured and detached tasks

Use `Task {}` when unstructured lifetime is the intended API boundary and the
owner stores or otherwise controls cancellation. Do not spawn it merely to make
a synchronous call “background.”

`Task.detached` changes context inheritance and isolation. It is not a generic
way to run faster or escape the main actor. Use it only when independent
unstructured lifetime and executor context are deliberate, and pass required
values safely.

Review long-lived tasks for retained feature state. Cancellation is cooperative:
the task and called APIs must observe it before captured state and resources can
be released.

## Continuations and streams

Continuation adapters should resume exactly once on every path. Their main
purpose is correctness at a callback boundary, not acceleration.

For high-frequency callback or `AsyncSequence` bridges:

- define buffering and drop policy;
- avoid one task or actor hop per tiny event when batching preserves semantics;
- terminate streams and release continuations at lifecycle end;
- propagate cancellation to the producer;
- measure retained buffer size and consumer lag.

Do not use an unbounded stream as a hidden queue.

## Main-actor work

The main actor protects UI-isolated state; it does not make work small. Keep UI
state transitions on it and move eligible pure CPU work only after defining a
safe value boundary.

When moving work:

1. capture the minimal immutable input;
2. perform the compute operation without touching UI-isolated state;
3. check cancellation at meaningful intervals;
4. return a compact result;
5. apply one current-state-validated UI update.

Avoid moving many tiny operations away from the main actor when scheduling and
copying cost more than the work. Do less work first.

## Measurement and review

Measure the complete operation, not only child-task duration:

- wall-clock latency and throughput;
- total CPU and peak concurrent CPU;
- task creation and active task counts;
- executor and actor intervals when the installed Instruments supports them;
- memory retained per in-flight unit;
- main-thread or main-actor responsiveness;
- cancellation completion time;
- energy or thermal effects for sustained work.

Use an optimized build and representative physical devices. Instruments features
vary by Xcode version; fall back to Time Profiler and System Trace rather than
inventing unavailable Swift Concurrency lanes.

Review questions:

- Is concurrency required for latency, responsiveness, or I/O overlap?
- Is each task large enough to amortize scheduling?
- Is in-flight work bounded by a real resource contract?
- Can actor operations be batched without changing semantics?
- Are values copied or retained across isolation longer than necessary?
- Are lifetime, error, ordering, priority, and cancellation preserved?
- Does the candidate improve the original metric without increasing memory or
  energy unacceptably?
