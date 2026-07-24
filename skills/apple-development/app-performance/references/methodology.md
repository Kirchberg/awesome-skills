# Performance investigation methodology

## Contents

- Scope and authority
- Performance contract
- Scenario design
- Measurement hygiene
- Field-to-lab workflow
- Root-cause standard
- Change and comparison rules
- Regression prevention
- Completion record

## Scope and authority

Treat performance as a property of a scenario on a particular system, not as a
property of a function in isolation.

Classify the task before acting:

- A plan request authorizes analysis and a proposed measurement strategy, not
  source edits.
- A diagnosis request authorizes read-only investigation and measurement, not a
  fix unless the request also asks to resolve the issue.
- An improvement request authorizes changes within the named feature and the
  validation needed to prove them.
- A regression-prevention request authorizes the smallest test or monitoring
  surface that protects the agreed behavior.

Do not commit, push, publish traces, upload symbols, or distribute a build unless
the user explicitly authorizes that action.

## Performance contract

Write the contract before collecting candidate measurements.

### Scenario

Record:

- a human-readable journey, such as “tap Search, enter a term, and show the
  first complete result page”;
- the exact measurement start and stop;
- setup state, data volume, cache state, permissions, authentication, and
  connectivity;
- foreground, background, suspended, launch, resume, or continuous-animation
  state;
- whether the scenario represents common use, a high-percentile case, or an
  intentional stress case.

Use separate contracts when states change the workload materially. Cold launch,
warm launch, and resume are not interchangeable. Neither are an empty database
and a mature user data set.

### Environment

Record:

- physical device model and relevant hardware generation;
- OS and Xcode/Instruments versions;
- app version or revision, scheme, configuration, compiler optimization, and
  architecture;
- thermal state, Low Power Mode, battery or external-power state, and competing
  workloads when relevant;
- network path and conditions for network-dependent scenarios;
- display refresh behavior, window or scene configuration, and visual fidelity
  for graphics work;
- symbols used to resolve a distribution trace.

Keep Debug and Release-like results in separate series. Keep Simulator and
physical-device results separate.

### Metric and target

Define:

- metric name, unit, and direction of improvement;
- statistic or distribution: median, 90th percentile, peak, total, rate, or
  app-defined interval;
- target source: product requirement, Organizer goal, historical release,
  similar-app goal, device deadline, or explicit baseline;
- allowed variance and the comparison rule;
- secondary guardrail metrics that prevent moving cost elsewhere.

Examples of secondary guardrails include peak memory for a CPU optimization,
energy and freshness for network batching, launch readiness for time-to-first-
draw work, or image quality for a Metal change.

Do not create a universal target when Apple provides a contextual goal or when
the app’s workload defines the acceptable tradeoff.

## Scenario design

Prefer scenarios that are:

- representative of real user or system behavior;
- repeatable without manual timing;
- narrow enough to attribute a change;
- long enough to rise above instrumentation and scheduling noise;
- deterministic in input and observable output;
- safe to repeat without corrupting user data.

Cover the common case first, then the affected high-percentile or stress case.
For long-running visionOS, media, networking, location, or thermal work, include
a duration long enough to expose steady-state and throttled behavior.

Use feature-on versus feature-off comparisons only when both paths perform the
same user-visible job. An idle path is not a valid baseline for a path that
produces results.

## Measurement hygiene

1. Build once for a baseline series when practical. Avoid including compilation,
   installation, or first-time setup in an interval unless that is the scenario.
2. Warm up code paths only when the contract is for a warm state. Preserve the
   cold state when measuring cold behavior.
3. Run enough repetitions to see normal spread. Record every valid run and the
   rule used to reject invalid runs.
4. Do not cherry-pick the best baseline and best candidate.
5. Change one causal mechanism at a time, or describe a multi-file change as one
   coherent mechanism.
6. Re-run baseline and candidate under matched conditions. When environmental
   drift is likely, interleave them or repeat the baseline after the candidate.
7. Retain the trace, test result, Organizer view, or MetricKit payload identifier
   needed to audit the claim without storing private user data.
8. Re-run relevant functional tests. Faster incorrect work is a regression.

Instrumentation has overhead. Use the narrowest set of instruments that answers
the question, and avoid comparing captures produced with materially different
instrument sets.

