# Controls, actions, and input

## Prefer system semantics

Start with the system control that matches the user's action: button, toggle,
segmented control, text field, text view, search controller, menu, date picker,
color picker, document or photo picker, page control, slider, stepper, or context
menu. Preserve its focus, keyboard, pointer, accessibility, state restoration,
and platform styling before considering a custom control.

Do not substitute a generic gesture recognizer for a control when activation,
focus, disabled state, keyboard access, or assistive technology semantics matter.
If a custom control is necessary, subclass `UIControl` when its value and events
fit that contract; send the appropriate events and expose a complete accessible
interaction.

## Use configuration as state

Use `UIButton.Configuration` for supported button content and styling. Derive
state-dependent appearance through a configuration update handler rather than
mutating several parallel title, image, background, and inset APIs. Preserve a
minimum usable hit target without hard-coding visual content to that size.

Use `UIListContentConfiguration`, `UIBackgroundConfiguration`, and custom
`UIContentConfiguration` where their state model reduces manual reuse logic.
Treat configuration values as descriptions of current content, not mutable
owners of domain state.

Use `UIContentUnavailableConfiguration` for loading, empty, search-empty, or
unavailable states when supported and appropriate. Keep error recovery and
primary actions explicit. Provide an equivalent fallback on earlier targets.

## Model commands and menus

Represent a user intent once. Use `UIAction`, `UIMenu`, `UIDeferredMenuElement`,
the responder chain, and keyboard commands according to lifetime and discoverability.
Keep action identifiers stable where state restoration or replacement depends
on them. Derive enabled, selected, mixed, destructive, and discoverability state
from current model permissions and selection.

Avoid duplicating an action across a closure, target, gesture, and delegate.
For destructive actions, use clear labels and confirmation only when consequence
and reversibility justify it. Preserve cancel and escape behavior.

## Handle text, focus, and selection

Choose `UITextField` for single-line input and `UITextView` for multiline or
rich text. Configure content type, keyboard type, capitalization, return key,
secure entry, and validation from the data contract. Never treat keyboard hints
as validation or security boundaries.

Keep validation errors associated with the field, readable by assistive
technology, and recoverable without losing input or focus. Avoid formatting
that fights marked text, dictation, paste, selection, or bidirectional input.

Use focus environments, preferred focus, key commands, and pointer or hover
interactions only where the supported device and platform require them. Test
hardware keyboard navigation and Full Keyboard Access for productivity surfaces.

## Choose pickers by data access

Use the current system picker or authorization flow for the specific data type.
For example, choose the Photos picker for selecting photo-library assets without
broad library access when its contract fits; do not describe it as a universal
replacement for camera capture or every `UIImagePickerController` use.

Keep picker delegates and asynchronous transfer work bounded to the presentation
owner. Handle cancellation, partial transfer, unavailable representation, and
large or cloud-backed assets without blocking the main actor.
