# Layout and visual hierarchy

Organize meaning first; use styling to make that organization perceptible.

## Establish the hierarchy

1. Identify the screen's purpose, primary content, primary action, and current
   state.
2. Remove elements that do not help recognition, decision, action, or feedback.
3. Group related content and separate unrelated content before adjusting
   spacing.
4. Establish a small number of visual anchors that reveal reading order.
5. Apply typography, color, imagery, and material to reinforce that order.

Prefer recognition over recall. Show the information needed to decide before
the action it affects. Place secondary metadata and infrequent controls behind
progressive disclosure without hiding necessary context.

## Choose the content layout

- Prefer a **list or table** for structured, text-heavy, comparable, or
  sequential information.
- Prefer a **grid or collection** when visual recognition and browsing dominate.
- Use **sections** to expose meaningful categories, not merely to decorate
  whitespace.
- Keep related labels, values, controls, and validation messages visually and
  semantically connected.
- Preserve image aspect and focal content; do not crop meaningful information
  to satisfy a decorative frame.
- Reserve prominent placement for the current task's most important content or
  action, not for every brand or business priority.

## Design an adaptive composition

- Respect system safe areas, bars, margins, readable-width guides, and device
  features.
- Express relationships with adaptive containers, alignment, and constraints
  rather than fixed coordinates or a reference-device screenshot.
- Let text wrap and controls reflow. Avoid truncation when expansion or a
  different composition preserves meaning.
- Design compact and regular arrangements intentionally; do not merely scale one
  canvas.
- Keep content and controls in predictable relative positions as the window,
  orientation, locale, text size, or input mode changes.
- Use leading and trailing semantics and identify content that must not mirror.
- Verify target and spacing specifications in the current HIG and Apple Design
  Resources; encode semantic tokens or system values rather than copied pixels.

## Design every relevant state

Specify the initial, loading, populated, empty, partial, stale or offline, error,
restricted, editing, selected, disabled, and completed states that can occur.
Keep the app's identity and navigation stable between them.

- Distinguish loading, empty, and failure; never render them as the same blank
  surface.
- Keep progress honest and preserve usable content during refresh when possible.
- Put recovery beside the failure and preserve valid input or work.
- Explain restrictions and provide the next available action.
- Prevent skeletons and placeholders from implying unavailable actions or false
  content structure.

## Guardrails

- Do not use color, size, or position as the only indication of meaning.
- Do not make all elements prominent; hierarchy requires contrast in emphasis.
- Do not let backgrounds, decoration, or floating controls obscure content.
- Do not place essential controls where system gestures, device features, or
  window chrome can interfere.
- Do not assume an ideal content length, text size, aspect ratio, or window.
- Do not shrink text or interaction targets to preserve a brittle composition.

## Evidence and validation

Validate with:

- wireframes before visual styling and screenshots after implementation;
- the current platform UI kit, safe-area guidance, and system component
  specifications;
- representative smallest, largest, split, rotated, and resizable
  configurations in scope;
- Dynamic Type through relevant accessibility sizes, Bold Text, localized
  expansion, and right-to-left direction;
- realistic empty, average, and high-volume data plus slow and failed loading;
- touch, pointer, keyboard, focus, and assistive technology where applicable.

Inspect reading order, visual order, accessibility order, hit regions,
occlusion, clipping, overlap, and preserved context. Record exceptions with the
user benefit and tested evidence that justify them.
