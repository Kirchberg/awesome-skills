# SwiftUI and UIKit implementation

## Contents

- Inspect targets before choosing APIs
- Start with native controls
- Implement SwiftUI semantics
- Group cards and expose secondary actions
- Represent custom SwiftUI controls
- Handle SwiftUI focus and announcements
- Implement UIKit semantics
- Build UIKit containers and custom actions
- Handle UIKit focus, modals, and announcements
- Preserve semantics across framework boundaries
- Review implementation hazards

## Inspect targets before choosing APIs

Before copying an example, inspect:

- deployment targets and supported iOS/iPadOS versions;
- Xcode, Swift, and SDK versions used by the repository;
- whether the view is owned by SwiftUI, UIKit, or a bridge;
- existing architecture, localization, design-system controls, and tests;
- API availability in the current Apple documentation.

Accessibility APIs evolve. WWDC examples demonstrate a design pattern, not
permission to raise a deployment target or use an unavailable overload. Compile
the affected targets and provide an availability-aware fallback when needed.

## Start with native controls

Prefer a standard control whose behavior matches the interaction:

```swift
Toggle("Include completed games", isOn: $includesCompleted)

Button("Add to backlog") {
    addToBacklog()
}

Slider(value: $rating, in: 0...5) {
    Text("Rating")
}
```

These controls provide a role, state or value, activation or adjustment, focus
behavior, and platform conventions. Customize appearance with styles before
replacing a native control with a gesture on a shape.

Do not replace a visible label with an icon-only implementation unless the
semantic label remains correct. Verify inferred SF Symbol descriptions in the
actual context.

## Implement SwiftUI semantics

SwiftUI builds accessibility elements from the view tree. Inspect the generated
result before adding modifiers.

Use the narrowest correction:

```swift
Button {
    remove(game)
} label: {
    Label("Remove", systemImage: "trash")
}
.accessibilityLabel(Text("Remove \(game.title)"))
.accessibilityHint(Text("Removes the game from your backlog"))
```

The label identifies the action and target. The optional hint describes the
result, not “Double tap to remove.” Omit the hint if the label and surrounding
context already make the result clear.

Keep dynamic state in a value:

```swift
ProgressView(value: downloaded, total: total)
    .accessibilityLabel(Text("Download progress"))
    .accessibilityValue(
        Text("\(Int(downloaded / total * 100)) percent")
    )
```

Guard division and formatting in production code and use localization-aware
formatters. Prefer the native `ProgressView` semantics when they already speak
the right result.

Treat test identifiers separately:

```swift
Button("Retry", action: retry)
    .accessibilityIdentifier("download.retry")
```

An identifier supports automation. It does not provide or replace the
user-facing accessibility label.

Hide decorative duplication, not meaningful content:

```swift
Image(systemName: "sparkles")
    .accessibilityHidden(true)
```

Only hide the image when adjacent accessible content already conveys its
meaning or it is purely decorative.

## Group cards and expose secondary actions

Reduce fragmented card navigation while preserving behavior:

```swift
Button(action: openDetails) {
    GameCardContents(game: game)
}
.buttonStyle(.plain)
.accessibilityElement(children: .combine)
.accessibilityAction(named: Text("Add to backlog")) {
    addToBacklog(game)
}
.accessibilityAction(named: Text("Mark as played")) {
    markAsPlayed(game)
}
```

Test the resulting label, role, and actions. `.combine` can merge labels and
promote child controls to actions, but its exact result depends on structure.
Add explicit actions when the generated names or availability are wrong.

Use `.contain` when children must remain separate stops but belong together:

```swift
GameSection()
    .accessibilityElement(children: .contain)
```

Use `.ignore` only when the replacement element supplies all meaningful
properties and actions. Avoid nesting interactive controls inside a `Button`.
Restructure the card or use explicit actions rather than relying on invalid
control composition.

Mark real headings:

```swift
Text("Recommended")
    .font(.headline)
    .accessibilityAddTraits(.isHeader)
```

