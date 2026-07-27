# VoiceOver testing and evidence

## Contents

- Use layered evidence
- Build the test matrix
- Prepare physical-device testing
- Run the no-sight common-task pass
- Audit each screen and state
- Exercise the VoiceOver interaction model
- Test navigation, focus, and updates
- Test forms and destructive flows
- Use Accessibility Inspector
- Add automated accessibility audits
- Avoid false confidence
- Record findings and completion evidence

## Use layered evidence

Use four evidence layers:

1. **Code and tree inspection** finds likely semantic, grouping, action, and
   availability problems.
2. **Builds and functional tests** prove the change compiles and preserves the
   ordinary user outcome.
3. **Accessibility Inspector and automated audits** catch supported classes of
   missing descriptions, inaccessible content, and trait problems.
4. **Manual VoiceOver testing on a physical device** proves that the named tasks
   are understandable and operable through the real assistive technology.

Each layer answers a different question. Only the fourth can support a claim
that a VoiceOver workflow works end to end. Apple explicitly states that a
clean accessibility audit does not guarantee an accessible app.

## Build the test matrix

Start with common tasks, not screens in isolation. For each task, record:

- entry point, initial focus, prerequisite data, and expected result;
- every screen, modal, menu, alert, and return transition;
- loading, empty, populated, error, disabled, selected, editing, and success
  states encountered;
- custom controls, gestures, context menus, drag and drop, and destructive
  actions;
- layout differences between iPhone and iPad;
- app locales and right-to-left layout relevant to the change;
- supported device types and OS versions selected for the run.

At minimum, include affected versions near the deployment floor and current
release when behavior or API availability differs. Apple’s App Store criterion
requires proficient testing on every supported device type, not a single
convenient phone.

Keep test fixtures representative. A one-row list does not exercise grouping,
repeated action names, pagination, or position preservation.

## Prepare physical-device testing

Apple’s current guidance says VoiceOver is unavailable in Simulator. Use a
physical iPhone or iPad for manual acceptance.

Before starting:

1. Install the exact build under test and record its revision and configuration.
2. Configure Accessibility Shortcut so VoiceOver can be turned on and off
   safely.
3. Practice VoiceOver gestures in Settings if needed.
4. Set a representative speaking rate and record the VoiceOver language or
   voice.
5. Turn spoken hints on for the first pass when the app supplies hints.
6. Disable visual debugging overlays that change focus or layout.
7. Start screen or audio capture only when allowed and ensure it cannot expose
   credentials, personal data, or private spoken content.

Use headphones when privacy requires them, but do not let audio routing hide
app feedback that is part of the task.

## Run the no-sight common-task pass

Turn on Screen Curtain with VoiceOver and complete each task from its real entry
point. Do not peek at the screen to locate a control, interpret a state, recover
focus, or decide what happened.

For every task, confirm:

- the initial screen and available next step are understandable;
- all important visible information is available through speech or braille;
- every required control and action is discoverable;
- the default action, adjustment, input, dismissal, and recovery work;
- each action reports success, failure, or changed state in time;
- navigation and focus remain predictable through the result;
- the final task outcome is the same as for ordinary touch interaction.

If sighted assistance is needed once, the task fails. Record the first barrier,
then continue after assistance only to discover downstream barriers; do not
mark that run as a pass.

Repeat the completed path with hints disabled. Essential purpose, state, action,
and error recovery must remain understandable.

## Audit each screen and state

On every relevant screen:

1. Swipe right from the first element to the last.
2. Swipe left from the last element back to the first.
3. Explore by touch to find spatially important controls.
4. Read continuously from the top when the screen contains narrative content.
5. Inspect headings, controls, links, form controls, and actions through
   applicable system rotors.

Check:

- one logical first element that establishes context;
- concise, unique labels that make sense out of context;
- correct role, value, selected or disabled state, and available actions;
- no raw asset names, test identifiers, ambiguous actions, or gesture text;
- no decorative, duplicate, invisible, stale, or background stops;
- no skipped element, dead end, loop, or mismatch between forward and backward
  traversal;
- a reasonable number of stops for repeated cards and data rows;
- headings and custom rotor entries that improve rather than clutter navigation.

Do not compare only a transcript of exact spoken words. VoiceOver verbosity,
language, speech settings, and OS version affect phrasing. Verify the conveyed
meaning and interaction.

## Exercise the VoiceOver interaction model

Use the interaction appropriate to each element:

- single-finger touch to select and hear an element;
- single-finger swipe right or left to move next or previous;
- one-finger double tap to activate the selected element;
- one-finger swipe up or down to choose actions or adjust an adjustable control;
- three-finger swipe to scroll content when applicable;
- two-finger scrub or the supported escape action to dismiss a modal or return;
- rotor navigation for headings, controls, links, actions, and custom
  destinations;
- direct touch, pass-through, accessible drag and drop, or hardware keyboard
  commands only when the feature supports them.

For adjustable controls, verify increment, decrement, lower and upper bounds,
value formatting, feedback after every accepted change, and feedback when a
boundary prevents a change.

