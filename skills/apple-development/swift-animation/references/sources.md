# Swift animation source map

Last reviewed: 2026-07-28.

Use primary Apple documentation, Human Interface Guidelines, release notes, and
WWDC sessions. Treat current DocC and the generated interface from the selected
SDK as availability and signature authority. Treat archived guides as
conceptual background and prerelease pages as unstable.

## Contents

- Interpretation and availability notes
- Motion and interaction
- SwiftUI animation
- UIKit and transitions
- AppKit and cross-framework animation
- Core Animation and frame updates
- Performance, power, and production diagnostics
- Testing and regression metrics
- Prerelease platform-27 material

## Interpretation and availability notes

- **Normative** sources define current design or accessibility expectations.
- **Current API** sources document public symbols, but the selected SDK's
  generated interface remains the final availability check.
- **Teaching** sources explain architecture and workflow; reconcile older
  samples with current signatures.
- **Archived conceptual** sources remain useful for the Core Animation mental
  model but are not current signature or availability authority.
- **Prerelease** sources may change and must not become the unconditional
  production baseline.
- `CustomAnimation` is the public SwiftUI protocol name; do not invent a
  lowercase `customAnimation` symbol.
- `Transaction.tracksVelocity` does not expose a public velocity value. Apple
  documents tracking and animation as mutually exclusive for the same change.
- `matchedTransitionSource` and zoom navigation are stable platform-18 APIs,
  subject to platform-specific support; do not group them with platform-27
  beta APIs.
- `NavigationTransition.crossFade`, Xcode 27 Organizer Hitches expansion, and
  the Swift-first MetricKit generation are prerelease as of this review.
- The cross-fade navigation API does not document automatic Reduce Motion
  adaptation; choose behavior from accessibility preferences deliberately.
- Remove tracking and presentation query parameters from canonical source URLs.

## Motion and interaction

