# Apple playback source map

Last reviewed: 2026-07-28.

Use this map for API-sensitive claims. Prefer the selected SDK's generated
interface and current Apple documentation over remembered signatures. Recheck
availability and deprecations whenever the Xcode or deployment baseline
changes.

## Contents

- Availability notes
- Required core
- Presentation and system integration
- Streaming, storage, and protected media
- Queues, looping, and multiview
- Diagnostics, testing, memory, and accessibility

## Availability notes

- Current Apple SDK documentation isolates principal `AVPlayer` and
  `AVPlayerItem` interaction to `MainActor`. Compile against the project's
  selected SDK and preserve its actual annotations.
- AVFoundation's Swift Observation integration is an OS 26-generation feature
  on supported platforms. It requires setting `AVPlayer.isObservationEnabled`
  before creating playback objects; progress still uses time-observer APIs.
- `AVMetrics` arrived for HLS playback in iOS 18 and related platform releases.
  Event types vary by SDK and media path.
- Current SDKs deprecate synchronous player-item access/error log retrieval.
  Select the current async fetch API or an availability-gated legacy adapter
  from the SDK interface.
- WWDC26 Now Playing and generated-subtitle material describes prerelease-era
  platform APIs as of this review date. Availability-gate it and keep shipped
  target fallbacks.
- Apple's 2024 HLS update states that FairPlay key loading through
  `AVAssetResourceLoader` is unsupported; use `AVContentKeySession`.
- Current offline-HLS APIs center on `AVAssetDownloadConfiguration` and
  `AVAssetDownloadTask`; inspect deprecations before copying aggregate-download
  examples from older sessions.

## Required core

1. [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer)
   — playback engine, transport, waiting, observers, and current item.
