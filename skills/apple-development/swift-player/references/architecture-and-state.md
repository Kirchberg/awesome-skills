# Playback architecture and state

Use this reference to design the ownership graph, SwiftUI integration,
observation boundary, and product state before implementing transport commands.

## Contents

- Establish one session owner
- Separate engine, presentation, and product state
- Place isolation deliberately
- Select Observation or KVO
- Reduce events into domain state
- Preserve SwiftUI identity
- Review architectural failure modes

## Establish one session owner

Give the playback flow a stable owner whose lifetime matches the product
experience:

```text
PlaybackSession
├── AVPlayer or AVQueuePlayer
├── current AVPlayerItem
├── user intent
├── state reducer
├── preparation and metric tasks
├── KVO/Observation and notification registrations
├── periodic and boundary time observers
└── teardown and cancellation

Presentation adapters
├── SwiftUI VideoPlayer
├── AVPlayerLayer host
├── AVPlayerViewController
└── Picture in Picture controller or delegate
```

Keep the session above a transient cell, sheet, or destination when playback
must survive that surface. Let navigation or a feature coordinator decide when
the session truly ends.

Use one player per independent playback timeline. Use `AVQueuePlayer` for an
ordered sequence, not as a global pool. Use several players only when content
must play simultaneously; define resource and audio policies before creating
them.

## Separate engine, presentation, and product state

Keep these concepts independent:

- **Engine**: player, item, clock, media pipeline, queue, and transport calls.
- **User intent**: requested play or pause, target item, requested seek, mute,
  selected media options, and retry intent.
- **Observed transport**: item readiness, time-control status, waiting reason,
  current time, seekable ranges, end, stall, and failure.
- **System conditions**: interruption, route, foreground, external playback,
  and resource constraints.
- **Presentation**: inline, full-screen, PiP, attached output, poster, controls,
  and first-frame readiness.
- **Product state**: the small reducer output consumed by UI and analytics.

Do not make a presentation object the authoritative owner of the player unless
its lifetime intentionally defines the entire playback session. Do not infer
user intent from `rate`, because a requested play may currently be waiting and a
zero rate can mean several unrelated conditions.

## Place isolation deliberately

Inspect the selected SDK's concurrency annotations. Current Apple SDKs isolate
core `AVPlayer` and `AVPlayerItem` interaction to `MainActor`; keep a
UI-controlled playback session on `MainActor` unless the actual declarations
and architecture prove a different boundary.

Perform network, manifest, license-server, cache, and analytics work through
their native asynchronous APIs. Return immutable results to the session owner.
Never add a detached task merely to bypass an actor annotation.

After every suspension:

1. check cancellation;
2. compare the request generation or item identity;
3. verify the session still wants the result;
4. then mutate the player or publish state.

Treat delegate callbacks, notifications, KVO, and metric streams as external
events. Hop to the session's isolation domain before reducing them. Preserve
ordering when event order changes semantics.

## Select Observation or KVO

Use the AVFoundation Observation integration only when the selected SDK and
deployment target support it.

- Set `AVPlayer.isObservationEnabled` before creating any playback objects.
- Treat that process-wide opt-in as startup configuration. Do not toggle it
  after objects exist; current documentation defines that as an exception.
- Observe only properties that the SDK exposes through Observation.
- Continue using a periodic time observer for playback progress; current time
  is not a continuously observed property.
- Keep the session's state model as the UI dependency. Avoid making an entire
  player graph an accidental SwiftUI dependency.

For older targets or properties outside Observation, use KVO or documented
notifications:

- retain every `NSKeyValueObservation`;
- invalidate item-scoped observations before releasing or replacing the item;
- record which object and item generation produced each callback;
- publish UI state on the session's actor;
- do not combine KVO, Observation, and polling for the same fact without one
  named source of truth.

Store notification tokens and remove them explicitly. Prefer object-filtered
item notifications so an old item cannot mutate the new item's state.

## Reduce events into domain state

Use a pure reducer where practical. Feed it explicit events instead of reading
scattered player properties from views.

At minimum, define events for:

- preparation started, succeeded, failed, or cancelled;
- item status changed;
- time-control status or waiting reason changed;
- progress, duration, loaded range, and seekable range changed;
- seek started, completed, superseded, or failed;
- first video frame became displayable;
- playback stalled, reached the end, or failed to reach the end;
- interruption began or ended, and an audio route changed;
- app background or foreground transition;
- full-screen, PiP, or external-playback transition;
- retry or item replacement;
- teardown.

A useful product state vocabulary is:

```text
idle
preparing
readyPaused
playing
waiting(reason)
seeking(origin, target)
ended
failed(classifiedError)
```

Keep `interrupted`, `backgrounded`, `pictureInPicture`, and
`externalPlayback` as orthogonal facts when a single enum would erase playback
intent. For example, an interruption can begin while the product state was
playing or already paused; only the former may be eligible to resume.

Derive waiting UI from `timeControlStatus`, `reasonForWaitingToPlay`, item
readiness, and recent progress. Treat buffer booleans as supporting signals, not
as a complete spinner state.

For video, keep the poster visible until the active `AVPlayerLayer` reports
`isReadyForDisplay` or the chosen AVKit presentation provides equivalent
first-frame evidence. `AVPlayerItem.Status.readyToPlay` only establishes media
readiness, not that a frame is on screen.

## Preserve SwiftUI identity

Create or inject the session at a stable feature boundary. A representative
shape for current Observation-based code is:

```swift
@MainActor
@Observable
final class PlaybackSession {
    let player: AVPlayer
    private(set) var state: PlaybackState = .idle

    private var preparationTask: Task<Void, Never>?
    private var itemObservations: [NSKeyValueObservation] = []
    private var notificationTokens: [NSObjectProtocol] = []
    private var periodicTimeObserver: Any?
    private var requestGeneration = 0
}
```

Use `@State` for an owned `@Observable` session or `@StateObject` for an owned
`ObservableObject`, subject to the project's deployment targets and
architecture. Inject an existing session when playback must outlive a
destination.

Do not:

- construct `AVPlayer(url:)` in `body`;
- key the session by a view value that changes during layout or navigation;
- pause unconditionally in `onDisappear`;
- derive all UI directly from mutable AVFoundation objects;
- retain a presentation controller from the session when a narrow delegate
  adapter is sufficient.

## Review architectural failure modes

Reject a design until it answers:

1. Who owns the session, and what exact event ends it?
2. Can presentation change without replacing the player or item?
3. Which state represents user intent while the engine waits?
4. Which callback wins after rapid item replacement?
5. How does every task, observation, notification, metric stream, seek, and
   time observer terminate?
6. Which actor publishes product state?
7. What proves a first frame rather than merely a ready item?
8. What resource limit applies to simultaneous or prewarmed players?
