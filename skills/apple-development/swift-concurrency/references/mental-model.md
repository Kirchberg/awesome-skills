# Swift concurrency mental model

## Contents

- [Separate suspension from parallelism](#separate-suspension-from-parallelism)
- [Reason in tasks, jobs, and executors](#reason-in-tasks-jobs-and-executors)
- [Apply Swift 6.2 and later semantics](#apply-swift-62-and-later-semantics)
- [Treat actors as isolation domains](#treat-actors-as-isolation-domains)
- [Trace one operation](#trace-one-operation)
- [Reject misleading shortcuts](#reject-misleading-shortcuts)

## Separate suspension from parallelism

Use these terms precisely:

- **Asynchronous** code can suspend without blocking its executing thread.
- **Concurrent** operations can make progress during overlapping lifetimes.
- **Parallel** work executes simultaneously on available compute resources.

An `async` function may run entirely serially. An `await` marks a possible
suspension and interleaving point; it does not promise a thread switch, actor
hop, allocation, or parallel execution.

Start from sequential code. Introduce overlapping work only when operations are
independent and latency, throughput, or responsiveness justifies the additional
lifetime, cancellation, ordering, and resource contracts.

## Reason in tasks, jobs, and executors

A task owns an asynchronous computation and its task-local context, priority,
cancellation state, and async frames. The runtime splits executable work into
jobs and schedules those jobs on executors.

An executor decides where eligible jobs run. A serial executor, including an
actor executor, runs at most one of its jobs at a time. The global concurrent
executor uses a cooperative thread pool. Tasks are not permanently bound to one
thread, and suspension returns the thread for other work.

Code running on the cooperative executor must cooperate:

- suspend for asynchronous waiting;
- keep synchronous work finite;
- avoid blocking I/O and waits;
- avoid assuming one task requires or owns one operating-system thread.

Thread explosion is not a fallback for blocked cooperative tasks. Blocking
enough pool threads can starve unrelated work or deadlock an application.

## Apply Swift 6.2 and later semantics

Detect the selected compiler, language mode, default actor isolation, and
enabled upcoming features before asserting executor behavior.

When the approachable-concurrency options introduced in Swift 6.2 are enabled:

- the `NonisolatedNonsendingByDefault` semantics make ordinary nonisolated
  async functions run in the caller's isolation context instead of
  automatically moving to the generic executor;
- `@concurrent` explicitly switches actor-isolated work to the generic
  executor, without promising a new thread or simultaneous execution;
- a module can opt into default `MainActor` isolation; an unspecified module
  remains nonisolated by default;
- sequential execution is the approachable default, while parallel execution
  is an explicit design choice.

Do not add `@concurrent` merely to “get off the main thread.” First determine
whether the function performs CPU-bound work, asynchronous I/O, or a short
synchronous transformation. Native asynchronous I/O suspends and usually does
not need parallel compute execution.

Treat Swift 6.3 as the detected current language/toolchain generation, not as a
reason to ignore Swift 6.2 semantics. Guard APIs and attributes whose
availability differs across supported toolchains.

## Treat actors as isolation domains

An actor serializes access to its isolated state. It does not make a multi-step
operation atomic across suspension.

When an actor method reaches `await`:

1. its current job can suspend;
2. another job may enter the actor;
3. isolated state may change;
4. the original job may resume with stale assumptions.

Prevent data races with isolation. Prevent logical races with state machines,
generation tokens, single-flight work, transactions, or post-suspension
validation.

Treat a global actor as an isolation contract shared by declarations. Use
`MainActor` to express UI and main-executor ownership. Reason about that actor
contract rather than scattering `Thread.isMainThread` or
`DispatchQueue.main.async` checks.

## Trace one operation

For each asynchronous operation, draw or describe:

1. the synchronous entry point and its isolation;
2. every child and unstructured task creation;
3. every value crossing an isolation boundary;
4. every suspension and possible interleaving point;
5. the executor required for each synchronous segment;
6. how results, errors, priority, task-local values, and cancellation travel;
7. who owns completion and resource cleanup.

Use this trace to distinguish an actual race or hop from a guessed one.

## Reject misleading shortcuts

Reject these claims without evidence:

- “`async` means background.”
- “Every `await` changes threads.”
- “Actor code cannot have races.”
- “`MainActor` means annotate all UI-related code.”
- “A detached task makes blocking work safe.”
- “Tasks are cheap enough to create without a bound.”
- “Compilation proves cancellation, ordering, and lifetime correctness.”

Use the canonical sources and applicability notes in `sources.md` when a claim
depends on a particular compiler, proposal, SDK, or WWDC-era model.
