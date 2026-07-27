# Structured concurrency, cancellation, and task lifetime

## Contents

- [Select the narrowest structure](#select-the-narrowest-structure)
- [Preserve the task tree](#preserve-the-task-tree)
- [Bound dynamic fan-out](#bound-dynamic-fan-out)
- [Design cooperative cancellation](#design-cooperative-cancellation)
- [Own unstructured tasks](#own-unstructured-tasks)
- [Control priority and task-local context](#control-priority-and-task-local-context)
- [Review lifetime and memory](#review-lifetime-and-memory)

## Select the narrowest structure

Choose in this order:

1. Use sequential `await` when an operation depends on the preceding result, the
   work is cheap, or overlapping it would violate a resource constraint.
2. Use `async let` for a small, fixed number of independent child operations.
3. Use a throwing or nonthrowing task group for a dynamic number of scoped child
   operations.
4. Use `Task {}` only when work must outlive the current structured scope or
   begin from a synchronous lifecycle boundary.
5. Use `Task.detached` only when losing actor inheritance, task-local values,
   and inherited priority is intentional.

Keep result ordering explicit. Task groups deliver completed child results in
completion order, not input order. Carry an input index or stable identifier
when the caller requires original order.

## Preserve the task tree

Structured child tasks remain inside their lexical scope. The parent does not
finish the scope until all children finish. Child errors, cancellation, and
priority participate in the structured relationship.

Prefer this structure because it makes these properties reviewable:

- no child silently outlives the operation;
- cancellation can propagate from the parent;
- thrown errors leave the group through one visible boundary;
- child resources are joined before scope exit;
- task-local context and priority follow structured rules.

Child cancellation remains cooperative. A child that blocks or ignores
cancellation can delay scope exit even after another child fails.

## Bound dynamic fan-out

Do not call `addTask` once for every element of an arbitrarily large collection
without a bound. A group can accumulate task records, captures, async frames,
results, sockets, requests, database work, and downstream pressure even when
the executor limits simultaneous CPU execution.

Use a sliding window:

1. Choose an initial in-flight limit from the downstream resource contract and
   a representative workload, not only CPU count.
2. Add at most that many children.
3. Consume one completed result.
4. Add one replacement child.
5. Stop adding work immediately after cancellation or the first terminal error.
6. Preserve input order separately if required.

Use batching when per-item work is too small relative to scheduling overhead.
Use an async channel or another producer-consumer design when the producer must
wait for consumer capacity. Re-measure the bound on older supported devices and
under realistic memory and service limits.

## Design cooperative cancellation

Define cancellation as part of the API contract:

- identify who initiates it;
- decide whether partial results are allowed;
- state whether cancellation throws `CancellationError`, returns a partial
  value, or becomes another domain result;
- propagate it to child tasks and underlying legacy operations;
- release resources and terminate streams.

Call `Task.checkCancellation()` in long CPU loops or between batches that have
no natural throwing suspension point. Use `Task.isCancelled` only when the code
must perform custom nonthrowing cleanup or return a partial value.

Use `withTaskCancellationHandler` when a task must signal cancellation to an
underlying operation. Keep `onCancel` synchronous, thread-safe, idempotent, and
safe to run concurrently with operation setup. Protect a cancel-before-start
race explicitly.

Use `Task.sleep` rather than thread sleep. Treat cancellation from sleep as
cancellation, not as an unexpected operational failure.

Do not swallow `CancellationError` in a broad `catch` unless the API deliberately
translates cancellation and preserves its meaning.

## Own unstructured tasks

`Task {}` creates an unstructured task, not a structured child. It can inherit
the current priority, task-local values, and actor context, but its lifetime and
cancellation are not automatically scoped to the creating function.

For every unstructured task:

- name the lifecycle boundary that requires it;
- store its handle when it can outlive the immediate call;
- define which owner cancels and clears the handle;
- define whether a replacement cancels earlier work;
- define how errors are observed;
- ensure teardown does not wait synchronously for async completion.

Do not discard a throwing task handle. An unobserved error is usually a missing
lifecycle or reporting contract.

Use `Task.detached` only for work that must not inherit the current actor or
task context. Pass all required `Sendable` inputs explicitly. Do not use it to
make synchronous blocking APIs safe or to bypass an isolation diagnostic.

## Control priority and task-local context

Treat priority as a scheduling hint, not an ordering guarantee or QoS lock.
Avoid arbitrary priority escalation. Prefer inheritance through structured
tasks and verify that high-priority work does not wait on avoidably lower-
priority unstructured work.

Use task-local values for scoped metadata such as trace IDs, not as mutable
dependency storage. Expect structured tasks to inherit them. Detached tasks do
not.

## Review lifetime and memory

Task closures retain their captures while those captures are needed across
suspension. Long-lived tasks, infinite loops, and streams can therefore retain
entire object graphs.

Check:

- whether the task handle is retained by the same object captured by the task;
- whether `[weak self]` is strengthened for the whole loop or across an
  indefinite suspension;
- whether a stream or notification source can finish;
- whether cancellation unblocks the next suspension;
- whether completed task handles and cached results are cleared;
- whether each child captures only its own bounded input.

Prefer finite task scopes and value snapshots. For long-lived loops, strengthen
weak references only for the smallest synchronous unit of work.
