# Item lifecycle and transport

Use this reference to implement asynchronous preparation, item replacement,
transport commands, progress, seeking, end behavior, retry, and teardown.

## Contents

- Prepare media asynchronously
- Guard replacement with identity
- Install item-scoped observation
- Model play and pause as intent
- Implement seeking and scrubbing
- Observe progress economically
- Handle end, failure, and retry
- Tear down deterministically

## Prepare media asynchronously

Create a cancellable preparation operation for every requested item. Keep the
operation separate from the UI and store its handle on the session.

1. Advance a monotonically increasing request generation.
2. Cancel the previous preparation task.
3. Construct the asset with the required URL, options, resource loader, or
   content-key configuration.
4. Load required properties with `AVAsset.load(_:)` and other native async APIs.
5. Validate playability, protected-content expectations, required tracks, and
   product-specific metadata.
6. Check cancellation and request generation.
7. Create the `AVPlayerItem` and commit it on the session's actor.
8. Install item-scoped observations before applying pending play intent.

Load only properties required for the decision. Do not synchronously read
duration, tracks, metadata, or thumbnails when the backing media may require
I/O. Treat indefinite or nonnumeric duration as valid for live content and
derive controls from `seekableTimeRanges`.

Use an explicit result type for preparation failures. Distinguish cancellation,
unplayable content, network or manifest failure, content-key failure, policy
rejection, and an unexpected framework error. Avoid presenting cancellation
from rapid item replacement as a playback failure.

## Guard replacement with identity

Use both a request generation and object identity. Generation prevents a late
preparation from committing; item identity prevents an old callback or
notification from mutating the current item's state.

Apply this replacement order:

1. increment the generation;
2. cancel preparation, thumbnail, license, and retry work owned by the request;
3. call `cancelPendingSeeks()` on the old item;
4. call `cancelPendingPrerolls()` on the player;
5. stop old metric streams;
6. invalidate old KVO and remove object-filtered notifications;
7. clear item-derived reducer state;
8. create the new item context and install its observations;
9. request KVO initial delivery or explicitly snapshot every observed value;
10. call `replaceCurrentItem(with:)` and seed player-derived state;
11. apply current user intent only after the new item is ready.

Choose whether to replace with `nil` between items from the product contract.
Do not insert a visible empty transition merely because it simplifies code.
Conversely, do not leave the old item authoritative while the UI labels the new
item as current.

Do not reuse an `AVPlayerItem` across several players simultaneously. Create
item instances according to AVFoundation's ownership rules.

## Install item-scoped observation

Install only the signals required by the product state and diagnostics:

- item status and error;
- duration when it becomes available;
- loaded and seekable ranges when the UI displays them;
- presentation size or media selection when required;
- stall, end, failed-to-end, and relevant access/error events;
- HLS metric streams when supported;
- first-frame readiness on the active video output.

Filter notifications by the specific item. Route callbacks through one
session-owned reducer. On replacement, remove all item-scoped sources before
installing the new set.

Do not rely on observing only future changes. A local or already prepared item
can reach readiness before registration. Use KVO's `.initial` option where it
fits, or read and reduce each current value immediately after registering.
Guard initial delivery and snapshots with item identity and request generation
just like later callbacks.

Keep player-scoped observation separate:

- `timeControlStatus`;
- `reasonForWaitingToPlay`;
- external playback;
- mute, volume, and rate only when product state depends on them;
- periodic and boundary time observers.

Do not observe the same property through two mechanisms without documenting
which source is authoritative and why the duplicate exists.

## Model play and pause as intent

Represent a user or product request separately from the engine call:

```text
play requested
├── item ready and policy allows → invoke play
├── item preparing              → retain intent, apply after readiness
├── interrupted                 → retain or clear according to policy
├── failed                      → expose retry, do not loop blindly
└── ended                       → replay or stay ended according to contract
```

On pause, clear automatic-resume eligibility before calling `pause()`. A system
wait must not rewrite requested play as requested pause.

