---
name: swift-ios-performance
description: Use when researching, writing, reviewing, refactoring, or benchmarking performance-sensitive Swift source in an iOS or iPadOS app, especially algorithms and data structures, allocations and ARC, value copying and copy-on-write, stored or computed static properties, closures, dispatch and specialization, generics and existentials, String or Data processing, Swift concurrency overhead, or safe low-level APIs. Trigger for questions about the runtime or memory cost of a concrete Swift construct, source-level performance reviews, reducing allocations or copies in a known hot path, or focused microbenchmarks. Do not use as the lead skill for whole-app profiling, launch, hangs, hitches, memory pressure, energy, storage, network, graphics, app size, SwiftUI state or updates, or a general Swift 6 migration; use app-performance, swiftui-optimization, or swift6-migration respectively.
---

# Optimize Swift code for iOS performance

## Outcome

Turn a Swift cost question or known hot path into a semantics-preserving
recommendation, focused change, or benchmark with an explicit runtime mechanism
and evidence proportionate to the claim.

Prefer the largest reliable gain. Remove unnecessary work before tuning ARC,
dispatch, bounds checks, or generated instructions.

## Read references selectively

- Read `references/methodology.md` before researching sources, reviewing a hot
  path, planning a change, or assigning a priority score.
- Read `references/cost-model-and-compiler.md` for allocation, stack versus heap,
  stored versus computed type properties, dispatch, generics, existentials,
  closures, exclusivity, specialization, and build optimization.
- Read `references/ownership-and-memory.md` for struct versus class decisions,
  ARC, weak or unowned references, copy-on-write, slices, captures, bridging, or
  long-lived shared storage.
- Read `references/collections-algorithms-and-text.md` for algorithmic
  complexity, capacity, collection choice, lazy pipelines, `String`, `Substring`,
  `Data`, parsing, mapping, or formatter reuse.
- Read `references/concurrency-costs.md` for task granularity, actor hops,
  executor scheduling, continuations, task groups, or bounded parallelism.
- Read `references/benchmarking.md` before writing a benchmark or claiming a
  CPU, allocation, memory, latency, or throughput improvement.
- Read `references/low-level-and-accelerated.md` only for a measured hot path
  that may justify `InlineArray`, `Span`, unsafe buffers, SIMD, or Accelerate.
- Read `references/ranked-sources.md` for a source-research request or when a
  recommendation is disputed, version-sensitive, or compiler-dependent.

Repository instructions, supported toolchains, deployment targets, and explicit
user scope override generic examples. They never weaken correctness, memory
safety, or evidence gates.

## Route the request

- Lead with `$app-performance` when the starting point is a whole-app symptom,
  field regression, launch, hang, hitch, memory pressure, energy, storage,
  networking, graphics, or app size. Apply this skill after evidence identifies
  a Swift hot path.
- Lead with `$swiftui-optimization` for SwiftUI dependencies, Observation,
  identity, view updates, lists, layout, or animation.
- Lead with `$swift6-migration` for a staged language-mode or strict-concurrency
  migration. Use this skill only for a distinct performance question.
- Keep this skill in the lead when the user names a concrete Swift construct,
  algorithm, data pipeline, source area, or focused benchmark.

## Classify the work

Choose one mode and respect its authority:

- **Research**: rank useful sources and synthesize supported guidance; do not edit
  project code.
- **Explain**: describe the cost model, uncertainty, and conditions under which a
  difference can matter.
- **Review**: inspect source and report prioritized findings; do not implement
  fixes unless requested.
- **Improve**: make the smallest justified source change and validate it.
- **Benchmark**: build or refine a focused harness and report its bounded result.

Do not turn a narrow question into a project-wide optimization campaign.

## Establish the context

1. Read repository instructions and inspect version-control status.
2. Record the Xcode and Swift toolchain, optimization configuration, deployment
   targets, module boundaries, and supported devices.
3. Identify the exact operation, input distribution and size, call frequency,
   lifetime, concurrency context, and correctness invariants.
