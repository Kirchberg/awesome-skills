# UIKit and SwiftUI interoperability

## Choose one owner per boundary

Decide which framework owns navigation, presentation, safe areas, scrolling,
focus, environment, and component lifetime. Pass state and actions across a
small explicit boundary. Avoid two independent sources of truth or nested
containers that both believe they own dismissal and navigation.

Keep framework-specific views replaceable. Use simple values, bindings,
observable models with deliberate ownership, delegates, or closures rather than
making domain code depend on a hosting controller.

## Host a SwiftUI subtree

Use `UIHostingController` for a general SwiftUI subtree inside UIKit. When it is
a child, perform normal view-controller containment and constrain its view.
Update `rootView` or shared observable state intentionally, preserving identity
only when state continuity is required. Verify safe-area, sizing, focus,
appearance, navigation, dismissal, and environment propagation.

Use `UIHostingConfiguration` for SwiftUI content in `UITableViewCell` or
`UICollectionViewCell`. Treat the configuration as reusable cell content.
Keep SwiftUI identity stable enough for the desired state, avoid hidden duplicate
owners, and test reuse, resizing, selection, highlight, and asynchronous updates.
Do not infer that hosting automatically improves performance.

When a SwiftUI view must present or navigate through UIKit, emit a semantic
action to the UIKit owner instead of discovering global view controllers.

## Embed UIKit in SwiftUI

Use `UIViewRepresentable` or `UIViewControllerRepresentable` for the smallest
UIKit surface that SwiftUI cannot supply or that must be migrated incrementally.
Create stable UIKit objects in the make method, perform idempotent state updates
in the update method, and use a coordinator only for delegate or callback
bridging that needs stable identity.

Avoid rebuilding UIKit hierarchy, targets, constraints, or observations on every
SwiftUI update. Keep UIKit callbacks from feeding unchanged state back into an
update loop. Tear down long-lived resources when the represented component's
actual ownership ends.

## Gate availability and migration

Check `UIHostingConfiguration` and newer interoperation APIs against the target
SDK and deployment range. Provide a behaviorally equivalent hosting-controller
or native UIKit fallback when required; do not raise the deployment target
silently.

Migrate one coherent boundary at a time. Preserve accessibility identifiers,
analytics, restoration, navigation, test hooks, and user-visible state. Compare
behavior at the oldest supported OS and current target OS before deleting the
previous path.

Use `$swiftui-optimization` for broad SwiftUI invalidation, unstable identity,
expensive view construction, scrolling, layout, or memory-lifetime problems in
the hosted subtree. Use `$swift-concurrency` when observation and asynchronous
ownership cross actor or task boundaries.
