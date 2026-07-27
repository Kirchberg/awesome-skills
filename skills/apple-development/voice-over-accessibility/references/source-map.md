# VoiceOver source map

Last reviewed: 2026-07-27.

This map preserves the supplied priority order and score for all 40 direct
sources. Treat current Apple documentation and WWDC material as normative for
Apple API behavior, App Store evaluation, and platform conventions. Use
first-hand practitioner material and UX research to understand real navigation
and testing. Use community code as a hypothesis or example that must compile
and pass VoiceOver testing on the target SDK and OS.

The first version of this skill covers iOS and iPadOS VoiceOver only. Sources
that also discuss other assistive technologies or web standards contribute
screen-reader mental models; they do not expand the skill to Voice Control,
Switch Control, TalkBack, or web accessibility.

## Contents

- Highest-priority design, API, and implementation sources
- Screen-reader mental model, gestures, and practical patterns
- Tooling, testing, and supplementary sources
- Source-use cautions

## Highest-priority design, API, and implementation sources

- [1 · 100/100 · Apple — VoiceOver evaluation criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/voiceover-evaluation-criteria/)
  is the acceptance authority: every common task must work with VoiceOver alone
  on supported device types, with correct labels, states, actions, order, focus,
  modals, custom interactions, and feedback.

- [2 · 99/100 · Apple WWDC19 — Writing Great Accessibility Labels](https://developer.apple.com/videos/play/wwdc2019/254/)
  explains concise, contextual, localized labels, avoidance of redundant role
  text, and updating semantics with UI state.

- [3 · 97/100 · Mikhail Rubanov — Про доступность на iOS](https://rubanov.dev/a11y-book/)
  provides a strong Russian-language, first-hand model of how blind people use
  iPhone, navigate screens, interpret labels, enter text, and complete flows.

- [4 · 97/100 · Apple HIG — VoiceOver](https://developer.apple.com/design/human-interface-guidelines/voiceover)
  gives Apple’s design framing for nonvisual understanding, efficient
  navigation, descriptions, and equivalent interaction.

- [5 · 96/100 · Apple — Supporting VoiceOver in your app](https://developer.apple.com/documentation/uikit/supporting-voiceover-in-your-app)
  covers UIKit auditing, labels, hints, values, accessible elements, grouping,
  gestures, and Screen Curtain.

- [6 · 95/100 · Apple WWDC24 — Catch up on accessibility in SwiftUI](https://developer.apple.com/videos/play/wwdc2024/10073/)
  explains SwiftUI’s generated accessibility elements, native-control styling,
  conditional modifiers, grouping, actions, custom content, and interactions.

- [7 · 95/100 · CVS Health — iOS SwiftUI Accessibility Techniques](https://github.com/cvs-health/ios-swiftui-accessibility-techniques)
  offers runnable good and bad SwiftUI examples for VoiceOver semantics,
  grouping, actions, focus, forms, notifications, and manual testing.

- [8 · 94/100 · Apple SwiftUI — Accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)
  is the entry point for automatic SwiftUI accessibility, modifiers, custom
  elements, and UIKit/AppKit bridges.

- [9 · 94/100 · Apple SwiftUI — Accessibility modifiers](https://developer.apple.com/documentation/swiftui/view-accessibility)
  is the current API index for labels, values, hints, traits, children,
  representations, actions, rotors, focus, and related modifiers.

- [10 · 93/100 · Apple WWDC21 — SwiftUI Accessibility: Beyond the basics](https://developer.apple.com/videos/play/wwdc2021/10119/)
  covers native accessibility representations, custom controls, synthetic
  children, combine/contain/ignore, order, rotors, identity, and cautious focus.

- [11 · 92/100 · Apple WWDC26 — Refine accessibility for custom controls](https://developer.apple.com/videos/play/wwdc2026/220/)
  adds current guidance for purpose, value, actions, feedback, adjustable
  controls, pass-through gestures, Direct Touch, and multidimensional controls.

- [12 · 92/100 · Apple sample — Integrating accessibility into your app](https://developer.apple.com/documentation/accessibility/integrating-accessibility-into-your-app)
  provides official common-control implementation examples to adapt after
  checking the target SDK and deployment versions.

- [13 · 91/100 · Apple Developer Documentation — VoiceOver](https://developer.apple.com/documentation/accessibility/voiceover)
  is the official reference entry point for VoiceOver as an assistive
  technology and related implementation guidance.

## Screen-reader mental model, gestures, and practical patterns

- [14 · 91/100 · Nielsen Norman Group — Challenges for Screen-Reader Users on Mobile](https://www.nngroup.com/articles/screen-reader-users-on-mobile/)
  explains sequential consumption, context loss, verbosity, discoverability,
  headings, repeated controls, and mobile task friction.

- [15 · 90/100 · Nielsen Norman Group — Screen Readers on Touchscreen Devices](https://www.nngroup.com/articles/touchscreen-screen-readers/)
  explains focus-then-activate interaction, touch exploration, gesture
  interception, and why custom touch patterns need accessible alternatives.

- [16 · 89/100 · Nielsen Norman Group — How Screen-Reader Users Type on and Control Mobile Devices](https://www.nngroup.com/articles/screen-reader-type-control/)
  contributes qualitative findings about text entry, dictation, correction,
  gestures, and form control on mobile devices.

- [17 · 89/100 · Apple Support — Use VoiceOver gestures on iPhone](https://support.apple.com/guide/iphone/use-voiceover-gestures-iph3e2e2281/ios)
  is the current user guide for the gestures developers need to practice and
  use in manual testing.

- [18 · 88/100 · Apple Support — Turn on and practice VoiceOver on iPhone](https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios)
  is the practical setup and VoiceOver Practice starting point for testers.

- [19 · 87/100 · Apple Support — Operate iPhone when VoiceOver is on](https://support.apple.com/guide/iphone/operate-iphone-when-voiceover-is-on-iph3e2e2329/ios)
  explains system-level navigation and context surrounding app interaction.

- [20 · 87/100 · W3C — Name, Role, Value](https://www.w3.org/WAI/WCAG21/Understanding/name-role-value.html)
  supplies the general semantic invariant; map it to Apple accessibility APIs
  rather than importing ARIA implementation details into native iOS.

- [21 · 86/100 · WebAIM — Designing for Screen Reader Compatibility](https://webaim.org/techniques/screenreader/)
  reinforces structure, semantics, predictable behavior, alternatives, and
  real screen-reader testing; its implementation examples are web-specific.

- [22 · 85/100 · WebAIM — Testing with Screen Readers: Questions and Answers](https://webaim.org/articles/screenreader_testing/)
  contributes QA reasoning about automation limits, tester proficiency, scope,
  and interpretation of manual screen-reader results.

- [23 · 85/100 · Orange — iOS developer guide](https://a11y-guidelines.orange.com/en/mobile/ios/development/)
  is a structured practical guide to iOS SDK attributes, methods, common
  controls, SwiftUI, UIKit, and links to Apple authority.

- [24 · 84/100 · Orange — iOS accessibility and VoiceOver guide](https://a11y-guidelines-orange.netlify.app/en/mobile/ios/)
  adds a tester-oriented VoiceOver and gesture perspective; prefer Orange’s
  canonical current site when this preview or mirror diverges.

- [25 · 84/100 · Create with Swift — Labels, Values and Hints](https://www.createwithswift.com/preparing-your-app-for-voice-over-labels-values-and-hints/)
  gives approachable SwiftUI/UIKit distinctions between stable purpose,
  changing value, and optional result-oriented hints.

- [26 · 83/100 · Create with Swift — Accessibility Traits](https://www.createwithswift.com/preparing-your-app-for-voice-over-accessibility-traits/)
  illustrates traits and roles; validate examples against native-control
  semantics and do not copy gesture instructions into hints.

- [27 · 83/100 · Create with Swift — Accessibility Actions](https://www.createwithswift.com/accessibility-actions/)
  demonstrates named and custom actions for visual components with multiple
  behaviors.

- [28 · 82/100 · Swift with Majid — Accessibility actions in SwiftUI](https://swiftwithmajid.com/2021/04/15/accessibility-actions-in-swiftui/)
  is a concise example of named and adjustable actions; refresh 2021 API syntax
  and assumptions against current SwiftUI.

- [29 · 81/100 · Deque — What iOS Traits Actually Do](https://www.deque.com/blog/ios-traits/)
  explains why role and trait choices change VoiceOver interaction; treat its
  2015 control-specific claims as historical.

- [30 · 80/100 · Deque University — VoiceOver Gestures on iOS](https://dequeuniversity.com/screenreaders/voiceover-ios-shortcuts)
  is a convenient gesture quick reference to compare with current Apple Support
  guidance.

- [31 · 79/100 · Deque University — Quick Reference Guide: VoiceOver for iOS PDF](https://dequeuniversity.com/assets/pdf/screenreaders/voiceover-ios-images-guide.pdf)
  is a printable gesture and keyboard reference; verify its 2019 details and
  settings paths against the current OS.

## Tooling, testing, and supplementary sources

- [32 · 79/100 · Apple — Accessibility Inspector](https://developer.apple.com/documentation/accessibility/accessibility-inspector)
  documents inspection of the accessibility hierarchy, properties, actions,
  frames, and audit results.

- [33 · 78/100 · Apple WWDC19 — Accessibility Inspector](https://developer.apple.com/videos/play/wwdc2019/257/)
  demonstrates the inspection and audit workflow; use current Xcode
  documentation when the historical UI or options differ.

- [34 · 78/100 · Apple — Performing accessibility testing for your app](https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app)
  defines main-task inventories, device matrices, physical-device VoiceOver,
  Screen Curtain, gestures, and assistive-technology completion.

- [35 · 77/100 · Apple — Performing accessibility audits for your app](https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app)
  defines Inspector audit types and XCUITest audit automation, while explicitly
  warning that clean audits do not guarantee accessibility.

- [36 · 76/100 · Capital One Tech — iOS Accessibility: Best Practices for the VoiceOver User Experience](https://medium.com/capital-one-tech/ios-accessibility-best-practices-for-the-voiceover-user-experience-dc08112ef16)
  provides a supplementary product-spec and implementation view of VoiceOver
  text, traits, hints, values, and states.

- [37 · 75/100 · 24 Accessibility — iOS Accessibility Properties and WCAG](https://www.24a11y.com/2018/ios-accessibility-properties/)
  bridges iOS properties to name, role, state, and value; refresh older API
  details against Apple documentation.

- [38 · 74/100 · Appt.org — SwiftUI accessibility samples](https://appt.org/en/docs/swiftui/samples)
  is a compact cookbook for individual SwiftUI patterns; use it as an example
  index rather than the sole authority.

- [39 · 73/100 · AppleVis — Complete list of iOS and iPadOS VoiceOver gestures](https://www.applevis.com/guides/complete-list-ios-ipados-gestures-available-voiceover-users)
  contributes a detailed community-maintained gesture reference and experienced
  user perspective.

- [40 · 70/100 · freeCodeCamp — Common Accessibility Challenges in iOS using SwiftUI](https://www.freecodecamp.org/news/how-to-address-ios-accessibility-challenges-using-swiftui/)
  is a supplementary overview of common SwiftUI problems; prefer Apple, CVS,
  and first-hand sources when recommendations conflict.

## Source-use cautions

- Apple documentation, SwiftUI modifiers, notifications, Inspector UI, and
  XCUITest audit availability can change with Xcode and OS releases. Recheck the
  target SDK before asserting an API or workflow.
- WWDC26 is an available current source, but its code can use newer APIs than a
  project’s deployment matrix permits.
- Rubanov’s book is strongest for user mental models and scenarios. Do not copy
  old private numeric traits, 3D Touch advice, or historical API limitations.
- CVS Health is a valuable live test bed, but reproduce documented framework
  bugs and delay-based workarounds on the target OS before adopting them.
- NN/g research is qualitative UX evidence, not a universal measurement of all
  VoiceOver users.
- W3C, WebAIM, and web-oriented sources supply semantic and testing principles,
  not native Apple API instructions.
- Older Deque, Orange, Create with Swift, Swift with Majid, Capital One, and
  24 Accessibility examples require current API, role, and behavior validation.
- Community gesture guides supplement but do not override current Apple Support
  documentation or testing with the actual supported OS.
