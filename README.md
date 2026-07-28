# awesome-skills

A reusable collection of skills for AI-native engineering workflows ✨

This repository is a portable skill library. Each skill folder under `skills/`,
either directly or one category deep, is installable into a personal or
project-local skills directory.

## Skills

- [`development-plan`](skills/development-plan/) creates adaptive, executable
  plans for medium and large engineering tasks, selecting compact, full, or
  long-running depth while preserving saved-plan lifecycle, validation evidence,
  quality gates, and truthful handling of unresolved checks.
- [`agent-autonomous-loop`](skills/agent-autonomous-loop/) runs an explicit,
  bounded multi-round handoff loop through fresh worker agents, with a
  review-only completion gate after the latest source changes. It is opt-in
  only and disables implicit invocation in `agents/openai.yaml`.
- [`github-issue-development-plan`](skills/github-issue-development-plan/)
  converts GitHub issues into implementation plans by collecting issue facts,
  inspecting repository context, and then applying `development-plan`.
- [`github-pr-codex-review-monitor`](skills/github-pr-codex-review-monitor/)
  monitors a GitHub PR for ChatGPT Codex Connector review feedback and failing
  PR checks, applies actionable fixes, pushes updates, and requests another
  `@codex review` until the review and checks are clear.
- [`docs-feature-write`](skills/docs-feature-write/) turns a feature
  evidence bundle into durable, domain-structured documentation under `docs/ai/`
  (explanation, reference, how-to, ADRs, changelog) and updates the agent-facing
  surface. It is the self-contained core of the documentation skill pack.
- [`docs-feature-collect`](skills/docs-feature-collect/) collects
  read-only feature evidence from a tracker item, change request, or PR,
  normalizes it, and hands off to `docs-feature-write`.
- [`docs-feature-style`](skills/docs-feature-style/) normalizes documentation
  style and structure with Vale and markdownlint when present, and applies the
  same rules manually when they are absent.
- [`swift-concurrency`](skills/apple-development/swift-concurrency/) designs,
  implements, reviews, diagnoses, profiles, tests, and migrates safe, bounded
  Swift concurrency across tasks, actors, isolation, cancellation, streams,
  performance, and staged Swift 6 adoption.
- [`swift-animation`](skills/apple-development/swift-animation/) designs,
  implements, reviews, diagnoses, profiles, and tests fluid Apple UI motion
  across SwiftUI, UIKit, AppKit, and Core Animation with explicit interruption,
  velocity, accessibility, availability, and performance contracts.
- [`swift-player`](skills/apple-development/swift-player/) designs, implements,
  reviews, diagnoses, profiles, and tests resilient Apple media playback across
  AVPlayer lifecycle, state reduction, transport, HLS, AVKit presentation,
  system integration, multiview, teardown, and production evidence.
- [`swiftui-optimization`](skills/apple-development/swiftui-optimization/)
  creates, refactors, reviews, and profiles SwiftUI views with narrow
  dependencies, stable identity, efficient Observation, scalable scrolling,
  bounded resource lifetime, and measured update performance.
- [`swift-ios-performance`](skills/apple-development/swift-ios-performance/)
  researches, reviews, refactors, and benchmarks performance-sensitive Swift
  source with explicit allocation, ownership, collection, dispatch, and
  concurrency cost models.
- [`app-performance`](skills/apple-development/app-performance/) diagnoses,
  measures, improves, and regression-tests Apple-platform app performance
  across responsiveness, CPU, memory, graphics, power, storage, and networking.
- [`voice-over-accessibility`](skills/apple-development/voice-over-accessibility/) plans,
  audits, implements, and reviews VoiceOver support for iOS and iPadOS
  interfaces across semantics, navigation, actions, focus, and device testing.
- [`swift-rtl-support`](skills/apple-development/swift-rtl-support/) plans,
  implements, audits, and tests native RTL support for SwiftUI and UIKit across
  semantic layout, bidi text, localized formatting, assets, interaction, and
  real-language verification.
- [`apple-product-marketing`](skills/apple-development/apple-product-marketing/)
  positions, launches, promotes, localizes, and measures apps and games across
  App Store discovery, product pages, Apple Ads, lifecycle communications,
  analytics, and web-to-app journeys.
