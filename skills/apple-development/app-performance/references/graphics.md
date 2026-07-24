# Metal frame time and memory

## Contents

- Define the graphics contract
- Game Performance workflow
- GPU-limited frames
- CPU and scheduling limits
- CPU-GPU overlap
- Game Memory workflow
- Metal memory interpretation
- Validation guardrails

## Define the graphics contract

Record:

- user-visible scene and camera path;
- target and actual refresh behavior;
- resolution, dynamic-resolution policy, and visual quality;
- content, mesh, texture, shader, and render-pass complexity;
- physical device, OS, Xcode, build, and thermal state;
- intended steady cadence and allowed stutter or hitch behavior;
- memory and energy guardrails.

Do not use 16.67 ms as a universal frame target. It represents one 60 fps
interval. Some displays update more frequently, and a consistently delivered
20 ms interval can be a healthy 50 fps target. Compare every frame with the
chosen cadence and its actual presentation deadlines.

## Game Performance workflow

For a visionOS RealityKit workload, begin with RealityKit Trace to inspect app
and shared render-server stalls and scene workload. Add the Metal and process
instruments that the target and installed Xcode support.

1. Profile the release-like app on a physical affected device with the Game
   Performance template when the target supports it.
2. Enable performance-limiter or utilization counter sets only when needed;
   they are not necessarily recorded by default.
3. Reproduce the exact stutter and mark its user scenario.
4. Find the abnormal display instance relative to neighboring frames.
5. Select the complete interval and correlate:

   - Display and frame delivery;
   - Metal Application and GPU;
   - thread state and Time Profiler;
   - system load and thread priority;
   - thermal state;
   - Metal resource events;
   - performance-limiter or utilization counters.

6. Classify the frame as GPU-limited, CPU-limited, scheduling-limited, waiting,
   synchronization-limited, or a mixture.
7. Change one mechanism and re-record the same scene.

Example durations and utilization percentages shown in Apple’s article describe
its sample trace. They are not product thresholds.

## GPU-limited frames

Evidence includes shader stages or GPU work extending beyond the intended frame,
high relevant utilization, and little idle opportunity in the selected interval.

Investigate:

- render-pass count and dependencies;
- resolution and render-target size;
- large textures and memory waits;
- mesh and geometry volume;
- fragment overdraw;
- shader control flow, data types, and hotspots;
- avoidable synchronization or resource transitions.

Use controlled experiments:

- reduce viewport or resolution to test fill or bandwidth sensitivity;
- simplify one shader or pass;
- replace one texture or mesh class;
- inspect dependency, geometry, and shader profiling views.

Do not ship the diagnostic quality reduction unless it satisfies the visual
contract. Use it to establish causality.

## CPU and scheduling limits

A CPU-limited frame can show delayed display delivery while shader cores have
idle capacity.

1. Select the rendering-thread interval.
2. Distinguish active CPU work, preemption, and blocking.
3. Use Time Profiler to locate the app-owned call path.
4. Inspect command encoding, scene update, resource preparation, allocation, and
   synchronization.
5. Remove repeated work before changing thread priority.

A scheduling limit can appear when runnable threads exceed available cores or
the rendering thread is repeatedly preempted. Reduce unnecessary threads and
assign priority consistent with the app’s real-time rendering contract.

Apple’s sample discusses a numeric priority for its dedicated game-rendering
thread. Do not copy that number into arbitrary UIKit, SwiftUI, actor, or worker
threads. Measure on the target architecture and respect system scheduling APIs.

## CPU-GPU overlap

Aim to keep both processors making useful progress without violating data
dependencies.

Look for:

- CPU waiting for a GPU result before encoding the next work;
- GPU waiting for late command submission;
- per-frame resource creation or synchronization;
- readbacks that serialize the pipeline;
- duplicated preparation that can be staged earlier.

Where the design permits, prepare data ahead, reuse resources, and consider
GPU-generated indirect work to avoid a CPU readback or submission dependency.
Keep the frame’s correctness, latency, and resource lifetime explicit.

## Game Memory workflow

Profile with Game Memory and reproduce the memory transition.

Use its instruments together:

- **Allocations** for heap and anonymous virtual-memory categories, counts,
  sizes, reference counts, and allocation stacks;
- **Metal Resource Events** for creation, destruction, labels, and resource
  lifetime events;
- **VM Tracker** for process footprint, dirty, swapped or compressed, and
  resident memory;
- **Virtual Memory Trace**, **Metal Application**, and **GPU** for correlation.

Steps:

1. mark the scenario before creating the suspect resources;
2. inspect heap and anonymous VM growth;
3. inspect `IOAccelerator`- and `IOSurface`-related categories where relevant;
4. sort large allocation categories by size and inspect their stacks;
5. correlate Metal resource create and destroy events with the selected range;
6. inspect VM Tracker at steady state and after the feature releases resources;
7. repeat the feature to detect accumulation;
8. validate memory at suspension when background survival matters.

## Metal memory interpretation

Keep these concepts separate:

- A virtual allocation reserves address space but may not occupy physical memory
  until accessed.
- Clean mapped pages can often be discarded and reloaded.
- Dirty pages include written heap and other process-owned state.
- Compressed or swapped dirty memory is still charged using its uncompressed
  size in the footprint described by the source.
- Resident size is not the whole charged footprint.
- A resource event in the selected interval does not prove the resource remains
  alive at the end of the interval.
- Allocations does not expose every Metal resource equally. The source notes
  that private storage resources are absent from the ordinary Metal allocation
  categories where managed and shared resources appear.

Therefore, combine allocation stacks, resource lifetime events, and VM Tracker.
Do not declare a leak from a creation event or declare safety from a flat heap
graph alone.

Possible changes include:

- reduce resource dimensions or format within quality requirements;
- shorten lifetimes and destroy transient resources promptly;
- reuse buffers, textures, heaps, and drawables safely;
- choose storage modes based on CPU and GPU access rather than habit;
- avoid simultaneous full-size copies;
- stream or page content within latency and complexity budgets;
- reduce unnecessary frames or rendering when content is static.

Measure CPU, GPU, memory, energy, and frame delivery after each change.

## Validation guardrails

- Use the same scene, camera, assets, resolution, cadence, device, and thermal
  state for baseline and candidate.
- Validate sustained behavior, not only one recovered frame.
- Check visual output and synchronization errors.
- Check memory after repeated entry and exit from the scene.
- Check the nearest CPU and power guardrails; a GPU improvement can move cost.
- Keep diagnostic counters consistent between compared captures.
- State when the article provides no explicit minimum platform or tool version;
  verify availability in the installed Xcode instead of borrowing Processor
  Trace’s support matrix.
