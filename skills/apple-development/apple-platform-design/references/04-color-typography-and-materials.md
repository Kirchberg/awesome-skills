# Color, typography, and materials

Use the visual system to clarify hierarchy, state, and brand while preserving
platform adaptation.

## Color

- Assign colors semantic roles such as primary content, secondary content,
  background level, separator, accent, status, or destructive action.
- Prefer dynamic system colors for platform roles. Keep custom brand colors in
  semantic asset or token variants rather than hard-coded literals.
- Use tint selectively to identify interactive emphasis and brand continuity;
  avoid making unrelated controls appear equally primary.
- Keep a color's meaning consistent within a locale and context.
- Pair every color-coded state with text, shape, symbol, position, or another
  perceivable cue.
- Design each semantic color for all supported appearances and elevated,
  grouped, material, media, and disabled contexts.

Do not copy documented system color values: the system may adjust them across
releases, displays, settings, and materials.

## Typography

- Start with system text styles and Dynamic Type to express hierarchy.
- Limit hierarchy levels and typefaces; use contrast in style intentionally.
- Prefer the system font for interface text. Use a custom face when it adds
  meaningful identity and remains legible, scalable, localizable, and available
  in every required script or fallback.
- Preserve the intended optical hierarchy as text grows; reflow or change the
  composition instead of capping accessibility sizes to protect a screenshot.
- Let labels state actions and headings state content. Avoid using type styling
  to compensate for vague writing or structure.
- Test weight, line length, wrapping, truncation, alignment, and spacing with
  real localized content.

Consult the current HIG and Apple Design Resources for platform text styles,
legibility guidance, and specifications. Do not encode remembered point sizes.

## Materials and layering

- Use material to communicate depth, separation, and functional hierarchy.
- Let system navigation and controls adopt the current platform material
  automatically wherever possible.
- Keep Liquid Glass in the functional layer for navigation and controls above
  content. Use standard materials or ordinary surfaces to organize the content
  layer.
- Apply custom glass effects sparingly and only to important interactive
  elements. Choose the system-supported variant for the background and
  legibility needs, not for a preferred screenshot color.
- Keep related glass elements grouped coherently and avoid stacking translucent
  surfaces until depth becomes ambiguous.
- Preserve content prominence under floating controls and account for scroll
  edge treatment, media brightness, and changing backgrounds.
- Expect materials to respond to appearance and accessibility settings; never
  depend on translucency to convey required structure.

## Brand and iconography

Express brand first through content, imagery, writing, typography, accent color,
and interaction character. Keep control semantics familiar.

Prefer current SF Symbols for familiar actions when an appropriate symbol
exists. Match symbol weight, scale, rendering, directionality, and state to its
text and context. Pair ambiguous or unfamiliar symbols with labels. Verify
custom symbols at intended sizes and accessibility settings.

## Guardrails

- Do not use a static palette for dynamic system roles.
- Do not use low opacity as a substitute for a semantic disabled state.
- Do not place fine text or icons over uncontrolled imagery without an adaptive
  contrast treatment.
- Do not use material as decoration across the content layer.
- Do not use custom fonts, all caps, thin weights, or tight tracking where they
  reduce legibility or localization resilience.
- Do not infer contrast from a design-tool snapshot alone.

## Evidence and validation

Maintain a semantic token map showing each role, context, and system or custom
source. Validate implemented screens with:

- light, dark, and any platform-specific appearance in scope;
- Increase Contrast, Differentiate Without Color, Reduce Transparency, Bold
  Text, and relevant color-filter or inversion settings;
- Dynamic Type across the supported range and realistic localized scripts;
- bright, dark, detailed, and changing content behind materials;
- disabled, selected, focused, destructive, warning, success, and error states;
- current HIG specifications, Apple Design Resources, and actual framework
  rendering on representative devices or displays.

Record failures by semantic role and state, then fix the token or component
source rather than patching isolated screenshots.
