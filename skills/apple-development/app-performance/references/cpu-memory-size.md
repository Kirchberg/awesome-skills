# CPU, memory, and app size

## Contents

- CPU investigation ladder
- Time profiles and call trees
- CPU bottlenecks
- Processor Trace
- Memory investigation ladder
- Memory remedies
- Low-memory handling
- Memory regression tests
- App-size measurement
- App-size optimization

## CPU investigation ladder

Use the cheapest question that can identify the cause:

1. Confirm the exact scenario misses a latency, throughput, CPU, energy, or frame
   goal.
2. Use Time Profiler to find the process, thread, interval, and app-owned call
   path.
3. Remove redundant work, inefficient algorithms, excessive allocation, and
   needless repetition.
4. Use CPU Counters when instruction delivery or execution stalls may still
   limit the measured scenario.
5. Use Processor Trace when exact call order, counts, instructions, cycles, or
   generated code are necessary and recording is supported.
6. Re-run the original contract and secondary energy or responsiveness metrics.

High CPU can be expected for a compute-heavy feature. Low CPU can still accompany
poor performance when a serial dependency, blocking wait, I/O, or memory stall
limits progress.

Design before micro-tuning:

- prefer optimized system frameworks for system tasks;
- prefer dynamic scheduling to a fixed thread pool;
- apply an appropriate quality of service;
- choose the Background Tasks type that matches the work;
- limit concurrency to useful parallelism rather than core-count speculation;
- make algorithms and data structures appropriate before examining individual
  instructions.

## Time profiles and call trees

Select the scenario interval and:

1. inspect active threads and their states;
2. use Top Functions to rank aggregate work;
3. inspect callers to explain why work occurs;
4. inspect callees to explain where one operation spends time;
5. compare self and total cost;
6. separate execution count from average cost;
7. use a flame graph to see stack context;
8. mark app-owned phases with signposts where needed.

For a repeated cheap operation, reduce frequency or batch the algorithm. For an
expensive operation, reduce its per-call work, use a better representation, or
move eligible work without violating isolation and ordering.

When comparing profiles, keep the inspection range and workload equivalent.
Treat the call-tree comparison percentage as change between runs, not share of
total samples.

## CPU bottlenecks

Use CPU Counters in CPU Bottlenecks mode after a stable test or interaction
shows that CPU execution is the relevant limit.

Correlate its lanes with Time Profiler and distinguish:

- useful instruction completion;
- front-end stalls, where instruction fetching cannot keep up;
- back-end stalls, where execution cannot keep up, often involving data access;
- bad speculation, where completed work is discarded.

The absence of a reported bottleneck does not prove the algorithm is efficient.
The CPU can execute unnecessary work efficiently.

For a detected interval:

1. select the bottleneck in the thread track;
2. inspect Summary: Metrics and Remarks;
3. use Suggested Next when Instruments offers a more specific counter mode;
4. correlate the counter with source and disassembly only after identifying the
   app-owned call path;
5. apply the relevant Apple silicon guidance;
6. validate the performance test and CPU Counters trace again.

Use `OSSignposter` around the affected algorithm to keep counter captures aligned
with the contract.

## Processor Trace

Processor Trace records branch and call flow across running threads with low
hardware tracing overhead. Instruments adds other tracing overhead, so do not
assume the complete profile overhead is below 1 percent.

Use its views deliberately:

- **Call Tree** for top-down instructions and cycles;
- **flame graph** for stack share;
- **Summary: Function Calls** for aggregate count, active duration,
  instructions, and library or compiler-generated work;
- **Function Calls** for time-ordered individual calls, thread, duration, and
  instruction count;
- per-thread timeline for exact call flow.

Set the inspection range to an individual call when studying one execution.
Filter by function, process, or thread. Charge helpers to callers, prune
irrelevant trees, and flatten libraries to boundary frames without forgetting
what the filter hides.

Supply the matching dSYM for a distributed build. Raw addresses can still remain
for compiler-generated branch islands or other unsymbolicated regions.

See `tools-and-evidence.md` for recording availability. Fall back to Time
Profiler and CPU Counters when the device cannot record Processor Trace.

## Memory investigation ladder

Define which behavior is wrong:

- peak footprint exceeds a device or product budget;
- footprint grows after repeating a feature;
- memory at suspension causes background eviction;
- an allocation spike creates latency or termination;
- reachable objects remain after their useful lifetime;
- unreachable allocations leak;
- Metal resources dominate the process footprint;
- the process receives memory warnings or a jetsam/memory-limit termination.

Then:

1. inspect Organizer memory by version, device, and median or high percentile;
2. reproduce on the affected physical device and data set;
3. observe Xcode’s memory report and gauge;
4. capture the memory graph for ownership and retain-cycle questions;
5. use Allocations and generation marks around the feature;
6. use Leaks for unreachable allocated memory;
7. inspect jetsam, termination, or MetricKit diagnostics when the system killed
   the app;
8. use Game Memory when Metal resources are material.