4. For a known symptom, preserve its scenario and existing trace evidence. For a
   preventive review, identify why the code is plausibly hot at production scale.
5. Define the metric or evidence needed before changing public APIs, ownership,
   data representation, synchronization, or safety.

Treat Debug behavior and unoptimized SIL as diagnostic context, not production
performance evidence.

## Inspect costs in order

1. Remove unused work, repeated passes, redundant decoding, and avoidable I/O.
2. Choose an algorithm and data structure with suitable complexity and locality.
3. Reduce repeated materialization, allocation, bridging, and oversized
   lifetimes.
4. Inspect value copies, copy-on-write uniqueness, ARC traffic, and captures.
5. Reduce overly fine tasks, actor hops, synchronization, and executor handoffs.
6. Examine dynamic dispatch or specialization only when it remains material.
7. Escalate to fixed-size storage, unsafe access, SIMD, or Accelerate last.

For every finding, report the source location, triggering workload, cost
mechanism, expected scale, safe correction, validation method, and tradeoffs.
Separate impact from confidence; do not manufacture precision from syntax alone.

## Apply Swift-specific decisions

- Distinguish stored `static let`, stored `static var`, and computed
  `static var`. Stored type properties initialize lazily once; `let` expresses
  immutability, not a guaranteed smaller or faster representation. A computed
  getter may repeat work, while either stored form may retain its value for the
  process lifetime. Isolate mutable shared state correctly.
- Choose `struct`, `enum`, or `class` for semantics and lifetime first. A value
  can contain heap storage and copy expensively; a reference can create ARC and
  locality costs. Inspect the complete representation.
- Preserve copy-on-write uniqueness where mutation is intended. Do not keep a
  tiny `ArraySlice` or `Substring` alive when retaining the full backing storage
  is materially worse than copying the needed result.
- Use `reserveCapacity` when a useful final-size estimate is known. Do not call
  it before every small growth step or assume that preserving capacity always
  wins under memory pressure.
- Select `Deque`, `Set`, `Dictionary`, or another collection from the operations
  required. Do not replace `Array` by fashion.
- Use lazy algorithms when they avoid work or intermediate storage. Full
  consumption, retained bases, and type-erasure boundaries can erase the gain.
- Treat `weak` and `unowned` as ownership and safety choices, not generic
  performance switches.
- Batch useful concurrent work while preserving isolation, cancellation,
  ordering, priority, and error behavior.

## Guard against folklore

- Do not claim that `static let` is inherently faster than `static var`, structs
  are always faster than classes, generics always beat existentials, or
  `ContiguousArray`, `lazy`, `final`, actors, and caching are universal fixes.
- Do not infer heap allocation, copying, specialization, or dispatch solely from
  surface syntax; optimizer and module context matter.
- Do not add `@inline(__always)`, underscored attributes, unchecked access,
  unmanaged references, or unsafe pointers without measured need and a safety
  argument.
- Do not extrapolate one microbenchmark to launch, scrolling, memory pressure, or
  battery impact. Hand those claims to `$app-performance`.
- Do not trade correctness, thread safety, API compatibility, or maintainability
  for an unmeasured theoretical win.

## Verify and report

For changed code, run repository formatting, static analysis, focused tests, and
a production-configuration build for affected targets.

For a performance claim, compare baseline and candidate with the same optimized
build, workload, environment, and metric. Prefer a representative older physical
device when the claim concerns iOS behavior. Report all valid runs or their
distribution, relevant allocation or memory effects, and secondary regressions.

For source research, rank the most useful sources from 0 to 100 using
authority, applicability, explanatory depth, currency, and actionability. Group
by topic, explain version-sensitive caveats, and prefer primary sources.

Finish with the selected mode, scope, supported mechanism, changed files if any,
checks run, before-and-after evidence if collected, tradeoffs, and remaining
uncertainty. Label an unmeasured recommendation as a hypothesis, never as a
verified improvement.