- [`apple-platform-design`](skills/apple-development/apple-platform-design/)
  designs, redesigns, reviews, and hands off native Apple-platform experiences
  from user goals and information architecture through components, visual
  language, interaction, accessibility, privacy, and implementation evidence.

## Repository Layout

```text
skills/
  apple-development/
    apple-product-marketing/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    app-performance/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    swift-ios-performance/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    voice-over-accessibility/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    swift-rtl-support/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    apple-platform-design/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    swift-concurrency/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    swift-animation/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    swift-player/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
    swiftui-optimization/
      SKILL.md
      agents/openai.yaml
      references/
      scripts/
  development-plan/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  agent-autonomous-loop/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  github-issue-development-plan/
    SKILL.md
    agents/openai.yaml
    references/
  github-pr-codex-review-monitor/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  docs-feature-write/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  docs-feature-collect/
    SKILL.md
    agents/openai.yaml
    references/
    scripts/
  docs-feature-style/
    SKILL.md
    agents/openai.yaml
    references/
    assets/
    scripts/
```

## Installation

Install one skill by copying its folder into your personal skills directory:

```bash
cp -R skills/development-plan "$SKILLS_HOME/development-plan"
```

Categorized skills are installed by their skill name rather than their category
path:

```bash
./install.sh swift-concurrency
./install.sh swift-animation
./install.sh swift-player
./install.sh swift-ios-performance
./install.sh app-performance
./install.sh voice-over-accessibility
./install.sh swift-rtl-support
./install.sh apple-product-marketing
./install.sh apple-platform-design
```

Install into a specific project by copying the folder into that project's local
skills directory:

```bash
cp -R skills/development-plan /path/to/project/.agents/skills/development-plan
```

Repeat for each skill you want to use. Keep the folder name the same as the
`name:` field in `SKILL.md`.

When upgrading an installation that previously contained `swift6-migration`,
archive or remove that old installed folder after installing
`swift-concurrency` and confirming it has no local-only changes, so both skill
identities cannot trigger for the same request.

### One-command install (Claude + Codex)

Use `install.sh` to (re)install the `docs-feature-*` documentation pack into your
Claude and Codex skill directories in one step:

```bash
./install.sh                                        # all docs-feature-* skills, both runtimes
./install.sh docs-feature-write docs-feature-style  # only the named skills
./install.sh --all                                  # every skill, including categorized skills
./install.sh --claude                               # Claude only (--codex for Codex only)
```

Destinations default to `~/.claude/skills` and `~/.codex/skills`, honoring
`CLAUDE_CONFIG_DIR` / `CODEX_HOME` when set; the explicit `CLAUDE_SKILLS_DIR` /
`CODEX_SKILLS_DIR` overrides take precedence. A named install automatically pulls in
any required sub-skills (installing `docs-feature-collect` also installs
`docs-feature-write`). Each installed skill is re-validated with its
`check_skill.sh`. Restart your Claude/Codex session afterwards to pick up
changes.

## Navigation

### `development-plan`

Use when a task needs a saved, verifiable plan before editing. The skill keeps
ordinary medium work compact and escalates to full or long-running structure
for risky, ambiguous, cross-boundary, or resumable work.

Default prompt:

```text
Use $development-plan to choose the right planning depth and create a saved, verifiable implementation plan.
```

Important files:

- [`skills/development-plan/SKILL.md`](skills/development-plan/SKILL.md)
- [`skills/development-plan/references/core-planning-rules.md`](skills/development-plan/references/core-planning-rules.md)
- [`skills/development-plan/references/compact-plan-template.md`](skills/development-plan/references/compact-plan-template.md)
- [`skills/development-plan/references/full-plan-template.md`](skills/development-plan/references/full-plan-template.md)
- [`skills/development-plan/references/long-running-addendum.md`](skills/development-plan/references/long-running-addendum.md)
- [`skills/development-plan/scripts/check_skill.sh`](skills/development-plan/scripts/check_skill.sh)

### `agent-autonomous-loop`

Use only when you explicitly want a bounded autonomous loop with handoff state
and worker rounds. Completion requires a fresh review-only worker after the
latest source changes. This is not intended to run automatically on every
session.

