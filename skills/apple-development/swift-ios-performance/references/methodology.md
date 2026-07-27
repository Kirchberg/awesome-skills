# Swift source-performance methodology

## Contents

- Scope and neighboring skills
- Context inventory
- Source-research mode
- Review workflow
- Finding standard
- Change sequence
- Completion record

## Scope and neighboring skills

Treat source performance as the cost of a concrete operation under a concrete
toolchain and workload. A Swift construct does not have one universal cost:
optimization mode, module visibility, concrete types, ownership, data scale,
bridging, and call context can change the generated work.

Use this skill for code-level questions and known hot paths. Route by the
starting evidence:

- Use `app-performance` first for an app symptom or resource regression that
  still needs profiling. Return here when the trace identifies Swift-owned work.
- Use `swiftui-optimization` for view invalidation, Observation, identity, lists,
  layout, and animation. Repeated pure-Swift work discovered inside an update can
  then receive a source-level review here.
- Use `swift-concurrency` for isolation, task lifetime, cancellation, target
  inventory, language-mode changes, and concurrency-safety migration. Keep
  performance tuning a separately measured concern.

Do not change code for a research, explanation, or review-only request. Do not
commit, push, publish traces, or upload symbols unless the user authorizes it.

## Context inventory

Record only facts that can affect the decision:

- Swift and Xcode versions, language mode, SDK, deployment target, and
  architectures;
- module and package boundaries, public API or binary-compatibility constraints,
  and whether library evolution is enabled;
- Release optimization level and compilation mode;
- operation boundary, caller, executor or thread, and repetition count;
- representative and worst-supported input distributions and sizes;
- value lifetimes, ownership, mutation, sharing, bridging, and cache state;
- supported older device class when iOS behavior is part of the claim;
- correctness, ordering, isolation, cancellation, memory, latency, and API
  invariants that a change must preserve.

Inspect the repository's real build configuration. Do not silently enable whole
module optimization, change `-Osize` to `-O`, expose an implementation with
`@inlinable`, or raise a deployment target to make an optimization compile.

## Source-research mode

Start with `ranked-sources.md`, then refresh links or claims that are
version-sensitive. Prefer sources in this order:

1. current Apple documentation and WWDC sessions;
2. the Swift language book, Swift.org, Swift Evolution, and Swift project docs;
3. Swift Forums posts from compiler or standard-library contributors for a
   narrow question;
4. measured production case studies;
5. secondary tutorials as examples, never as the sole authority for runtime
   behavior.

Score practical value from 0 to 100:

- **Authority, 0–30**: proximity to the language, compiler, runtime, standard
  library, or Apple platform behavior.
- **Applicability, 0–25**: usefulness for ordinary iOS source review and older
  supported devices.
- **Explanatory depth, 0–20**: whether the source explains the causal mechanism,
  not just a rule.
- **Actionability, 0–15**: whether it helps choose, measure, or validate a change.
- **Currency, 0–10**: whether APIs, optimizer assumptions, and tooling remain
  current.

An old source can still score highly when its mental model remains foundational.
Mark it as foundational and recheck concrete advice against the current
toolchain. Do not score multiple mirrors or summaries as separate sources.

For each listed source, include:

- title and direct URL;
- score and topic;
- why it matters;
- version or authority caveat;
- whether it is normative, explanatory, or a hypothesis source.

## Review workflow

### 1. Establish a plausible hot path

Accept any of:

- a symbolicated profile or allocation path;
- a focused benchmark regression;
- a call site whose scale and frequency make the cost material;
- a preventive review of a bounded parser, mapper, search, sort, serializer, or
  other data-processing path.

Do not require a prior production incident for preventive review. Do require a
scale argument before proposing invasive optimization.

### 2. Trace the complete operation

Follow values from input to final consumer. Account for:

- number of passes and asymptotic complexity;
- materialized intermediate collections and temporary strings or buffers;
- allocation, growth, bridging, and conversion boundaries;
- value copies, copy-on-write uniqueness, and reference-count traffic;
- closures, captures, existential containers, witness calls, and dispatch;
- task creation, actor crossings, suspension, and synchronization;
- lifetime extension caused by caches, type properties, slices, tasks, or
  closures.

Search for callers and consumers before changing a declaration. A local generic
rewrite, ownership change, or new cache can move cost across a module boundary
or extend memory lifetime.

### 3. Rank mechanisms before syntax

Prefer this order:

1. eliminate work or reduce data volume;
2. improve algorithmic complexity;
3. choose a better data structure or representation;
4. fuse passes or avoid unnecessary materialization;
5. reduce allocation, copying, ARC, bridging, or lifetime;
6. reduce scheduling or synchronization overhead;
7. improve specialization or dispatch in a proven residual hot path;
8. use fixed storage, unsafe access, SIMD, or Accelerate.

Do not let a simple search hit outrank a measured mechanism. A computed property
in cold setup is less important than one avoidable sort per keystroke.

## Finding standard

For every actionable finding, provide:

- source location and the exact operation;
- production trigger, data scale, and frequency;
- current cost mechanism;
- impact and confidence as separate judgments;
- smallest semantics-preserving correction;
- API, memory, concurrency, readability, and maintenance tradeoffs;
- evidence already available and the next validating measurement;
- focused correctness checks.

When a numeric priority is useful, score expected practical impact:

- **90–100**: measured dominant work or an algorithmic defect on a critical path;
- **70–89**: repeated allocation, copy, bridge, or scheduling cost with strong
  scale evidence;
- **40–69**: plausible local improvement that still needs a benchmark;
- **1–39**: minor or highly conditional cost; normally document, do not change;
- **0**: unsupported folklore, duplicate advice, or no relevant cost.

This is a prioritization aid, not a speedup forecast. Never map a score directly
to a percentage improvement.

## Change sequence

1. Preserve a reproducible baseline and functional tests.
2. State one falsifiable mechanism.
3. Make one coherent change.
4. Rebuild with the same production optimization settings.
5. Run focused correctness tests.
6. Repeat the same benchmark or capture.
7. Inspect secondary costs such as peak memory, binary size, energy, latency,
   synchronization, and retained lifetime.
8. Keep the change only if evidence or a clear complexity proof justifies its
   tradeoffs.

For public APIs, module boundaries, concurrency semantics, and unsafe code,
require stronger evidence than for a private loop or capacity hint.

## Completion record

Report:

1. selected mode and scope;
2. toolchain, build mode, device if applicable, and workload;
3. supported cost mechanism and rejected folklore;
4. ranked findings or ranked sources;
5. changed files and preserved invariants, if edits were requested;
6. baseline and candidate distributions with units, if measured;
7. functional and performance checks;
8. memory, API, safety, concurrency, and maintenance tradeoffs;
9. missing evidence and the next discriminating measurement.

Use “supported by the cost model” for an unmeasured recommendation, “improved in
this benchmark” for a focused result, and “improved in this app scenario” only
after a matched app-level comparison. Do not collapse those claims.
