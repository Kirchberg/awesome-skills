# Presentation and system integration

Use this reference to select an AVKit or custom presentation, preserve playback
through full-screen and Picture in Picture, and integrate audio sessions,
background behavior, remote commands, media selection, accessibility, and
external playback.

## Contents

- Choose the smallest presentation surface
- Split behavior by platform
- Preserve playback across presentation changes
- Configure audio-session behavior
- Handle interruptions and route changes
- Decide background behavior
- Publish Now Playing state and commands
- Support captions, audio options, and accessibility
- Handle AirPlay and external playback
- Maintain an availability matrix

## Choose the smallest presentation surface

Prefer the most system-owned surface that satisfies the product:

- Use `AVPlayerViewController` for standard video playback, full-screen
  behavior, system controls, PiP, media selection, external playback, hardware
  input, and platform evolution.
- Use SwiftUI `VideoPlayer` as a presentation adapter when its control and
  transition behavior is sufficient. Inject a stable external player.
- Use `AVPlayerLayer` when the product requires a genuinely custom video
  composition or control surface.
- Use an audio-only view model for audio playback; do not create a hidden video
  controller solely to gain remote-command behavior.

Document which system behaviors become application responsibilities before
choosing a custom player. Include captions, audio descriptions, VoiceOver,
keyboard and remote input, safe-area and rotation behavior, PiP, AirPlay, Now
Playing, route changes, and future SDK behavior.

Do not put session ownership in a `UIViewControllerRepresentable` coordinator
or a SwiftUI view merely because that is where the player is displayed. Let the
adapter attach and detach from the stable session.

## Split behavior by platform

Do not present an iOS recipe as a cross-platform implementation:

- On iOS and iPadOS, use `AVPlayerViewController`, UIKit or SwiftUI adapters,
  and `AVAudioSession` where the product audio policy requires it.
- On tvOS, prefer the system player and design for focus, remote input,
  platform media controls, routes, and tvOS-specific API availability. Treat
  AVKit's automatic Now Playing publication and command handling as the active
  stack for a system-player presentation; do not create an
  `MPNowPlayingSession` for that player.
- On visionOS, verify the selected window, immersive, spatial, and PiP
  presentation contract rather than assuming an iPad presentation lifecycle.
- On Mac Catalyst, distinguish Catalyst availability from native AppKit
  availability.
- On native macOS, use `AVPlayerView` or an AppKit/layer adapter as appropriate.
  Do not prescribe `AVAudioSession`, which is not the native macOS audio-session
  model; use the macOS lifecycle and audio APIs required by the product.
- Treat watchOS playback as outside this skill's declared platform scope.
  Inspect its target APIs separately instead of importing AVKit, PiP, or
  multiview assumptions.

Record availability from the actual SDK declarations. In the 26-generation
SDKs reviewed for this skill, AVFoundation Observation and several multiview
resource APIs are new. `AVPlaybackCoordinationMedium` is not a watchOS API;
`AVRoutingPlaybackArbiter` is limited to supported iOS/tvOS 26-era targets, and
its nonmixable-audio preference has a narrower platform contract. Keep every
such call behind a platform adapter and compile each supported target.

## Preserve playback across presentation changes

Model inline, full-screen, and PiP as presentation states over one session:

```text
stable PlaybackSession + AVPlayerItem
               │
      attach or move presentation
       ┌───────┼────────┐
     inline  full-screen  PiP
```

For every transition:

1. preserve player, item, current time, user intent, and metric session;
2. coordinate source and destination adapters so two visible outputs do not
   fight over ownership;
3. keep a poster until the destination output reports a first frame;
4. use AVKit delegate callbacks to align app chrome and navigation;
5. avoid a compensating seek when the player has continued on the same clock;
6. restore focus and accessible context after the transition.

Do not treat `onDisappear` as session teardown. Determine whether the view left
because playback ended, navigation abandoned the feature, full-screen began,
or PiP detached the presentation.

For custom layer hosting, inspect `AVPlayerLayer.isReadyForDisplay`. Reset
first-frame state when the output or item changes. Item readiness is not display
readiness.

## Implement Picture in Picture as a lifecycle

Use standard AVKit PiP when possible. For custom PiP:

- verify device, content, entitlement, and API support;
- keep the same player and session;
- own the PiP controller and delegate through an explicit presentation
  coordinator;
- represent start, active, stop, failure, and restore requests as reducer
  events;
- restore the correct feature screen before completing AVKit's restoration
  callback;
- handle the user closing PiP as a product terminal event when appropriate;
- do not automatically enter PiP without a documented platform-compliant flow.

Test PiP on a physical device. Include home-screen entry, app relaunch or
restoration when supported, route changes, remote commands, and item end.

## Configure audio-session behavior

On targets that provide `AVAudioSession`, derive its configuration from the
media and product contract. Long-form playback commonly uses category
`.playback` and, for video, mode `.moviePlayback`, but do not apply that as a
universal recipe. On native macOS, follow the app's macOS audio and lifecycle
contract instead.

Decide explicitly:

- whether playback mixes with or interrupts other audio;
- whether the app may play while the device is silent or locked;
- whether recording, voice chat, spoken-audio ducking, or Bluetooth input
  changes the category or options;
- when to activate and deactivate the session;
- which component owns configuration if several features use audio.

Activate close to actual playback so the app does not interrupt another audio
session prematurely. Coordinate deactivation with the shared app audio policy;
one feature must not deactivate a session still used by another.

Do not hide an audio-session change inside a view callback. Make configuration,
activation, and failure visible to the playback-session reducer or its owning
media coordinator.

## Handle interruptions and route changes