Simulator limits differ from physical devices. A green Simulator memory gauge
does not prove safety on a device; macOS does not reproduce iOS memory-warning
and out-of-memory termination behavior for the Simulator process. Avoid
inventing one memory ceiling for all devices and workloads.

### Interpret memory evidence

- **Leak**: allocated memory is unreachable and cannot be freed.
- **Retain cycle**: objects remain reachable through strong references.
- **Reachable unused memory**: caches, histories, models, or views remain
  referenced despite no longer supporting current behavior; Leaks may report
  nothing.
- **Transient peak**: the feature temporarily needs multiple representations or
  a large transaction.
- **Dirty footprint**: resident data the system cannot simply discard; relate it
  to memory at suspension and pressure.
- **Mapped or purgeable content**: not equivalent to a retained heap object.

Turn on Malloc Stack Logging for allocation backtraces when its overhead is
acceptable. Export a memory graph only under the project’s privacy policy.

In Allocations, mark a generation before and after the target action. Repetition
across generations helps reveal objects that accumulate, but unrelated
allocations inside the interval still require ownership analysis.

## Memory remedies

Choose the remedy that matches the evidence:

- Downsample large images to display dimensions and suitable color depth before
  retaining decoded data; use Image I/O for efficient transforms.
- Bound caches and histories by need, cost, and pressure behavior.
- Release image, video, SceneKit, and other recreatable view resources when the
  app enters a lifecycle state that does not need them.
- Break retain cycles and free manual allocations.
- Remove references to stale but reachable objects.
- Reduce Core Data transaction size while measuring the increased storage-write
  tradeoff from saving more often.
- Avoid holding multiple full-size representations through a transformation.
- Reduce Metal resource lifetime and storage modes using `graphics.md`.

Do not clear every cache reflexively. A smaller footprint can increase CPU,
networking, disk I/O, energy, and visible latency.

## Low-memory handling

iOS may deliver memory pressure through app-delegate and view-controller
callbacks, a notification, or a dispatch memory-pressure source. Delivery is
best effort; rapid pressure can terminate an app before it responds.

Respond quickly:

- stop or reduce future large allocations;
- release known recreatable content;
- use purgeable data where its access contract fits;
- lower fidelity or batch size if the product permits;
- preserve state needed for restoration.

Do not traverse the entire object graph on warning. Touching cold compressed
pages can increase pressure. Avoid combining `NSCache` and `NSPurgeableData`
without understanding both discard policies.

If one large allocation terminates the app before warning delivery, redesign the
operation to allocate incrementally or use a more compact representation.

An `EXC_RESOURCE` diagnostic with memory subtype indicates proximity to a
device-dependent resource limit; it does not by itself prove that a particular
event was a jetsam termination. Use the actual termination or jetsam report.
Detailed jetsam-report field interpretation is outside the 48-page source set
and must be verified from its linked current article.

## Memory regression tests

Use `XCTMemoryMetric` around a deterministic feature. Xcode reports peak memory
and growth across the measured block.

- Keep data and setup stable.
- Repeat the feature enough to expose accumulation.
- Set a baseline only after inspecting normal variance.
- Pair the metric with correctness checks and, when relevant, a lifecycle return
  to the expected resting state.
- Keep field memory and termination monitoring because a test device cannot
  represent all pressure conditions.

## App-size measurement

Do not measure App Store download or installed size from a Debug `.app`, an
`.xcarchive`, or the uploaded IPA. Those artifacts contain files that users do
not receive in the same form.

Preferred evidence:

- App Store Connect for the most accurate size of each processed variant;
- an Xcode-generated App Thinning Size Report for a close development estimate.

To create the report:

1. archive the app;
2. export an Ad Hoc, Development, or Enterprise distribution;
3. choose all compatible device variants for app thinning;
4. inspect `App Thinning Size Report.txt`;
5. record compressed download size and uncompressed installed size per variant.

For automation, export the archive with `xcodebuild -exportArchive` and an export
options property list whose `thinning` value requests all variants. Keep signing
credentials and paths outside the skill and repository.

TestFlight includes additional test data and can be larger than the final App
Store build. App Store processing and DRM can also change final size.

## App-size optimization

Apply measured changes in this order:

1. Confirm the Release target uses the intended size optimization, commonly
   `Fastest, Smallest [-Os]`, and inspect every relevant target.
2. Inspect thinned IPA contents and remove unused or accidentally bundled files.
3. Put resources in asset catalogs with correct device metadata, resizing, and
   compression.
4. Move data and media out of source-code literals into appropriate asset files.
5. Use efficient formats and acceptable resolution, bit depth, sample rate, and
   bit rate.
6. Keep frequently changed update content separate from stable content so App
   Store delta updates remain small.
7. Adopt on-demand resources for infrequently used assets when lifecycle and
   availability permit it.
8. Ensure non-App-Store distribution exports the required thinned variants.

Measure download size, installed size, update size, launch, decoding cost,
memory, network use, and visible quality as applicable. Removing bytes is not an
improvement if the replacement creates a worse user or resource outcome.
