# Existing-app audit and migration

Adopt Liquid Glass as a hierarchy migration, not a modifier sweep. Inspect the
existing experience, restore system semantics, and then decide which custom
surfaces remain justified.

## Establish the baseline

Record the selected Xcode and SDK, deployment targets, runtime matrix, app and
screen state, framework boundaries, device or Simulator, appearance, content
size, and accessibility display settings. Build the unchanged app with the
selected current SDK and capture representative flows before editing.

Treat compile warnings, screenshots, view-debugger evidence, and source inspection
as different evidence. Do not call a visual difference a regression until the
expected semantic or product behavior is defined.

## Inventory the interface

Search the relevant scope for:

- custom navigation, tab, sidebar, toolbar, search, sheet, popover, and menu
  implementations;
- `UIVisualEffectView`, `UIBlurEffect`, SwiftUI `Material`, visual-effect wrappers,
  custom blur views, backdrop layers, and glass-like packages;
- `UINavigationBarAppearance`, `UITabBarAppearance`, `UIToolbarAppearance`,
  global appearance proxies, background images, shadow images, and scroll-edge
  overrides;
- manual safe-area overlays, floating `HStack` bars, fixed bottom offsets,
  presentation backgrounds, borders, masks, shadows, and separator workarounds;
- buttons or gestures built from nonsemantic views, including missing disabled,
  focus, hover, pointer, keyboard, or accessibility states;
- SwiftUI and UIKit hosting boundaries that split one visual control group across
  separate hierarchies.

Classify each surface as system-owned, intentionally custom, legacy fallback,
brand content, compatibility workaround, or unknown. Do not delete unknown code
until its supported behavior is traced.

## Migrate in dependency order

1. **App structure**: restore navigation stacks, split views, tabs, and scene or
   window organization before styling descendants.
2. **Navigation and search**: adopt semantic destinations, titles, search, and
   sidebar behavior so the system can coordinate placement and transitions.
3. **Bars and toolbars**: move actions into correct placements and groups; remove
   conflicting custom backgrounds and separators only after parity is confirmed.
4. **Controls**: replace visual lookalikes with buttons, menus, pickers, and native
   styles while preserving actions, roles, states, shortcuts, and hit targets.
5. **Presentations**: let sheets and popovers own their backgrounds and safe-area
   behavior; remove embedded visual-effect backgrounds that double the material.
6. **Content edges**: correct scroll-edge relationships and use background
   extension APIs only for intentional edge-to-edge content.
7. **Custom glass**: add native effects only for important functional elements
   that remain genuinely custom after the earlier steps.
8. **Fallbacks and verification**: exercise pre-iOS 26 behavior, accessibility,
   adaptive layouts, visual states, and measured performance scenarios.

Keep each stage buildable. Separate semantic restoration from optional visual
polish when that makes review and rollback safer.

## Remove conflicts without erasing product behavior

- Remove a legacy bar background only after confirming title, buttons, scrolling,
  status-bar contrast, and old-system fallback remain correct.
- Do not globally clear all appearance configuration; keep semantic colors,
  typography, compact metrics, and intentional product styling that still apply.
- Do not replace a working old-system branch with a crude visual imitation of the
  new material.
- Preserve automation identifiers, accessibility labels, actions, analytics,
  keyboard commands, menus, focus, and state restoration while changing views.
- Avoid an all-at-once redesign unless the user explicitly authorizes that scope.
- Treat `UIDesignRequiresCompatibility`, where current Apple guidance and the
  selected SDK still support it, only as a temporary migration escape hatch with
  explicit rationale, scope, and removal plan. Do not make it the target
  architecture or assume it exists forever.

## Use an evidence-driven agent workflow

Follow the useful pattern from OpenAI's Liquid Glass implementation workflow:

1. Inspect the current flow and source before proposing edits.
2. Write a migration plan tied to actual components and deployment targets.
3. Prefer native system structures and APIs over hand-built visual recipes.
4. Add explicit availability and a complete older-system fallback.
5. Build after each coherent stage and resolve diagnostics at their source.
6. Run the changed flow, compare representative visual states, and iterate from
   concrete evidence rather than a single generated screenshot.

Expand that workflow with UIKit and hybrid inspection, current HIG constraints,
accessibility settings, matched runtime validation, and Instruments when a
performance claim depends on measurement.

## Produce the migration record

Report the components inspected, legacy customizations retained or removed,
system roles restored, custom glass justified, availability branches, checks run,
visual states exercised, measurements collected, and unresolved device or beta
verification. Distinguish source-proven corrections from observed runtime results.
