# Autogrow Element

A declared textarea grows with its content and shrinks back to its floor as
content is deleted.

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
- `paste.ui.utilities.animation-frame`

There are no methods. The module binds once, when it is defined.

### Activation

`textarea[data-paste-autogrow]`. The attribute is the whole declaration; its
value is not read. The `.autogrow` class alone activates nothing.

```html
<textarea data-paste-autogrow placeholder="Type here..."></textarea>
```

No `data-paste-autogrow-min` or `data-paste-autogrow-max` attribute exists:
minimum and maximum heights are CSS.

### Behaviour

- Sizing follows the `input` event — typing, delete, cut, paste, undo —
  coalesced into one animation-frame pass for every changed field.
- The floor is the field's rendered height when the module first sees it
  rendered: at bind, or at the first pass after a field hidden at bind is
  shown. A field that is not rendered is skipped.
- The browser's resize handle keeps working with or without JavaScript; a
  height the user drags to becomes the new floor.
- A height transition never runs on the module's own sizing writes, and a
  collapse that clamps the page's or the nearest scrolled ancestor's offset
  puts it back.

## Mixin parameters

`@include paste-ui-autogrow(...)`; `autogrow.scss` includes it with the
defaults. The rule targets `[data-paste-autogrow]` and also sets
`overflow-y: auto`.

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
