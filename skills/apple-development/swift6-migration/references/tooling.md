# Tooling and configuration

## Contents

- [Source priority](#source-priority)
- [Inventory](#inventory)
- [Xcode](#xcode)
- [Tuist and XcodeGen](#tuist-and-xcodegen)
- [SwiftPM](#swiftpm)
- [Diagnostics](#diagnostics)
- [Verification matrix](#verification-matrix)
- [Workspace artifacts](#workspace-artifacts)
- [Official references](#official-references)

## Source priority

Use this order before running commands or changing configuration:

1. Repository instructions and supported scripts.
2. Checked-in manifests, build settings, and configuration helpers.
3. Installed toolchain behavior and generated build settings inspected read-only.
4. Official documentation for the installed Swift, Xcode, SwiftPM, and project generator versions.
5. Generic examples in this reference.

Never copy an example command until its scheme, destination, configuration, and working directory match the project.

## Inventory

Capture:

- `xcodebuild -version`;
- `swift --version`;
- available schemes, destinations, and test plans;
- every target's current language mode;
- default actor isolation and enabled upcoming language features;
- the authoritative source of that setting;
- supported platforms and configurations;
- package and generator versions.

Prefer structural code navigation for Swift and Objective-C symbols. Use text search for manifests, `.xcconfig`, YAML, project-generator settings, and build-setting keys.

Exclude secrets, generated environment files, IDE user data, package caches, and build output.

## Xcode

Swift 6 language mode is selected with:

```text
SWIFT_VERSION = 6
```

Complete checking while still compiling in Swift 5 mode can be enabled with:

```text
SWIFT_STRICT_CONCURRENCY = complete
```

Treat default actor isolation and optional upcoming features as separate
configuration decisions. Do not enable them implicitly when switching
`SWIFT_VERSION`; add them to the migration scope and verification matrix when
the project intends to adopt them.

Trace the final value through target settings, project settings, `.xcconfig` inheritance, and generator output. Change the nearest maintained source of truth.

Generic build shape:

```bash
xcodebuild \
  -workspace <Workspace.xcworkspace> \
  -scheme <Scheme> \
  -destination '<Project-specific destination>' \
  -configuration Debug \
  build
```

Generic test shape:

```bash
xcodebuild \
  -workspace <Workspace.xcworkspace> \
  -scheme <Scheme> \
  -destination '<Project-specific destination>' \
  -configuration Debug \
  test
```

Use `-project` instead of `-workspace` only when the repository's supported workflow does so. Use explicit simulator architecture or device requirements when dependencies constrain them.

Do not edit generated project files. Inspect them only to understand resolved settings.

## Tuist and XcodeGen

For Tuist, treat `Project.swift`, `Workspace.swift`, `Tuist.swift`, and project-description helpers as sources of truth. A shared `Settings` value or `SettingsDictionary.swiftVersion(_:)` may affect many targets.

For XcodeGen, treat `project.yml`, included YAML, templates, and referenced `.xcconfig` files as sources of truth.

Before changing a shared helper:

1. Find all consumers.
2. List every affected target.
3. Check for existing Swift 5 and Swift 6 variants.
4. Decide whether the whole group belongs in the stage.
5. Regenerate through the repository's documented command.
6. Inspect the generated diff but do not commit generated projects unless repository policy explicitly requires them.

Do not add a new configuration abstraction when an established helper already models the intended setting.

## SwiftPM

`swift-tools-version: 6.0` selects Swift 6 language mode by default for package targets unless overridden. Package-level `swiftLanguageModes` and target-level `.swiftLanguageMode(...)` must match the manifest API available to the declared tools version.

Mixed-mode example:

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Example",
    targets: [
        .target(name: "Migrated"),
        .target(
            name: "Legacy",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
```

Do not raise the tools version automatically. First determine whether the package must support older Swift toolchains. Use a compatible manifest, a version-specific manifest, or an explicitly approved minimum-version increase.

Temporary command-line probes:

```bash
swift build -Xswiftc -swift-version -Xswiftc 6
swift test -Xswiftc -swift-version -Xswiftc 6
```

Preparation while remaining in Swift 5 mode:

```bash
swift build -Xswiftc -strict-concurrency=complete
swift test -Xswiftc -strict-concurrency=complete
```

A package that relies on workspace-generated frameworks, local application packages, plugins, or custom build steps also needs its integration scheme. A standalone `swift build` is not sufficient evidence in that case.

## Diagnostics

For every check, retain:

- exact command and working directory;
- toolchain versions;
- exit code and completion time;
- full log path when needed;
- concise root-cause summary without secrets.

Group compiler messages by symbol and isolation boundary. One incorrect protocol isolation or captured mutable variable can produce many downstream diagnostics; fix the root cause before editing each occurrence.

Treat warnings promoted to errors, plugin failures, module-interface failures, and generated-source failures as part of the target's actual build contract.

## Verification matrix

Assign each target at least:

- a local Swift 6 build;
- unit tests;
- one nearest-consumer build;
- public API or module-interface validation when exported.

For shared project settings, add:

- every inheriting target;
- top-level applications and extensions;
- Debug and production configurations;
- supported Apple platforms;
- relevant product variants;
- integration and UI tests selected by repository policy.

Do not run every expensive test indiscriminately. Derive the matrix from changed isolation boundaries, consumers, platform-specific code, and project instructions.

## Workspace artifacts

Keep migration state outside source folders, for example:

```text
.swift6-migration/<task-id>/
```

Store small logs only when they help resume or review. Do not store source copies, `DerivedData`, package caches, credentials, generated environments, or IDE user data.

Keep the worktree's unrelated changes untouched. Use separate worktrees only when the user authorizes parallel source edits and the integration plan is explicit.

## Official references

Use documentation matching the installed toolchain:

- [Migrating to Swift 6](https://www.swift.org/migration/)
- [Swift 6 data-race safety](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/dataracesafety/)
- [The Swift Programming Language: Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)
- [PackageDescription: SwiftLanguageMode](https://docs.swift.org/swiftpm/documentation/packagedescription/swiftlanguagemode/)
- [PackageDescription: swiftLanguageMode](https://docs.swift.org/swiftpm/documentation/packagedescription/swiftsetting/swiftlanguagemode%28_%3A_%3A%29/)
- [Setting the Swift tools version](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/settingswifttoolsversion/)