2. [AVPlayerItem](https://developer.apple.com/documentation/avfoundation/avplayeritem)
   — item readiness, timing, buffering, media selection, logs, and metrics.
3. [Observing playback state in SwiftUI](https://developer.apple.com/documentation/avfoundation/observing-playback-state-in-swiftui)
   — current AVFoundation Observation setup and SwiftUI playback pattern.
4. [Loading media data asynchronously](https://developer.apple.com/documentation/avfoundation/loading-media-data-asynchronously)
   — type-safe asynchronous asset inspection.
5. [Create a more responsive media app](https://developer.apple.com/videos/play/wwdc2022/110379/)
   — async asset and thumbnail work plus custom local data loading.
6. [Controlling the transport behavior of a player](https://developer.apple.com/documentation/avfoundation/controlling-the-transport-behavior-of-a-player)
   — play, pause, seek, tolerances, and transport policy.
7. [Monitoring playback progress in your app](https://developer.apple.com/documentation/avfoundation/monitoring-playback-progress-in-your-app)
   — periodic and boundary time observers.
8. [Remove a time observer](https://developer.apple.com/documentation/avfoundation/avplayer/removetimeobserver%28_%3A%29)
   — explicit observer-token teardown.
9. [Cancel pending seeks](https://developer.apple.com/documentation/avfoundation/avplayeritem/cancelpendingseeks%28%29)
   — obsolete seek cancellation.
10. [Cancel pending prerolls](https://developer.apple.com/documentation/avfoundation/avplayer/cancelpendingprerolls%28%29)
    — obsolete preroll cancellation.
11. [Replace the current item](https://developer.apple.com/documentation/avfoundation/avplayer/replacecurrentitem%28with%3A%29)
    — player-item replacement boundary.
12. [AVPlayer time control status](https://developer.apple.com/documentation/avfoundation/avplayer/timecontrolstatus-swift.property)
    — paused, waiting, and playing transport facts.
13. [AVPlayer waiting reason](https://developer.apple.com/documentation/avfoundation/avplayer/reasonforwaitingtoplay)
    — why requested playback is waiting.
14. [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer)
    and [isReadyForDisplay](https://developer.apple.com/documentation/avfoundation/avplayerlayer/isreadyfordisplay)
    — presentation layer and first-frame evidence.
15. [Playing video content in a standard user interface](https://developer.apple.com/documentation/avkit/playing-video-content-in-a-standard-user-interface)
    — Apple's AVKit sample for standard playback presentation.
16. [Create a great video playback experience](https://developer.apple.com/videos/play/wwdc2022/10147/)
    — system-player capabilities and product guidance.
17. [Discover media performance metrics in AVFoundation](https://developer.apple.com/videos/play/wwdc2024/10113/)
    — HLS `AVMetrics`, startup, stalls, requests, and summaries.
18. [Configuring your app for media playback](https://developer.apple.com/documentation/avfoundation/configuring-your-app-for-media-playback)
    — audio session, background capability, and playback setup.

## Presentation and system integration

- [AVPlayerViewController](https://developer.apple.com/documentation/avkit/avplayerviewcontroller)
  and [AVPlayerViewControllerDelegate](https://developer.apple.com/documentation/avkit/avplayerviewcontrollerdelegate)
  — standard controls and presentation lifecycle.
- [AVPlayerView](https://developer.apple.com/documentation/avkit/avplayerview)
  — native macOS AVKit presentation.
- [VideoPlayer](https://developer.apple.com/documentation/avkit/videoplayer) —
  SwiftUI playback presentation.
- [Adopting Picture in Picture in a standard player](https://developer.apple.com/documentation/avkit/adopting-picture-in-picture-in-a-standard-player)
  — AVKit-managed PiP.
- [Adopting Picture in Picture in a custom player](https://developer.apple.com/documentation/avkit/adopting-picture-in-picture-in-a-custom-player)
  — custom presentation requirements.
- [Restoring the UI after Picture in Picture](https://developer.apple.com/documentation/avkit/restoring-the-user-interface-for-picture-in-picture)
  — restoration completion contract.
- [Handling audio interruptions](https://developer.apple.com/documentation/avfaudio/handling-audio-interruptions)
  — interruption notification and resume policy.
- [Responding to audio route changes](https://developer.apple.com/documentation/avfaudio/responding-to-audio-route-changes)
  — route reasons and headphone-disconnect behavior.
- [Explore media metadata publishing and playback interactions](https://developer.apple.com/videos/play/wwdc2022/110338/)
  — Now Playing sessions, metadata, and multiple-player interactions.
- [MPNowPlayingSession](https://developer.apple.com/documentation/mediaplayer/mpnowplayingsession),
  [automaticallyPublishesNowPlayingInfo](https://developer.apple.com/documentation/mediaplayer/mpnowplayingsession/automaticallypublishesnowplayinginfo),
  [AVPlayerItem.nowPlayingInfo](https://developer.apple.com/documentation/avfoundation/avplayeritem/nowplayinginfo),
  [MPNowPlayingInfoCenter](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter),
  and [MPRemoteCommandCenter](https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter)
  — shipped-target Now Playing and command surfaces.
- [Meet the Now Playing framework](https://developer.apple.com/videos/play/wwdc2026/312/)
  and [Publishing media sessions](https://developer.apple.com/documentation/NowPlaying/publishing-media-sessions)
  — availability-gated Swift Now Playing framework.
- [Now Playing framework overview](https://developer.apple.com/documentation/NowPlaying)
  — framework boundary and the prohibition on mixed local publication stacks.
- [Selecting subtitles and alternative audio tracks](https://developer.apple.com/documentation/avfoundation/selecting-subtitles-and-alternative-audio-tracks)
  — media-selection groups, options, and automatic criteria.
- [Discover generated subtitles and subtitle styles](https://developer.apple.com/videos/play/wwdc2026/256/)
  — availability-gated OS 27 subtitle generation and style preview.
- [Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/)
  — view identity, lifetime, and dependency model.

## Streaming, storage, and protected media

- [Using AVFoundation to play and persist HTTP Live Streams](https://developer.apple.com/documentation/avfoundation/using-avfoundation-to-play-and-persist-http-live-streams)
  — Apple HLS playback and download sample.
- [HLS Authoring Specification for Apple Devices](https://developer.apple.com/documentation/http-live-streaming/hls-authoring-specification-for-apple-devices)
  — canonical playlist, rendition, codec, and delivery requirements.
- [Enabling Low-Latency HLS](https://developer.apple.com/documentation/http-live-streaming/enabling-low-latency-http-live-streaming-hls)
  — end-to-end low-latency live requirements.
- [Transition media gaplessly with HLS](https://developer.apple.com/videos/play/wwdc2021/10142/)
  — queue behavior plus content-authoring continuity.
- [Technical Note TN2436: Debugging HTTP Live Streaming](https://developer.apple.com/library/archive/technotes/tn2436/_index.html)
  — archived but still useful failure categories and validation workflow.
- [AVPlayer waiting and buffering](https://developer.apple.com/documentation/avfoundation/avplayer/automaticallywaitstominimizestalling)
  and [AVPlayerItem buffering policy](https://developer.apple.com/documentation/avfoundation/avplayeritem/preferredforwardbufferduration)
  — startup-versus-stall behavior.
- [AVAssetResourceLoader](https://developer.apple.com/documentation/avfoundation/avassetresourceloader)
  and [AVAssetResourceLoaderDelegate](https://developer.apple.com/documentation/avfoundation/avassetresourceloaderdelegate)
  — custom byte and content-information requests.
- [Offline playback and storage](https://developer.apple.com/documentation/avfoundation/offline-playback-and-storage)
  and [AVAssetDownloadConfiguration](https://developer.apple.com/documentation/avfoundation/avassetdownloadconfiguration)
  — current offline-HLS lifecycle.
- [FairPlay Streaming](https://developer.apple.com/streaming/fps/),
  [AVContentKeySession](https://developer.apple.com/documentation/avfoundation/avcontentkeysession),
  and [What's new in HLS 2024](https://developer.apple.com/streaming/Whats-new-HLS-2024.pdf)
  — protected-content architecture and current key-loading boundary.
- [Creating images from a video asset](https://developer.apple.com/documentation/avfoundation/creating-images-from-a-video-asset)
  — asynchronous, bounded thumbnail generation.

## Queues, looping, and multiview

- [AVQueuePlayer](https://developer.apple.com/documentation/avfoundation/avqueueplayer)
  — sequential playback topology.
- [AVPlayerLooper](https://developer.apple.com/documentation/avfoundation/avplayerlooper)
  — repeated item replicas and queue ownership.
- [Create a seamless multiview playback experience](https://developer.apple.com/videos/play/wwdc2025/302/)
  and [sample code](https://developer.apple.com/documentation/avfoundation/creating-a-seamless-multiview-playback-experience)
  — coordination, AirPlay routing, and quality.
- [AVPlaybackCoordinationMedium](https://developer.apple.com/documentation/avfoundation/avplaybackcoordinationmedium)
  — synchronized local playback coordinators.
- [AVRoutingPlaybackArbiter](https://developer.apple.com/documentation/avrouting/avroutingplaybackarbiter)
  — preferred external and nonmixable audio participant.
- [AVPlayer network resource priority](https://developer.apple.com/documentation/avfoundation/avplayer/networkresourcepriority-swift.property)
  — relative network importance among players.

## Diagnostics, testing, memory, and accessibility

- [Performance and metrics](https://developer.apple.com/documentation/xcode/performance-and-metrics)
  — Apple performance workflow and tools.
- [Analyze heap memory](https://developer.apple.com/videos/play/wwdc2024/10173/)
  — transient growth, persistent growth, and heap investigation.
- [Reducing your app's memory use](https://developer.apple.com/documentation/xcode/reducing-your-app-s-memory-use)
  and [Preventing memory-use regressions](https://developer.apple.com/documentation/xcode/preventing-memory-use-regressions)
  — measurement and regression protection.
- [Detect and diagnose memory issues](https://developer.apple.com/videos/play/wwdc2021/10180/)
  — Memory Graph, memgraph, MetricKit, and test metrics.
- [Testing a release build](https://developer.apple.com/documentation/xcode/testing-a-release-build)
  — release-like device and network testing.
- [Asynchronous tests and expectations](https://developer.apple.com/documentation/xctest/asynchronous-tests-and-expectations)
  — XCTest support for asynchronous behavior.
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
  and [Playing video](https://developer.apple.com/design/human-interface-guidelines/playing-video)
  — interaction and media presentation guidance.
- [Captions](https://developer.apple.com/documentation/mediaaccessibility/captions)
  — system caption preferences and styling.
