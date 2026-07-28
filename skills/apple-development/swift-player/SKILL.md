---
name: swift-player
description: Use when designing, implementing, refactoring, reviewing, debugging, or profiling Swift media playback for iOS, iPadOS, tvOS, visionOS, macOS, or Mac Catalyst with AVFoundation, AVKit, SwiftUI, or UIKit/AppKit. Trigger for AVPlayer, AVQueuePlayer, AVPlayerItem, audio or video players, HLS/VOD/live/offline playback, loading or seeking, buffering and stalls, playback state, player lifetime, observation teardown, inline/full-screen/Picture in Picture transitions, background audio, interruptions and route changes, Now Playing or remote commands, subtitles and accessibility, multiple synchronized players, AirPlay, FairPlay or resource loading, playback metrics, memory, and playback tests.
---

# Engineer resilient Swift playback

## Define the outcome

Produce a playback flow with one explicit session owner, a reducible product
state, bounded asynchronous work, deterministic teardown, coherent system
integration, and evidence for startup, stalls, failures, and memory.

Treat `AVPlayer` as an engine rather than a UI state model. Keep user intent,
item readiness, transport activity, presentation lifecycle, and system
conditions distinct. A compiling player is not complete if stale observations,
unbounded preloading, interruption bugs, or unmeasured stalls remain.

## Read references selectively

- Read `references/architecture-and-state.md` before choosing session ownership,
  state inputs, Observation or KVO boundaries, and SwiftUI identity.
- Read `references/lifecycle-and-transport.md` before preparing or replacing an
  item, seeking, observing time, handling completion, or tearing down playback.
- Read `references/presentation-and-system-integration.md` for `VideoPlayer`,
  `AVPlayerLayer`, `AVPlayerViewController`, full-screen, Picture in Picture,
  audio sessions, background playback, Now Playing, remote commands, media
  selection, accessibility, AirPlay, or external playback.
- Read `references/streaming-and-multiview.md` for HLS, buffering, quality,
  queues, looping, feeds, custom resource loading, offline media, FairPlay, or
  coordinated simultaneous players.
- Read `references/diagnostics-and-testing.md` before diagnosing a playback
  symptom, making a performance claim, defining telemetry, or reporting
  implementation completeness.
- Read `references/sources.md` whenever a claim is SDK-sensitive, unfamiliar,
  disputed, or requires an Apple sample or canonical API reference.

Repository instructions, supported platforms, the selected SDK, deployment
targets, content contracts, and the user's requested scope override generic
examples. Availability-check APIs at the call site; never raise a deployment
target silently.

## Route the request

Choose one lead mode:

- **Explain**: clarify engine, item, transport, buffering, and presentation
  semantics without editing.
- **Design**: specify ownership, state transitions, cancellation, content
  policy, system integration, failure behavior, and evidence before APIs.
- **Review or diagnose**: inspect the actual ownership graph and event sequence;
  report root causes and prioritized findings without fixing unless requested.
- **Implement**: make the smallest lifecycle-complete change and validate it.
- **Profile**: for measurement-dependent playback tuning or a performance claim,
  establish an equivalent scenario, measure, change one supported mechanism,
  and measure again.
- **Research**: prefer current Apple documentation and samples; separate
  verified behavior from inference and older deployment-target fallbacks.

In Implement mode, apply a safe correction immediately when ownership, event
ordering, cancellation, observation teardown, or API semantics prove it.
Do not leave it as advice because a network profile, Simulator, physical
device, or performance baseline is unavailable. Run available correctness
checks and keep startup, stall, memory, and buffering claims pending until
measured.

Lead with `$swift-player` when the core question is media-session behavior.
Use `$swift-concurrency` for a deeper isolation or task-graph problem,
`$swiftui-optimization` for view invalidation or scrolling behavior, and
`$app-performance` for a whole-app performance investigation.

Do not lead with this skill for camera or microphone capture, recording,
editing, composition, export, transcoding, `AVAudioEngine`, DSP, or
backend-only HLS authoring unless playback is the specific boundary in scope.

## Establish the playback contract

Before editing:

1. Read repository instructions and inspect version-control status.
2. Record platform, Xcode and SDK, deployment targets, UI framework, and whether
   the project enables AVFoundation Observation.
3. Classify the media: audio or video; local, progressive, HLS VOD, live,
   low-latency live, offline, protected, queued, looped, or multiview.
4. Record product semantics for autoplay, mute, resume, end, retry, scrubbing,
   backgrounding, interruptions, routes, full-screen, PiP, and remote commands.
5. Name the owner of the player, current item, preparation task, observations,
   time observers, notification tokens, metric streams, and presentation
   adapters. Give each one an end condition.
