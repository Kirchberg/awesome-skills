# Current platform state and availability

Last reviewed: 2026-08-02.

Use this file to separate the stable iOS 26 adoption baseline from later
prerelease behavior. Recheck `references/sources.md`, the selected SDK's generated
interfaces, and release notes whenever the toolchain changes.

## Stable baseline

- Treat iOS 26 and the aligned 2025 platform releases as the introduction point
  for native Liquid Glass APIs in SwiftUI and UIKit.
- Expect standard SwiftUI and UIKit navigation, controls, bars, search, and
  presentations to acquire the system appearance when built with the applicable
  current SDK. Observe that behavior before adding custom effects.
- Use SwiftUI `Glass`, `glassEffect`, `GlassEffectContainer`, glass button styles,
  identities, unions, and transitions only where their declared availability
  permits.
- Distinguish the base `.glass` and `.glassProminent` button styles introduced in
  26.0 from 26.1 and later overloads such as the configurable `GlassButtonStyle`
  initializer; verify the precise declaration rather than gating the whole family
  identically.
- Use UIKit `UIGlassEffect`, `UIGlassContainerEffect`, glass button
  configurations, and `UIBackgroundExtensionView` only where their declared
  availability permits.
- Keep the app's deployment target unchanged unless the user explicitly changes
  the product support policy. A newer SDK does not require abandoning older OS
  releases.

Do not infer exact API availability from a WWDC slide, sample deployment target,
or remembered declaration. Inspect Quick Help, generated interfaces, or a compile
against the selected SDK at the use site.

## Prerelease boundary

As of the review date, Xcode 27 and the 2027 OS generation are prerelease. Apple
describes a refreshed Liquid Glass appearance that standard SwiftUI components
adopt automatically, plus evolving toolbar, minimization, overflow, and adaptive
layout APIs.

- Read `09-current-beta.md` only when the selected toolchain or request includes that
  prerelease generation.
- Keep beta-only code in a narrow availability-gated path.
- Do not make a prerelease screenshot, metric, or behavior the stable iOS 26
  contract.
- Revalidate names, signatures, availability, and behavior against the installed
  SDK before emitting code.
- Label beta evidence with the exact Xcode build, SDK, OS build, and device.

## Availability and fallback contract

At each new API use site:

1. Determine the framework and platform declaration in the selected SDK.
2. Gate with `if #available` or an equivalent structural boundary when the
   deployment target predates the API.
3. Confirm the compiler knows the symbol. Runtime availability cannot make an
   unknown API parse in an older toolchain; use a compatible Xcode or a verified
   compile-time isolation strategy.
4. Preserve the same action, state, focus behavior, accessibility semantics, hit
   target, and hierarchy on both branches.
5. Use an existing system component, standard `Material`, or an opaque semantic
   surface as the fallback.
6. Do not backport the visual effect with private APIs, `CABackdropLayer`, stacked
   blurs, or fixed refraction recipes.
7. Compile the old and new paths. Exercise both when matching runtimes are
   available.

Prefer extracting the common label and action over duplicating business logic in
the availability branches. Keep branch-specific styling local.

## Platform scope

This skill leads iOS and iPadOS work in SwiftUI, UIKit, and mixed applications.
Apply the same system-first principle to Mac Catalyst when it shares those
frameworks, but verify Catalyst-specific availability and behavior. Route native
AppKit implementation to an AppKit-capable workflow and avoid importing iOS
signatures by analogy.

Do not conflate these APIs with visionOS `glassBackgroundEffect` or
`GlassBackgroundDisplayMode`; spatial glass has a different purpose and API model.

## Refresh protocol

Before a version-sensitive implementation or review:

- record the exact Xcode, Swift, SDK, deployment targets, and runtime versions;
- open the current Apple technology overview and API declarations;
- compare the stable source branch with the installed SDK interface;
- inspect release notes for deprecated compatibility switches or changed default
  behavior;
- update claims and examples rather than preserving stale pixel descriptions;
- report any behavior that remains unverified on the requested runtime.
