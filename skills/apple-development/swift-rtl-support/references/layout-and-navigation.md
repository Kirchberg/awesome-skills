# Layout, navigation, and directional interaction

Use semantic coordinates for ordinary interface flow and preserve absolute
coordinates only when they carry physical meaning.

## Contents

- Separate semantic and physical geometry
- Let standard navigation adapt
- Review custom SwiftUI layout
- Review custom UIKit layout
- Map gestures and animations by intent
- Classify charts and timelines

## Separate semantic and physical geometry

Prefer these pairs for reading-flow behavior:

- `leading` and `trailing` instead of `left` and `right`;
- `forward` and `backward` instead of physical arrow directions;
- directional margins and insets instead of physical edge values;
- source order that expresses reading order instead of a post-layout transform.

Retain physical sides for controls that literally mean left or right in space.
Document the reason next to a non-obvious absolute constraint or direction.

Do not perform a blind textual replacement of every `left` and `right`.
Classify the enclosing component first. A steering control, a media timeline,
and a disclosure row can contain similar code while requiring different
behavior.

Avoid fixed widths for text-bearing controls. Prefer intrinsic sizing, wrapping,
minimum and maximum constraints, layout priorities, and adaptable grids. RTL
often arrives with different glyph metrics and translation length, so a layout
that merely swaps sides can still clip.

## Let standard navigation adapt

Keep the native behavior of `NavigationStack`, `UINavigationController`,
`UIPageViewController`, standard lists, tables, collection layouts, menus, and
controls unless a reproduced failure proves that product code overrides it.

For custom navigation, verify all related parts together:

- the visual placement of back and forward affordances;
- the SF Symbol or asset variant;
- the transition's insertion and removal edge;
- interactive-pop or custom-pan progress;
- cancellation and completion animation;
- initial page and logical next-page index;
- page dots, carousel order, snapping, and scroll-to-item behavior;
- VoiceOver order and localized action names when accessibility is in scope.

Do not reverse the underlying data array merely to make a screenshot look
correct. Preserve logical model order and adapt presentation and navigation
semantics at the UI boundary.

## Review custom SwiftUI layout

Standard stacks and containers follow the environment's `layoutDirection`.
Review any code that bypasses their placement:

- custom `Layout` implementations;
- `GeometryReader` calculations;
- `Canvas` and custom `Shape` paths;
- `position`, `offset(x:)`, alignment guides, and anchors;
- manual scroll targets and initial positions;
- asymmetric transitions and matched-geometry effects;
- drag thresholds and velocity signs.

Inside a custom `Layout`, inspect `LayoutSubviews.layoutDirection` rather than
inferring direction from `Locale`, a language code, or screen coordinates.
Express placement from a semantic leading edge, or intentionally classify the
layout as fixed.

Use `layoutDirectionBehavior(_:)`, a `Shape`'s
`layoutDirectionBehavior`, or
`flipsForRightToLeftLayoutDirection(_:)` only where the selected SDK and
deployment targets support the intended behavior. Availability-gate newer APIs
and verify their actual generated interfaces.

If an older target needs manual geometry, centralize the mapping:

```swift
@Environment(\.layoutDirection) private var layoutDirection

private var semanticForwardSign: CGFloat {
    layoutDirection == .leftToRight ? 1 : -1
}
```

Multiply a horizontal delta by the semantic sign only when the action means
forward in reading flow. Do not reuse it for spatial or playback movement.

Avoid a high-level `.environment(\.layoutDirection, ...)` override. It also
affects descendants such as text, labels, menus, and system controls. Apply an
override only to the smallest classified subtree and test both directions.

## Review custom UIKit layout

Use:

- `leadingAnchor` and `trailingAnchor`;
- `directionalLayoutMargins`;
- `NSDirectionalEdgeInsets`;
- `effectiveUserInterfaceLayoutDirection` after inherited semantics resolve;
- `NSTextAlignment.natural` or an explicit content-aware policy for text.

Do not mix `leading` or `trailing` with `left` or `right` in the same horizontal
constraint relationship.

Keep `UIView.semanticContentAttribute` at `.unspecified` for ordinary
reading-flow UI. Apply `.spatial` or `.playback` to the smallest component whose
meaning requires it. Treat `.forceLeftToRight` and `.forceRightToLeft` as narrow
integration tools, not screen-level fixes.

For a custom `UICollectionViewLayout`, inspect:

- `developmentLayoutDirection`;
- `flipsHorizontallyInOppositeLayoutDirection`;
- initial and restored content offsets;
- layout attributes for cells, supplementary, and decoration views;
- invalidation during bounds changes;
- target content offset and custom snapping;
- scroll-to-index and interactive movement;
- layout transitions.

The default value of
`flipsHorizontallyInOppositeLayoutDirection` is not an instruction to always
override it. Decide whether the coordinate system represents reading flow, then
test the complete layout in both directions.

## Map gestures and animations by intent

Name gesture logic by intent, such as `advance`, `goBack`, `openLeadingPanel`,
or `moveObjectLeft`. Avoid names like `swipeRightAction` when the user-facing
meaning changes with layout direction.

For each custom gesture:

1. classify it as reading-flow, spatial, playback, or another domain;
2. convert physical translation and velocity into that semantic space;
3. keep threshold, predicted end, cancellation, and rubber-banding consistent;
4. verify the matching visual transition;
5. repeat with assistive technologies if the gesture has no ordinary control.

Keep hit testing and source order untransformed. A full-container negative scale
can make the visual result appear mirrored while leaving gesture, coordinate,
and accessibility behavior contradictory.

## Classify charts and timelines

Do not apply one policy to all data visualizations:

- Preserve an absolute Cartesian or scientific axis when its direction is part
  of the domain.
- Adapt a reading-sequence or culture-specific timeline when that matches user
  expectations.
- Review calendar progression by locale and product convention.
- Keep playback time in the playback category.
- Verify labels, legends, annotations, selection gestures, and scroll direction
  separately from the plotted axis.

Record the semantic reason for the chosen orientation. A chart that stays LTR
inside an RTL screen can be correct, but it must not inherit accidental
mirroring from its container.
