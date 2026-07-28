# RTL support source map

Last reviewed: 2026-07-28.

Use primary Apple documentation for platform behavior and APIs. Use Unicode for
the normative bidi and locale-data models, and W3C Internationalization notes
for script requirements and practical bidi explanations. Verify generated SDK
interfaces whenever availability or deprecation affects an implementation.

## Contents

- Availability and interpretation notes
- Required design and implementation core
- Current text and SDK behavior
- Assets, symbols, and custom layout
- Unicode, scripts, and formatting
- Localization and testing workflow

## Availability and interpretation notes

- Treat Apple archive documents as historical detail, not current API
  authority. Reconcile them with current HIG, SDK interfaces, and newer WWDC
  sessions.
- Apps built with the iOS 26 SDK adopt content-based paragraph writing
  direction for SwiftUI `Text`, `TextField`, and `TextEditor`; do not generalize
  older UI-language-based behavior.
- Natural alignment resolution depends on framework, selected SDK, and TextKit
  configuration. Verify rather than assuming one timeless meaning.
- `UITextView.selectedRanges` and multi-range delegate behavior are
  availability-sensitive. Keep TextKit 2 when Natural Selection is required.
- SwiftUI shape mirroring defaults can differ by deployment target. Avoid
  automatic plus manual double mirroring.
- Treat WWDC26 translation-agent guidance as availability-sensitive while its
  described toolchain is prerelease or not selected by the project.
- Use `String(localized:)` with catalog plural variations; it does not invent
  grammatical variants for an unconfigured message.
- Use Unicode controls only after system localization, formatting, paragraph
  direction, and isolation boundaries fail to express a documented case.

## Required design and implementation core

- [1 · Right to left — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/right-to-left)
- [2 · Get it right (to left) — WWDC22](https://developer.apple.com/videos/play/wwdc2022/10107/)
- [3 · Design for Arabic — WWDC22](https://developer.apple.com/videos/play/wwdc2022/10034/)
- [4 · Unicode Standard Annex #9: Bidirectional Algorithm](https://www.unicode.org/reports/tr9/)
- [5 · Supporting Right-to-Left Languages — Apple archive](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/SupportingRight-To-LeftLanguages/SupportingRight-To-LeftLanguages.html)
- [6 · Build localization-friendly layouts using Xcode — WWDC20](https://developer.apple.com/videos/play/wwdc2020/10219/)
- [7 · Supporting multiple languages in your app](https://developer.apple.com/documentation/xcode/supporting-multiple-languages-in-your-app)
- [8 · Localize your SwiftUI app — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10220/)
- [9 · UIView.semanticContentAttribute](https://developer.apple.com/documentation/uikit/uiview/semanticcontentattribute)
- [10 · Build global apps: Localization by example — WWDC22](https://developer.apple.com/videos/play/wwdc2022/10110/)
- [11 · Anatomy of a Constraint](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html)
- [12 · Formatters: Make data human-friendly — WWDC20](https://developer.apple.com/videos/play/wwdc2020/10160/)

## Current text and SDK behavior

- [13 · Enhance your app's multilingual experience — WWDC25](https://developer.apple.com/videos/play/wwdc2025/222/)
- [14 · iOS and iPadOS 26 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-26-release-notes)
- [15 · Text.WritingDirectionStrategy](https://developer.apple.com/documentation/swiftui/text/writingdirectionstrategy)
- [16 · multilineTextAlignment(strategy:)](https://developer.apple.com/documentation/swiftui/view/multilinetextalignment%28strategy:%29)
- [17 · LayoutDirectionBehavior](https://developer.apple.com/documentation/swiftui/layoutdirectionbehavior)
- [18 · UITextView.selectedRanges](https://developer.apple.com/documentation/uikit/uitextview/selectedranges-3hvsl)
- [19 · NSTextAlignment.natural](https://developer.apple.com/documentation/uikit/nstextalignment/natural)

## Assets, symbols, and custom layout

- [20 · SF Symbols — Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
- [21 · Localizing assets in a catalog](https://developer.apple.com/documentation/xcode/localizing-assets-in-a-catalog)
- [22 · UICollectionViewLayout.flipsHorizontallyInOppositeLayoutDirection](https://developer.apple.com/documentation/uikit/uicollectionviewlayout/flipshorizontallyinoppositelayoutdirection)
- [23 · NSDirectionalEdgeInsets](https://developer.apple.com/documentation/uikit/nsdirectionaledgeinsets)
- [24 · View.flipsForRightToLeftLayoutDirection(_:)](https://developer.apple.com/documentation/swiftui/view/flipsforrighttoleftlayoutdirection%28_%3A%29)
- [25 · Compose custom layouts with SwiftUI — WWDC22](https://developer.apple.com/videos/play/wwdc2022/10056/)

## Unicode, scripts, and formatting

- [26 · Arabic and Persian Layout Requirements](https://www.w3.org/TR/alreq/)
- [27 · Unicode Bidirectional Algorithm basics](https://www.w3.org/International/articles/inline-bidi-markup/uba-basics)
- [28 · Unicode LDML Part 3: Numbers](https://www.unicode.org/reports/tr35/tr35-numbers.html)
- [29 · Unicode Security Mechanisms](https://www.unicode.org/reports/tr39/)
- [30 · Hebrew Script Resources](https://www.w3.org/International/hlreq/hebr/)
- [31 · CLDR Language Plural Rules](https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html)
- [32 · Use cases for bidi and language metadata](https://www.w3.org/International/articles/lang-bidi-use-cases/)

## Localization and testing workflow

- [33 · Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog)
- [34 · Streamline your localized strings — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10221/)
- [35 · Testing localizations when running your app](https://developer.apple.com/documentation/xcode/testing-localizations-when-running-your-app)
- [36 · Preparing your interface for localization](https://developer.apple.com/documentation/xcode/preparing-your-interface-for-localization)
- [37 · Code-along: Explore localization with Xcode — WWDC25](https://developer.apple.com/videos/play/wwdc2025/225/)
- [38 · Translate your app using agents in Xcode — WWDC26](https://developer.apple.com/videos/play/wwdc2026/213/)
- [39 · Record, replay, and review: UI automation with Xcode — WWDC25](https://developer.apple.com/videos/play/wwdc2025/344/)
- [40 · Creating screenshots of your app for localizers](https://developer.apple.com/documentation/xcode/creating-screenshots-of-your-app-for-localizers)