Default prompt:

```text
Use $agent-autonomous-loop to execute this well-scoped task through an explicit autonomous handoff loop.
```

Important files:

- [`skills/agent-autonomous-loop/SKILL.md`](skills/agent-autonomous-loop/SKILL.md)
- [`skills/agent-autonomous-loop/references/control-protocol.md`](skills/agent-autonomous-loop/references/control-protocol.md)
- [`skills/agent-autonomous-loop/references/worker-rules.md`](skills/agent-autonomous-loop/references/worker-rules.md)
- [`skills/agent-autonomous-loop/scripts/check_skill.sh`](skills/agent-autonomous-loop/scripts/check_skill.sh)

### `github-issue-development-plan`

Use when a GitHub issue URL or issue number should become an implementation
plan before any code changes.

Default prompt:

```text
Use $github-issue-development-plan to create an implementation plan from this GitHub issue.
```

Important files:

- [`skills/github-issue-development-plan/SKILL.md`](skills/github-issue-development-plan/SKILL.md)
- [`skills/github-issue-development-plan/references/issue-context.md`](skills/github-issue-development-plan/references/issue-context.md)
- [`skills/github-issue-development-plan/references/development-plan-handoff.md`](skills/github-issue-development-plan/references/development-plan-handoff.md)

### `github-pr-codex-review-monitor`

Use when a PR needs a live monitor loop for ChatGPT Codex Connector comments,
failing PR checks, fix commits, and follow-up `@codex review` requests. The loop
stops without claiming approval after 60 minutes of Connector silence.

Default prompt:

```text
Use $github-pr-codex-review-monitor to monitor this PR until Codex review feedback and required checks are clear, or stop after 60 minutes of Connector silence without claiming approval.
```

Important files:

- [`skills/github-pr-codex-review-monitor/SKILL.md`](skills/github-pr-codex-review-monitor/SKILL.md)
- [`skills/github-pr-codex-review-monitor/references/pr-state-and-checks.md`](skills/github-pr-codex-review-monitor/references/pr-state-and-checks.md)
- [`skills/github-pr-codex-review-monitor/references/fix-validate-review.md`](skills/github-pr-codex-review-monitor/references/fix-validate-review.md)
- [`skills/github-pr-codex-review-monitor/scripts/check_skill.sh`](skills/github-pr-codex-review-monitor/scripts/check_skill.sh)

### `docs-feature-write`

Use when a finished or in-progress feature needs durable docs for humans and
agents, routed by domain and written under `docs/ai/`.

Default prompt:

```text
Use $docs-feature-write to write durable, domain-structured docs for this feature under docs/ai/.
```

Important files:

- [`skills/docs-feature-write/SKILL.md`](skills/docs-feature-write/SKILL.md)
- [`skills/docs-feature-write/references/doc-model.md`](skills/docs-feature-write/references/doc-model.md)
- [`skills/docs-feature-write/references/feature-doc-template.md`](skills/docs-feature-write/references/feature-doc-template.md)
- [`skills/docs-feature-write/scripts/check_docs.sh`](skills/docs-feature-write/scripts/check_docs.sh)

### `docs-feature-collect`

Use when documentation should start from a tracker item, change request, or PR,
collecting evidence read-only before handing off to `docs-feature-write`.

Default prompt:

```text
Use $docs-feature-collect to document a shipped feature from its tracker item and change requests.
```

Important files:

- [`skills/docs-feature-collect/SKILL.md`](skills/docs-feature-collect/SKILL.md)
- [`skills/docs-feature-collect/references/evidence-collection.md`](skills/docs-feature-collect/references/evidence-collection.md)
- [`skills/docs-feature-collect/references/docs-feature-write-handoff.md`](skills/docs-feature-collect/references/docs-feature-write-handoff.md)

### `docs-feature-style`

Use when documentation markdown needs style and structure normalization, with or
without Vale and markdownlint installed.

Default prompt:

```text
Use $docs-feature-style to normalize the style and structure of these docs.
```

Important files:

- [`skills/docs-feature-style/SKILL.md`](skills/docs-feature-style/SKILL.md)
- [`skills/docs-feature-style/references/style-rules.md`](skills/docs-feature-style/references/style-rules.md)
- [`skills/docs-feature-style/references/tooling.md`](skills/docs-feature-style/references/tooling.md)

