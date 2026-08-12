# Controllers, containment, and presentation

## Keep controllers cohesive

Let a view controller own one screen or presentation responsibility: bind view
state, coordinate child UI, respond to lifecycle, and route user intent. Move
networking, persistence, domain policy, and unrelated transformations behind
injected dependencies. Do not extract every delegate method mechanically; split
responsibilities where ownership, reuse, or tests become clearer.

Use lifecycle methods for their documented purpose. Keep one-time hierarchy
wiring in `viewDidLoad()`, appearance-sensitive work in the matching appearance
callbacks, size adaptation in transition or trait mechanisms, and cleanup at the
point the owned activity should actually stop. Do not assume disappearance means
deallocation or permanent cancellation.

## Use standard containers first

Prefer `UINavigationController`, `UITabBarController`, `UISplitViewController`,
page controllers, and search controllers when their behavior matches the flow.
Use semantic navigation through `show(_:sender:)` and
`showDetailViewController(_:sender:)` when container adaptation should decide
the presentation.

For a custom container, maintain the parent-child contract:

1. Call `addChild(_:)` before adding the child view.
2. Add and constrain the child view within the container's hierarchy.
3. Call `didMove(toParent:)` after installation.
4. Before removal, call `willMove(toParent: nil)`.
5. Remove the child view, then call `removeFromParent()`.

Forward appearance, status-bar, home-indicator, rotation, and trait behavior only
when custom container semantics require an override. Test nested presentation,
interactive transitions, and child replacement.

## Present from the correct context

Resolve the presenting controller from the owned scene and current hierarchy;
do not present from a stale controller or global key-window shortcut. Avoid
presenting while another transition is incomplete. Make repeated input idempotent
and make dismissal ownership explicit.

Configure `UISheetPresentationController` after assigning the modal presentation
style and before presentation. Choose detents, scrolling expansion, grabber,
edge attachment, and dismissal behavior from the task. Treat custom detents and
newer properties as availability-scoped.

Configure popovers with a valid `sourceView` and `sourceRect` or
`barButtonItem`. Decide whether compact adaptation should become a sheet or
remain a popover. Never assume an iPhone-only presentation environment.

Use a presentation-controller delegate when the component must observe or
control adaptive presentation and interactive dismissal. Preserve unsaved state
and explain why dismissal is prevented.

## Preserve navigation and restoration

Keep navigation state separate from view rendering when it must survive scene
reconnection, deep links, or restoration. Define stable restoration identifiers
and reconstruct dependencies without serializing transient objects.

Route URLs, activities, and other external inputs into the correct scene and
navigation owner. Test cold start, warm routing, repeated route delivery,
cancellation, and restoration with missing or obsolete data.
