# Make features discoverable in context

Design the interface to teach through visible structure, familiar language, and
feedback. Add onboarding or contextual help only for information the interface
cannot reasonably communicate at the moment of use.

## Diagnose the discovery problem first

Classify the barrier before adding education:

- the primary action is visually subordinate or offscreen;
- the label, symbol, grouping, or hierarchy is ambiguous;
- a gesture has no visible equivalent or affordance;
- the feature appears before the person has relevant data or intent;
- the benefit is unclear even though the action is visible;
- a permission, setup dependency, or unfamiliar domain concept needs context.

Correct the component, hierarchy, or timing first. Do not use a tutorial to
compensate for an avoidably hidden or confusing action.

## Design first-run experience

1. Bring the person to real product value as quickly as possible.
2. Defer optional personalization, account data, and permissions until their
   benefit is apparent.
3. Teach a core interaction through the actual task when it is safe and
   reversible.
4. Preserve skip, back, cancel, and later paths unless setup is essential to the
   product's function or a documented requirement.
5. Persist completed setup and avoid replaying it after an update without a new
   need.
6. Design interrupted, offline, denied, and partially completed setup states.

Avoid launch-screen advertising, long feature carousels, forced tours of
controls not yet relevant, and up-front permission prompts without context.

## Use progressive disclosure

Keep frequent and essential actions visible. Move infrequent, advanced, or
destructive options into an appropriate menu, detail view, disclosure group, or
settings surface without making them undiscoverable.

Preserve a stable path back to disclosed features. Do not overload a “More”
menu with unrelated primary tasks merely to make a screen look minimal.

## Design contextual tips

Use a tip only when all of these are defined:

- a concrete feature and benefit;
- a relevant audience and prerequisite state;
- the event or condition that makes the moment appropriate;
- a display-frequency policy;
- a dismissal or invalidation rule;
- the product event that proves the person has learned or used the feature.

For TipKit, model eligibility with rules and events, choose inline or popover
presentation from the surrounding task, and invalidate the tip after the feature
is used or becomes irrelevant. Do not show a tip to someone who already
completed the behavior. Do not chain many tips across one screen.

Keep tip copy short: name the benefit, then the action. Anchor it unambiguously,
allow dismissal, preserve accessibility reading order, and ensure the target
remains usable without the tip.

## Use empty states as product states

Distinguish:

- first use with no content;
- no search results;
- content removed by filters;
- unavailable or restricted content;
- offline or failed loading;
- a completed inbox or task list.

Explain the state and offer one relevant next action. Do not fill useful space
with generic illustration or promotional copy when the person needs recovery,
filter changes, or confirmation that work is complete.

## Request permissions in context

Explain the direct feature benefit immediately before the system prompt when
explanation is needed. Request only the capability required at that moment.
Design a useful denial path, a later retry path, and settings guidance only when
the person deliberately tries the blocked feature again.

Never simulate a system permission prompt or imply that access is mandatory
when the product can provide reduced functionality.

## Validate discovery

Test with people or fresh evaluators who have not seen the design rationale.
Observe whether they can identify the primary action, predict consequences,
recover from mistakes, and find secondary features without coaching. Treat
successful completion after verbal guidance as evidence that discoverability
still needs work.
