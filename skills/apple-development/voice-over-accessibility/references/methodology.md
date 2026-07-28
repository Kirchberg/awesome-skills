# VoiceOver methodology

## Contents

- Scope and authority
- Build the task inventory
- Define the acceptance contract
- Establish a no-sight baseline
- Diagnose before changing semantics
- Prioritize barriers
- Make and validate a correction
- Record evidence and completion

## Scope and authority

Classify the request before acting:

- A plan authorizes an inventory, risk assessment, semantic design, and
  validation proposal, not source edits or claims that tests ran.
- An audit authorizes read-only inspection, builds, and non-destructive
  reproduction needed to identify barriers, not fixes unless requested.
- An implementation request authorizes the smallest code and test changes inside
  the named flow plus proportional verification.
- A review authorizes inspection of the supplied delta and surrounding code, not
  edits, commits, or publication.

Do not turn a VoiceOver request into a whole-app accessibility program. Keep
Dynamic Type, contrast, color, motion, captions, other assistive technologies,
and non-Apple screen readers out of scope unless the user adds them.

## Build the task inventory

Treat accessibility as an end-to-end property of a user task, not a count of
labeled views. Inventory the shortest representative route through each
in-scope task:

- entry point and first focus;
- information the person needs to decide what to do;
- primary and secondary actions;
- input, selection, adjustment, validation, and recovery;
- navigation to the next screen and return to the previous context;
- confirmation, result, or changed state that proves the action happened.

Include states that materially change the accessibility tree:

- first launch, permission, and onboarding;
- loading, skeleton, empty, populated, filtered, and paginated content;
- offline, validation, server, and partial-failure states;
- selected, disabled, expanded, editing, and destructive-confirmation states;
- sheets, alerts, menus, overlays, and custom presentations;
- content inserted, removed, reordered, or refreshed in the background.

For a bounded feature, list its tasks explicitly. Do not assume a happy-path
screen represents the empty, error, or modal experience.

## Define the acceptance contract

Record:

- target app, feature, build, revision, and account or data state;
- iPhone and iPad device types in scope, OS versions, orientation, and input
  hardware when relevant;
- Xcode, Swift, SDK, deployment target, and SwiftUI/UIKit ownership boundary;
- app language, VoiceOver language or voice, speaking rate, hints setting, and
  braille or hardware-keyboard use when relevant;
- exact common tasks and the observable result of each task;
- states and content volumes covered;
- evidence required before the chosen mode is complete.

The implementation acceptance gate is stronger than “every control has a
label.” A person must be able to:

1. discover every important element and action;
2. understand its name, role, current value or state, and context;
3. activate, adjust, edit, dismiss, or recover using VoiceOver;
4. receive timely, non-disruptive feedback;
5. retain a logical position as screens and content change;
6. finish the common task without viewing the screen or asking for assistance.

App Store “Supports VoiceOver” is a product-level claim across all common tasks
and supported device types. Do not infer it from one corrected flow.

## Establish a no-sight baseline

Use a physical device because Apple’s current testing guidance states that
VoiceOver is unavailable in Simulator. Simulator, SwiftUI previews, and
Accessibility Inspector can still help inspect structure but cannot replace the
device interaction.

When a defect depends on spoken output, focus, traversal, or interaction and a
physical device is available, capture the no-sight baseline before editing. Do
not block a source-evident correction on device availability: inspect the
existing semantic tree and code, implement the smallest complete change, run
available non-device checks, and report manual VoiceOver verification pending.

For the device baseline and later comparison:

1. Install a representative, preferably release-like build.
2. Configure the VoiceOver accessibility shortcut and confirm how to turn
   VoiceOver off safely.
3. Enable VoiceOver, set a usable speaking rate, and enable spoken hints if the
   app supplies hints.
4. Turn on Screen Curtain.
5. Start from the task’s real entry point and attempt the complete task without
   visual assistance.
6. Capture each barrier with screen, state, focused element, spoken output,
   attempted gesture or action, expected result, and actual result.

Do not record private spoken content, credentials, or user data in logs or
shared evidence.

## Diagnose before changing semantics

Classify each barrier:

- **Missing element**: important content or control is absent from the
  accessibility tree.
- **Duplicate or noisy element**: decorative or repeated content creates
  unnecessary stops or repeated speech.
- **Wrong name, role, value, or state**: the element is present but misleading.
- **Wrong grouping or order**: related information is fragmented, context
  arrives after an action, or traversal skips, loops, or traps.
- **Missing or mismatched action**: VoiceOver activation differs from tap, or a
  visual gesture has no discoverable equivalent.
- **Focus failure**: focus enters background content, resets unexpectedly, or
  fails to follow a real context transition.
- **Feedback failure**: a result, error, loading state, or value change is
  silent, stale, late, or excessively announced.
- **Text-entry failure**: label, value, insertion point, selection, validation,
  keyboard, or custom entry behavior is unusable.

Inspect the framework-generated accessibility tree before adding modifiers.
Many SwiftUI and UIKit controls already provide correct semantics. A redundant
override can make the experience worse or go stale as state changes.

## Prioritize barriers

Fix in this order unless user risk dictates otherwise:

1. common task cannot start or finish;
2. focus trap, inaccessible modal, or unexposed destructive action;
3. missing critical information, incorrect role or state, or unusable input;
4. ambiguous action, broken order, lost focus, or silent result;
5. excessive stops, verbosity, inefficient navigation, or missing rotor path;
6. optional polish that does not block or mislead.

Treat a wrong destructive label or state as higher risk than ordinary
verbosity. Distinguish a usability preference from a functional blocker.

## Make and validate a correction

Prefer changes in this order:

1. use the native control that represents the behavior;
2. preserve the native control and customize its style;
3. correct the view structure or grouping;
4. add the missing label, value, hint, trait, action, or focus behavior;
5. provide a native accessibility representation for custom visuals;
6. implement a fully custom accessibility element or container only when the
   behavior cannot be represented otherwise.

Change one semantic mechanism at a time when practical. Rebuild and re-run the
same baseline task after each coherent correction. Verify both forward and
backward traversal because a fix that works in one direction can still create a
loop or place an action before its context.

Preserve ordinary touch behavior, keyboard behavior, navigation, state,
localization, and business rules. Accessibility must expose the same outcome,
not a divergent shortcut with different validation or side effects.

## Record evidence and completion

For every run, record:

- app revision and build configuration;
- physical device, OS, app locale, and VoiceOver configuration;
- task and initial state;
- Screen Curtain status;
- forward, backward, touch-exploration, rotor, action, input, and focus checks
  that apply;
- observed speech or braille meaning, without asserting an exact utterance when
  VoiceOver settings can vary;
- pass, fail, not run, or blocked status and retained evidence.

Use these completion levels:

- **Planned**: contract and validation strategy exist; no audit is implied.
- **Audited**: barriers are reproduced and bounded; no fix is implied.
- **Implemented**: code and non-device checks pass; manual VoiceOver evidence
  may still be pending.
- **Verified for named tasks**: all in-scope tasks pass on the recorded physical
  device matrix with VoiceOver and Screen Curtain.

Never upgrade “implemented” to “verified” because Accessibility Inspector or an
automated audit is clean.
