# Apple platform design source map

Last reviewed: 2026-07-28.

Use current Apple guidance as the authority for platform design and API
behavior. Treat WWDC sessions as dated explanations, Apple Design Resources as
release snapshots, and secondary research as supporting evidence rather than
Apple policy.

## Contents

- Source priority and interpretation
- Current Apple guidance
- Apple release and implementation sources
- Historical Apple heuristics
- Secondary research supplements

## Source priority and interpretation

1. Prefer current HIG for design decisions and current API documentation and
   release notes for implementation and availability.
2. Use the current Apple Design Resources kit for the target platform and
   release. Link to it; do not bundle or redistribute Apple templates or fonts.
3. Keep the year attached to WWDC guidance. Reconcile older sessions and samples
   with current HIG, SDK interfaces, and deployment targets.
4. Treat exact dimensions, search placement, material appearance, component
   anatomy, icon formats, and supported APIs as version-sensitive.
5. Treat the state checklist and two-pass review in this skill as derived
   methods, not claims that Apple mandates one universal process.
6. Use secondary sources only when they add user-research or evaluation methods
   not supplied by Apple. Label any conflict and prefer current primary guidance.

## Current Apple guidance

- [current-guidance · Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [current-guidance · Design principles](https://developer.apple.com/design/human-interface-guidelines/design-principles)
- [current-guidance · Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
- [current-guidance · Designing for iPadOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ipados)
- [current-guidance · Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos)
- [current-guidance · Designing for watchOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos)
- [current-guidance · Designing for tvOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-tvos)
- [current-guidance · Designing for visionOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos)
- [current-guidance · Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [current-guidance · Components](https://developer.apple.com/design/human-interface-guidelines/components)
- [current-guidance · Patterns](https://developer.apple.com/design/human-interface-guidelines/patterns)
- [current-guidance · Navigation and search](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
- [current-guidance · Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- [current-guidance · Writing](https://developer.apple.com/design/human-interface-guidelines/writing)
- [current-guidance · Color](https://developer.apple.com/design/human-interface-guidelines/color)
- [current-guidance · Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- [current-guidance · Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [current-guidance · Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback)
- [current-guidance · Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
- [current-guidance · Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars)
- [current-guidance · SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
- [current-guidance · Gestures](https://developer.apple.com/design/human-interface-guidelines/gestures)
- [current-guidance · Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
- [current-guidance · Loading](https://developer.apple.com/design/human-interface-guidelines/loading)
- [current-guidance · Launching](https://developer.apple.com/design/human-interface-guidelines/launching)
- [current-guidance · Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)
- [current-guidance · Offering help](https://developer.apple.com/design/human-interface-guidelines/offering-help)
- [current-guidance · Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [current-guidance · Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [current-guidance · Inclusion](https://developer.apple.com/design/human-interface-guidelines/inclusion)
- [current-guidance · Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy)
- [current-guidance · Right to left](https://developer.apple.com/design/human-interface-guidelines/right-to-left)
- [current-guidance · App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [current-guidance · Apple Design Resources](https://developer.apple.com/design/resources/)
- [current-guidance · Apple design updates](https://developer.apple.com/design/whats-new/)
- [current-guidance · Apple Design Resources license](https://developer.apple.com/support/downloads/terms/apple-design-resources/Apple-Design-Resources-License-20230621-English.pdf)
- [current-guidance · Apple Design Awards](https://developer.apple.com/design/awards/)

## Apple release and implementation sources

- [release-snapshot · Principles of great design — WWDC26](https://developer.apple.com/videos/play/wwdc2026/250/)
- [release-snapshot · Communicate your brand identity on iOS — WWDC26](https://developer.apple.com/videos/play/wwdc2026/251/)
- [release-snapshot · Craft clear names for features and labels — WWDC26](https://developer.apple.com/videos/play/wwdc2026/290/)
- [release-snapshot · Design intuitive search experiences — WWDC26](https://developer.apple.com/videos/play/wwdc2026/292/)
- [release-snapshot · Meet Liquid Glass — WWDC25](https://developer.apple.com/videos/play/wwdc2025/219/)
- [release-snapshot · Get to know the new design system — WWDC25](https://developer.apple.com/videos/play/wwdc2025/356/)
- [release-snapshot · Design foundations from idea to interface — WWDC25](https://developer.apple.com/videos/play/wwdc2025/359/)
- [implementation · Build a SwiftUI app with the new design — WWDC25](https://developer.apple.com/videos/play/wwdc2025/323/)
- [implementation · Build a UIKit app with the new design — WWDC25](https://developer.apple.com/videos/play/wwdc2025/284/)
- [release-snapshot · Say hello to the new look of app icons — WWDC25](https://developer.apple.com/videos/play/wwdc2025/220/)
- [implementation · Create icons with Icon Composer — WWDC25](https://developer.apple.com/videos/play/wwdc2025/361/)
- [implementation · TipKit documentation](https://developer.apple.com/documentation/tipkit)
- [implementation · Highlighting app features with TipKit](https://developer.apple.com/documentation/tipkit/highlightingappfeatureswithtipkit)
- [release-snapshot · Make features discoverable with TipKit — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10229/)
- [release-snapshot · Customize feature discovery with TipKit — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10070/)
- [implementation · SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback)
- [implementation · Core Haptics](https://developer.apple.com/documentation/corehaptics)
- [implementation · Delivering rich app experiences with haptics](https://developer.apple.com/documentation/corehaptics/delivering-rich-app-experiences-with-haptics)
- [release-snapshot · Enhance UI animations and transitions — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10145/)

## Historical Apple heuristics

- [historical-heuristic · Discoverable design — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10126/)
- [historical-heuristic · Practice audio haptic design — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10278/)
- [historical-heuristic · Designing Fluid Interfaces — WWDC18](https://developer.apple.com/videos/play/wwdc2018/803/)
- [historical-heuristic · The Life of a Button — WWDC18](https://developer.apple.com/videos/play/wwdc2018/804/)
- [historical-heuristic · Intentional Design — WWDC18](https://developer.apple.com/videos/play/wwdc2018/802/)
- [historical-heuristic · Designing Award Winning Apps and Games — WWDC19](https://developer.apple.com/videos/play/wwdc2019/802/)

## Secondary research supplements

- [research-supplement · Onboarding tutorials versus contextual help](https://www.nngroup.com/articles/onboarding-tutorials/)
- [research-supplement · Progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
- [research-supplement · Instructional overlays and coach marks](https://www.nngroup.com/articles/mobile-instructional-overlay/)
- [research-supplement · Designing empty states](https://www.nngroup.com/articles/empty-state-interface-design/)
- [research-supplement · Ten usability heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
- [research-supplement · Conducting a heuristic evaluation](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/)
- [research-supplement · Error-message guidelines](https://www.nngroup.com/articles/error-message-guidelines/)
- [research-supplement · The Design of Everyday Things](https://jnd.org/books/the-design-of-everyday-things-revised-and-expanded-edition/)