Treat the system as a source of facts, not as a direct command to toggle an
untracked `isPlaying` flag.

On interruption begin:

1. capture the current item identity and user intent;
2. publish the interrupted condition;
3. allow AVFoundation and the audio session to suspend transport;
4. cancel product work that cannot remain pending.

On interruption end:

1. inspect the system's resume option;
2. confirm the same session and item are current;
3. confirm the user has not paused, navigated away, or started other media;
4. reactivate the audio session when required;
5. resume only when every condition permits it.

On route change, classify the reason. For `.oldDeviceUnavailable`, especially a
headphone disconnect, normally pause to avoid unexpected private audio on the
speaker. Do not resume merely because a new route later appears.

Handle media-services loss and reset when the product supports long-lived audio
playback. Recreate invalidated system objects rather than assuming the prior
session remains usable.

## Decide background behavior

Enable the Audio, AirPlay, and Picture in Picture background mode only when the
product supports those behaviors. Keep entitlement and capability changes
visible in the implementation and review.

Do not pause on every `scenePhase == .background` transition:

- PiP may intentionally continue;
- audio playback may have a background contract;
- an external route may own presentation;
- a normal video without background rights may need its own pause policy.

Define behavior for lock, Control Center, incoming calls, app suspension,
foreground return, and item end. Verify on a device with a release-like build;
the simulator does not establish system lifecycle correctness.

## Publish Now Playing state and commands

Choose the integration from the selected SDK and deployment targets:

- Prefer `MPNowPlayingSession` with `AVPlayer` where supported and appropriate,
  except with AVKit's system player on tvOS.
- Use `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter` deliberately for
  older targets or a custom playback engine.
- Availability-gate the Swift `NowPlaying` framework introduced at WWDC26. As
  a prerelease-era API, do not make it the only implementation for shipped
  targets without confirming the final SDK contract.

Select exactly one publication and command stack for a local playback session.
On tvOS, count AVKit's automatic system-player integration as that one stack;
Apple explicitly says not to combine it with `MPNowPlayingSession`.
Do not use the Swift `NowPlaying` framework alongside
`MPNowPlayingInfoCenter`, `MPNowPlayingSession`, or
`MPRemoteCommandCenter` for the same local session; Apple defines mixed use as
undefined behavior. Fully tear down the active stack before enabling a fallback
or migrating the session.

Within `MPNowPlayingSession`, choose automatic or manual metadata publication:

- For automatic publication, keep `automaticallyPublishesNowPlayingInfo`
  enabled and place application-supplied metadata in each
  `AVPlayerItem.nowPlayingInfo`. Do not write to the session's
  `nowPlayingInfoCenter`.
- For manual publication, set `automaticallyPublishesNowPlayingInfo` to `false`
  before writing the session's `nowPlayingInfoCenter`, then own the complete
  metadata and timing publication contract.

Publish title, artist or series, artwork, duration when finite, elapsed time,
playback rate, live-stream facts, media type, and command availability from the
same product state as in-app controls.

For each remote command:

- enable only supported actions;
- validate the current item and target;
- route the action through the same session methods as local controls;
- return the correct command result;
- retain and remove handler registrations according to the API contract;
- avoid duplicate targets after session recreation.

Keep Lock Screen, Control Center, Dynamic Island, CarPlay, headset controls, and
in-app controls coherent. Do not publish signed media URLs, authentication
tokens, or internal error details as metadata.

## Support captions, audio options, and accessibility

Leave automatic media-selection criteria enabled unless the product has a
documented override. Load media-selection groups asynchronously where required.
Represent Off, Automatic, forced subtitles, captions, subtitles for the deaf
and hard of hearing, alternate audio, and audio descriptions without collapsing
their semantics.

Prefer the AVKit media-selection UI. For custom UI:

- use `AVMediaSelectionGroup` and `AVMediaSelectionOption`;
- respect locale and accessibility characteristics;
- preserve authored caption timing and the user's caption style;
- keep selection tied to the current item generation;
- make unavailable or changed options recover predictably.

Use authored captions and audio descriptions as the production baseline.
Availability-gate newer generated-subtitle or style-preview features; do not
substitute them silently for accessible source media.

Prefer native controls. For every custom control:

- provide an accurate accessibility label, value, trait, and action;
- expose play/pause state and seek increments coherently;
- support Dynamic Type and sufficient touch targets;
- avoid announcing every periodic time update;
- provide a discoverable way to stop autoplay or motion;
- test VoiceOver focus through inline, full-screen, PiP return, errors, and
  media-selection changes.

Use `$voice-over-accessibility` for a comprehensive VoiceOver audit, but keep
playback state and command semantics owned here.

## Handle AirPlay and external playback

Define whether external playback is allowed, how local presentation changes,
which player supplies audio, and how controls remain synchronized.

For multiview:

- choose a preferred player for constrained video routes;
- choose the participant for nonmixable audio routes;
- use `AVRoutingPlaybackArbiter` where the selected SDK supports the multiview
  policy;
- represent route arbitration and external playback in diagnostics.

Do not assume every receiver supports the same codecs, subtitle options, number
of streams, or transport behavior. Test representative AirPlay routes and
fallback behavior on real hardware.

## Maintain an availability matrix

Before using newer Observation, Now Playing, AVMetrics, multiview, subtitle, or
offline-download APIs, record:

- SDK used to compile;
- minimum platform version;
- runtime availability check;
- legacy implementation or explicit unsupported behavior;
- test coverage for both paths.

Avoid sprinkling availability checks across views. Put version-specific
adapters behind one session-facing protocol or narrow integration boundary.
