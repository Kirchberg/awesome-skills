# Design principles and HIG guardrails

Use current Apple HIG and technology guidance as the authority for where Liquid
Glass belongs. Use API documentation to decide how to implement that decision.

## Keep content and controls distinct

Treat the interface as two cooperating layers:

- **Content layer**: the information or media people came to view, edit, or
  create. Prefer ordinary layout, semantic backgrounds, and standard materials.
- **Functional layer**: navigation, search, persistent or contextual controls,
  menus, bars, and important actions that float above or frame the content.

Liquid Glass primarily belongs to the functional layer. Do not use it as the
default background for cards, list rows, sections, reading surfaces, or every
container. Let content remain visually primary and legible.

## Prefer semantic system components

Start with the platform component that owns the role: navigation stack or split
view, tab or sidebar, toolbar, search, sheet, popover, menu, button, picker, or
other control. System components coordinate material, safe areas, input, focus,
accessibility, animation, and future visual updates.

Require a concrete product benefit before replacing one with custom UI. A custom
header that merely resembles a navigation bar is not equivalent to a navigation
bar.

## Choose material deliberately

- Use regular glass as the default native custom variant.
- Reserve clear glass for limited media-rich contexts whose backgrounds can be
  dimmed as necessary and whose bold, bright foreground remains legible across
  real content.
- Do not mix regular and clear variants within one visually related group.
- Use standard `Material` or an opaque surface for content-layer grouping or an
  earlier-OS fallback; do not force every translucent surface into Liquid Glass.
- Test the material over the actual range of content. A quiet preview image does
  not prove legibility over a busy, bright, dark, or animated background.

## Express hierarchy without decoration

- Use tint to communicate prominence, selection, status, or a primary action.
  Keep most controls neutral so tinted emphasis remains meaningful.
- Never encode state or validity through tint alone. Preserve label, symbol,
  trait, value, or other semantic evidence.
- Add interactive behavior only to an element that is actionable or focusable.
  A decorative surface must not respond as if it were a control.
- Keep related shapes, spacing, and corner treatment coherent. Use concentric
  geometry for nested rounded surfaces rather than repeating arbitrary radii.
- Preserve familiar symbol meaning and predictable action placement.

## Compose one functional layer

Group related custom effects in one container so the system can coordinate their
shapes, merging, separation, and morphing. Avoid glass-on-glass, nested effect
stacks, and a row of independent containers.

Use identity and morphing only when one functional element meaningfully becomes
another or a related control appears or disappears. Do not animate material merely
to advertise the technology.

## Design for adaptation

Review the interface across compact and regular widths, rotation, multitasking,
resizing, pointer and touch input, light and dark appearance, changing safe areas,
and long or localized labels. Allow the system to place overflow and adapt bars
instead of hard-coding a screenshot's dimensions.

Do not freeze blur radius, opacity, highlight, border, shadow, or refraction to
match one OS release. Liquid Glass is rendered by the system and may evolve while
the semantic component remains correct.

## Review questions

Before approving a glass surface, answer:

1. What functional role does it serve?
2. Which system component or style was considered first?
3. Why is custom glass better for the user than a standard component or material?
4. Is its variant, tint, shape, and interactivity semantically justified?
5. Which related effects share one container and identity domain?
6. Does content stay readable and primary on representative backgrounds?
7. Does the design survive accessibility display settings and larger text?
8. Does it adapt without fixed appearance constants on the next system release?

Reject a surface that can answer only “it looks more like Liquid Glass.”
