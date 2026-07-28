# Concurrency performance and memory

## Contents

- [Measure the right symptom](#measure-the-right-symptom)
- [Protect the cooperative executor](#protect-the-cooperative-executor)
- [Control task granularity](#control-task-granularity)
- [Reduce actor contention](#reduce-actor-contention)
- [Choose synchronization by contract](#choose-synchronization-by-contract)
- [Inspect task and stream memory](#inspect-task-and-stream-memory)
- [Profile, fix, and verify](#profile-fix-and-verify)

## Measure the right symptom

Separate:

- end-to-end latency;
- main-actor responsiveness;
- throughput;
- task creation and live-task count;
- actor and lock contention;
- cooperative-pool starvation;
- retained memory and peak memory;
- CPU and energy;
- network, database, filesystem, and service wait.

More asynchronous code is not automatically faster. Overlapping work can reduce
latency while increasing CPU, memory, energy, and downstream load.

Do not optimize from surface syntax. `async`, `await`, an actor call, or a task
does not alone prove an allocation, hop, suspension, or performance problem.

## Protect the cooperative executor

Reject blocking operations from executor jobs:

- `DispatchSemaphore.wait()`;
- `NSCondition` or equivalent condition waits;
- `Thread.sleep`;
- synchronous callback-to-async bridges;
- blocking file, socket, subprocess, or database I/O;
- long lock ownership;
- `DispatchQueue.sync` where queue or executor dependencies can cycle.

Use a native async API, move unavoidable blocking work to a bounded subsystem
designed for blocking, or retain an existing `OperationQueue`/GCD boundary with
an explicit capacity. `Task.detached` still uses Swift's cooperative executor
and does not make blocking work safe.

Investigate pool starvation when apparently unrelated tasks stop making
progress while a small set of jobs blocks.

## Control task granularity

Tasks are lightweight relative to threads, not free. Account for:

- task records and async frames;
- captured and copied inputs;
- scheduling and queue operations;
- suspension and resumption;
- task-group bookkeeping;
- cancellation checks;
- result storage;
- actor hops and downstream requests.

Batch trivial operations. Bound dynamic child tasks. Avoid starting one task per
pixel, row, tiny transform, or arbitrarily large collection item.

Select an in-flight limit from the narrowest real resource: server request
limits, connections, file descriptors, database transactions, memory, device
class, energy, or useful CPU work. Benchmark representative and worst-supported
input sizes.

`@concurrent` requests generic-executor execution where supported; it does not
guarantee simultaneous execution, a fresh thread, or a speedup. Measure the
actual workload.

## Reduce actor contention

An actor can become a serialization bottleneck when many tasks perform tiny
cross-actor operations or one job performs long synchronous work.

Consider:

- returning a value snapshot instead of many property reads;
- batching one coherent update;
- doing pure local computation before entering the actor;
- shortening synchronous actor work;
- partitioning truly independent state by key or owner;
- avoiding an actor hop for immutable values;
- preserving ordering while coalescing updates.

Do not shard an actor until measurement shows contention and the state invariants
can be split safely.

## Choose synchronization by contract

Use an actor for async-owned mutable state. Use a mutex for a small synchronous
critical state when callers cannot become async. Compare latency only after both
designs preserve the same semantics.

Never:

- hold a mutex across `await`;
- invoke unknown callbacks while holding a lock;
- mix multiple locks without a documented order;
- expose protected mutable storage;
- replace an actor with atomics because atomics appear lower-level or faster.

Use Swift Atomics only for specialized measured code whose memory-ordering
argument is documented and reviewable.

## Inspect task and stream memory

Look for:

- unbounded task groups and queues;
- task handles retained after completion;
- infinite tasks retained by their owner;
- closures holding large values across suspension;
- `AsyncStream` buffers without a bound;
- continuations never resumed;
- in-flight task caches that never evict failures;
- slices or response bodies retaining oversized backing storage;
- observers and delegates not removed on termination.

Track both allocation rate and live retained memory. A reduction in task count
can still increase peak memory if each task captures a larger batch.

For a long-lived loop, avoid strengthening a weak owner across the next
indefinite suspension. Retain the owner only while performing one finite unit of
work.

## Profile, fix, and verify

Use this loop for causal diagnosis, mechanism-sensitive tuning, and performance
claims. Do not let it block a source-proven, semantics-preserving correction:
apply that correction in Implement mode, run correctness and load checks, and
measure afterward when available.

For measurement-dependent work:

1. Reproduce the same scenario and record toolchain, device, build
   configuration, input, and environment.
2. Capture Time Profiler, Swift Tasks, hangs, allocations, memory graph, or
   another instrument that matches the symptom.
3. Isolate one causal mechanism such as main-actor work, actor contention,
   blocked pool threads, task fan-out, retained tasks, or a leaked continuation.
4. Make the smallest semantics-preserving change.
5. Repeat the same capture and compare primary and secondary metrics.
6. Run correctness, cancellation, ordering, and load tests.

Use an optimized production-like build for performance claims. Prefer a
representative older physical device for Apple-platform latency, memory, and
energy conclusions.

Report the raw before-and-after evidence, run-to-run variability, changed
semantics, and remaining uncertainty. Label an unmeasured performance effect as
pending or hypothetical; do not relabel the already implemented safe correction
as recommendation-only.
