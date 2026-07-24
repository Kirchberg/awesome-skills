# Power, storage, and network performance

## Contents

- Power investigation
- Power Profiler
- Efficient CPU and background work
- Low Power Mode and thermal pressure
- Rendering and media energy
- Networking, Bluetooth, and location energy
- Disk writes
- Storage footprint
- HTTP Traffic in Instruments
- Regression and privacy guardrails

## Power investigation

Treat battery use as the combined result of subsystems over a representative
scenario.

For a shipped regression:

1. inspect foreground and background battery use by release in Organizer;
2. check the available device filters and sample sufficiency;
3. inspect contribution categories such as CPU/GPU processing, display, audio,
   networking, Bluetooth, location, camera, torch, NFC, and other activity;
4. open energy exception signatures for their function, share of energy,
   sample stack, OS, device, log count, and trend;
5. design a local scenario around the dominant subsystem.

Organizer’s foreground battery metric is normalized to a day of onscreen,
unplugged use. Preserve that context when comparing it with a short lab trace.
Apple does not publish the energy-exception threshold in these articles; do not
invent one.

Use MetricKit when the app needs an owned field pipeline. Check every requested
metric against the current SDK: the captured documentation marks several newer
CPU, GPU, luminance, location, network, and file-size metrics as beta, while an
older average-pixel-luminance unit is deprecated.

## Power Profiler

Use Power Profiler on a physical device for a reproducible local scenario.

Interpret:

- overall system power in the device and environmental context;
- charging state, brightness, thermal state, and sleep or wake behavior;
- process CPU, GPU, display, and networking power-impact lanes;
- correlation with a specialized CPU, Metal, SwiftUI, display, or network trace.

Record multiple matched baseline and candidate runs. Do not compare absolute
power-impact values across different device models.

Availability in the captured Apple page is iPhone with iOS 26 or later and iPad
with iPadOS 26 or later. Verify the installed Xcode, OS, and device because this
surface can evolve.

Important recording constraints:

- Selecting all processes produces a system trace without app-specific power
  metrics.
- Instruments reports system power as zero while the device is charging. Use
  wireless debugging when pairing is required for an unplugged system-power
  measurement.
- Xcode can keep Apple silicon awake; investigate sleep and wake with an
  autonomous on-device trace.
- On-device Performance Trace can collect for extended periods and exports an
  archive that Finder expands into a trace.

Use `XCTCPUMetric` only as a repeatable proxy for a CPU-heavy energy regression.
It does not directly measure battery consumption.

## Efficient CPU and background work

Apply this order:

1. remove unnecessary computation;
2. use a better algorithm or optimized system framework;
3. cache and reuse results when memory and freshness permit;
4. replace polling with event-driven notification;
5. batch operations and system wakeups;
6. choose the lowest QoS that still meets the user-facing contract;
7. schedule deferrable work with Background Tasks.

Concurrency can shorten elapsed time without reducing total work, and excessive
parallelism can increase power. Apple gives 10–100 ms as a useful rough
granularity for an independent concurrent operation. Treat it as a scheduling
heuristic, not a universal task size or SLA.

Use Thread Performance Checker to find a higher-QoS waiter blocked by lower-QoS
work. Do not mark all work user-interactive to hide an inversion.

For nonurgent Live Activity pushes, use the lower APNs priority documented for
power-efficient delivery. Never lower priority if it breaks the product’s
timeliness contract.

## Low Power Mode and thermal pressure

Observe power-state change notifications and query Low Power Mode. Reduce
optional activity such as:

- animation and display-update frequency;
- network refresh frequency;
- location accuracy or update frequency;
- prefetching and speculative computation;
- background processing not needed for current user intent.

Observe thermal-state changes and adapt progressively:

- **nominal**: normal plan;
- **fair**: defer nonurgent work and avoid increasing load;
- **serious**: reduce networking, location, animations, screen updates, and
  sustained compute;
- **critical**: stop or sharply reduce camera, Bluetooth, location, and other
  heavy optional work while preserving safe recovery.

Measure degraded-mode latency and correctness. Thermal adaptation must not leave
the app in a permanently reduced state after conditions improve.

For visionOS, include session duration, Shared Space versus immersive mode, room
and scene complexity, and thermal inducer tests. A short cool-device trace does
not prove sustained performance.

## Rendering and media energy

For UI rendering:

- use the SwiftUI instrument to find long or frequent updates;
- limit animation rate and duration to the product need;
- stop completed or hidden animations;
- flash updated regions and invalidate the smallest correct rectangle;
- avoid hierarchy designs where a small change redraws large overlapping areas;
- reduce expensive blur and compositing effects when visual requirements allow;
- reduce average pixel luminance where design permits and support Dark Mode.

For Liquid Glass on supported systems, use effect containers deliberately.
Combining distant views can enlarge the invalidation extent. Verify the current
SDK and measure because this API is version-sensitive.

For media playback, prefer the high-level media framework when it satisfies the
feature. A sample-buffer display layer is often more energy-efficient than a
custom Metal-backed playback path, but Apple does not guarantee it for every
pipeline.

For camera capture:

- run `AVCaptureSession` only while its data is needed;
- stop it promptly when the preview is hidden or covered;
- choose the lowest capture format that meets the product requirement;
- prefer a binned video format when supported and appropriate.

Validate quality, latency, dropped frames, and recovery after any energy change.

## Networking, Bluetooth, and location energy

### Networking

- Use `URLSession` for HTTP and the Network framework for lower-level needs.
- Reuse sessions so connection pooling can work.
- Batch requests and compress payloads when latency and server semantics permit.
- Wait for connectivity instead of running a tight retry loop.
- Opt deferrable work out of expensive or constrained paths where the product
  can tolerate delay.