## Field-to-lab workflow

### Start from field evidence

For App Store releases:

1. Open Organizer Insights and the relevant metric or diagnostic page.
2. Identify the affected app version, device family, percentile, and signature.
3. Compare with the previous release, historical goal, and similar-app goal when
   Xcode provides them.
4. Account for margin of error and insufficient sample size.
5. Prioritize by user impact and app purpose, not by the largest raw number.
6. Use the signature, backtrace, or workload clue to design a local scenario.

MetricKit can add daily histogram and diagnostic data to an app-controlled
pipeline. Preserve histogram semantics; do not turn bucketed population data
into a false exact average.

### Reproduce in the lab

1. Match an affected device and state as closely as possible.
2. Use a production-like build and retain its dSYM.
3. Reproduce the user journey without profiling first.
4. Add a point-of-interest interval when the system’s boundary does not match
   user-perceived readiness.
5. Capture only the relevant interval with the tool selected in
   `tools-and-evidence.md`.
6. Confirm that the local trace exhibits the same symptom class as the field
   report.

If local reproduction fails, keep field evidence and the local experiment
separate. Do not declare the signature fixed because a synthetic case improved.

## Root-cause standard

A supported root cause connects all of the following:

- the missed contract or field regression;
- the exact timeline interval;
- thread, process, CPU, GPU, I/O, network, or memory state in that interval;
- a symbolicated call path, allocation path, resource lifetime, request, or
  system diagnostic;
- a mechanism explaining why that state produces the symptom.

“This function is near the top of Time Profiler” is not enough. Determine:

- self cost versus cost in descendants;
- call frequency versus per-call duration;
- wall-clock duration versus active CPU time;
- running versus runnable, blocked, suspended, preempted, or waiting state;
- app-process work versus render-server, network, storage, or framework work;
- one-off initialization versus steady-state behavior.

Write the hypothesis so a new capture can falsify it. Example: “Repeated image
decoding on the main actor consumes the commit interval; downsampling before UI
handoff should reduce main-thread active time without increasing peak memory.”

## Change and comparison rules

Prefer this order:

1. Remove unnecessary work.
2. Reduce frequency, data volume, or invalidations.
3. Use an appropriate system API or representation.
4. Batch or defer work within the product’s freshness and lifecycle contract.
5. Move eligible work off a constrained executor.
6. Optimize algorithms and data locality.
7. Apply microarchitectural tuning only after higher-level waste is removed.

When moving work:

- preserve actor isolation, thread affinity, ordering, cancellation, priority,
  lifetime, and error handling;
- prove that the work actually executes away from the constrained executor;
- include scheduling, copying, synchronization, and context-switch overhead;
- return only the minimal UI update to the main actor or main thread.

When caching or batching, measure memory, storage, energy, and staleness. When
lowering rendering or media fidelity, state the visible quality tradeoff.

Compare baseline and candidate in the same view or test where possible. Explain
whether a difference is larger than normal variability and whether it meets the
contract, not merely whether the number moved in the desired direction.

## Regression prevention

Add a guard only when the scenario is stable and meaningful.

- Use an XCTest clock, CPU, memory, storage, or signpost metric for a repeatable
  feature boundary.
- Use UI tests when the contract crosses UI interaction and rendering.
- Configure relevant runtime API checks as test failures when the team is ready
  to enforce them.
- Preserve field monitoring for effects that depend on diverse devices,
  long-lived state, thermals, or real networks.
- Keep baselines scoped by device class, configuration, and scenario; update a
  baseline only with an explained product or environment change.

A test that measures setup noise, a mocked no-op, or a different user outcome
does not protect the original regression.

## Completion record

Report:

1. request mode and scope;
2. contract and environment;
3. field evidence, sample limitations, and reproduction status;
4. baseline series and variability;
5. trace type, interval, and root-cause chain;
6. implemented mechanism, if authorized;
7. candidate series and secondary guardrails;
8. functional checks and regression prevention;
9. tradeoffs, unavailable tools, platform constraints, unresolved hypotheses,
   and the next measured bottleneck.

Use “improved in this scenario” when that is all the evidence proves. Reserve
“fixed” for the original contract and affected population after the relevant
validation succeeds.
