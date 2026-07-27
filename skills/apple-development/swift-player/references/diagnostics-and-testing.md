# Playback diagnostics and testing

Use this reference to diagnose real playback failures, define telemetry, test
state and lifecycle behavior, profile memory, and make evidence-bounded
completion claims.

## Contents

- Start with a measurement contract
- Correlate one playback timeline
- Use modern and legacy diagnostics deliberately
- Classify failures by stage
- Test reducer and cancellation semantics
- Exercise transport and system integration
- Stress network, HLS, and multi-player policy
- Establish a memory baseline
- Report only supported conclusions

## Start with a measurement contract

Define the scenario before collecting data:

- device model and OS;
- Xcode, SDK, build configuration, and app version;
- media classification and a privacy-safe asset identifier;
- local, Wi-Fi, cellular, constrained, expensive, or simulated network;
- cold or warm process and cache state;
- inline, full-screen, PiP, background, or external route;
- player count, viewport sizes, and audio owner;
- expected start, seek, buffering, retry, and end behavior.

Record clocks and endpoints for the metrics that matter:

- user intent → item preparation started;
- preparation → item ready or failed;
- user intent → first audible sample or displayed frame;
- play request → transport playing;
- stall start → transport recovery or terminal failure;
- seek request → accepted target and completion;
- interruption or route event → product response;
- item replacement → old-context teardown;
- session teardown → stable memory baseline.

Do not compare different media, routes, network conditions, build modes, or
cache states as if one code change caused the difference.

## Correlate one playback timeline

Assign a session ID, item generation, seek generation, and privacy-safe content
ID. Include them in structured logs, signposts, reducer events, and metric
records.

Create signpost intervals for:

- prepare;
- content-key request when applicable;
- preroll;
- startup;
- first frame;
- stall;
- seek;
- item replacement;
- PiP and full-screen transition;
- teardown.

Log state transitions rather than polling snapshots. Include the prior state,
event, new state, user intent, item generation, and monotonic timestamp. Avoid
dumping entire manifests, errors with credentials, or media URLs.

Capture the underlying error chain and relevant `AVError` information. Redact:

- signed URL query strings;
- cookies and authorization headers;
- user identifiers;
- certificates, SPC and CKC payloads, or persistent content keys;
- filesystem paths that reveal private user data;
- subtitle or metadata text not required for diagnosis.

## Use modern and legacy diagnostics deliberately

For supported HLS paths, prefer `AVMetrics` from `AVPlayerItem`:

- subscribe only to event types required by the investigation;
- bind the async metric stream to the item context;
- cancel it during item replacement;
- correlate playlist, segment, content-key, likely-to-keep-up, stall, variant
  switch, seek, rate, error, and playback-summary events as available;
- retain bounded aggregates rather than an unlimited event history.

Use startup and stall events to locate the slow stage instead of treating every
wait as a generic network problem. Inspect associated URL-session task metrics
only after applying privacy redaction.

For older deployments, use documented item notifications and access/error logs
available in that SDK. Current SDKs deprecate synchronous `accessLog()` and
`errorLog()` access; prefer current asynchronous fetch APIs where available and
keep the legacy path behind an availability adapter. Never suppress a
deprecation warning without recording the deployment-target reason.

Use Instruments, Xcode Organizer, MetricKit, XCTest or Swift Testing, and
Network Link Conditioner according to the question. Do not infer a memory leak
from a single peak or a network regression from one manual run.

## Classify failures by stage

Report the earliest supported failing stage:

- source resolution or authentication;
- asset property loading;
- manifest or media format validation;
- content-key acquisition;
- player-item readiness;
- initial buffering;
- first-frame presentation;
- mid-play segment or network failure;
- seek;
- queue transition;
- interruption, route, background, PiP, or external playback;
- offline availability or expiration;
- teardown or resource accumulation.

Differentiate:

- deterministic policy or authoring errors;
- transient connectivity;
- cancellation caused by current user behavior;
- stale callbacks from an obsolete generation;
- unsupported device, OS, codec, route, or entitlement;
- application state-reducer defects;
- unproven hypotheses.

For HLS, inspect nested errors, response status, playlist updates, segment
availability, rendition switches, and `mediastreamvalidator` output. A client
spinner change is not a fix for an invalid stream.

## Test reducer and cancellation semantics

Keep the reducer testable without a real player. Cover event sequences, not only
individual enum cases:

- play requested before preparation completes;
- pause requested while waiting;
- old preparation succeeds after a new item was requested;
- old item end or failure arrives after replacement;
- interruption begins while playing versus while paused;
- interruption ends after user pause or navigation;
- stall begins and playback resumes;
- seek is superseded, cancelled, fails, or completes out of order;
- end followed by replay, queue advance, or no action;
- PiP activation and restoration;
- teardown followed by a late event.