- Use background sessions and discretionary scheduling for genuinely deferrable
  transfers.
- Configure background refresh with a realistic earliest start, an expiration
  handler, and completion reporting.
- Use exponential backoff. The source’s 5, 10, and 20 minute sequence is an
  example, not a mandatory schedule.

### Bluetooth

- Keep a connection open only while the feature exchanges data or requires
  continuity.
- Avoid continuous discovery and reconnect loops.
- Use AccessorySetupKit for supported accessories and systems when it reduces
  unnecessary scanning; verify current availability.

### Location

- Request the lowest accuracy and frequency that satisfy the feature.
- Set a meaningful distance filter.
- Stop continuous updates when the device is stationary or the feature ends.
- Prefer monitored conditions or lower-power location events when continuous
  tracking is unnecessary.
- Use background location or an activity session only when the user-facing
  feature truly requires it and the permission model is satisfied.

Correlate networking power with bytes, transactions, connection reuse, waiting,
and background wakeups. Correlate location power with accuracy, duration, and
movement. A lower request count alone does not prove lower energy.

## Disk writes

Distinguish evidence layers:

- **Filesystem Activity**: logical system calls, requested bytes, duration, and
  backtrace; use it to locate app code.
- **Disk Usage and Disk I/O Latency**: physical storage activity and latency.
- **Organizer Disk Writes and MetricKit**: daily logical write volume and field
  distribution by release and device.
- **Disk-write exception**: a high-write diagnostic signature with stack,
  contribution, device, total writes, and trend.

Logical and physical writes differ. Storage controllers use blocks, often around
4 KB, so a tiny logical change can cause a larger physical write.
`XCTStorageMetric` measures logical blocks, not exact SSD wear.

Organizer commonly offers median and 90th-percentile write volume. A spike may
represent new content or repeated rewriting; a trend alone does not identify
the cause. Apple does not publish the 24-hour exception threshold in these
articles.

Optimization order:

1. remove writes that do not preserve user or system state;
2. batch small changes within the durability contract;
3. avoid rewriting a complete serialized JSON, XML, or property-list document
   for frequent small edits;
4. use SwiftData, Core Data, or SQLite for frequently changing structured data;
5. avoid rapid file create/delete/rename loops;
6. avoid explicit synchronization unless the product requires that durability.

For SQLite:

- reuse connections;
- group writes in transactions;
- create only useful indices and verify them with the query plan;
- use write-ahead logging where it fits;
- prefer incremental reclamation to a full `VACUUM` when appropriate.

Atomicity, durability, latency, memory, and write volume are tradeoffs. Do not
replace a safe write with a weaker barrier or non-atomic path without an
explicit data-loss contract. File-operation metadata byte examples in the source
are iOS observations, not universal filesystem guarantees.

## Storage footprint

Separate:

- app bundle or thinned App Size;
- Documents and Data;
- cache and temporary content;
- local copies of cloud content;
- total file count and size;
- APFS clone accounting.

Use Organizer Storage and device Settings for field or user-visible footprint.
Use MetricKit file-size reports only through APIs available in the current SDK.
Compare by version, device, percentile, and similar-app context when available.

Storage practices:

- put regenerable data in cache or temporary locations;
- implement an app-owned cache budget and eviction policy because system purge
  timing is not an SLA;
- manage completed download-task temporary files;
- remove an iCloud local copy only after upload is confirmed and use the API
  that preserves the cloud copy;
- use filesystem clones when supported, while retaining a correct fallback on
  other filesystems.

APFS clones may count in total-file-size reporting even though blocks are shared.
Do not infer physical device consumption from a logical file total alone.

## HTTP Traffic in Instruments

The HTTP Traffic instrument observes URL Loading System activity on the
platforms listed by its article: iOS, iPadOS, watchOS, tvOS, and macOS.
Do not promise the same visibility for arbitrary raw sockets or every custom
Network framework protocol.

Workflow:

1. Profile with the Network template.
2. Correlate Network Connections and HTTP Traffic.
3. Expand all HTTP → process → `URLSession` → domain.
4. Give sessions a stable `sessionDescription` so traces remain intelligible.
5. Inspect tasks and their creation or `resume` backtraces.
6. Inspect each task’s one or more transactions.
7. Inspect cache lookup, blocked, request-send, response-wait, and response-
   receive phases.
8. Group transactions by connection and inspect request, response, redirects,
   errors, bytes, and duration.
9. Use Transaction Durations to compare count, average, maximum, and total time
   by endpoint, connection, and path.

A long blocked phase does not prove a server problem. A long response wait does
not distinguish network path, connection setup, scheduling, and server latency
without correlation. Multiple transactions can be valid redirects or retries.

HTTP traces and system logs can contain decrypted encrypted and unencrypted
traffic, including headers, bodies, tokens, personal data, and URLs. Sanitize
before sharing and do not commit raw traces.

## Regression and privacy guardrails

- Compare power only on the same device model and matched environment.
- Pair local power changes with the metric of the dominant subsystem.
- Pair write-volume changes with durability and recovery tests.
- Pair storage changes with offline, cache-miss, and cloud-state behavior.
- Pair network changes with correctness, freshness, constrained-path, retry, and
  background-expiration tests.
- Keep Organizer or MetricKit monitoring after release.
- Verify beta, deprecated, and newly introduced APIs against the project SDK.
- Treat correlation as a hypothesis until a specialized trace and a controlled
  change support causation.
- Redact field payloads, network captures, paths, user content, and identifiers
  from artifacts.