### Apple development / `apple-product-marketing`

Use when an app or game for Apple platforms needs positioning, App Store
discovery and conversion work, localized product marketing, launch or lifecycle
communications, Apple Ads, analytics, web-to-app SEO, or metadata automation
with explicit policy, evidence, and downstream-quality guardrails.

Default prompt:

```text
Use $apple-product-marketing to position this app and build a compliant, measurable App Store growth plan.
```

Important files:

- [`skills/apple-development/apple-product-marketing/SKILL.md`](skills/apple-development/apple-product-marketing/SKILL.md)
- [`skills/apple-development/apple-product-marketing/references/methodology.md`](skills/apple-development/apple-product-marketing/references/methodology.md)
- [`skills/apple-development/apple-product-marketing/references/positioning-and-messaging.md`](skills/apple-development/apple-product-marketing/references/positioning-and-messaging.md)
- [`skills/apple-development/apple-product-marketing/references/app-store-discovery.md`](skills/apple-development/apple-product-marketing/references/app-store-discovery.md)
- [`skills/apple-development/apple-product-marketing/references/conversion-and-experiments.md`](skills/apple-development/apple-product-marketing/references/conversion-and-experiments.md)
- [`skills/apple-development/apple-product-marketing/references/localization-and-transcreation.md`](skills/apple-development/apple-product-marketing/references/localization-and-transcreation.md)
- [`skills/apple-development/apple-product-marketing/references/launch-and-communications.md`](skills/apple-development/apple-product-marketing/references/launch-and-communications.md)
- [`skills/apple-development/apple-product-marketing/references/apple-ads.md`](skills/apple-development/apple-product-marketing/references/apple-ads.md)
- [`skills/apple-development/apple-product-marketing/references/analytics-and-attribution.md`](skills/apple-development/apple-product-marketing/references/analytics-and-attribution.md)
- [`skills/apple-development/apple-product-marketing/references/web-seo-and-automation.md`](skills/apple-development/apple-product-marketing/references/web-seo-and-automation.md)
- [`skills/apple-development/apple-product-marketing/references/deliverables.md`](skills/apple-development/apple-product-marketing/references/deliverables.md)
- [`skills/apple-development/apple-product-marketing/references/sources.md`](skills/apple-development/apple-product-marketing/references/sources.md)
- [`skills/apple-development/apple-product-marketing/scripts/check_skill.sh`](skills/apple-development/apple-product-marketing/scripts/check_skill.sh)

### Apple development / `swift-concurrency`

Use when Swift concurrency needs to be designed, implemented, reviewed,
diagnosed, profiled, tested, or migrated, including task lifetime, cancellation,
actors and reentrancy, isolation and transfer, continuations and streams,
SwiftUI integration, bounded parallelism, and staged Swift 6 adoption.

Default prompt:

```text
Use $swift-concurrency to review this Swift code for isolation, task lifetime, cancellation, and performance issues, then propose a verified fix.
```

Important files:

- [`skills/apple-development/swift-concurrency/SKILL.md`](skills/apple-development/swift-concurrency/SKILL.md)
- [`skills/apple-development/swift-concurrency/references/mental-model.md`](skills/apple-development/swift-concurrency/references/mental-model.md)
- [`skills/apple-development/swift-concurrency/references/structured-concurrency.md`](skills/apple-development/swift-concurrency/references/structured-concurrency.md)
- [`skills/apple-development/swift-concurrency/references/isolation-and-sendability.md`](skills/apple-development/swift-concurrency/references/isolation-and-sendability.md)
- [`skills/apple-development/swift-concurrency/references/performance-and-memory.md`](skills/apple-development/swift-concurrency/references/performance-and-memory.md)
- [`skills/apple-development/swift-concurrency/references/migration-methodology.md`](skills/apple-development/swift-concurrency/references/migration-methodology.md)
- [`skills/apple-development/swift-concurrency/references/sources.md`](skills/apple-development/swift-concurrency/references/sources.md)
- [`skills/apple-development/swift-concurrency/scripts/check_skill.sh`](skills/apple-development/swift-concurrency/scripts/check_skill.sh)

