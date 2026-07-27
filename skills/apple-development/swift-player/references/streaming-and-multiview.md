# Streaming, queues, and multiview

Use this reference to design buffering and quality policy, HLS and offline
playback, custom byte loading, FairPlay integration boundaries, queues,
looping, feeds, and simultaneous players.

## Contents

- Classify the content path
- Keep buffering policy evidence-based
- Treat HLS authoring as part of playback
- Separate transient, offline, custom, and protected storage
- Use queues and looping for their intended topology
- Bound playback in feeds
- Coordinate multiview deliberately
- Budget network, decode, memory, and audio

## Classify the content path

Identify the actual path before changing player settings:

- local file with direct random access;
- progressive HTTP media;
- HLS video on demand;
- ordinary live HLS;
- low-latency HLS;
- user-requested offline HLS;
- custom local or network-backed byte storage;
- FairPlay-protected content;
- a sequence, loop, feed, or simultaneous multiview.

Record manifest ownership, CDN behavior, authentication lifetime, content-key
service, offline expiration, supported routes, and server observability. A
client-only fix cannot repair an invalid playlist, missing segment, misaligned
rendition, expired license, or unsupported receiver.

For live media, record target latency, rewind window, live-edge behavior,
reconnect policy, and what "ended" means. Do not reuse VOD duration and replay
assumptions.

## Keep buffering policy evidence-based

Start with AVFoundation's defaults:

- keep `automaticallyWaitsToMinimizeStalling` enabled for ordinary long-form
  playback;
- keep `AVPlayerItem.preferredForwardBufferDuration` at `0` so the system
  chooses;
- avoid preroll until the product predicts a near-term start;
- let adaptive streaming select a rendition unless the product has a measured
  reason to constrain it.

Change one mechanism for one measured objective:

- use `playImmediately(atRate:)` for a latency-sensitive preview only when
  accepting additional stall risk;
- set `preferredPeakBitRate` from a bandwidth or product policy;
- set `preferredPeakBitRateForExpensiveNetworks` for the corresponding network
  cost policy where available;
- set `preferredMaximumResolution` from the viewport and transition contract;
- set `networkResourcePriority` to express relative importance among
  simultaneous players.

Do not treat these values as guarantees. Network conditions, rendition
availability, hardware decode resources, player count, and layer size also
affect the outcome.

Use `isPlaybackLikelyToKeepUp`, `isPlaybackBufferEmpty`,
`isPlaybackBufferFull`, loaded ranges, and seekable ranges as diagnostic and
reducer inputs. Do not toggle a spinner from any one buffer flag.

Cancel `preroll(atRate:completionHandler:)` through
`cancelPendingPrerolls()` when its predicted start no longer applies. Bound the
number of simultaneous prerolls.

## Treat HLS authoring as part of playback

Validate HLS against Apple's current authoring specification. Inspect:

- master and media playlist syntax and update behavior;
- codec, container, frame-rate, and device support;
- variant bandwidth declarations;
- segment duration, keyframe cadence, and rendition alignment;
- discontinuities and timeline continuity;
- audio, subtitle, caption, and accessibility characteristics;
- encryption and key rotation;
- live-window and low-latency tags;
- CDN status, caching, redirects, and content type.

Use `mediastreamvalidator` and `hlsreport` where available. Keep the exact test
URL and credentials out of committed logs and bug reports.

Do not call an `AVQueuePlayer` transition gapless solely because the client
queued both items. Gapless HLS also requires compatible media characteristics
and authoring continuity. Define the acceptable audio gap, video transition,
and measurement before claiming success.

Use low-latency HLS only for latency-sensitive live content with compatible
origin, CDN, playlist, player, and product behavior. It is not a generic VOD
startup optimization.

## Separate transient, offline, custom, and protected storage

Keep four lifecycles distinct:

1. **AVFoundation's transient streaming behavior**: system-managed data used to
   sustain current playback.
2. **User-requested offline HLS**: persistent media managed through current
   `AVAssetDownloadConfiguration` and `AVAssetDownloadTask` APIs, background
   restoration, storage policy, and expiration.
3. **Custom byte storage**: data exposed through `AVAssetResourceLoader` because
   the asset cannot be addressed by an ordinary supported URL.
4. **FairPlay content keys**: key acquisition and persistence managed through
   `AVContentKeySession`.

Do not market transient playback data as an offline download. Do not build a
filesystem HLS cache by scraping playlists and segments when AVFoundation's
offline lifecycle fits the requirement.

For offline playback:

