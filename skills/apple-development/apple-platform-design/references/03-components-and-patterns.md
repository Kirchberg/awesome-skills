# Components and patterns

Choose components by semantic behavior and task fit, not by appearance.

## Use the component decision ladder

1. Select the system component whose role and behavior match the task.
2. Configure its content, prominence, placement, and supported states.
3. Apply supported styling without changing learned semantics.
4. Compose system components when no single component expresses the workflow.
5. Build a custom component only when the product needs behavior or expression
   the system cannot provide.

Before customizing, inspect the current HIG, framework API, and Apple Design
Resources. A replica must recreate the system component's adaptation, input
behavior, accessibility, state feedback, and future visual updates.

## Match behavior to intent

- Use a **button** for an immediate action and label it with the outcome.
- Use a **toggle** for an independent binary setting whose change takes effect
  directly.
- Use a **picker or selection control** to choose from known alternatives.
- Use a **menu** for related secondary choices, not for the only path to a core
  action.
- Use a **list or table** for structured rows and native selection, editing, and
  reordering behavior where appropriate.
- Use an **alert** for information or a decision that genuinely requires
  immediate attention.
- Use a **confirmation dialog** when a consequential or destructive choice
  needs explicit confirmation or alternatives.
- Use a **sheet or popover** for a focused task or contextual detail with clear
  completion and dismissal.
- Use a **progress indicator** only when work is actually in progress; show
  determinate progress when the system can report it meaningfully.
- Use a **gesture** as a shortcut to an action that remains discoverable and
  operable another way.

Follow platform-specific guidance when the same semantic role maps to different
components on iPhone, iPad, Mac, Apple Watch, Apple TV, or Apple Vision Pro.

## Specify the whole interaction

For every control or reusable pattern, define:

- role, label, value, state, help, and accessible action;
- default, pressed or active, selected, disabled, focused, hovered, loading,
  success, error, and destructive states that apply;
- touch, pointer, keyboard, focus, voice, switch, and indirect-input behavior in
  scope;
- validation timing, cancellation, retry, undo, and interruption;
- feedback when an action starts, completes, fails, or changes state;
- localization, bidirectional layout, text expansion, and Dynamic Type behavior.

Prefer visible state changes and system feedback. Use animation, sound, and
haptics as coordinated reinforcement, never as the sole confirmation.

## Admit custom components deliberately

Require all of the following before proceeding:

- a specific user or brand benefit that supported customization cannot deliver;
- semantics and interaction behavior documented independently of visuals;
- parity for relevant platform inputs, accessibility settings, appearances, and
  content variation;
- a complete state model, including failure and interruption;
- implementation and maintenance ownership;
- prototype evidence that the custom behavior is understandable and superior
  for the intended task.

Keep custom controls visually harmonious with system geometry and hierarchy
without impersonating a system control that behaves differently.

## Guardrails

- Do not replace a control solely to make the app look unique.
- Do not use tabs for commands or ordinary buttons for persistent selection.
- Do not place destructive actions where accidental activation is likely.
- Do not confirm low-risk, reversible actions so often that confirmation loses
  meaning.
- Do not request permissions at launch without task context.
- Do not remove native behavior such as focus, keyboard activation, swipe-back,
  selection, text editing, dismissal, or state restoration without an explicit
  product reason and equivalent path.

## Evidence and validation

Retain a component inventory and state matrix. Validate each component against
the current HIG and framework behavior, then test:

- all reachable states and transitions, including rapid repeated interaction;
- cancellation, undo, interruption, failure, retry, and restored state;
- accessibility semantics and order without duplicating framework semantics;
- relevant input modes and device configurations;
- light and dark appearances, contrast and transparency settings, large text,
  long localization, and right-to-left direction.

Reject custom UI that passes screenshot review but lacks semantic, adaptive, or
interaction parity with the system component it replaces.