Choose among `play()`, `playImmediately(atRate:)`, and ordinary waiting from the
measured startup-versus-stall requirement. `playImmediately(atRate:)` is not a
generic latency optimization; it accepts a greater risk of running out of
buffer.

After an end event, define whether play means replay from zero, continue a
queue, request a fresh live edge, or remain ended. Avoid issuing an implicit
zero seek for a live stream.

## Implement seeking and scrubbing

Treat interactive scrubbing as a sequence with three phases:

1. **Begin**: capture the prior user intent and enter a seeking UI state.
2. **Change**: coalesce rapid targets, cancel obsolete pending seeks, and use
   reasonable tolerances for preview responsiveness.
3. **Commit**: seek to the final valid target with the precision justified by
   the product, then restore current intent if the generation still matches.

Do not issue an exact zero-tolerance seek for every pointer movement. Exact
seeks can require additional decoding and I/O. Do not assume completions arrive
in request order.

Clamp targets to valid finite duration or the current seekable window. Re-read
the window for live streams because it can move while the gesture is active.
Handle an empty seekable range without manufacturing a zero-based duration.

Define seek behavior across:

- item replacement;
- a pending interruption;
- end-of-item boundaries;
- queue transitions;
- PiP or external playback;
- live-edge controls;
- protected or offline content becoming unavailable.

Use a seek generation or target identity in addition to
`cancelPendingSeeks()`. Cancellation reduces obsolete work but does not make a
late callback semantically current.

## Observe progress economically

Use `addPeriodicTimeObserver(forInterval:queue:using:)` for timeline progress
and `addBoundaryTimeObserver(forTimes:queue:using:)` for sparse semantic
boundaries such as chapters.

Choose cadence from the UI:

- a static elapsed-time label often needs only one update per second;
- a visible scrubber commonly needs a few updates per second;
- analytics and first-frame instrumentation need event timestamps, not
  frame-rate UI polling.

Avoid a display-rate time observer unless the output truly needs it. Normalize
`CMTime` only after checking numeric validity. Keep UI progress separate from
buffered and seekable ranges.

Store each opaque observer token together with the exact player that returned
it. Remove it with `removeTimeObserver(_:)` before discarding or repurposing the
session. Never pass a token to a different player.

## Handle end, failure, and retry

Handle `AVPlayerItem.didPlayToEndTimeNotification`,
`failedToPlayToEndTimeNotification`, and
`playbackStalledNotification` as distinct events.

- **End**: publish an intentional terminal state and apply queue or replay
  policy.
- **Failed to end**: capture the underlying error chain and current item
  identity; do not label it a normal end.
- **Stall**: record the waiting context and measure duration; let the reducer
  exit waiting when transport actually resumes.
- **Item failure**: preserve the stage, URL classification without secrets,
  network state, and available metrics.

Define retry ownership, backoff, maximum attempts, and whether retry creates a
new asset or item. Cancel retry when the user changes media or pauses a
policy-driven autoplay flow. Do not retry deterministic manifest, entitlement,
or content-key errors as if they were transient connectivity.

## Tear down deterministically

Provide explicit item teardown and session teardown. Make both idempotent.

Item teardown must:

- cancel item preparation, seek, thumbnail, key, metric, and retry work;
- cancel pending seeks and prerolls;
- invalidate item observations;
- remove item-filtered notifications;
- clear item-specific reducer and diagnostic state;
- detach or replace the item according to the next transition.

Session teardown must additionally:

- remove every periodic and boundary time observer;
- unregister player-scoped KVO or Observation bridges;
- remove audio-session, app-lifecycle, PiP, and route registrations it owns;
- unregister remote-command targets it installed;
- detach presentation adapters;
- stop playback and release queue or looper policy objects;
- mark the reducer terminated so late events are ignored.

Use `deinit` as a final assertion or fallback, not the only cleanup path. Test
teardown during rapid replacement and navigation; a retained session may never
deinitialize even while old item resources should already be gone.