### Apple development / `swift-animation`

Use when Apple UI motion needs to be designed, implemented, refactored,
reviewed, diagnosed, profiled, or tested across SwiftUI, UIKit, AppKit, or Core
Animation, including state-driven and gesture-driven animation, interruption,
springs, transitions, Reduce Motion, platform fallbacks, animation hitches, and
regression evidence.

Default prompt:

```text
Use $swift-animation to design, implement, or diagnose this Apple UI animation for continuity, accessibility, availability, and measured performance.
```

Important files:

- [`skills/apple-development/swift-animation/SKILL.md`](skills/apple-development/swift-animation/SKILL.md)
- [`skills/apple-development/swift-animation/references/methodology-and-motion-design.md`](skills/apple-development/swift-animation/references/methodology-and-motion-design.md)
- [`skills/apple-development/swift-animation/references/interruption-and-velocity.md`](skills/apple-development/swift-animation/references/interruption-and-velocity.md)
- [`skills/apple-development/swift-animation/references/swiftui-state-and-transactions.md`](skills/apple-development/swift-animation/references/swiftui-state-and-transactions.md)
- [`skills/apple-development/swift-animation/references/swiftui-sequences-and-effects.md`](skills/apple-development/swift-animation/references/swiftui-sequences-and-effects.md)
- [`skills/apple-development/swift-animation/references/uikit-property-animations.md`](skills/apple-development/swift-animation/references/uikit-property-animations.md)
- [`skills/apple-development/swift-animation/references/navigation-transitions.md`](skills/apple-development/swift-animation/references/navigation-transitions.md)
- [`skills/apple-development/swift-animation/references/appkit-and-cross-framework.md`](skills/apple-development/swift-animation/references/appkit-and-cross-framework.md)
- [`skills/apple-development/swift-animation/references/core-animation-and-frame-driving.md`](skills/apple-development/swift-animation/references/core-animation-and-frame-driving.md)
- [`skills/apple-development/swift-animation/references/performance-and-diagnostics.md`](skills/apple-development/swift-animation/references/performance-and-diagnostics.md)
- [`skills/apple-development/swift-animation/references/accessibility-and-availability.md`](skills/apple-development/swift-animation/references/accessibility-and-availability.md)
- [`skills/apple-development/swift-animation/references/testing-and-evidence.md`](skills/apple-development/swift-animation/references/testing-and-evidence.md)
- [`skills/apple-development/swift-animation/references/sources.md`](skills/apple-development/swift-animation/references/sources.md)
- [`skills/apple-development/swift-animation/scripts/check_skill.sh`](skills/apple-development/swift-animation/scripts/check_skill.sh)

### Apple development / `swift-player`

Use when audio or video playback for iOS, iPadOS, tvOS, visionOS, macOS, or Mac
Catalyst needs to be designed, implemented, reviewed, diagnosed, profiled, or
tested with explicit ownership, state, cancellation, teardown, presentation,
streaming, system-integration, and measurement contracts.

Default prompt:

```text
Use $swift-player to design or review this AVFoundation playback flow for correct ownership, state, teardown, buffering, system integration, and measurable reliability.
```

Important files:

- [`skills/apple-development/swift-player/SKILL.md`](skills/apple-development/swift-player/SKILL.md)
- [`skills/apple-development/swift-player/references/architecture-and-state.md`](skills/apple-development/swift-player/references/architecture-and-state.md)
- [`skills/apple-development/swift-player/references/lifecycle-and-transport.md`](skills/apple-development/swift-player/references/lifecycle-and-transport.md)
- [`skills/apple-development/swift-player/references/presentation-and-system-integration.md`](skills/apple-development/swift-player/references/presentation-and-system-integration.md)
- [`skills/apple-development/swift-player/references/streaming-and-multiview.md`](skills/apple-development/swift-player/references/streaming-and-multiview.md)
- [`skills/apple-development/swift-player/references/diagnostics-and-testing.md`](skills/apple-development/swift-player/references/diagnostics-and-testing.md)
- [`skills/apple-development/swift-player/references/sources.md`](skills/apple-development/swift-player/references/sources.md)
- [`skills/apple-development/swift-player/scripts/check_skill.sh`](skills/apple-development/swift-player/scripts/check_skill.sh)

