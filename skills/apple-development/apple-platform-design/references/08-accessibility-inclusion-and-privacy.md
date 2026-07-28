# Build accessibility, inclusion, and privacy into the design

Treat access and trust as product requirements established before visual polish.
Design equivalent information, actions, and recovery across supported
interaction modes without requiring people to disclose more than the task needs.

## Establish the access contract

For every common task and relevant state, define:

- the information required to understand the screen;
- the actions, order, values, and consequences;
- keyboard, touch, pointer, remote, gaze, switch, voice, and assistive-technology
  paths that apply to the target platforms;
- larger text, zoom, contrast, reduced motion, transparency, and color settings
  that can change presentation;
- the evidence required before calling the task accessible.

Prefer native controls because they carry platform semantics and behavior, but
inspect the resulting experience. A standard component can still be used with
ambiguous labels, illogical order, inaccessible content, or insufficient space.

## Design perceivable information

- Keep text legible at supported content sizes and allow wrapping and layout
  reflow without clipping, overlap, or lost actions.
- Meet current platform contrast guidance in each appearance and increased
  contrast mode.
- Never encode status, selection, validity, or priority by color alone.
- Provide text or semantic alternatives for meaningful images, charts, audio,
  video, and custom drawing; hide decoration from the accessibility tree.
- Preserve meaning when transparency, motion, or sound is reduced or disabled.
- Keep targets and spacing usable for the platform and input method; verify
  current HIG rather than copying a remembered number.

## Design operable interaction

- Expose a visible and semantic alternative to custom or hidden gestures.
- Preserve logical focus and reading order as content inserts, deletes, filters,
  refreshes, or presents modally.
- Keep critical controls reachable with supported keyboard, switch, voice, and
  assistive navigation.
- Separate a control's accessible name, role, value, state, actions, and
  optional hint.
- Announce important asynchronous changes without stealing focus or flooding
  speech.
- Make destructive actions explicit and reversible where possible.

Use a specialized VoiceOver, localization, RTL, or motion skill for deep
implementation and testing when available. Do not collapse all accessibility
into one screen-reader pass.

## Design inclusive content

- Avoid unnecessary assumptions about identity, family, culture, ability,
  finances, location, connectivity, or technical expertise.
- Ask only for identity attributes the task truly requires; support omission and
  self-description when practical.
- Use representative imagery and examples without stereotyping.
- Write neutral errors and recovery paths; do not blame a person for system,
  network, or validation failures.
- Test names, addresses, dates, numbers, calendars, text expansion, and
  bidirectional content with real representative locales.

## Design privacy as an experience

1. Minimize collection, retention, exposure, and sharing before designing a
   permission explanation.
2. Request protected data or capabilities only when a feature needs them.
3. Explain the direct benefit and use before the system prompt when context is
   not already obvious.
4. Preserve useful behavior after denial whenever possible.
5. Provide clear status, revocation, deletion, and retry paths appropriate to
   the product.
6. Avoid dark patterns, false urgency, preselected consent, or visual hierarchy
   that obscures the privacy-preserving choice.

Do not imitate a system permission dialog. Do not promise security, anonymity,
or data practices that were not verified in product policy and implementation.

## Validate claims proportionally

Combine design inspection, accessibility-tree inspection, automated checks,
representative simulator coverage, and manual device tasks with relevant
assistive technologies and settings. Include real localized content.

Report exactly which tasks, states, devices, OS versions, locales, inputs, and
settings were exercised. Use “designed with accessibility requirements;
runtime verification pending” when evidence stops at static artifacts.
