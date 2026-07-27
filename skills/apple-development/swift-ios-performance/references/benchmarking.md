# Benchmarking Swift source changes

## Contents

- Define the contract
- Choose the evidence surface
- Build the harness
- Control compiler effects
- Control runtime effects
- Select metrics
- Compare results
- Add a regression guard
- Report honestly

## Define the contract

Write the benchmark contract before implementing an optimization:

- operation and start/stop boundary;
- exact input families, distributions, and sizes;
- common, high-percentile, and stress cases;
- cold or warm state;
- synchronous or concurrent execution context;
- metric, unit, direction, and aggregation;
- secondary memory, correctness, API, or energy guardrails;
- toolchain, optimization configuration, architecture, and device.

Benchmark the user-relevant operation, not a helper selected because it is easy
to time. Keep setup outside the measured interval unless setup is the cost under
investigation.

## Choose the evidence surface

### XCTest performance tests

Prefer Xcode and XCTest for iOS target code, framework integration, and
device-specific regression baselines. Select supported metrics such as clock,
CPU, memory, signpost, or hitch metrics according to the scenario and installed
SDK.

Use a real supported iPhone for device claims. Keep baselines scoped to a device
and configuration; do not compare simulator, Mac, and iPhone baselines as one
series.

### Focused package benchmark

Use a package benchmark for a pure portable algorithm when it can run in a
stable optimized executable with representative inputs. The Benchmark package
announced on Swift.org is a community package maintained outside the Swift
standard library and is strongest on its supported macOS and Linux surfaces. It
does not replace XCTest and Instruments for iOS-device behavior.

Pin the package version and record its configuration. Do not copy current API
syntax into a long-lived rule without checking that version's documentation.

### Instruments

Use Time Profiler or Allocations when the question is call path, call frequency,
ARC, or allocation behavior rather than only elapsed time. Use points of
interest to isolate the operation when practical.

Use Processor Trace or CPU Counters only when supported hardware and the
residual question require instruction flow, cache, or pipeline analysis. These
newer hardware-assisted tools may not run on the older iPhone that motivated the
optimization.

### App scenario

Use `app-performance` for launch, scrolling, responsiveness, field memory,
energy, or other end-to-end claims. A function benchmark can explain a mechanism
but cannot prove the app outcome.

## Build the harness

Keep baseline and candidate interchangeable:

- expose one operation signature;
- generate or load inputs identically;
- validate identical outputs;
- keep allocation and setup boundaries explicit;
- make cache state deterministic;
- keep concurrency count and executor context fixed;
- include realistic success, miss, duplicate, Unicode, and error paths;
- avoid network, filesystem, logging, randomness, and UI work unless they are
  intentionally part of the contract.

Use input sizes large enough to rise above timer and scheduler noise, but not so
large that the benchmark measures thermal throttling unless sustained behavior
is the target.

Run a warmup when measuring warm steady-state behavior. Preserve first-use
initialization when cold behavior is the target. Do not mix both in one result.

## Control compiler effects

Compile the benchmark with the same Swift version, optimization level, module
visibility, conditional flags, architecture, and library-evolution setting as
the target when possible.

Prevent invalid measurements:

- consume and validate results so the optimizer cannot delete the operation;
- vary inputs enough to prevent constant folding of the complete benchmark;
- keep baseline and candidate equally visible to the optimizer;
- avoid including assertion, logging, or result-printing work in the interval;
- do not benchmark an `@inline(never)` or other artificial boundary unless that
  boundary exists in production or is explicitly part of the experiment;
- inspect generated code only when an implausibly tiny result suggests
  elimination or when generated instructions are the question.

Avoid changing the implementation solely to defeat the benchmark harness. Fix
the harness.

## Control runtime effects

For each series:

- use the same device and OS;
- use one production-like build;
- keep thermal state, Low Power Mode, power source, and competing workloads
  stable when relevant;
- reset data and cache state consistently;
- run enough repetitions to observe spread;
- retain every valid run and predefine invalid-run criteria;
- interleave baseline and candidate or repeat the baseline if environment drift
  is likely;
- keep instrumentation identical between compared captures.

Do not cherry-pick the fastest run. A single number hides warmup, scheduling,
allocation, and thermal variation.

For sustained concurrent work, monitor total CPU, memory, and thermals in
addition to wall-clock time. More parallel work can appear faster briefly while
using more energy and throttling later.

## Select metrics

Match the metric to the mechanism:

- **wall-clock duration** for user-visible completion latency;
- **CPU time** for compute work and energy-related hypotheses;
- **throughput** for repeated parsing, mapping, search, or serialization;
- **allocation count and allocated bytes** for temporary-storage changes;
- **peak and resting memory** for footprint and retained-lifetime changes;
- **call or task count** for repeated dispatch and scheduling;
- **binary size** when specialization or inlining may duplicate code;
- **cancellation latency** for long-running concurrent operations.

Track at least one correctness result. Faster incorrect output is not a valid
sample.

Use a secondary metric when cost may move:

- capacity reuse can reduce allocations but raise retained memory;
- caching can reduce CPU but raise footprint and staleness;
- generics can improve specialization but increase code size;
- concurrency can reduce latency but raise CPU and energy;
- unsafe access can reduce checks but increase correctness and security risk.

## Compare results

Report:

- count of valid runs;
- median and a useful spread such as minimum/maximum or percentiles;
- absolute and relative difference with units;
- whether the difference exceeds normal variability;
- result for each representative input family;
- secondary metrics and any regression;
- profiling or generated-code evidence that connects the change to the result.

Do not apply a statistical test mechanically to dependent or environmentally
drifting samples. The benchmark design and effect magnitude matter more than a
decorative p-value.

Reject or narrow a claim when:

- only one input favors the candidate;
- the effect disappears in the target module or device;
- setup dominates the interval;
- the candidate changes output or ordering;
- memory, energy, binary size, or API cost is unacceptable;
- the difference is smaller than ordinary variance.

## Add a regression guard

Add a persistent performance test only when:

- the operation is important and deterministic;
- the environment and input can be reproduced;
- expected variance is understood;
- baseline ownership and update policy are documented;
- the test is fast and stable enough for its intended suite.

Keep benchmarks that require special hardware, long thermals, or manual
Instruments analysis as a documented investigation procedure rather than a
flaky blocking test.

Set or update an XCTest baseline only after reviewing the complete distribution.
An environment or toolchain upgrade is a reason to re-establish evidence, not to
silently accept every regression.

## Report honestly

Use bounded language:

- “The candidate reduced median allocations in this optimized parser benchmark.”
- “The cost model suggests avoiding one materialized intermediate; no benchmark
  was available.”
- “The function improved, but the app-level impact was not measured.”

Include the benchmark source, command or scheme, device, OS, toolchain,
configuration, input, run count, raw or summarized results, correctness checks,
and unresolved limitations. Never claim an older-device improvement from a Mac
or simulator-only benchmark.
