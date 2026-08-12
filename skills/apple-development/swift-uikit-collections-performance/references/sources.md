# Primary sources for UIKit collection performance

Last reviewed: 2026-08-13.

## Contents

- Core collection architecture
- Reuse, content, and updates
- Prefetching and images
- Layout and self-sizing
- Hitches and field evidence
- Hosted SwiftUI
- Availability notes

Scores rank authority, direct applicability, explanatory depth, currency, and
actionability for this skill. Prefer the narrow API page when checking an exact
signature or availability declaration.

## Core collection architecture

- **100/100** — [Make blazing fast lists and collection views](https://developer.apple.com/videos/play/wwdc2021/10252/) — Cell lifecycle, registrations, prefetch, stable identifiers, reconfiguration, and image preparation.
- **99/100** — [Building high-performance lists and collection views](https://developer.apple.com/documentation/uikit/building-high-performance-lists-and-collection-views) — Official sample paired with the WWDC21 session.
- **98/100** — [Implementing modern collection views](https://developer.apple.com/documentation/uikit/implementing-modern-collection-views) — Diffable data sources, compositional layouts, lists, and supplementary views.
- **95/100** — [UICollectionView](https://developer.apple.com/documentation/uikit/uicollectionview) — Collection lifecycle, data source, layout, reuse, prefetching, and interaction API.
- **91/100** — [UITableView](https://developer.apple.com/documentation/uikit/uitableview) — Table lifecycle and the simple-list alternative.
- **96/100** — [Advances in UICollectionView](https://developer.apple.com/videos/play/wwdc2020/10097/) — Lists, section snapshots, modern dequeuing, and hierarchical data.
- **94/100** — [Lists in UICollectionView](https://developer.apple.com/videos/play/wwdc2020/10026/) — Collection-view list behavior and mixed section types.

## Reuse, content, and updates

- **97/100** — [Updating collection views using diffable data sources](https://developer.apple.com/documentation/uikit/updating-collection-views-using-diffable-data-sources) — Snapshot-driven structural and content updates.
- **95/100** — [NSDiffableDataSourceSnapshot](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot) — Identifier and snapshot operations.
- **99/100** — [reconfigureItems](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot-swift.struct/reconfigureitems(_:)) — Existing-cell reconfiguration and self-sizing behavior.
- **93/100** — [reloadItems](https://developer.apple.com/documentation/uikit/nsdiffabledatasourcesnapshot-swift.struct/reloaditems(_:)) — Replacement-cell update semantics.
- **98/100** — [UICollectionView.CellRegistration](https://developer.apple.com/documentation/uikit/uicollectionview/cellregistration) — Stable registration lifetime and the provider-closure exception warning.
- **90/100** — [UICollectionView.SupplementaryRegistration](https://developer.apple.com/documentation/uikit/uicollectionview/supplementaryregistration) — Modern reusable supplementary configuration.
- **95/100** — [Modern cell configuration](https://developer.apple.com/videos/play/wwdc2020/10027/) — Configuration state, content, background, and reuse-safe cells.
- **91/100** — [UIContentConfiguration](https://developer.apple.com/documentation/uikit/uicontentconfiguration) — Value-style content configuration contract.
- **87/100** — [UIBackgroundConfiguration](https://developer.apple.com/documentation/uikit/uibackgroundconfiguration) — State-aware reusable backgrounds.

## Prefetching and images

- **96/100** — [UICollectionViewDataSourcePrefetching](https://developer.apple.com/documentation/uikit/uicollectionviewdatasourceprefetching) — Optional advance data demand, fallback states, and cancellation.
- **91/100** — [UITableViewDataSourcePrefetching](https://developer.apple.com/documentation/uikit/uitableviewdatasourceprefetching) — Table-view data prefetch contract.
- **95/100** — [Prefetching collection view data](https://developer.apple.com/documentation/uikit/prefetching-collection-view-data) — Apple sample for ready, in-flight, missing, and canceled states.
- **90/100** — [isPrefetchingEnabled](https://developer.apple.com/documentation/uikit/uicollectionview/isprefetchingenabled) — Cell and data-prefetch switch semantics.
- **94/100** — [UIImage](https://developer.apple.com/documentation/uikit/uiimage) — Display preparation and thumbnail-preparation APIs.
- **96/100** — [preparingForDisplay](https://developer.apple.com/documentation/uikit/uiimage/preparingfordisplay()) — Synchronous image decode for display.
- **98/100** — [prepareForDisplay](https://developer.apple.com/documentation/uikit/uiimage/preparefordisplay(completionhandler:)) — Asynchronous display preparation.
- **95/100** — [preparingThumbnail](https://developer.apple.com/documentation/uikit/uiimage/preparingthumbnail(of:)) — Synchronous thumbnail preparation.
- **97/100** — [prepareThumbnail](https://developer.apple.com/documentation/uikit/uiimage/preparethumbnail(of:completionhandler:)) — Asynchronous thumbnail preparation.

## Layout and self-sizing

- **95/100** — [Advances in Collection View Layout](https://developer.apple.com/videos/play/wwdc2019/215/) — Compositional layout mental model and adaptive sections.
- **94/100** — [UICollectionViewCompositionalLayout](https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout) — Compositional layout API and section providers.
- **89/100** — [UICollectionLayoutListConfiguration](https://developer.apple.com/documentation/uikit/uicollectionlayoutlistconfiguration) — Collection-view list configuration.
- **90/100** — [selfSizingInvalidation](https://developer.apple.com/documentation/uikit/uicollectionview/selfsizinginvalidation-swift.property) — Collection self-sizing invalidation policy.
- **92/100** — [SelfSizingInvalidation modes](https://developer.apple.com/documentation/uikit/uicollectionview/selfsizinginvalidation-swift.enum) — Intrinsic-size and constraint-aware invalidation modes.
- **91/100** — [estimatedItemSize](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/estimateditemsize) — Flow-layout self-sizing switch and estimates.
- **90/100** — [preferredLayoutAttributesFitting](https://developer.apple.com/documentation/uikit/uicollectionreusableview/preferredlayoutattributesfitting(_:)) — Reusable-view size fitting contract.
- **91/100** — [UICollectionViewLayout](https://developer.apple.com/documentation/uikit/uicollectionviewlayout) — Custom layout attributes, invalidation, and update contract.
- **89/100** — [NSCollectionLayoutDimension](https://developer.apple.com/documentation/uikit/nscollectionlayoutdimension) — Absolute, fractional, and estimated compositional dimensions.
- **93/100** — [What's new in UIKit](https://developer.apple.com/videos/play/wwdc2022/10068/) — Self-sizing invalidation and UIKit layout updates.
- **88/100** — [Creating self-sizing table view cells](https://developer.apple.com/documentation/uikit/creating-self-sizing-table-view-cells) — Constraint-complete self-sizing and estimates.

## Hitches and field evidence

- **98/100** — [Understanding hitches in your app](https://developer.apple.com/documentation/xcode/understanding-hitches-in-your-app) — Frame lifetime, commit versus render hitches, and Organizer bands.
- **96/100** — [Improving app responsiveness](https://developer.apple.com/documentation/xcode/improving-app-responsiveness) — Device profiling, main-thread work, and field diagnostics.
- **95/100** — [Explore UI animation hitches and the render loop](https://developer.apple.com/videos/play/tech-talks/10855/) — Render-loop foundation and hitch timing.
- **94/100** — [Find and fix hitches in the commit phase](https://developer.apple.com/videos/play/tech-talks/10856/) — Layout, display, decoding, and layer-tree commit work.
- **93/100** — [Demystify and eliminate hitches in the render phase](https://developer.apple.com/videos/play/tech-talks/10857/) — Render-server CPU and GPU diagnosis.
- **92/100** — [Analyzing responsiveness issues in your shipping app](https://developer.apple.com/documentation/xcode/analyzing-responsiveness-issues-in-your-shipping-app) — Organizer hitch and hang population workflow.
- **86/100** — [MXAnimationMetric](https://developer.apple.com/documentation/metrickit/mxanimationmetric) — MetricKit animation responsiveness payload semantics.
- **92/100** — [XCTHitchMetric](https://developer.apple.com/documentation/xctest/xcthitchmetric) — Hitch metrics for supported iOS and iPadOS 26+ tests.
- **88/100** — [scrollingAndDecelerationMetric](https://developer.apple.com/documentation/xctest/xctossignpostmetric/scrollinganddecelerationmetric) — Scrolling performance metric for supported iOS 15+ tests.
- **96/100** — [Profile, fix, and verify: Improve app responsiveness with Instruments](https://developer.apple.com/videos/play/wwdc2026/268/) — Current Time Profiler, System Trace, signpost, release-build, and run-comparison workflow.

## Hosted SwiftUI

- **86/100** — [UIHostingConfiguration](https://developer.apple.com/documentation/swiftui/uihostingconfiguration) — SwiftUI content hosted in table and collection cells.
- **84/100** — [Use SwiftUI with UIKit](https://developer.apple.com/videos/play/wwdc2022/10072/) — Incremental UIKit and SwiftUI integration.

## Availability notes

- Verify every API against the project's deployment targets. Cell registration
  and modern content configurations begin earlier than `reconfigureItems(_:)`,
  image preparation, `UIHostingConfiguration`, and self-sizing invalidation.
- Treat WWDC examples as explanations of the SDK announced in that session, not
  as proof that later UIKit versions preserve every implementation detail.
- Tool names, hitch tracks, Organizer goals, MetricKit fields, and XCTest metric
  APIs can change with Xcode and OS releases. Record the installed versions.
- WWDC26 sessions describe Xcode and Instruments 27 features that may remain
  prerelease until their public release. Require an availability check and a
  supported fallback before depending on their new views or comparison tools.
- The modern collection-view sample currently declares a newer sample runtime
  than the initial introduction of diffable and compositional APIs. Check each
  symbol's availability instead of inheriting the sample's requirement.
- Keep community articles as optional explanatory material. Resolve API,
  lifecycle, availability, and performance claims against Apple documentation,
  sessions, samples, and the installed SDK.