### Apple development / `swiftui-optimization`

Use when SwiftUI views or screens need to be created, refactored, reviewed, or
profiled with explicit dependency, Observation, identity, and hitch-performance
guardrails, including scrolling and memory-lifetime investigations.

Default prompt:

```text
Use $swiftui-optimization to build or refactor this SwiftUI view for correct, measurable update, scrolling, and resource-lifetime performance.
```

Important files:

- [`skills/apple-development/swiftui-optimization/SKILL.md`](skills/apple-development/swiftui-optimization/SKILL.md)
- [`skills/apple-development/swiftui-optimization/references/data-flow-and-diffing.md`](skills/apple-development/swiftui-optimization/references/data-flow-and-diffing.md)
- [`skills/apple-development/swiftui-optimization/references/observation.md`](skills/apple-development/swiftui-optimization/references/observation.md)
- [`skills/apple-development/swiftui-optimization/references/construction-patterns.md`](skills/apple-development/swiftui-optimization/references/construction-patterns.md)
- [`skills/apple-development/swiftui-optimization/references/collections-and-scrolling.md`](skills/apple-development/swiftui-optimization/references/collections-and-scrolling.md)
- [`skills/apple-development/swiftui-optimization/references/memory-and-resources.md`](skills/apple-development/swiftui-optimization/references/memory-and-resources.md)
- [`skills/apple-development/swiftui-optimization/references/profiling.md`](skills/apple-development/swiftui-optimization/references/profiling.md)
- [`skills/apple-development/swiftui-optimization/references/source-notes.md`](skills/apple-development/swiftui-optimization/references/source-notes.md)
- [`skills/apple-development/swiftui-optimization/scripts/check_skill.sh`](skills/apple-development/swiftui-optimization/scripts/check_skill.sh)

### Apple development / `swift-ios-performance`

Use when a concrete Swift construct, algorithm, data pipeline, or known iOS hot
path needs source-level research, review, refactoring, or a focused benchmark
covering CPU, allocation, ARC, copying, collections, dispatch, or concurrency
costs.

Default prompt:

```text
Use $swift-ios-performance to review and improve this Swift code with measurement-backed CPU and memory optimizations.
```

Important files:

- [`skills/apple-development/swift-ios-performance/SKILL.md`](skills/apple-development/swift-ios-performance/SKILL.md)
- [`skills/apple-development/swift-ios-performance/references/methodology.md`](skills/apple-development/swift-ios-performance/references/methodology.md)
- [`skills/apple-development/swift-ios-performance/references/cost-model-and-compiler.md`](skills/apple-development/swift-ios-performance/references/cost-model-and-compiler.md)
- [`skills/apple-development/swift-ios-performance/references/ownership-and-memory.md`](skills/apple-development/swift-ios-performance/references/ownership-and-memory.md)
- [`skills/apple-development/swift-ios-performance/references/collections-algorithms-and-text.md`](skills/apple-development/swift-ios-performance/references/collections-algorithms-and-text.md)
- [`skills/apple-development/swift-ios-performance/references/concurrency-costs.md`](skills/apple-development/swift-ios-performance/references/concurrency-costs.md)
- [`skills/apple-development/swift-ios-performance/references/benchmarking.md`](skills/apple-development/swift-ios-performance/references/benchmarking.md)
- [`skills/apple-development/swift-ios-performance/references/low-level-and-accelerated.md`](skills/apple-development/swift-ios-performance/references/low-level-and-accelerated.md)
- [`skills/apple-development/swift-ios-performance/references/ranked-sources.md`](skills/apple-development/swift-ios-performance/references/ranked-sources.md)
- [`skills/apple-development/swift-ios-performance/scripts/check_skill.sh`](skills/apple-development/swift-ios-performance/scripts/check_skill.sh)

### Apple development / `app-performance`

Use when an iOS, iPadOS, macOS, watchOS, tvOS, or visionOS app needs an
evidence-driven performance plan, diagnosis, improvement, or regression guard
using Xcode, Instruments, Organizer, MetricKit, and XCTest.

Default prompt:

