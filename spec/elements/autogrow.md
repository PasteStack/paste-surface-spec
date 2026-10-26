# Autogrow Element

A declared textarea grows when its content overflows. Deleting content leaves
its current height in place.

## Module

```
paste-elements/modules/autogrow/
├── autogrow.js
├── autogrow.scss       (stylesheet module paste.ui.autogrow)
└── _mixin.scss         (mixin paste-ui-autogrow)
```

## JavaScript

**Module:** `paste.ui.autogrow`

**Dependencies:**
- `paste.dom`
- `paste.event`

There are no methods. The module binds once, when it is defined.

### Activation

`textarea[data-paste-autogrow]` or the original `.autogrow` class. The
attribute value is not read. Class-only fields remain supported.

```html
<textarea data-paste-autogrow placeholder="Type here..."></textarea>
```

No `data-paste-autogrow-min` or `data-paste-autogrow-max` attribute exists:
minimum and maximum heights are CSS.

### Behaviour

Shared `input` and legacy `keyup` handlers size visible fields at bind and on input (typing,
paste, cut, delete and undo). It only increases height. A field whose content
fits does no computed-style read or style write. Box sizing, padding and
borders are accounted for; resolved pixel max-height is honored.

CSS owns min/max height, manual resizing and transitions. Existing inline
height priority is preserved. There is no collapse, shrink, remembered floor,
transition suppression, scroll restoration or animation-frame queue. Hidden
fields wait for a visible input event. Programmatic value changes need an
input event when they should trigger growth.

## Mixin parameters

`@include paste-ui-autogrow(...)` applies to the caller's textarea selector
and sets `overflow-y: auto`. Definition imports alone emit nothing.
`autogrow.scss` selects `.autogrow, [data-paste-autogrow]` with the defaults.
Place custom includes inside the intended textarea selector.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `$min-height` | `80px` | `min-height` of the field |
| `$max-height` | `400px` | `max-height` of the field; content beyond it scrolls |
| `$transition` | `null` | Emits a `transition` only when passed |

The mixin sets no `resize`; add `resize: none` in page CSS to hide the handle.

## Example

```html
<label for="message">Message</label>
<textarea id="message" name="message" data-paste-autogrow
          placeholder="Enter your message..."></textarea>
```

## Surface FormField

In `paste-surface-scala`, use the `Textarea` formfield. `dataAttributes`
keys are emitted with a `data-` prefix:

```scala
@import com.pastestack.surface.view_models.components.formfield.Textarea

@paste.surface.components.formfield.html.textarea(Textarea(
  name = "message",
  id = Some("message"),
  label = Some("Message"),
  placeholder = Some("Enter your message..."),
  dataAttributes = Map("paste-autogrow" -> "true")
))
```

The `id` associates the label with the field (see
[form](../components/formfield/form.md)).
