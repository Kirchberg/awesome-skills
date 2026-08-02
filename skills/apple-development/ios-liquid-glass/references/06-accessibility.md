# Accessibility and legibility

Treat accessibility as part of material selection and control semantics, not a
final visual check. Standard components adapt to system display preferences more
reliably than a hand-built optical stack, but custom elements still require direct
validation.

## Preserve semantic interaction

- Build actions from `Button`, `UIButton`, `Menu`, or another semantic control.
- Provide an accurate label, value, trait, role, disabled state, action, and focus
  order independent of shape, tint, transparency, or animation.
- Keep touch targets and control content usable when text grows or localization
  changes length.
- Expose custom groups as separate or combined accessibility elements according to
  the task, not according to the rendered glass union.
- Preserve focus when a glass element morphs, appears, disappears, moves between
  overflow, or crosses a SwiftUI/UIKit boundary.

Do not make tint, translucency, glow, motion, depth, or position the only carrier
of selection, status, validation, hierarchy, or affordance.

## Exercise display and motion settings

Test the changed flow with:

- Reduce Transparency on and off;
- Increase Contrast and relevant color-filter or differentiate-without-color
  settings;
- Reduce Motion on and off, including insertion, removal, and morphing;
- light and dark appearance over quiet, bright, dark, busy, and moving content;
- Dynamic Type through the largest supported accessibility sizes;
- Bold Text where relevant to legibility and layout;
- the person's preferred system Liquid Glass appearance when the runtime exposes
  such a setting.

Let system components adapt automatically. For a custom element, ensure foreground
content remains readable when transparency or motion changes and when the material
no longer looks like the default screenshot.

Provide a complete Reduce Motion outcome. Replace unnecessary spatial morphing with
a simpler insertion, cross-fade when appropriate, or no animation while preserving
state, focus, and task completion.

## Validate assistive interaction

Use VoiceOver to check reading order, concise labels, values, hints only when
needed, activation, adjustable or custom actions, focus after presentation and
dismissal, and focus continuity through dynamic hierarchy changes.

Check Voice Control names and target discoverability for custom controls. Check
keyboard navigation, focus indication, pointer behavior, and hover or focus states
on supported iPad configurations. Add Switch Control coverage when the changed flow
or product policy requires it.

Material grouping must not accidentally merge semantic controls. Conversely, a
single logical action must not become several confusing accessibility stops because
its decoration uses multiple views.

## Use automated evidence proportionately

Run an XCTest accessibility audit on the affected flow when the project supports
it. Treat automated findings as a useful screen, not proof of complete readiness.
Inspect intentional exceptions narrowly and document their reason.

Use Accessibility Inspector to investigate labels, traits, focus order, contrast,
and hit regions. Verify VoiceOver behavior manually on a physical device before
claiming production VoiceOver readiness; Simulator or hierarchy inspection alone
does not prove the real interaction.

## Review checklist

- Does the interface remain operable when glass becomes less transparent or motion
  is reduced?
- Is every control understandable without tint, refraction, or animation?
- Do text and symbols remain legible over the full content range and at large type?
- Does focus move predictably through containers, morphs, sheets, search, and
  hosting boundaries?
- Were automated audits, Inspector checks, and physical-device passes reported
  separately rather than collapsed into “accessible”?

When required evidence is unavailable, report “accessibility implementation
reviewed; physical-device assistive-technology verification pending.”
