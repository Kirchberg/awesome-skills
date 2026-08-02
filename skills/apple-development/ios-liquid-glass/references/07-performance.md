# Performance and diagnostics

Liquid Glass participates in background sampling, compositing, rendering, and
animation. Diagnose the user-visible scenario rather than attributing every hitch
to blur or measuring heap alone.

## Apply source-proven topology corrections

Without waiting for a profiler, correct a proven misuse that preserves behavior:

- consolidate related custom effects into one appropriate container;
- remove duplicate glass-on-glass or an effect already supplied by a system
  component;
- avoid creating one independent container per related control or scrolling row;
- keep stable identity and stop rebuilding a dynamic glass hierarchy needlessly;
- remove hidden, offscreen, or obsolete custom effects from the active hierarchy;
- replace private or stacked optical simulations with native supported APIs.

Run functional checks after the edit. Describe it as a source-proven topology
correction, not a measured performance improvement.

## Define a performance contract

Before profiling, record:

- the exact interaction: launch, scroll, resize, present, expand, morph, hover, or
  repeatedly activate controls;
- device, OS, Xcode and SDK, build configuration, refresh rate, appearance,
  accessibility settings, data, background content, power, and thermal state;
- the baseline and candidate commit or build;
- the metric, unit, aggregation, run count, acceptable variability, and completion
  threshold;
- acceptable trade-offs in visual hierarchy, interaction, memory, energy, and
  implementation complexity.

Use a Release-like build on the weakest supported device class relevant to the
product for a readiness claim. Use Simulator observations only as leads.

## Separate commit and render causes

Investigate commit-side work such as state churn, SwiftUI dependency updates,
layout, model computation, decoding, hierarchy mutation, and main-thread blocking.
Investigate render-side work such as offscreen passes, masks, shadows, blending,
background sampling, overlapping effects, fill cost, and animation composition.

A normal main-thread trace does not rule out render hitches. A visually expensive
effect does not prove it caused a state-update storm.

## Choose evidence by symptom

- Use the SwiftUI instrument for view-body updates, dependency fan-out, and long
  updates in a SwiftUI path.
- Use Animation Hitches and render-loop evidence for missed frames and separate
  commit from render phases.
- Use Core Animation or the applicable graphics instrument for compositing,
  offscreen rendering, blending, and frame pacing.
- Use Time Profiler for CPU paths and main-thread work.
- Use Allocations, memory graph, and footprint evidence for growth, lifetime, or
  pressure; do not infer a leak from growth alone.
- Use Power Profiler or the supported energy tool for sustained animated, media,
  scrolling, or always-active scenarios.

Use Instruments features supported by the selected Xcode. Do not make stable
validation depend on a beta-only template.

## Compare matched scenarios

Run baseline and candidate with the same journey, content, device class, build,
runtime, appearance, accessibility settings, and thermal assumptions. Compare
animation hitches or frame duration, SwiftUI updates, render activity, CPU,
allocations and memory growth, and energy only when they relate to the reported
symptom or claim.

Do not use average FPS, one favorable run, Debug builds, or unmatched content as
proof. Retain trace names and inspected intervals, and note variability.

## Avoid false rules

Apple provides no universal maximum such as 8, 10, or 12 glass views. Limit
simultaneously visible effects, group related effects, and measure the actual
screen. Do not trade away semantics, legibility, accessibility, or an important
control merely to satisfy an invented count.

After profiling, report the supported cause, rejected alternatives, exact change,
functional checks, before and after evidence, resource trade-offs, device and build
context, and remaining uncertainty. If no matched capture ran, do not claim a
measured hitch, power, or memory improvement.