Do not apply the heading trait to every card title. Use
`.accessibilitySortPriority` only within a deliberate container and only after
structure and grouping fail to express the correct order.

## Represent custom SwiftUI controls

When a custom visual control has a native semantic equivalent, prefer
`accessibilityRepresentation`:

```swift
CustomRatingControl(rating: $rating)
    .accessibilityRepresentation {
        Stepper(value: $rating, in: 0...5) {
            Text("Rating")
        }
        .accessibilityValue(Text("\(rating) out of 5"))
    }
```

The visible control remains custom while assistive technologies receive the
native control’s role and interaction model. Verify that the representation
performs the same validation, clamping, side effects, and feedback.

For a custom one-dimensional value without a suitable representation, expose a
label, current value, adjustable semantics, and increment/decrement behavior:

```swift
CoffeeLevelView(level: level)
    .accessibilityElement()
    .accessibilityLabel(Text("Coffee amount"))
    .accessibilityValue(Text("\(level) ounces"))
    .accessibilityAdjustableAction { direction in
        switch direction {
        case .increment:
            increaseLevel()
        case .decrement:
            decreaseLevel()
        @unknown default:
            break
        }
    }
```

Apple’s current SDK examples may also add an explicit adjustable trait. Check
the target SDK and resulting VoiceOver output instead of copying a newer trait
to older deployment targets blindly.

For multidimensional or finite gesture behavior, expose specific named actions:

```swift
EqualizerPad()
    .accessibilityLabel(Text("Filter"))
    .accessibilityValue(Text("Frequency \(frequency), amplitude \(amplitude)"))
    .accessibilityAction(named: Text("Move up"), moveUp)
    .accessibilityAction(named: Text("Move down"), moveDown)
    .accessibilityAction(named: Text("Move left"), moveLeft)
    .accessibilityAction(named: Text("Move right"), moveRight)
```

Keep action count manageable. Direct Touch and pass-through gestures can
preserve rich interaction, but they must not be the only route when named or
adjustable actions can provide an equivalent outcome.

Use `.accessibilityChildren` to synthesize navigable data points for custom
drawings, canvases, and charts while leaving the visual rendering unchanged.
Give each synthetic child a meaningful label, value, and stable identity.

## Handle SwiftUI focus and announcements

Use `@AccessibilityFocusState` to read or request accessibility focus:

```swift
enum FocusTarget: Hashable {
    case validationError
}

@AccessibilityFocusState
private var focusedTarget: FocusTarget?

Text(validationMessage)
    .accessibilityFocused($focusedTarget, equals: .validationError)
```

Request focus after the target exists and only for a meaningful context change,
such as a user-triggered validation failure. Do not set focus on every render or
passive update. If a temporary view is focused, avoid removing it on a timer
before the person can finish reading or acting.

Use the current SwiftUI accessibility notification API when supported:

```swift
AccessibilityNotification
    .Announcement("Saved to backlog")
    .post()
```

Check exact API availability and argument types for the repository’s SDK. For
older targets, bridge intentionally to UIKit notification APIs. Announce an
important result once; do not duplicate state VoiceOver already speaks.

## Implement UIKit semantics

Standard UIKit controls usually expose basic semantics automatically. For a
custom view that acts as one element, configure the complete contract:

```swift
final class RatingView: UIView {
    var onRatingChanged: ((Int) -> Void)?

    var rating = 0 {
        didSet {
            accessibilityValue = "\(rating) out of 5"
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAccessibility()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAccessibility()
    }

    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Rating"
        accessibilityTraits.insert(.adjustable)
        accessibilityValue = "\(rating) out of 5"
    }

    override func accessibilityIncrement() {
        updateRating(rating + 1)
    }

    override func accessibilityDecrement() {
        updateRating(rating - 1)
    }

    private func updateRating(_ proposedRating: Int) {
        let updatedRating = min(max(proposedRating, 0), 5)
        guard updatedRating != rating else { return }
        rating = updatedRating
        onRatingChanged?(rating)
    }
}
```

