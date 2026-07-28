# Review the product before reviewing the pixels

Use this checklist as a derived review method, not as a substitute for current
HIG, product evidence, usability research, or runtime testing. Apply only items
relevant to the task and target platforms.

## Contents

- Record the review contract
- Pass 1: purpose, structure, and comprehension
- Pass 2: presentation, interaction, and craft
- Write actionable findings
- Gate completion

## Record the review contract

- Name the artifact, build, commit, screen, flow, and state reviewed.
- Record target users, product goal, platforms, device or window classes,
  deployment range, inputs, appearances, locales, and accessibility settings.
- Separate observed evidence from inferred behavior and design preference.
- State whether the review is static, interactive, code-based, simulator-based,
  device-based, or user-tested.
- Do not claim coverage for states or environments that were not available.

## Pass 1: purpose, structure, and comprehension

### Purpose and agency

- Does the flow solve one identifiable user problem?
- Is the primary outcome obvious and valuable?
- Can the person cancel, go back, undo, or recover proportionally?
- Are destructive, irreversible, expensive, or privacy-sensitive consequences
  clear before commitment?
- Has unnecessary setup, interruption, choice, or data collection been removed?

### Information architecture and navigation

- Does hierarchy match the person's mental model and task frequency?
- Are persistent destinations distinct from contextual actions?
- Does each navigation or presentation pattern match its structural role?
- Is location, selection, modal scope, and a route back clear?
- Does search have a justified scope, placement, query state, and recovery path?
- Does the anatomy adapt coherently across supported devices and input methods?

### States and discoverability

- Are applicable initial, loading, content, empty, partial, error, offline,
  restricted, and completed states designed?
- Can a new person find the primary action without coaching?
- Do labels, symbols, grouping, affordances, and feedback explain behavior?
- Is every hidden gesture backed by a visible or semantic alternative?
- Are tips contextual, eligible, dismissible, frequency-bounded, and invalidated
  after learning?
- Are permissions requested in context with a useful denial path?

## Pass 2: presentation, interaction, and craft

### Layout and visual hierarchy

- Does content lead while controls remain distinct and reachable?
- Do grouping, alignment, spacing, type, and emphasis agree on priority?
- Does the layout survive text expansion, keyboard, safe areas, window resizing,
  rotation, and representative data extremes?
- Are density and progressive disclosure appropriate to platform and task?
- Are loading, error, and empty presentation visibly distinct?

### Components and visual language

- Was a current system component evaluated before custom UI?
- Does every custom component justify its behavior and preserve system semantics?
- Do semantic colors work in light, dark, and increased-contrast appearances?
- Is meaning available without color, transparency, imagery, or motion?
- Do typography and symbols scale, localize, and retain legibility?
- Do materials communicate hierarchy rather than decorate content?
- Is Liquid Glass limited to a justified interface layer and implemented through
  current platform behavior?

### Writing, motion, and feedback

- Are nouns consistent and actions specific?
- Do empty and error states explain the state and next useful action?
- Does motion explain state or space, preserve continuity, and support
  interruption?
- Is the Reduce Motion alternative meaningful rather than merely faster?
- Are sound and haptics causal, harmonious, useful, and nonessential?
- Does feedback occur when the outcome is known rather than prematurely?

### Accessibility, inclusion, privacy, and trust

- Can every common task be perceived and operated through applicable assistive
  modes and input methods?
- Do larger text, contrast, reduced motion, reduced transparency, localization,
  and bidirectional content preserve meaning and actions?
- Are accessible name, role, value, state, order, focus, and actions coherent?
- Does content avoid unsupported assumptions and exclusionary defaults?
- Is data collection minimized, explained, and survivable after denial?
- Are claims about privacy, security, accessibility, and conformance supported
  by implementation and test evidence?

## Write actionable findings

For each issue, report:

1. **Evidence**: where and in which state it occurs.
2. **Impact**: the task, audience, platform, or risk affected.
3. **Principle**: the product goal, current Apple guidance, or established
   design-system rule involved.
4. **Correction**: the smallest complete change, including affected states.
5. **Confidence and validation**: what supports the finding and how to verify it.

Use severity consistently:

- **Blocker**: prevents a critical task, creates severe loss or trust risk, or
  makes an essential path inaccessible.
- **Major**: materially harms comprehension, control, completion, or broad
  adaptability.
- **Minor**: localized inconsistency or friction with a clear user impact.
- **Opportunity**: optional craft or delight improvement with no current defect.

Do not inflate visual preference into a blocker. Do not bury functional and
accessibility failures under polish notes.

## Gate completion

Approve only when the design contract, applicable states, platform adaptations,
custom-component rationale, accessibility and privacy requirements,
implementation mapping, and validation plan are present. If runtime evidence is
missing, approve the artifact conditionally and state the remaining device,
locale, assistive, motion, material, or performance verification.
