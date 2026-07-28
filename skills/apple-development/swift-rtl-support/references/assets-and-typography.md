# Assets, symbols, and RTL typography

Classify visual content by meaning before choosing mirroring or localization.

## Contents

- Choose an Asset Catalog direction
- Classify images and artwork
- Use semantic symbols
- Review custom shapes and effects
- Verify Arabic typography
- Verify Hebrew, Persian, and Urdu independently

## Choose an Asset Catalog direction

Treat the Asset Catalog **Direction** values as three choices:

- **Fixed**: keep one rendition in both layout directions.
- **Mirrors**: let the system mirror one safe directional rendition.
- **Both**: supply purpose-built left-to-right and right-to-left renditions.

Treat localization as an orthogonal dimension. A localized asset can vary by
language or region in addition to having a direction policy. Do not describe it
as a fourth Direction menu value.

Prefer separate renditions over mechanical mirroring when the asset contains:

- text, numerals, or script-specific punctuation;
- several elements with different semantic directions;
- asymmetric light, shadow, depth, or perspective;
- a hand, body side, vehicle, road, map, or physical device;
- culture-specific imagery;
- a composition whose balance breaks when flipped.

Keep asset names semantic. Avoid embedding `left` or `right` in a reading-flow
asset name unless those words are truly physical.

## Classify images and artwork

Keep these fixed by default:

- photographs and user-generated images;
- posters, covers, game artwork, and editorial illustrations;
- logos, trademarks, flags, badges, and certification marks;
- screenshots that must depict an actual fixed state;
- maps and physical diagrams whose coordinate meaning must stay stable.

Mirror simple arrows, chevrons, folds, and reading-flow cues only when their
meaning changes with interface direction.

Provide a localized composition when an image contains words or when culture,
region, script, or storefront storytelling changes the intended result.
Whenever possible, render translatable text as text instead of baking it into a
bitmap.

Inspect images inside composite controls separately from the control order. A
row can mirror while its thumbnail remains fixed and its disclosure symbol
changes direction.

## Use semantic symbols

Use SF Symbols that encode reading-flow semantics:

- choose `forward` and `backward` for semantic progression;
- choose `left` and `right` for physical direction;
- let script-specific localized variants resolve through the system;
- preview every symbol in supported languages and layout directions.

Do not mirror a symbol manually until checking its own direction and
localization behavior. A second transform can cancel system mirroring or
reverse a localized variant.

Use a custom symbol or separate RTL rendition when a correct localized glyph is
not a simple horizontal reflection. Preserve the symbol's baseline, rendering
mode, variable value, and accessibility meaning.

## Review custom shapes and effects

Classify a custom `Shape`, path, mask, gradient, and transition independently.
On current SwiftUI deployments, a shape's default
`layoutDirectionBehavior` can differ from older targets. Inspect availability
and avoid layering manual reflection over automatic mirroring.

Check:

- path control points and winding;
- clipping and masks;
- gradient start and end points;
- shadows and light source;
- border asymmetry and corner selection;
- animation origin and transition edge;
- hit-test and accessibility frames.

Never mirror a container merely to mirror one path. Keep text and content
outside the transformed subtree.

## Verify Arabic typography

Render real Arabic strings with the production font and Dynamic Type. Check:

- contextual joining and ligatures;
- diacritics above and below the nominal glyph bounds;
- line height, baseline, clipping, and truncation;
- font fallback across Arabic, Latin, digits, and symbols;
- weight and optical size;
- emphasis that does not assume Latin italics;
- opacity or animation applied to a whole run instead of isolated letters;
- punctuation, kashida, wrapping, and justification;
- Western and Eastern Arabic numeral preferences.

Do not apply Latin tracking assumptions to joined Arabic script. Use zero tracking
when the chosen font cannot preserve joining with letter spacing, but do not turn
that into a universal rule for every font and script. Verify the actual rendered
result.

Do not impose a fixed point-size or percentage adjustment as a universal Arabic
formula. Compare optical balance using the production typeface, text style, and
Dynamic Type sizes.

## Verify Hebrew, Persian, and Urdu independently

Do not use an Arabic pass as evidence for every RTL language.

For Hebrew, test niqqud, quotation marks, mixed Hebrew and Latin, numbers,
punctuation, line breaking, and the selected typeface.

For Persian, test Persian-specific letters, preferred digits, punctuation,
joining, locale formatting, and vocabulary distinct from Arabic.

For Urdu, test the product's chosen script and font, joining, vertical metrics,
line spacing, and complex word shapes. A font that covers Arabic code points
does not necessarily produce acceptable Urdu typography.

Record the exact language, region, font, OS, and content reviewed. Require
native-speaker feedback for linguistic and cultural decisions, including icon
and imagery meaning.