```text
Use $app-performance to classify this Apple app performance request, define its measurement contract, gather only authorized evidence, and report the supported result.
```

Important files:

- [`skills/apple-development/app-performance/SKILL.md`](skills/apple-development/app-performance/SKILL.md)
- [`skills/apple-development/app-performance/references/methodology.md`](skills/apple-development/app-performance/references/methodology.md)
- [`skills/apple-development/app-performance/references/tools-and-evidence.md`](skills/apple-development/app-performance/references/tools-and-evidence.md)
- [`skills/apple-development/app-performance/references/responsiveness.md`](skills/apple-development/app-performance/references/responsiveness.md)
- [`skills/apple-development/app-performance/references/cpu-memory-size.md`](skills/apple-development/app-performance/references/cpu-memory-size.md)
- [`skills/apple-development/app-performance/references/power-storage-network.md`](skills/apple-development/app-performance/references/power-storage-network.md)
- [`skills/apple-development/app-performance/references/graphics.md`](skills/apple-development/app-performance/references/graphics.md)
- [`skills/apple-development/app-performance/references/apple-source-map.md`](skills/apple-development/app-performance/references/apple-source-map.md)
- [`skills/apple-development/app-performance/scripts/check_skill.sh`](skills/apple-development/app-performance/scripts/check_skill.sh)

### Apple development / `voice-over-accessibility`

Use when an iOS or iPadOS SwiftUI, UIKit, or mixed interface needs a VoiceOver
plan, audit, implementation, fix, or review covering semantic elements,
navigation, custom actions, focus, announcements, and physical-device
verification. The first version intentionally excludes other accessibility
categories and assistive technologies.

Default prompt:

```text
Use $voice-over-accessibility to make this iOS flow fully operable with VoiceOver using correct semantics, focus, actions, and device testing.
```

Important files:

- [`skills/apple-development/voice-over-accessibility/SKILL.md`](skills/apple-development/voice-over-accessibility/SKILL.md)
- [`skills/apple-development/voice-over-accessibility/references/methodology.md`](skills/apple-development/voice-over-accessibility/references/methodology.md)
- [`skills/apple-development/voice-over-accessibility/references/semantics-and-navigation.md`](skills/apple-development/voice-over-accessibility/references/semantics-and-navigation.md)
- [`skills/apple-development/voice-over-accessibility/references/swiftui-and-uikit.md`](skills/apple-development/voice-over-accessibility/references/swiftui-and-uikit.md)
- [`skills/apple-development/voice-over-accessibility/references/testing-and-evidence.md`](skills/apple-development/voice-over-accessibility/references/testing-and-evidence.md)
- [`skills/apple-development/voice-over-accessibility/references/source-map.md`](skills/apple-development/voice-over-accessibility/references/source-map.md)
- [`skills/apple-development/voice-over-accessibility/scripts/check_skill.sh`](skills/apple-development/voice-over-accessibility/scripts/check_skill.sh)

### Apple development / `swift-rtl-support`

Use when an iOS or iPadOS SwiftUI, UIKit, or mixed interface needs an RTL plan,
implementation, audit, diagnosis, review, or test covering semantic layout,
bidi text, writing direction, locale-aware formatting, directional assets,
navigation, gestures, typography, supported real RTL localizations, and
representative Arabic and Hebrew fixtures for general RTL claims.

Default prompt:

```text
Use $swift-rtl-support to implement or audit this SwiftUI or UIKit flow for native RTL layout, bidi text, localized assets, and regression testing.
```

Important files:

- [`skills/apple-development/swift-rtl-support/SKILL.md`](skills/apple-development/swift-rtl-support/SKILL.md)
- [`skills/apple-development/swift-rtl-support/references/methodology.md`](skills/apple-development/swift-rtl-support/references/methodology.md)
- [`skills/apple-development/swift-rtl-support/references/layout-and-navigation.md`](skills/apple-development/swift-rtl-support/references/layout-and-navigation.md)
- [`skills/apple-development/swift-rtl-support/references/text-and-formatting.md`](skills/apple-development/swift-rtl-support/references/text-and-formatting.md)
- [`skills/apple-development/swift-rtl-support/references/swiftui-and-uikit.md`](skills/apple-development/swift-rtl-support/references/swiftui-and-uikit.md)
- [`skills/apple-development/swift-rtl-support/references/assets-and-typography.md`](skills/apple-development/swift-rtl-support/references/assets-and-typography.md)
- [`skills/apple-development/swift-rtl-support/references/testing-and-evidence.md`](skills/apple-development/swift-rtl-support/references/testing-and-evidence.md)
- [`skills/apple-development/swift-rtl-support/references/sources.md`](skills/apple-development/swift-rtl-support/references/sources.md)
- [`skills/apple-development/swift-rtl-support/scripts/check_skill.sh`](skills/apple-development/swift-rtl-support/scripts/check_skill.sh)

