# SwiftUI state, transactions, and interpolation

Use this reference for state-driven animation, explicit and value-scoped
animation, transactions, transitions, custom interpolation, completion, view
identity, and shared-element effects.

## Contents

- Start with state
- Scope animation context
- Use transactions deliberately
- Preserve identity and transitions
- Implement custom interpolation
- Coordinate completion
- Use matched geometry safely
- Bridge SwiftUI and UIKit
- Review failure modes

## Start with state

Define stable source and target values first. Let SwiftUI interpolate supported
values between them:

```swift
struct DisclosureCard: View {
    @State private var isExpanded = false

    var body: some View {
        card
            .scaleEffect(isExpanded ? 1 : 0.94)
            .opacity(isExpanded ? 1 : 0.72)
            .onTapGesture {
                withAnimation(.spring(duration: 0.42, bounce: 0.16)) {
                    isExpanded.toggle()
                }
            }
    }
}
```

Keep the durable value semantic (`isExpanded`, selection, destination, phase)
rather than storing a sequence of temporary visual booleans. Use transient
gesture state only while interaction owns the presentation.

Do not mutate animation state from `body`. Do not recreate an owning model or
random identity on each update.

## Scope animation context

Use explicit animation around the state mutation that owns the transition:

```swift
withAnimation(animation) {
    selection = item.id
}
```

Use value-scoped animation when one view should animate whenever a specific
value changes:

```swift
.animation(animation, value: validationState)
```

Avoid the unscoped legacy `.animation(_:)`. Avoid placing even value-scoped
animation so high that unrelated descendants inherit the transaction and move
accidentally.

Remember that `withAnimation` associates an animation with state changes in the
current transaction. It does not make arbitrary side effects asynchronous and
does not guarantee that unrelated rendering or business work waits for pixels
to settle.

## Use transactions deliberately

Use `Transaction` to inspect or override animation context at a narrow
boundary:

```swift
child.transaction { transaction in
    if shouldUpdateImmediately {
        transaction.disablesAnimations = true
    }
}
```

Use `withTransaction` when a particular state mutation needs customized
transaction behavior. Prefer a local override over globally disabling
animations or attaching a second animation to a large ancestor.

Transactions can carry capabilities that vary by SDK, including completion or
velocity-related behavior. Verify the generated interface for the selected SDK
before using those capabilities, and preserve a fallback that does not rely on
them.

For a non-gesture continuous source on supported SDKs, track velocity while
updating, then animate the distinct final change:

```swift
var transaction = Transaction()
if isFinal {
    transaction.animation = .spring(duration: 0.4, bounce: 0.15)
} else {
    transaction.tracksVelocity = true
}

withTransaction(transaction) {
    offset = newOffset
}
```

Apple documents tracking and animation as mutually exclusive for the same
transaction change. Gesture callbacks already enable velocity tracking. Do not
set both flags or assume a public `Transaction.velocity` value exists.

Do not create nested animation contexts casually. When parent and child
transactions differ, document which state change owns each timing model.

## Preserve identity and transitions

An animation changes values of an existing identity. A transition animates the
insertion or removal of an identity.

For a transition:

- make insertion and removal conditional in the view tree;
- provide stable identity for the logical object;
- perform the insertion or removal inside an animation transaction;
- verify asymmetric insertion and removal under reversal;
- keep the source and destination complete with animations disabled.

Do not use `.id(UUID())` to “refresh” a view that should animate continuously.
It replaces identity and often resets state, focus, tasks, and interpolation.

When list or collection identity changes during animation, diagnose identity
before tuning timing. Duplicate or unstable IDs can look like animation bugs.

## Implement custom interpolation

Adopt `Animatable` when a domain value must interpolate and standard view
modifiers do not expose the required path:

```swift
struct ProgressRing: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // Build the path from the interpolated progress.
    }
}
```

Keep `animatableData` continuous and finite. Use an appropriate
`VectorArithmetic` representation for multiple values. Avoid hiding logical
state mutations inside the setter.

Differentiate:

- the target value stored by the view;
- the intermediate `animatableData` supplied during rendering;
- any durable product state committed before or after animation.

Use `GeometryEffect` only when geometry transformation semantics fit. A custom
modifier or shape may express the behavior more clearly.

## Coordinate completion

Use current SwiftUI animation completion APIs when subsequent presentation
state genuinely depends on animation completion. Choose the completion
criterion deliberately: a spring can reach its logical target before it fully
settles.

Do not estimate completion using `DispatchQueue.asyncAfter` or `Task.sleep`
with a copied duration. Such work becomes stale when the animation is
interrupted, system animation scale changes, or a spring settles differently.

Keep completion idempotent and verify that its state mutation does not
immediately trigger the same animation again. Cancel or generation-gate any
additional asynchronous work owned by the transition.

Commit business state independently of visual completion unless the product
contract explicitly requires the visual boundary.

## Use matched geometry safely

Use `matchedGeometryEffect` to preserve the visual identity of an element
moving between locations in a compatible SwiftUI hierarchy.

Require:

- one stable namespace for the relationship;
- a stable match ID for the logical object;
- exactly one intended source at a time;
- compatible source and destination geometry;
- deliberate z-order and clipping;
- a complete fallback when source or destination is unavailable.

Do not assume matched geometry crosses arbitrary navigation, window, hosting,
or independently rendered hierarchy boundaries. Prefer current system
navigation transitions when they provide the required relationship.

Test interruption, scroll movement, cell reuse, source disappearance, rotation,
and Reduce Motion. Shared-element motion can become disorienting when the
source moves or vanishes mid-flight.

## Bridge SwiftUI and UIKit

When updating a representable, inspect the incoming `Transaction`. Coordinate
the hosted UIKit change with the SwiftUI animation context instead of launching
an unrelated fixed-duration animation.

When embedding SwiftUI in a UIKit transition, let the UIKit transition context
own completion and cancellation. Keep SwiftUI state aligned with the actual
transition result.

Avoid two independent springs targeting the same visual property across the
framework boundary. Choose one owner or translate the same context deliberately.

## Review failure modes

Look for:

- animation attached to a container with many unrelated dependencies;
- transitions without conditional insertion or removal;
- identity replacement used as an animation trigger;
- delayed state choreography that survives reversal;
- `Animatable` values that are discontinuous or derived from stale geometry;
- completion used to commit state that should already be durable;
- source and destination both marked as the matched-geometry source;
- implicit UIKit animation inside a SwiftUI-owned transaction;
- animation behavior that changes only because `body` update order changed.

Reproduce the smallest state sequence that fails before replacing APIs.