For custom actions, verify names, order, availability by state, result, and
updated value. Confirm that the default double tap still performs the primary
action.

## Test navigation, focus, and updates

Exercise:

- push and pop navigation;
- tabs, split views, sidebars, and iPad column changes;
- sheets, popovers, alerts, menus, and custom overlays;
- content insertion, deletion, sorting, filtering, refresh, and pagination;
- loading completion, retry, timeout, offline recovery, and transient banners.

Confirm:

- focus enters a new screen or modal at a useful context;
- inactive background content cannot receive focus;
- escape dismisses a dismissible modal;
- dismissal returns focus to the invoking control or a predictable successor;
- removing the focused element chooses a logical nearby element;
- refresh and pagination preserve position instead of jumping to the beginning;
- a passive update does not steal focus;
- important status is announced once without interrupting unrelated speech;
- rapidly changing content is throttled to meaningful updates.

Run actions after both swipe navigation and touch exploration. A focus target
with a wrong accessibility frame can appear correct in sequential traversal but
fail direct touch.

## Test forms and destructive flows

For every text field:

- hear a persistent purpose before and after content is entered;
- activate editing and inspect the current value;
- type, dictate, review, select, replace, and clear content as supported;
- navigate among fields and dismiss or change the keyboard;
- discover requirements before submit;
- submit invalid data, hear a specific error, and reach the field to correct it;
- submit valid data and hear or reach the success result.

Test custom PIN and token inputs as complete entry systems, including deletion,
insertion point, pasted content if supported, auto-advance, errors, and secure
speech behavior.

For destructive actions:

- the label identifies both action and target;
- disabled and unavailable states are accurate;
- confirmation and cancel are independently accessible;
- the result or failure is announced;
- focus after cancel or deletion is logical;
- VoiceOver and ordinary touch execute the same validation and side effects.

## Use Accessibility Inspector

Use Accessibility Inspector against representative screens and states to:

- inspect labels, values, traits, actions, frames, hierarchy, and traversal;
- run VoiceOver-relevant audits such as element description, element detection,
  and traits when the platform offers them;
- highlight an issue’s element and examine the fix suggestion;
- export an audit report when durable evidence is useful and safe to share.

Run an audit for every state that materially changes the tree. An empty state,
loaded list, error alert, and open modal are separate audit surfaces.

Treat Inspector output as a diagnostic. It cannot prove that custom actions are
discoverable, labels make sense in sequence, focus is preserved, speech timing
is usable, or a common task can be completed without sight.

## Add automated accessibility audits

When supported by the repository’s Xcode and target matrix, exercise each
representative screen state in an XCUITest and call the accessibility-audit API:

```swift
func testSearchResultsAccessibility() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-ui-testing", "-fixture", "search-results"]
    app.launch()

    try app.performAccessibilityAudit()
}
```

Check the current API availability and repository conventions. Scope issue
filters narrowly and document why an issue is intentionally ignored; do not
blanket-filter an audit until it passes.

Use stable `accessibilityIdentifier` values to reach fixtures and controls in UI
tests. Keep identifiers separate from localized labels. Add focused functional
assertions for primary and secondary actions, values, navigation, and state
changes because the audit does not execute a full VoiceOver task.

Automated UI tests do not run the VoiceOver interaction model or guarantee its
spoken order. Keep the manual device matrix.

## Avoid false confidence

Do not claim VoiceOver readiness from:

- the presence of `accessibilityLabel` modifiers;
- a visually plausible accessibility tree;
- SwiftUI Preview or Simulator inspection;
- zero Accessibility Inspector or XCUITest audit findings;
- a UI test that taps by identifier using ordinary touch semantics;
- one screen, state, language, direction, device type, or favorable OS version;
- a screenshot or written checklist with no observed task execution;
- testing by a sighted person who repeatedly peeks at the display.

Automated tools find detectable properties. They do not judge whether a label
is concise and contextual, a group is efficient, a custom action is
discoverable, or focus movement is disorienting.

## Record findings and completion evidence

Record each defect with:

- task, screen, state, build, device, OS, locale, and VoiceOver settings;
- element and how it was reached;
- spoken meaning or missing feedback;
- attempted gesture or action;
- expected and actual outcome;
- severity based on task impact and user risk;
- proposed semantic or structural mechanism;
- retest result and retained evidence.

Prioritize blockers, traps, misleading destructive semantics, missing critical
state, and unusable text entry over verbosity polish.

For completion, report:

- every common task and state in scope;
- device and OS matrix actually run;
- Screen Curtain and hints settings;
- forward, backward, touch, rotor, action, focus, input, and modal checks;
- Inspector and automated-audit commands and results;
- build and functional-test results;
- tasks that passed, failed, were not run, or remain blocked;
- residual risks and adjacent out-of-scope accessibility issues.

Say “manual VoiceOver verification pending” when device testing is unavailable.
Do not claim App Store “Supports VoiceOver” from a partial feature audit.