6. Define the focused build, tests, network conditions, device checks, and
   measurements that will prove the requested outcome.

Do not invent server, manifest, key-server, entitlement, audio-session, or
background-mode behavior. Surface missing contracts before encoding policy.

## Preserve a stable session

Keep `AVPlayer` or `AVQueuePlayer` in a playback-session object whose lifetime
matches the product flow, not a transient SwiftUI `body`, list cell, or
presentation controller. Attach `VideoPlayer`, `AVPlayerLayer`, or
`AVPlayerViewController` as presentation adapters.

Use the system player by default when it meets the product requirements. A
custom control surface inherits responsibility for accessibility, media
selection, full-screen, PiP, remote input, and platform conventions.

For inline → full-screen → PiP transitions, move or reconnect presentation
while retaining the session and item. Do not pause merely because a presenting
view receives `onDisappear`. Keep a poster until the active output reports a
displayable first frame.

## Reduce signals into product state

Keep requested playback intent separate from observed transport state. Reduce
at least these inputs:

- `AVPlayerItem.status`;
- `AVPlayer.timeControlStatus` and `reasonForWaitingToPlay`;
- current and seekable time, duration, and buffer signals;
- end, stall, and failure notifications;
- preparation, seek, and retry generations;
- interruption, route, background, PiP, and external-playback events;
- first-frame readiness for video.

Model domain states such as `idle`, `preparing`, `readyPaused`, `playing`,
`waiting(reason)`, `seeking`, `ended`, and `failed(error)`. Represent
interruption and presentation facts orthogonally when collapsing them would
lose user intent. Never use `rate == 0` as the sole definition of paused,
buffering, ended, or failed.

## Make replacement and teardown symmetric

When replacing an item:

1. Advance a request generation and cancel the preparation task.
2. Cancel pending seeks and prerolls.
3. Remove old item observations, notifications, metric streams, and derived
   item state.
4. Create the new item context and install observations with initial delivery
   or an explicit current-value snapshot.
5. Replace the current item and seed player-derived state.
6. Publish readiness or failure only if the request generation is still
   current.
7. Restore playback only when current user intent and policy allow it.

Explicitly remove every periodic or boundary time observer from the player that
created it. Do not defer correctness to `deinit`; teardown must also run for
item replacement, session reset, and cancelled presentation flows.

## Apply deliberate media policy

- Load asset properties asynchronously in cancellable work. Do not perform
  media I/O through synchronous property access on the main actor.
- Coalesce scrubber seeks, cancel obsolete seeks, use tolerances during
  interactive movement, and reserve exact seeking for a justified final target.
- Leave forward-buffer selection to AVFoundation by default. Override startup,
  bitrate, resolution, and buffer policy per measured scenario.
- Bound active players and prewarming in feeds. Prefer posters or async
  thumbnails for offscreen content.
- Treat HLS authoring, CDN responses, content keys, and playlist continuity as
  part of playback correctness. `AVQueuePlayer` alone does not guarantee a
  gapless transition.
- Use Apple offline-download and content-key lifecycles where they fit. Do not
  build a whole-file `Data` cache behind `AVAssetResourceLoader`.

## Integrate with the system coherently

Configure the audio session and background capabilities from the product
contract. Handle interruptions and route changes as state-machine inputs, and
resume only when system options and the prior user intent both permit it.

Keep Now Playing metadata, elapsed time, rate, and command availability aligned
with the same domain state as in-app controls. Gate the current Now Playing
framework by SDK and deployment target; preserve a deliberate
`MPNowPlayingInfoCenter` and `MPRemoteCommandCenter` fallback when required.

Treat PiP, AirPlay, external playback, captions, alternate audio, and
accessibility as first-class playback behavior. Verify custom controls with
VoiceOver, Dynamic Type, hardware input where applicable, and the system's
media-selection expectations.

## Verify and report

Run the repository's formatting, static analysis, focused tests, and affected
builds. Exercise rapid item replacement, repeated seeks, slow and lossy
networks, background and foreground, interruption and route changes, end and
retry, inline/full-screen/PiP, and every supported multi-player mode.

Measure user-intent-to-first-frame or first-audio latency, stall count and
duration, seek latency, failures by stage, active player and task counts, and a
memory baseline across repeated open/close cycles. Use `AVMetrics` for supported
HLS paths and retain access logs, error logs, notifications, signposts, and
device traces for other paths.

Finish with the mode, environment, content contract, ownership graph, state and
cancellation model, changes or findings, checks run, measured evidence, system
integration, public behavior changes, and remaining uncertainty. Never claim
seamless playback, a fixed leak, or better buffering without corresponding
evidence.
