# Testing and evidence

## Match checks to the contract

Run the repository's formatter, linter, static analysis, focused tests, and a
build for every changed target. Do not invent commands; inspect project scripts,
CI, schemes, destinations, and toolchain selection first.

Use focused unit tests for pure state reduction, configuration mapping, action
routing, validation, formatting, and dependency behavior. Load the view only
when a view-controller test requires it. Keep tests independent from incidental
private hierarchy unless that hierarchy is itself the contract.

Use integration or UI tests for navigation, presentation, dismissal, focus,
keyboard input, restoration, accessibility identifiers, and system-controller
handoffs. Treat snapshots as change detectors for a defined environment, not as
proof of usability, accessibility, or adaptability.

## Exercise a component matrix

Select rows that intersect the change:

- initial, loading, content, empty, partial, disabled, selected, focused,
  highlighted, error, retry, and unavailable states;
- smallest and largest supported containers, rotation, split view, resizable
  windows, safe-area changes, and keyboard presentation;
- default and accessibility Dynamic Type, longer localized text, right-to-left
  layout, light and dark appearances, increased contrast, and reduced motion;
- touch, pointer, hardware keyboard, VoiceOver, Voice Control, Switch Control,
  and Full Keyboard Access where the interaction contract requires them;
- oldest supported OS, current stable target OS, and any explicitly supported
  prerelease path with its fallback;
- cold and warm presentation, repeated configuration, rapid input, cancellation,
  background and foreground, memory pressure, and owner deallocation.

Do not claim full matrix coverage when only a subset ran. Record device or
simulator model, OS, orientation or window size, locale, content size, appearance,
assistive setting, build configuration, and data state for material evidence.

## Diagnose runtime failures

For layout warnings, preserve the first unsatisfiable-constraint output and
identify the actual conflicting requirements. Use symbolic identifiers and a
reduced hierarchy. Check ambiguity separately and inspect final frames at the
failing content size.

For hangs or hitches, select the exact interaction interval and separate
main-thread commit work from render work. Use Time Profiler, Hangs, Animation
Hitches, Core Animation, Allocations, Leaks, Memory Graph, or signposts according
to the suspected mechanism. Do not average away a localized stall.

For reuse or stale-state defects, log stable identity and configuration order
without including sensitive model data. Exercise deletion or mutation while
asynchronous work is in flight.

## Protect evidence integrity

Classify each check as passed, relevant failure, pre-existing failure, flaky,
unavailable, or unrelated. A later pass does not erase a flake. A compilation
pass does not prove presentation, touch, focus, accessibility, or hardware
behavior.

Use physical hardware and a representative Release build for performance,
camera, photo capture, haptics, pointer, external display, or other device-bound
claims. Compare baseline and candidate under matched conditions for performance
claims and report distributions, variability, and secondary resource effects.

When evidence stops at source inspection or build success, report
`runtime component verification pending`. When assistive technology, localization,
RTL, or performance was not exercised, name that gap directly.
