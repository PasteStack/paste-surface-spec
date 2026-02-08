# Form Fields

Paste form field components with bundled SCSS/JS from paste-elements.

## FormField (Base Trait)

Base contract for all form fields.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | yes | Field name |

---

## Input

Text input field.

### Properties

Inherits from `FormField`, plus:

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `type` | string | no | `"text"` | Input type (text, email, password, etc.) |
| `value` | string | no | `""` | Current value |
| `placeholder` | string | no | `null` | Placeholder text |
| `maxLength` | int | no | `null` | Maximum length |
| `pattern` | string | no | `null` | Validation pattern |
| `autocomplete` | string | no | `null` | Autocomplete hint |

### Example (Scala)

```scala
case class Input(
  name: String,
  inputType: String = "text",
  id: Option[String] = None,
  label: Option[String] = None,
  description: Option[String] = None,
  value: String = "",
  placeholder: Option[String] = None,
  required: Boolean = false,
  disabled: Boolean = false,
  maxLength: Option[Int] = None,
  pattern: Option[String] = None,
  autocomplete: Option[String] = None,
  errors: Seq[String] = Seq.empty,
  dataAttributes: Map[String, String] = Map.empty
) extends FormField
```

### HTML Output

```html
<div class="paste-ui-form-field paste-ui-form-field-input {hasErrors ? 'has-error' : ''}">
  {label && <label for="{id}">{label}{required && <span class="required">*</span>}</label>}
  
  <input 
    type="{type}"
    id="{id}"
    name="{name}"
    value="{value}"
    placeholder="{placeholder}"
    {required && 'required'}
    {disabled && 'disabled'}
    maxlength="{maxLength}"
    pattern="{pattern}"
    autocomplete="{autocomplete}"
    {dataAttributes.map(([k,v]) => `data-${k}="${v}"`)}
  >
  
  {description && <p class="paste-ui-form-description">{description}</p>}
  {errors.map(e => <p class="paste-ui-form-error">{e}</p>)}
</div>
```

---

## Button

Button element.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | - | Button name |
| `type` | string | no | `"submit"` | Button type (submit, button, reset) |
| `label` | string | yes | - | Button text |
| `disabled` | boolean | no | `false` | Disabled state |
| `dataAttributes` | Map | no | `{}` | Custom data-* attributes |

### HTML Output

```html
<button 
  type="{type}"
  name="{name}"
  class="paste-ui-button"
  {disabled && 'disabled'}
  {dataAttributes.map(([k,v]) => `data-${k}="${v}"`)}
>
  {label}
</button>
```

---

## Textarea

Multiline text input.

### Properties

Inherits from `FormField`, plus:

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `value` | string | no | `""` | Current value |
| `placeholder` | string | no | `null` | Placeholder text |
| `rows` | int | no | `4` | Number of visible rows |
| `maxLength` | int | no | `null` | Maximum length |

### HTML Output

```html
<div class="paste-ui-form-field paste-ui-form-field-textarea">
  {label && <label for="{id}">{label}</label>}
  
  <textarea
    id="{id}"
    name="{name}"
    rows="{rows}"
    placeholder="{placeholder}"
    maxlength="{maxLength}"
    {required && 'required'}
    {disabled && 'disabled'}
  >{value}</textarea>
  
  {description && <p class="paste-ui-form-description">{description}</p>}
</div>
```

---

## Hidden

Hidden fields for passing data through forms.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | yes | Field group name |
| `fields` | Map[string, string] | yes | Name-value pairs for hidden fields |

### Example (Scala)

```scala
case class Hidden(
  name: String,
  fields: Map[String, String]
) extends FormField
```

### HTML Output

```html
{fields.map(([name, value]) => 
  <input type="hidden" name="{name}" value="{value}">
)}
```

---

## Template Paths

Templates are located at:

| Template | Twirl | Jinja/Nunjucks |
|----------|-------|----------------|
| Input | `paste.surface.formfield.html.input` | `paste/surface/formfield/input.html` |
| Button | `paste.surface.formfield.html.button` | `paste/surface/formfield/button.html` |
| Textarea | `paste.surface.formfield.html.textarea` | `paste/surface/formfield/textarea.html` |
| Hidden | `paste.surface.formfield.html.hidden` | `paste/surface/formfield/hidden.html` |
