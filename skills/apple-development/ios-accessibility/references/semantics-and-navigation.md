# VoiceOver semantics and navigation

## Contents

- Think in accessibility elements
- Provide name, role, value, state, actions, and feedback
- Write labels
- Use values, states, and hints
- Expose text and images
- Group without hiding behavior
- Build a logical reading order
- Support efficient navigation
- Manage focus, modals, and updates
- Expose every interaction
- Handle text entry and errors
- Localize spoken meaning
- Reject common anti-patterns

## Think in accessibility elements

VoiceOver does not consume the visual hierarchy directly. It navigates an
accessibility tree whose elements expose semantic attributes and actions.
Design and review that semantic interface as deliberately as the visual one.

For each element, ask:

- What is this, without pointing to its location or appearance?
- What role and interaction model should VoiceOver announce?
- What current value or state is visually apparent?
- What default and secondary actions are available?
- What feedback proves an action or change occurred?
- What information must be heard before the person chooses the action?

The traversal is sequential even when the screen is spatial. A person may reach
an element by swiping, touching it directly, using a rotor, returning from
another screen, or following an external keyboard command. The element must
make sense from each entry path.

## Provide name, role, value, state, actions, and feedback

Map the general name-role-value principle to Apple APIs:

- **Name**: `accessibilityLabel` or the native control’s visible label.
- **Role**: the native control type and appropriate accessibility traits.
- **Value or state**: `accessibilityValue`, native control state, selection,
  enabled state, expansion, progress, or other semantic properties.
- **Actions**: default activation, adjustable behavior, named custom actions,
  escape, magic tap, rotor actions, or accessible drag and drop.
- **Feedback and focus**: the updated value or state, an appropriate
  announcement, or a logical focus transition.

Prefer native controls because they keep these pieces synchronized. For a
custom control, reproduce the complete semantic contract, not just its label.

## Write labels

Make every label:

- concise, localized, and human-readable;
- specific enough to make sense outside visual and traversal context;
- stable in purpose while values and states change;
- distinct from repeated controls that affect different objects;
- explicit about the target of a destructive or irreversible action.

Use “Remove Hades from backlog” rather than a row of identical “Remove”
buttons. Use “Add to backlog” rather than “Plus.” Preserve the native visible
text as the label when it already communicates the right purpose.

Do not put these in a label:

- control types such as “button,” “link,” “checkbox,” or “text field”;
- state words that a native control or trait already exposes, such as
  “selected,” “checked,” or “disabled”;
- the changing value of a control when it belongs in `accessibilityValue`;
- gesture instructions such as “double tap” or “swipe up”;
- implementation names, asset filenames, symbol identifiers, or test IDs;
- visual-only directions such as “tap the icon on the right.”

When a control changes purpose, update the label with the visible behavior. Do
not encode an on/off state by alternating labels when a stable label plus native
state is clearer.

## Use values, states, and hints

Use a value for the current content or position of a control: rating, progress,
quantity, playback position, selection summary, or formatted measurement.
Update it immediately after the underlying state changes.

Use the framework’s semantic state instead of spoken text where possible:

- bind real state to `Toggle`, `Picker`, `Slider`, `Stepper`, and other controls;
- use selected, disabled, header, link, button, adjustable, and related traits
  only when they accurately describe behavior;
- remove a stale or conflicting trait when a custom element changes role;
- expose expansion, validation, and loading state through the most appropriate
  current SDK API or value.

Use a hint only for the non-obvious result of activation. Keep essential
information out of hints because users may disable them. Do not repeat the
label, role, value, or VoiceOver’s own gesture guidance. “Opens game details”
can be useful when the result is otherwise ambiguous; “Double tap to open” is
not.

Verify behavior with spoken hints both enabled and disabled.

## Expose text and images

Ensure all meaningful visible text appears in the accessibility tree. Do not add
a duplicate label to ordinary text when the framework already exposes it.

For images:

- describe the information or meaning needed for the task, not every visual
  detail;
- hide purely decorative images from accessibility;
- avoid repeating a visible caption as a separate image stop;
- verify inferred SF Symbol labels in context; do not assume they match the
  intended action;
- provide a way to author or obtain descriptions when user-generated images are
  required for a common task.

For charts, maps, canvases, and custom drawing, provide navigable data elements,
a native chart accessibility representation, or at minimum a sufficiently
complete textual alternative. A single label such as “Chart” does not expose
the data.

Represent visual-only status such as an unread dot, color change, animation,
disabled appearance, spinner, or filled progress track as semantic state or
value. Do not rely on color, position, or opacity to communicate it.

## Group without hiding behavior

Use grouping to attach context and reduce excessive stops:

- **combine** related text and non-conflicting controls into one element when
  one concise stop represents the whole item and child controls can become
  understandable custom actions;
- **contain** related children when they must stay independently focusable but
  should be traversed before leaving the group;
- **ignore and replace** children only when the replacement exposes every
  meaningful property and action.

Common list and card patterns often benefit from one primary element containing
the title, relevant metadata and state, plus a small number of named actions.
Do not make “one cell equals one element” a universal rule. Keep children
separate when independent focus, detailed reading, text selection, adjustable
behavior, or too many actions would make a combined element worse.

