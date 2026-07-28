# Core Animation and frame driving

Use this reference for layer-level animation, model and presentation state,
explicit `CAAnimation`, timing hierarchies, interruption, display-synchronized
updates, and variable refresh rates.

## Contents

- Understand the layer trees
- Choose implicit or explicit animation
- Keep model state authoritative
- Interrupt from presentation state
- Control Core Animation time
- Choose a frame driver
- Support variable refresh rates
- Bound rendering and lifecycle
- Review failure modes

## Understand the layer trees

Keep the conceptual states distinct:

- the **model layer** stores the durable property values configured by the app;
- the **presentation layer** exposes an approximate current onscreen state while
  animation is active;
- the render system consumes committed layer state and animation metadata to
  produce frames.

Treat the presentation layer as read-only, short-lived observation. Do not
persist references to presentation-layer objects and do not mutate them.

Core Animation efficiently composites prepared layer content. It does not make
arbitrary per-frame layout, path generation, image decoding, or view-hierarchy
mutation free.

## Choose implicit or explicit animation

UIKit generally controls layer actions for view-backed layers. Do not assume a
property assignment on a view's backing layer will receive the same implicit
animation behavior as a standalone layer.

Use `CATransaction` to group layer changes, set completion, configure duration
or timing where implicit actions apply, and disable actions for a deliberate
model update:

```swift
CATransaction.begin()
CATransaction.setDisableActions(true)
layer.position = target
CATransaction.commit()
```

Use explicit `CABasicAnimation`, `CAKeyframeAnimation`, `CASpringAnimation`,
`CAAnimationGroup`, or `CATransition` when layer-specific timing, path,
keyframes, grouping, or snapshot-like transitions are required.

Prefer higher-level SwiftUI or UIKit animation when it already expresses the
product state and interruption contract.

## Keep model state authoritative

An explicit animation object does not, by itself, make its `toValue` the
durable model-layer value. Update the model layer separately:

```swift
let start = layer.presentation()?.position ?? layer.position

CATransaction.begin()
CATransaction.setDisableActions(true)
layer.position = target
CATransaction.commit()

let animation = CABasicAnimation(keyPath: "position")
animation.fromValue = start
animation.toValue = target
animation.duration = 0.35
layer.add(animation, forKey: "position")
```

Set a valid key path and compatible value type. Keep the animation's final
value aligned with the already-updated model state.

Do not use `fillMode` plus `isRemovedOnCompletion = false` as a substitute for
updating model state. It leaves the model and presentation inconsistent and
complicates hit testing, layout, interruption, and future animation.

## Interrupt from presentation state

When replacing a running layer animation:

1. sample the relevant presentation value;
2. update the model to the new target with actions disabled;
3. remove or replace the obsolete animation deliberately;
4. animate from the sampled value to the new target;
5. keep one owner for completion and cleanup.

Sample all coupled values in one coherent step when position, transform,
opacity, or path must remain synchronized.

For transforms, verify value representation and coordinate system. For paths,
ensure compatible topology when expecting smooth interpolation.

Presentation sampling preserves position, not automatically velocity. If
velocity continuity matters, use a spring or custom timing model whose units
and prior motion are available. Do not infer velocity from two noisy frame
samples unless the design and tests justify that estimator.

## Control Core Animation time

Core Animation uses local media time. Use `CACurrentMediaTime()` for media-time
coordination rather than wall-clock dates.

Layer timing can apply speed, time offset, begin time, repeat, and parent-child
time conversion. For pause and resume:

- convert time in the correct layer timing space;
- store the paused local time;
- restore speed and begin time in the documented order;
- test nested layers and repeated pause/resume;
- clear temporary timing state after completion.

Avoid building a second timing system with wall-clock delays around Core
Animation. Prefer animation groups or a single local-time contract.

## Choose a frame driver

Use no manual frame driver for ordinary property interpolation.

Use `CADisplayLink` when a Core Animation or cross-framework system genuinely
needs display-synchronized callbacks and the current platform supports it.

Use `UIUpdateLink` on supported UIKit platforms when work belongs in the UI
update cycle and its API better expresses the required cadence. It is stable
from the iOS 18 SDK generation on its documented platforms; check selected SDK
availability. Keep `requiresContinuousUpdates` false unless continuously
changing content actually requires it.

Use `TimelineView` for SwiftUI time-dependent drawing when its schedule and
lifecycle match the behavior.

Do not use a display link to “make an animation smoother” when Core Animation
or SwiftUI can interpolate the same property.

## Support variable refresh rates

Never assume 60 FPS or a fixed callback interval. Compute simulation and motion
from timestamps:

```swift
let elapsed = min(timestamp - previousTimestamp, maximumStep)
position += velocity * CGFloat(elapsed)
previousTimestamp = timestamp
```

Choose how to handle a large delta after a stall, debugger pause, background
transition, or display change:

- clamp for a stable real-time simulation;
- integrate in bounded substeps;
- jump to wall-clock-derived state;
- pause and restart from an explicit origin.

Use preferred frame-rate APIs only after defining the product need and power
tradeoff. The system may choose an actual refresh cadence different from the
requested range.

Keep visual velocity in units per second, not units per frame.

## Bound rendering and lifecycle

For layers and frame-driven content:

- create paths, images, gradients, and other reusable inputs outside the frame
  callback where possible;
- avoid allocation, decoding, logging, and layout in every callback;
- set `shadowPath` when a stable explicit shape avoids repeated shadow
  calculation and visual correctness is preserved;
- bound mask, blur, transparency, and rasterized surface area;
- stop updates when static, hidden, backgrounded, or deallocated;
- remove observers and invalidate links from the owner;
- profile memory, GPU or renderer work, and power on hardware.

Do not set `shouldRasterize` or another cache flag speculatively. Animated
scale, dynamic content, and large surfaces can make rasterization slower or
blurrier.

## Review failure modes

Look for:

- explicit animation without a matching model-layer update;
- presentation-layer mutation or retained presentation objects;
- fill mode used as persistent state;
- wall-clock timing mixed with layer local time;
- a new animation starting from the old model value and jumping;
- manual callbacks for a property Core Animation can interpolate;
- fixed-per-frame movement;
- a continuous update link left active for static content;
- synchronous work or allocation in every frame callback;
- unmeasured rasterization, mask, blur, shadow, or offscreen work;
- cleanup depending only on `deinit`.