Localize and format the value in production. If the control’s behavior changes,
update `accessibilityLabel`, `accessibilityValue`, `accessibilityHint`, and
`accessibilityTraits` together. Use `.notEnabled`, `.selected`, `.button`,
`.header`, `.link`, `.adjustable`, and other traits only when accurate.
Route the pan gesture through the same `updateRating` path so touch and
VoiceOver apply identical bounds, callbacks, drawing, and side effects.

Do not set both a container and all of its interactive descendants as competing
accessibility elements without a deliberate grouping design.

## Build UIKit containers and custom actions

For a view whose subcomponents must remain separate:

- set the container’s `isAccessibilityElement` to `false`;
- expose real subviews in a logical `accessibilityElements` order; or
- create `UIAccessibilityElement` instances for virtual content and keep their
  labels, values, traits, actions, frames, and identity synchronized.

When overriding accessibility-container methods, implement the full count,
element-at-index, and index-of-element contract consistently. Update virtual
element frames after layout. Test right-to-left layout, scrolling, reuse,
insertion, deletion, and rotation.

Add secondary behavior with `UIAccessibilityCustomAction`. Use localized,
specific action names and route them to the same business logic as visible
controls. Return success only when the operation succeeds.

For an adjustable UIKit control, override `accessibilityIncrement()` and
`accessibilityDecrement()`, clamp at real bounds, update the value, and provide
feedback. Do not create an adjustable trait with no working methods.

Support modal dismissal by overriding `accessibilityPerformEscape()` when the
presentation is dismissible and the system does not already provide the
behavior. Return `true` only after initiating the dismissal.

## Handle UIKit focus, modals, and announcements

Use notifications according to the context:

```swift
UIAccessibility.post(
    notification: .screenChanged,
    argument: screenHeading
)

UIAccessibility.post(
    notification: .layoutChanged,
    argument: validationErrorLabel
)

UIAccessibility.post(
    notification: .announcement,
    argument: "Saved to backlog"
)
```

- Use `.screenChanged` for a real new context.
- Use `.layoutChanged` for a meaningful partial update or logical focus target.
- Use `.announcement` for important status that should not steal focus.

Do not post several notifications for the same transition. Ensure the argument
exists in the active hierarchy. Avoid fixed delays; synchronize with actual
presentation and layout completion.

For a custom modal container, set `accessibilityViewIsModal` so background
content is not traversable, provide escape behavior when appropriate, move
focus into the modal logically, and return focus to the presenting control or a
predictable successor after dismissal.

## Preserve semantics across framework boundaries

For `UIViewRepresentable` and `UIViewControllerRepresentable`, make the
underlying UIKit hierarchy accessible and update its properties in
`updateUIView` or `updateUIViewController` as SwiftUI state changes. Do not add
a SwiftUI label while leaving stale UIKit children exposed.

For `UIHostingController` embedded in UIKit, inspect the combined hierarchy,
presentation containment, modal isolation, and focus transition at the bridge.
Avoid duplicating a hosted SwiftUI element with an accessible UIKit wrapper.

For reused cells and views, reset accessibility labels, values, traits, custom
actions, and hidden state during configuration. Stale semantics from previous
content are user-visible defects.

## Review implementation hazards

- `accessibilityIdentifier` mistaken for spoken text.
- Labels or values built once and not updated with state.
- An icon’s inferred label changing after an SF Symbol replacement.
- `.accessibilityHidden(true)` applied above meaningful descendants.
- `.combine` removing independent adjustment or text-reading behavior.
- A custom action duplicating the default action with a different outcome.
- `onTapGesture` replacing `Button` and losing role or activation behavior.
- Focus requested before a destination exists or after every state update.
- An announcement repeated by the native control’s own value feedback.
- Raw numeric or private traits copied from old articles.
- New APIs added without an availability check or affected-target build.