Never hide a parent if doing so removes meaningful descendants. Never combine
controls whose roles or default actions conflict. Test the generated tree
because framework combination behavior can vary with view structure and SDK.

## Build a logical reading order

Make source and container structure express the same logical order in which a
person needs information:

1. screen or section context;
2. item identity and important state;
3. value or supporting content;
4. actions after the information needed to choose them.

Traverse every screen from first to last and last to first. Ensure:

- no meaningful element is skipped;
- no element repeats or loops unexpectedly;
- a person can always move away in both directions;
- offscreen, hidden, removed, or inactive background content is not reachable;
- right-to-left locales follow their natural reading direction;
- refresh and pagination preserve the current reading position when possible.

Fix view structure and grouping before using `accessibilitySortPriority`.
Priorities are local to accessibility containers and can become brittle as
content changes. Do not assign numeric priorities across an entire screen.

## Support efficient navigation

Mark genuine section titles as headings. Do not mark every bold label or card
title as a heading; a noisy headings rotor is not useful.

Use system rotors first. Add a custom rotor when a dense or data-rich screen has
a stable, meaningful class of destinations that sighted people can scan
directly, such as warnings or search matches. Give entries stable identity and
test navigation forward and backward after insertion, deletion, filtering, and
reordering.

Expose a short, prioritized set of custom actions on combined items. Too many
actions create their own navigation burden. Keep action names specific,
localized, and synchronized with availability and state.

## Manage focus, modals, and updates

Let the framework preserve focus unless the context truly changes. Programmatic
focus movement interrupts the person’s current reading and should be rare.

Move focus deliberately when:

- a new screen or modal requires an initial context;
- the currently focused element disappears and a logical successor exists;
- a user-triggered validation failure needs focus on the actionable error;
- a genuinely high-priority event must interrupt the current task.

For lower-priority status, announce the change without moving focus. Throttle
rapid updates and announce meaningful thresholds or final values rather than
every tick.

For a modal or overlay:

- focus must enter the active content logically;
- background content must be unavailable while inactive;
- the accessibility escape action must dismiss when dismissal is supported;
- focus should return to the invoking control or another predictable successor.

For refresh, pagination, insertion, and deletion, preserve semantic identity so
the VoiceOver cursor does not jump to the beginning. Do not use arbitrary
delays to “fix” focus. React to lifecycle or state transitions and target an
element that exists in the current accessibility tree.

Choose notification semantics intentionally:

- a screen change communicates a new context and may move focus;
- a layout change communicates a meaningful partial update or changed focus
  target;
- an announcement communicates important status without implying a new screen.

Verify the current SwiftUI or UIKit API and deployment target before coding;
notification APIs and availability evolve.

## Expose every interaction

VoiceOver’s default activation must produce the same result as an ordinary tap.
Prefer `Button`, `NavigationLink`, `Toggle`, `Slider`, `Stepper`, menus, and
other native controls over `onTapGesture` on an image or shape.

For custom behavior:

- expose a long press, context menu, swipe, or secondary card action as a named
  custom action;
- expose an ordered one-dimensional value through adjustable increment and
  decrement behavior with current value and boundaries;
- expose a finite drag-and-drop result as an action in addition to accessible
  drag and drop when useful;
- use multiple named actions for a multidimensional control when increment and
  decrement cannot represent it;
- support direct touch only when the interaction truly benefits from raw touch,
  require activation when appropriate, and still offer actions when possible;
- provide immediate semantic feedback after every successful or rejected
  action.

Do not make a hidden gesture the only route to a common task. Do not trigger an
action merely because focus lands on an element.

## Handle text entry and errors

Give every input a persistent label independent of placeholder or current
content. Expose the current value, secure-entry behavior, selection, and editing
state through native text controls whenever possible.

Ensure a VoiceOver user can:

- focus and activate the field;
- enter, dictate, review, select, edit, and clear text;
- move between fields and dismiss or replace the keyboard;
- discover requirements before submitting;
- hear an error at the right time and navigate to the field that needs work;
- complete custom PIN, token, search, comment, and multi-field inputs without
  relying on visual position.

Do not erase the only accessible name when a placeholder disappears. Do not
announce every keystroke or validation pass in addition to the system’s normal
feedback.

## Localize spoken meaning

Localize labels, values, hints, action names, rotor names, errors, and
announcements. Format dates, times, currencies, units, abbreviations, scores,
and counts for natural speech in the active locale. Avoid string concatenation
that produces the wrong grammar or reading order.

Test at least one non-default locale when the change constructs accessibility
text dynamically. Treat pronunciation overrides as a narrow last resort after
using correct localized content and system formatters.

## Reject common anti-patterns

- An `Image` or `Shape` with `onTapGesture` standing in for a button.
- A placeholder or asset filename used as the only accessible name.
- Repeated “More,” “Edit,” or “Delete” actions with no target context.
- Essential state or instructions stored only in a hint.
- A custom drag, swipe, or long press with no discoverable alternative.
- A group that removes independent actions or makes a large paragraph one stop.
- Global sort priorities used to repair a structurally incorrect hierarchy.
- Fixed-delay focus changes or announcements racing view presentation.
- Focus movement for passive updates and announcements for every progress tick.
- Private or raw numeric traits copied from old examples.
- SDK-specific workarounds promoted without reproducing them on the target OS.