### Apple development / `apple-platform-design`

Use when an Apple-platform product experience needs to be designed, redesigned,
reviewed, or translated into implementation guidance from user purpose and
information architecture through native components, adaptive layout, visual
language, writing, discoverability, motion, haptics, accessibility, privacy,
and evidence-based validation.

Default prompt:

```text
Use $apple-platform-design to design or review this Apple interface from user goals through native patterns, states, accessibility, and implementation guidance.
```

Important files:

- [`skills/apple-development/apple-platform-design/SKILL.md`](skills/apple-development/apple-platform-design/SKILL.md)
- [`skills/apple-development/apple-platform-design/references/00-design-principles.md`](skills/apple-development/apple-platform-design/references/00-design-principles.md)
- [`skills/apple-development/apple-platform-design/references/01-information-architecture-and-navigation.md`](skills/apple-development/apple-platform-design/references/01-information-architecture-and-navigation.md)
- [`skills/apple-development/apple-platform-design/references/02-layout-and-visual-hierarchy.md`](skills/apple-development/apple-platform-design/references/02-layout-and-visual-hierarchy.md)
- [`skills/apple-development/apple-platform-design/references/03-components-and-patterns.md`](skills/apple-development/apple-platform-design/references/03-components-and-patterns.md)
- [`skills/apple-development/apple-platform-design/references/04-color-typography-and-materials.md`](skills/apple-development/apple-platform-design/references/04-color-typography-and-materials.md)
- [`skills/apple-development/apple-platform-design/references/05-writing-and-naming.md`](skills/apple-development/apple-platform-design/references/05-writing-and-naming.md)
- [`skills/apple-development/apple-platform-design/references/06-onboarding-and-discoverability.md`](skills/apple-development/apple-platform-design/references/06-onboarding-and-discoverability.md)
- [`skills/apple-development/apple-platform-design/references/07-motion-feedback-and-haptics.md`](skills/apple-development/apple-platform-design/references/07-motion-feedback-and-haptics.md)
- [`skills/apple-development/apple-platform-design/references/08-accessibility-inclusion-and-privacy.md`](skills/apple-development/apple-platform-design/references/08-accessibility-inclusion-and-privacy.md)
- [`skills/apple-development/apple-platform-design/references/09-implementation-handoff.md`](skills/apple-development/apple-platform-design/references/09-implementation-handoff.md)
- [`skills/apple-development/apple-platform-design/references/10-design-review-checklist.md`](skills/apple-development/apple-platform-design/references/10-design-review-checklist.md)
- [`skills/apple-development/apple-platform-design/references/sources.md`](skills/apple-development/apple-platform-design/references/sources.md)
- [`skills/apple-development/apple-platform-design/scripts/check_skill.sh`](skills/apple-development/apple-platform-design/scripts/check_skill.sh)

## Maintenance Notes

- Keep `SKILL.md` concise and move detailed procedures into one-level
  `references/` files.
- Place broad skills directly under `skills/`. Use one category directory for
  domain collections such as `skills/apple-development/`; skill names must stay
  unique because installation destinations are flat.
- Keep skills project-agnostic: avoid hard-coded repository names, app names,
  branch names, and product-specific paths.
- Keep runtime state out of this repository. For example,
  `agent-autonomous-loop` writes handoff state under `.agent-autonomous-loop/`
  in the active project, not in this skill library.
- Validate changed skills with the validator for your agent runtime:

```bash
python3 /path/to/skill-creator/scripts/quick_validate.py skills/development-plan
```

Run the same command for each edited skill folder.