- [1 · Normative · Motion — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/motion)
- [2 · Normative · Accessibility — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [3 · Teaching · Designing Fluid Interfaces — WWDC18](https://developer.apple.com/videos/play/wwdc2018/803/)
- [4 · Teaching · Animate with springs — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10158/)
- [5 · Current API · UIAccessibility.isReduceMotionEnabled](https://developer.apple.com/documentation/uikit/uiaccessibility/isreducemotionenabled)
- [6 · Current API · Reduce Motion status change notification](https://developer.apple.com/documentation/uikit/uiaccessibility/reducemotionstatusdidchangenotification)
- [7 · Current API · SwiftUI accessibilityReduceMotion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion)
- [8 · Current API · SwiftUI accessibilityPrefersCrossFadeTransitions](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilitypreferscrossfadetransitions)
- [9 · Current API · SwiftUI accessibilityPlayAnimatedImages](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityplayanimatedimages)

## SwiftUI animation

- [10 · Teaching · Explore SwiftUI animation — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10156/)
- [11 · Current API · Animations](https://developer.apple.com/documentation/swiftui/animations)
- [12 · Current API · Transaction](https://developer.apple.com/documentation/swiftui/transaction)
- [13 · Current API · Transaction.tracksVelocity](https://developer.apple.com/documentation/swiftui/transaction/tracksvelocity)
- [14 · Current API · Transaction.addAnimationCompletion](https://developer.apple.com/documentation/swiftui/transaction/addanimationcompletion%28criteria%3A_%3A%29)
- [15 · Current API · withAnimation completion](https://developer.apple.com/documentation/swiftui/withanimation%28_%3Acompletioncriteria%3A_%3Acompletion%3A%29)
- [16 · Current API · AnimationCompletionCriteria](https://developer.apple.com/documentation/swiftui/animationcompletioncriteria)
- [17 · Current API · Animatable](https://developer.apple.com/documentation/swiftui/animatable)
- [18 · Current API · GeometryEffect](https://developer.apple.com/documentation/swiftui/geometryeffect)
- [19 · Current API · PhaseAnimator](https://developer.apple.com/documentation/swiftui/phaseanimator)
- [20 · Current API · KeyframeAnimator](https://developer.apple.com/documentation/swiftui/keyframeanimator)
- [21 · Current API · CustomAnimation](https://developer.apple.com/documentation/swiftui/customanimation)
- [22 · Teaching · Advanced animations in SwiftUI — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10157/)
- [23 · Current API · matchedGeometryEffect](https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect%28id%3Ain%3Aproperties%3Aanchor%3Aissource%3A%29)
- [24 · Current API · matchedTransitionSource](https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource%28id%3Ain%3A%29)
- [25 · Current API · ZoomNavigationTransition](https://developer.apple.com/documentation/swiftui/zoomnavigationtransition)
- [26 · Current API · NavigationTransition.zoom](https://developer.apple.com/documentation/swiftui/navigationtransition/zoom%28sourceid%3Ain%3A%29)
- [27 · Teaching · Enhance your UI animations and transitions — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10145/)
- [28 · Current API · ContentTransition](https://developer.apple.com/documentation/swiftui/contenttransition)
- [29 · Current API · TimelineView](https://developer.apple.com/documentation/swiftui/timelineview)
- [30 · Current API · Canvas](https://developer.apple.com/documentation/swiftui/canvas)
- [31 · Teaching · Add rich graphics to your SwiftUI app — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10021/)
- [32 · Current API · scrollTransition](https://developer.apple.com/documentation/swiftui/view/scrolltransition%28_%3Aaxis%3Atransition%3A%29)
- [33 · Teaching · Animate symbols in your app — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10258/)
- [34 · Teaching · Create custom visual effects with SwiftUI — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10151/)

## UIKit and transitions

- [35 · Teaching · Advanced Animations with UIKit — WWDC17](https://developer.apple.com/videos/play/wwdc2017/230/)
- [36 · Teaching · Advances in UIKit Animations and Transitions — WWDC16](https://developer.apple.com/videos/play/wwdc2016/216/)
- [37 · Current API · UIViewPropertyAnimator](https://developer.apple.com/documentation/uikit/uiviewpropertyanimator)
- [38 · Current API · Property-based animations](https://developer.apple.com/documentation/uikit/property-based-animations)
- [39 · Current API · UISpringTimingParameters](https://developer.apple.com/documentation/uikit/uispringtimingparameters)
- [40 · Current API · View controller transitions](https://developer.apple.com/documentation/uikit/view-controller-transitions)
- [41 · Current API · Enhancing your app with fluid transitions](https://developer.apple.com/documentation/uikit/enhancing-your-app-with-fluid-transitions)
- [42 · Current API · UIViewControllerTransitionCoordinator](https://developer.apple.com/documentation/uikit/uiviewcontrollertransitioncoordinator)
- [43 · Current API · UIUpdateLink](https://developer.apple.com/documentation/uikit/uiupdatelink)
- [44 · Teaching · What’s new in UIKit — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10118/)
- [45 · Current API · UIKeyboardLayoutGuide](https://developer.apple.com/documentation/uikit/uikeyboardlayoutguide)
- [46 · Current API · UIKit Dynamics](https://developer.apple.com/documentation/uikit/uikit-dynamics)

## AppKit and cross-framework animation

- [47 · Current API · NSAnimationContext](https://developer.apple.com/documentation/appkit/nsanimationcontext)
- [48 · Current API · NSWorkspace accessibilityDisplayShouldReduceMotion](https://developer.apple.com/documentation/appkit/nsworkspace/accessibilitydisplayshouldreducemotion)
- [49 · Current API · Unifying your app’s animations](https://developer.apple.com/documentation/swiftui/unifying-your-app-s-animations)

## Core Animation and frame updates

- [50 · Archived conceptual · Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)
- [51 · Archived conceptual · Core Animation Basics](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/CoreAnimationBasics/CoreAnimationBasics.html)
- [52 · Archived conceptual · Animating Layer Content](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/CreatingBasicAnimations/CreatingBasicAnimations.html)
- [53 · Current API · CABasicAnimation](https://developer.apple.com/documentation/quartzcore/cabasicanimation)
- [54 · Current API · CALayer.presentation](https://developer.apple.com/documentation/quartzcore/calayer/presentation%28%29)
- [55 · Archived conceptual · Advanced Animation Tricks](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html)
- [56 · Current API · CADisplayLink](https://developer.apple.com/documentation/quartzcore/cadisplaylink)
- [57 · Current API · Supporting ProMotion displays](https://developer.apple.com/documentation/quartzcore/optimizing-iphone-and-ipad-apps-to-support-promotion-displays)

## Performance, power, and production diagnostics

- [58 · Teaching · Explore UI animation hitches and the render loop](https://developer.apple.com/videos/play/tech-talks/10855/)
- [59 · Teaching · Find and fix hitches in the commit phase](https://developer.apple.com/videos/play/tech-talks/10856/)
- [60 · Teaching · Demystify and eliminate hitches in the render phase](https://developer.apple.com/videos/play/tech-talks/10857/)
- [61 · Current guidance · Understanding hitches in your app](https://developer.apple.com/documentation/xcode/understanding-hitches-in-your-app)
- [62 · Current guidance · Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness)
- [63 · Teaching · Optimize SwiftUI performance with Instruments — WWDC25](https://developer.apple.com/videos/play/wwdc2025/306/)
- [64 · Teaching · Demystify SwiftUI performance — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10160/)
- [65 · Current API · SwiftUI graphics and rendering modifiers](https://developer.apple.com/documentation/swiftui/view-graphics-and-rendering)
- [66 · Current guidance · Measuring power use with Power Profiler](https://developer.apple.com/documentation/xcode/measuring-your-app-s-power-use-with-power-profiler)
- [67 · Current guidance · Improving rendering efficiency](https://developer.apple.com/documentation/xcode/improving-your-app-s-rendering-efficiency)
- [68 · Teaching · Profile and optimize power usage — WWDC25](https://developer.apple.com/videos/play/wwdc2025/226/)
- [69 · Teaching · Diagnose performance issues with Organizer — WWDC20](https://developer.apple.com/videos/play/wwdc2020/10076/)
- [70 · Current API · MetricKit updates](https://developer.apple.com/documentation/updates/metrickit)

## Testing and regression metrics

- [71 · Current API · XCTHitchMetric](https://developer.apple.com/documentation/xctest/xcthitchmetric)
- [72 · Current API · XCTOSSignpostMetric](https://developer.apple.com/documentation/xctest/xctossignpostmetric)
- [73 · Current API · Scrolling and deceleration metric](https://developer.apple.com/documentation/xctest/xctossignpostmetric/scrollinganddecelerationmetric)
- [74 · Teaching · Eliminate animation hitches with XCTest — WWDC20](https://developer.apple.com/videos/play/wwdc2020/10077/)

## Prerelease platform-27 material

- [75 · Prerelease · NavigationTransition.crossFade](https://developer.apple.com/documentation/swiftui/navigationtransition/crossfade)
- [76 · Prerelease · CrossFadeNavigationTransition](https://developer.apple.com/documentation/swiftui/crossfadenavigationtransition)
- [77 · Prerelease · iOS and iPadOS 27 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes)
- [78 · Prerelease · Xcode 27 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes)
- [79 · Prerelease · What’s new in Xcode 27 — WWDC26](https://developer.apple.com/videos/play/wwdc2026/258/)
- [80 · Prerelease · Meet the new MetricKit — WWDC26](https://developer.apple.com/videos/play/wwdc2026/222/)
- [81 · Teaching with prerelease context · Compose advanced graphics effects with SwiftUI — WWDC26](https://developer.apple.com/videos/play/wwdc2026/322/)
- [82 · Teaching with prerelease context · SwiftUI Group Lab — WWDC26](https://developer.apple.com/videos/play/wwdc2026/8006/)
