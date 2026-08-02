# UIKit and hybrid applications

Preserve UIKit system ownership where the app already uses it well. Do not rewrite
a mature UIKit shell in SwiftUI merely to obtain Liquid Glass, and do not embed a
second navigation shell across a hosting boundary.

## Contents

- Start with UIKit system structure
- Prefer native button configurations
- Build a justified custom effect
- Extend a background rather than the layout
- Define one hybrid shell owner
- Validate UIKit behavior

## Start with UIKit system structure

Inspect `UINavigationController`, `UINavigationBar`, `UITabBarController`,
`UITabBar`, `UIToolbar`, `UISplitViewController`, `UISearchController`, menus,
buttons, sheets, and popovers before creating custom visual-effect views. Build
with the selected current SDK and observe what those components adopt
automatically.

Audit `UINavigationBarAppearance`, `UITabBarAppearance`,
`UIToolbarAppearance`, appearance proxies, background and shadow images, scroll-
edge configurations, presentation backgrounds, and custom container chrome.
Remove only the values that conflict with intended system rendering. Preserve
semantic colors, typography, compact metrics, and earlier-OS behavior that still
serve the product.

Use Apple's navigation-bar customization technote to reason about standard,
compact, and scroll-edge appearances. Do not clear every appearance object as a
blanket migration tactic.

## Prefer native button configurations

Use `UIButton.Configuration.glass()` or
`UIButton.Configuration.prominentGlass()` when the selected SDK declares them and
the view is a `UIButton`. Configure the title, image, role, state changes, content
insets, and accessibility on the button instead of constructing a visual-effect
lookalike around a gesture recognizer.

Keep a complete pre-iOS 26 configuration path when the deployment target requires
it. Preserve the same action, target, menu, enabled state, identifier, pointer,
keyboard, and accessibility behavior.

## Build a justified custom effect

For a custom UIKit functional surface, create a `UIGlassEffect` with the required
style and host it in a `UIVisualEffectView`. Set `isInteractive` only for a control
surface and `tintColor` only for meaningful emphasis.

```swift
if #available(iOS 26.0, *) {
    let effect = UIGlassEffect(style: .regular)
    effect.isInteractive = true
    effect.tintColor = .systemBlue
    let effectView = UIVisualEffectView(effect: effect)
    // Add semantic controls and constraints to effectView.contentView.
}
```

Keep the effect view's bounds, corner geometry, hit testing, and accessibility
relationship explicit. A visual-effect view is not itself a semantic button.
When transitioning a `UIVisualEffectView`, animate a supported change to its
`effect` rather than fading the entire effect view's opacity and its content as one
layer.

For multiple related custom effects, create one `UIVisualEffectView` configured
with `UIGlassContainerEffect`, set its spacing deliberately, and add nested
`UIVisualEffectView` children configured with `UIGlassEffect` to the container's
`contentView`. Let the container render the group as one coordinated effect.
Avoid sibling containers, deep effect nesting, and glass-on-glass.

Do not use legacy `UIBlurEffect`, private backdrop layers, or repeated snapshots to
imitate Liquid Glass on iOS 26+. Keep `UIVisualEffectView` only as the documented
host for a native glass effect or as part of an intentional older-system design.

## Extend a background rather than the layout

Use `UIBackgroundExtensionView` for supported media or background content that
must visually extend outside the safe area under a sidebar or inspector. Put the
content in `contentView` and review `automaticallyPlacesContentView` before
changing placement.

Do not move interactive content outside safe areas or use the extension view as a
universal substitute for constraints. Verify cropping, focus, rotation, keyboard,
multitasking, and resizing.

For a custom control container that overlays a scroll edge, inspect
`UIScrollEdgeElementContainerInteraction` in the selected SDK so descendant labels,
images, glass views, and controls can participate in the system edge effect. Do not
approximate that relationship with a fixed gradient or blur overlay.

## Define one hybrid shell owner

Choose exactly one framework to own persistent navigation, tabs, toolbars, search,
and presentation coordination for a flow:

- Keep UIKit ownership when a `UINavigationController`, tab controller, or split
  controller is the existing app shell; host SwiftUI as content.
- Keep SwiftUI ownership when a `NavigationStack`, `TabView`, or split view is the
  existing shell; wrap only the UIKit content or control that requires it.
- Pass actions and state across the boundary without rendering duplicate bars or
  applying effects on both sides.

When UIKit owns the shell, have hosted SwiftUI content expose its title and action
model through a coordinator or screen contract, then populate `navigationItem`,
`UIBarButtonItem`, menus, or the owned `UIToolbar`. Remove a competing SwiftUI
`.toolbar` for those persistent actions. Preserve roles, disabled state, keyboard
commands, analytics, and one action invocation across the bridge.

Inspect `UIHostingController`, `UIViewControllerRepresentable`,
`UIViewRepresentable`, sizing options, safe-area behavior, presentation ownership,
trait propagation, and lifecycle. Ensure one effect container does not get split
into visually overlapping framework-owned surfaces.

## Validate UIKit behavior

Exercise standard and scroll-edge bar states, rotation, Split View or resizing,
keyboard and pointer input, sheets and popovers, light and dark appearance,
accessibility display settings, Dynamic Type, VoiceOver order and actions, old-OS
fallbacks, and the actual hosting boundary. Report whether verification occurred on
hardware, Simulator, or source alone.
