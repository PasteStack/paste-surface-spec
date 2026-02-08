# Autogrow Element

Auto-resizing textarea that grows with content.

## Module

```
paste-elements/modules/autogrow/
├── autogrow.js
└── autogrow.scss
```

## JavaScript API

**Module:** `paste.ui.autogrow`

**Dependencies:**
- `paste.dom`
- `paste.event`

### Activation

Textareas with `data-paste-autogrow` attribute are automatically initialized.

```html
<textarea data-paste-autogrow placeholder="Type here..."></textarea>
```

### Data Attributes

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-paste-autogrow` | - | Enable autogrow (required) |
| `data-paste-autogrow-min` | number | Minimum height in pixels |
| `data-paste-autogrow-max` | number | Maximum height in pixels |

### Methods

```javascript
paste.ui.autogrow.init();           // Re-initialize
paste.ui.autogrow.resize(element);  // Force resize specific textarea
```

## SCSS Variables

```scss
$paste-autogrow-min-height: 80px !default;
$paste-autogrow-max-height: 400px !default;
$paste-autogrow-transition: height 0.1s ease !default;
```

## Example

```html
<label for="message">Message</label>
<textarea 
  id="message"
  data-paste-autogrow
  data-paste-autogrow-min="100"
  data-paste-autogrow-max="300"
  placeholder="Enter your message...">
</textarea>
```

## Surface FormField

In `paste-surface-scala`, use the `Textarea` formfield:

```scala
@import com.pastestack.surface.view_models.components.formfield.Textarea

@paste.surface.components.formfield.html.textarea(Textarea(
  name = "message",
  label = Some("Message"),
  placeholder = Some("Enter your message..."),
  dataAttributes = Map("paste-autogrow" -> "true")
))
```
