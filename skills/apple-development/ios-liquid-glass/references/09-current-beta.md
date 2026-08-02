# Current beta delta

Snapshot: 2026-08-02. Beta-only. Verify current Apple documentation, release notes,
and the installed Xcode SDK and compiler before use. Do not copy this file's API
names into stable examples without that verification.

## Scope

As of this snapshot, Xcode 27 and the 2027 iOS and iPadOS generation are
prerelease. Apple presents the following as evolving behavior rather than the
stable iOS 26 baseline:

- a refreshed Liquid Glass appearance that standard SwiftUI components adopt on
  2027 OS releases without source changes;
- user-adjustable Liquid Glass appearance or tint behavior that can change the
  rendered result independently of app code;
- toolbar overflow and visibility-priority behavior;
- new pinned toolbar placements and navigation-bar minimization behavior;
- a prominent tab role and related tab presentation changes;
- resizable iPhone interfaces and size-class-driven adaptation;
- Xcode 27 previews and device workflows for those changing sizes.

Do not encode the refreshed look with fixed blur, opacity, highlight, refraction,
border, or shadow values. Preserve semantic native components and validate their
current system rendering.

## Seed-sensitive API names

Apple's prerelease pages and session material have exposed evolving names around
toolbar minimization, including forms resembling `toolbarMinimizeBehavior` and
`toolbarMinimizationBehavior`. Treat any exact spelling, signature, placement,
role, or availability as seed-sensitive.

Before writing code:

1. Record the installed Xcode and SDK build.
2. Inspect the generated SwiftUI interface or compiler completion.
3. Check Xcode 27 and iOS/iPadOS 27 release notes for the current seed.
4. Compile a minimal use site in the real project and deployment configuration.
5. Gate the runtime path with its declared availability.
6. Keep stable iOS 26 behavior and tests independent of the beta branch.

An `if #available` check cannot make an API known to an older compiler. Do not add
unverified beta spellings to source that must compile with an older Xcode.

## Beta validation record

For every beta result, record:

- Xcode, SDK, compiler, OS, and device build identifiers;
- whether the behavior came automatically from a system component or from new
  source;
- compact, regular, rotated, multitasking, and resizable states exercised;
- toolbar overflow, pinned placement, minimization, tab, search, presentation, and
  focus behavior affected;
- light, dark, accessibility display, and preferred glass appearance settings;
- failures or assumptions that must be revisited on the next seed.

Do not use beta-only metrics, screenshots, or Device Hub coverage as the completion
gate for an ordinary stable iOS 26 request. Label beta findings provisional and
refresh this file when the release candidate or stable SDK changes the contract.
