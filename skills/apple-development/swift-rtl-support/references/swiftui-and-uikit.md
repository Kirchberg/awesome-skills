# SwiftUI and UIKit implementation guidance

Prefer framework-native semantics, then narrow custom behavior to the component
whose meaning requires it.

## Contents

- Inspect availability first
- Implement with SwiftUI
- Implement with UIKit
- Handle custom collections and text
- Review interoperability boundaries

## Inspect availability first

Record the selected Xcode, SDK, Swift language mode, and deployment targets.
Read the generated interface for availability and deprecation before copying an
example.

Separate deployment availability from link-time behavior. New SDKs can change
default writing-direction and alignment resolution even when the minimum OS
does not change.

Do not raise a deployment target, adopt a beta-only API, or replace a supported
fallback unless the user authorizes that scope.

## Implement with SwiftUI

Let standard containers consume `EnvironmentValues.layoutDirection`:

```swift
@Environment(\.layoutDirection) private var layoutDirection
```

Use `HStack`, alignment guides, `Spacer`, `frame` alignment, and standard
navigation before manual coordinates. Keep source order logical and let the
container adapt. Read `layoutDirection` only for custom semantic behavior.

For custom `Layout`, read `LayoutSubviews.layoutDirection` during placement.
Compute from semantic leading and trailing edges. Test subview spacing,
proposal handling, cache invalidation, animations, and hit testing in both
directions.

For a custom `Shape`, decide whether its path is fixed or mirrors. Use the
selected SDK's `Shape.layoutDirectionBehavior`,
`View.layoutDirectionBehavior(_:)`, or
`flipsForRightToLeftLayoutDirection(_:)` when appropriate. Availability-gate
the mechanism and do not mirror child text.

For text:

- keep localizable literals and interpolations in one `Text` or
  `String(localized:)` message;
- use `.multilineTextAlignment` or its strategy overload when line alignment
  needs an explicit policy;
- account for the iOS 26 SDK's content-based default writing direction;
- apply `.writingDirection(strategy: .layoutBased)` only when the paragraph
  must follow interface layout;
- use `AttributedString.writingDirection` for known per-paragraph metadata.

Apply `.environment(\.layoutDirection, .leftToRight)` or `.rightToLeft` only to
the smallest spatial, playback, preview, or test subtree. Verify every
descendant affected by that override.

Use semantic SF Symbol names for reading-flow actions. Keep
`arrow.forward`/`arrow.backward` distinct from `arrow.left`/`arrow.right`.

## Implement with UIKit

Use Auto Layout's directional anchors:

```swift
NSLayoutConstraint.activate([
    titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
    actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
])
```

Use `directionalLayoutMargins` and `NSDirectionalEdgeInsets` for semantic
spacing. Keep `leftAnchor`, `rightAnchor`, and `UIEdgeInsets` only for physical
geometry.

Leave `semanticContentAttribute` as `.unspecified` for ordinary UI. On the
smallest component that requires an exception:

```swift
transportControls.semanticContentAttribute = .playback
alignmentControl.semanticContentAttribute = .spatial
```

Avoid `.forceLeftToRight` and `.forceRightToLeft` as page-level patches. They
propagate through view hierarchies and can reverse otherwise-correct
subcomponents.

Read `effectiveUserInterfaceLayoutDirection` when custom drawing or layout
needs the resolved direction after inheritance. Do not infer it from
`Locale.current.language`.

Prefer `.natural` text alignment, then choose an explicit paragraph or
content-aware policy for mixed-language content. Verify the selected SDK's
TextKit resolution behavior.

For buttons, configurations, and symbol placement, choose semantic leading or
trailing placement for reading flow and physical left or right only when the
symbol describes an absolute direction.

## Handle custom collections and text

For a reading-flow `UICollectionViewLayout`, consider overriding the
coordinate-system contract:

```swift
override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
    .leftToRight
}

override var flipsHorizontallyInOppositeLayoutDirection: Bool {
    true
}
```

Use that pattern only after verifying the layout was authored in LTR semantic
coordinates. Recheck decoration views, supplementary views, invalidation,
content offset, snapping, interactive movement, and transitions.

Prefer standard flow or compositional layouts when they satisfy the design.
Avoid maintaining a custom mirroring layer whose only purpose duplicates
framework behavior.

For TextKit 2 on supported SDKs:

- read and write `selectedRanges` for natural bidi selections;
- adopt multi-range delegate callbacks;
- use `textLayoutManager` rather than accessing the TextKit 1
  `layoutManager`;
- apply edits safely across noncontiguous ranges;
- test selection across LTR and RTL boundaries.

Availability-gate these APIs and preserve a correct older-OS fallback. Do not
pretend a single-range fallback offers Natural Selection.

## Review interoperability boundaries

Check direction at every bridge:

- `UIViewRepresentable` and `UIViewControllerRepresentable`;
- hosting SwiftUI inside UIKit and UIKit inside SwiftUI;
- attributed strings crossing Foundation, UIKit, and SwiftUI;
- package resources and String Catalog tables;
- web views, Markdown, remote HTML, and rich-text renderers;
- design-system components that override semantics internally;
- snapshot-test hosts that force a locale or direction.

Pass semantic intent through the boundary once. Avoid applying one override in
SwiftUI and an opposite `semanticContentAttribute` in UIKit.

When a third-party component fails RTL, isolate it, document the observed
contract, add a focused adapter and regression test, and prefer an upstream fix
over a screen-wide transform.