Assert user intent, product state, side-effect commands, item generation, and
automatic-resume eligibility. A reducer test that asserts only a spinner flag
does not prove lifecycle behavior.

Test the session with controllable adapters for:

- asset preparation;
- clock and progress;
- audio-session events;
- notifications;
- content-key and resource loading;
- metrics;
- remote commands;
- presentation callbacks.

Avoid making all tests depend on public internet media. Keep local deterministic
fixtures for basic transport and malformed-media cases, and use separately
owned integration streams for HLS behavior.

## Exercise transport and system integration

Run focused scenarios for each supported behavior:

- play, pause, replay, mute, rate, and end;
- rapid source changes;
- repeated scrubbing and a precise final seek;
- seeking outside duration or a moving live window;
- failed preparation and bounded retry;
- queue insertion, removal, transition, and item failure;
- loop start, repeated cycles, and loop teardown;
- background and foreground;
- device lock and unlock;
- incoming interruption and resume eligibility;
- headphone disconnect and Bluetooth route changes;
- media-services reset when supported;
- full-screen entry and exit;
- PiP start, stop, failure, and UI restoration;
- Now Playing metadata and every enabled remote command;
- captions, forced subtitles, alternate audio, and audio descriptions;
- AirPlay connection, route loss, and return.

Use a physical device for audio-session, lock-screen, PiP, AirPlay, remote
commands, thermal, and representative memory evidence. State explicitly when a
simulator-only result leaves those behaviors unverified.

For custom controls, test VoiceOver, Voice Control, Switch Control, keyboard or
remote focus where applicable, Dynamic Type, and Reduce Motion. Do not announce
the periodic playback clock on every update.

## Stress network, HLS, and multi-player policy

Use controlled conditions:

- offline at start;
- disconnect and reconnect during preparation and playback;
- high latency;
- packet loss;
- constrained bandwidth;
- a bandwidth drop and recovery;
- expensive or constrained network policy;
- HTTP authentication or redirect failure;
- missing or invalid HLS playlist or segment;
- content-key latency, denial, expiration, and offline failure.

Record startup, first frame, stalls, rendition switches, error stage, recovery,
and bytes or bitrate as available. Repeat enough times to distinguish a stable
effect from run-to-run noise.

For feeds and multiview, assert:

- maximum active and prepared players;
- cancellation when content leaves eligibility;
- audio ownership;
- quality and network priority by role;
- coordinated versus independent seek behavior;
- AirPlay participant arbitration;
- degradation under constrained network or hardware;
- teardown when views are removed rapidly.

Validate the server side of HLS with the current authoring specification and
tools. Keep backend remediation separate from client changes in the report.

## Establish a memory baseline

Measure a repeatable release-like scenario:

1. launch and settle;
2. record the baseline footprint and relevant allocations;
3. open, play, seek, transition, and close the player;
4. replace representative items;
5. repeat enough cycles to expose accumulation;
6. allow expected asynchronous release and system caches to settle;
7. compare the stable floor and retained object graph.

Use 50 open/close or item-replacement cycles when making a strong lifecycle or
memory-regression claim, unless the repository defines a more representative
stress count. Do not claim that test ran in a design or review task.

Inspect more than retain cycles:

- decoded audio and video buffers;
- `AVPlayerItem` and looper replicas;
- player layers and presentation controllers;
- periodic and boundary time-observer tokens;
- KVO and notification registrations;
- preparation, metric, thumbnail, retry, and content-key tasks;
- poster and thumbnail decoded images;
- custom byte caches and queued range requests;
- subtitle and metadata objects.

Use Memory Graph for ownership, Allocations and VM tools for growth, and
automated memory metrics for regression protection. A high temporary peak and a
steadily rising post-settle floor are different findings.

## Report only supported conclusions

Finish with:

- mode and requested outcome;
- environment and content contract;
- ownership and state model;
- reproduced timeline and earliest failing stage;
- changes or review findings;
- build, tests, device scenarios, and tools run;
- before/after measurements with units and sample counts;
- API availability and fallback paths;
- privacy redactions;
- unsupported or untested system behaviors;
- remaining uncertainty and the next evidence needed.

Use precise language:

- say "the focused tests pass" rather than "playback is correct";
- say "no accumulation appeared across 50 measured cycles" rather than "there
  are no leaks";
- say "startup median improved in this controlled scenario" rather than "the
  player is faster";
- say "the stream fails authoring validation" rather than masking it as a
  client buffering bug.
