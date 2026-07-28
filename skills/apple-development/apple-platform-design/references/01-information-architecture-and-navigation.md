# Information architecture and navigation

Make the product's scope legible before choosing navigation chrome.

## Build the information model

1. Inventory the objects people recognize, their relationships, and the tasks
   they perform with them.
2. Separate destinations, content, actions, settings, and transient states.
3. Group by user meaning — such as topic, time, progress, ownership, or
   frequency — rather than by storage or service boundaries.
4. Rank common and consequential tasks. Keep their entry points direct.
5. Sketch the hierarchy without UI components, then name every level in clear,
   stable, localizable language.

Split mixed content types when they require different decisions. Use progressive
disclosure to reveal detail or rare capability in context, while keeping the
primary task visible.

## Choose a navigation structure

- Use a **tab bar** for stable, peer top-level destinations. Preserve each
  destination's navigation state and do not use tabs as commands.
- Use a **sidebar** when a regular-width experience benefits from an overview,
  broader categories, hierarchy, or user customization.
- Use a **navigation stack** for parent-to-child exploration with a clear return
  path.
- Use a **split view** when seeing selection and detail together improves
  comparison, orientation, or productivity.
- Use a **sheet or other presentation** for a focused, bounded task that can be
  completed or cancelled without becoming a hidden branch of the hierarchy.
- Use a **toolbar** for view-specific actions, navigation controls, search, and
  orientation — not as a second set of top-level destinations.
- Use a **menu or context menu** for secondary or contextual commands. Keep
  important actions discoverable outside a hidden menu.
- Add **search** when retrieval is central or the collection warrants it. Define
  its scope, suggestions, filters, empty results, and relationship to browsing;
  do not use search to repair incoherent organization.

Confirm limits, placement, labeling, and adaptive behavior against the current
HIG and platform UI kit instead of relying on memorized counts.

## Preserve orientation and context

- Give each destination a distinct purpose, direct label, and predictable home.
- Keep navigation placement stable across content states.
- Preserve selection, scroll position, entered data, filters, and navigation
  state when people switch context, unless resetting is the explicit action.
- Make Back, Close, Cancel, Done, and dismissal semantics distinct.
- Let deep links and restored activities land in a comprehensible hierarchy.
- Use transition continuity to explain spatial or state relationships; never
  depend on motion alone.

Adapt the same information model to compact and regular windows. A tab bar may
become a sidebar or split hierarchy, but destination identity and user state
must remain coherent. Account for multitasking, resizing, multiple windows,
keyboard commands, pointer or focus input, and platform-specific menu systems.

## Guardrails

- Do not mirror the database, organizational chart, or API as navigation.
- Do not add a top-level destination for a single action.
- Do not hide the app's primary value behind onboarding, sign-in, or permission
  prompts unless the capability genuinely cannot work without them.
- Do not make every screen modal or nest presentations until location and
  dismissal become ambiguous.
- Do not overload one icon or label with different destinations in different
  contexts.
- Do not discard state merely because the layout changed.

## Evidence and validation

Produce and test:

- a content model, task-ranked sitemap, and navigation map;
- a destination/action inventory with a reason for each placement;
- route traces for first use, return use, deep link, cancellation, error, and
  restoration;
- a state-preservation matrix across destination switches and window changes;
- prototypes at representative compact and regular configurations;
- navigation runs using touch, keyboard, pointer or focus, and assistive
  technology where supported;
- long localized labels, right-to-left direction, large text, sparse content,
  and realistic high-volume content.

Revise when people lose their place, confuse a destination with an action,
cannot predict dismissal, or need search to locate the product's primary task.