- persist stable asset identity rather than a temporary task object;
- restore background download sessions;
- surface selection, progress, cancellation, expiration, and deletion;
- reuse compatible assets between download and playback;
- test partial, interrupted, expired, and storage-pressure states;
- inspect the selected SDK because older aggregate download APIs are
  deprecated in current SDKs.

For `AVAssetResourceLoader` custom bytes:

- answer content-information and byte-range requests correctly;
- serialize or synchronize access on the delegate's queue;
- honor cancellation promptly;
- support backpressure and bounded buffering;
- distinguish random-access local storage from network latency;
- never retain an entire large media file in one `Data` value by default.

Set `entireLengthAvailableOnDemand` only for data that is truly available with
local, bounded-latency random access. Do not set it for network filesystems,
remote caches, or storage that can block unpredictably.

For FairPlay:

- use `AVContentKeySession`; current Apple HLS guidance no longer supports
  FairPlay key loading through `AVAssetResourceLoader`;
- isolate certificate, SPC, CKC, persistent-key, renewal, expiration, and
  retry policy behind a content-key adapter;
- cancel key work when the item generation ends;
- measure key latency as a startup stage;
- never log certificates, signed requests, SPC/CKC payloads, persistent keys,
  authorization headers, or license-server secrets;
- verify online, offline, expired, revoked, and server-failure behavior against
  the content provider's contract.

## Use queues and looping for their intended topology

Choose by behavior:

- `AVQueuePlayer`: ordered sequential items.
- `AVPlayerLooper`: repeated playback of a template item through a queue.
- several `AVPlayer` instances: simultaneous independent or coordinated media.
- `AVPlaybackCoordinationMedium`: synchronized transport for logically related
  simultaneous timelines where supported.

For queues:

- own item preparation and observations per queued item;
- define preload depth and cancellation;
- handle insertion, removal, failure, and end without corrupting UI identity;
- preserve metadata and media-selection policy per item;
- measure transitions rather than assuming they are seamless.

For looping:

- retain the `AVPlayerLooper` for the loop lifetime;
- remember that it creates replicas of the template `AVPlayerItem`;
- include replicas and decoded media in the memory budget;
- do not manually mutate the portion of the queue managed by the looper;
- define loop exit and teardown explicitly.

## Bound playback in feeds

Prefer posters or asynchronously generated thumbnails for most cells. A
representative policy is:

- no player for offscreen cells;
- one active autoplay player;
- at most a small, measured set of near-visible prepared candidates;
- cancellation as soon as a candidate loses eligibility;
- lower bitrate or maximum resolution for preview-sized layers;
- promotion of the active or full-screen player's network priority;
- one product-level audio owner.

Do not prewarm every item in a long list. Do not keep a player per reused cell.
Do not let an offscreen player compete for network or decode resources merely
because its view retained a session.

Generate thumbnails asynchronously, set a bounded maximum size, use tolerances
appropriate to preview accuracy, and cancel generation for obsolete cells.
Budget decoded image size rather than judging poster memory by compressed file
size.

## Coordinate multiview deliberately

Decide first whether streams share a logical timeline.

For synchronized camera angles or accessibility views, use
`AVPlaybackCoordinationMedium` where supported instead of broadcasting
`play()`, `pause()`, and `seek()` manually. Let playback coordinators handle
rate changes, time jumps, startup synchronization, stalls, and interruptions.

For unrelated simultaneous content, do not impose a common clock. Still define
shared product policy for:

- the audible participant;
- interruption and route response;
- active or focused player;
- external playback;
- quality degradation;
- maximum stream count;
- memory and thermal pressure;
- session-wide stop and teardown.

Use `AVRoutingPlaybackArbiter` where supported to choose the preferred external
video participant and nonmixable audio participant. Test constrained AirPlay
routes; many receivers can present only one video or nonmixable audio stream.

Assign `networkResourcePriority` by product importance, not array order. Record
that it is a resource-allocation hint rather than a bandwidth reservation.

## Budget network, decode, memory, and audio

For every multi-item or multi-player design, set explicit upper bounds:

- active players;
- prepared items and prerolls;
- aggregate expected bitrate;
- maximum resolutions;
- simultaneously decoded video surfaces;
- poster and thumbnail memory;
- content-key and resource-loader requests;
- retained metrics and logs;
- audible streams.

Define a degradation order: reduce secondary resolution, stop offscreen
preparation, demote network priority, remove a secondary view, or fall back to a
poster. Validate the order under poor network, thermal pressure, backgrounding,
and external playback.
