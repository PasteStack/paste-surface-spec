# Forms and Form Fields

Form and form field components. Field view models carry their own validation
messages, so a presenter that re-renders a view model after a failed submit
shows the errors in place. The `paste.ui.form` Element optionally submits a
[Form](#form) in the background and swaps the returned IO reply fragment into
its target; see [Rendering a View Model](../../rendering/rendering.md). No
Element styles the fields.

## Form

A `<form>` element with a content slot for its fields.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `action` | string | yes | - | Submit URL |
| `method` | string | no | `"post"` | `get` or `post` |
| `enctype` | string | no | `"application/x-www-form-urlencoded"` | `application/x-www-form-urlencoded` or `multipart/form-data` |
| `id` | string | no | `None` | Element id |
| `backgroundSubmit` | boolean | no | `false` | Emit `data-paste-form` so `paste.ui.form` submits in the background |
| `errors` | Seq[string] | no | empty | Form-level messages, rendered above the fields |
| `cssClass` | string | no | `""` | Additional CSS classes on the `<form>` |
| `dataAttributes` | Map | no | `{}` | Custom `data-*` attributes |

Construction rejects a blank `action`, a `method` or `enctype` outside the
listed values (an implementation with enumerations makes those
unrepresentable), and a `dataAttributes` name that does not match
`[a-z0-9][a-z0-9._-]*` (`IllegalArgumentException`, including through `copy`).

### HTML Output

```html
<form class="paste-ui-form {cssClass}"
      id="{id}"
      action="{action}"
      method="{method}"
      enctype="{enctype}"
      accept-charset="utf-8"
      data-paste-form
      {dataAttributes.map(([k,v]) => `data-${k}="${v}"`)}>
  <ul class="paste-ui-form-errors" role="alert">
    <li>{error}</li>
  </ul>
  <!-- content slot -->
</form>
```

`id` appears only when supplied, `data-paste-form` only when `backgroundSubmit`
is true, and the error list only when `errors` is nonempty.

### Element Contract: `paste.ui.form`

The Element enhances every `form[data-paste-form]` that sits inside an
[IO reply fragment target](../../rendering/rendering.md#io-reply-fragment-targets).
Paste loads at the end of the document, after the markup it enhances, so every
form present when the module runs is enhanced immediately, and forms placed by
an IO reply fragment are enhanced as they are placed. Each form is enhanced
once. The Element exposes no public API.

On submit it:

1. Reads the submission the way the browser does: the submitting button's
   `formaction`, `formmethod`, `formenctype` and `formtarget` override the
   form's `action`, `method`, `enctype` and `target`; without either target,
   the document's `<base target>` applies. A nonempty action resolves
   against the document's base URL; an empty one is the document's URL.
2. Leaves the event alone when it was already default-prevented, when the form
   has no enclosing `[data-paste-io-reply-fragment-target]`, when the browser
   does not report the submitting button (`SubmitEvent.submitter`), when the
   submitting button is an image control, when the method is neither `get` nor
   `post`, when a `post` is encoded as `text/plain`, when the target names a
   browsing context other than `_self`, when the resolved action is not on the
   page's origin, when the browser's `FormData` does not take the submitting
   button (`new FormData(form, submitter)`), or when `WeakMap`,
   `XMLHttpRequest`, `XMLHttpRequest.responseURL`, `FormData`,
   `URLSearchParams` or `URL` is unavailable. The browser then submits
   normally. Only same-origin markup is ever placed in the page.
3. Prevents the navigation and sends the request through `paste.io`, which adds
   `X-Requested-With: XMLHttpRequest`. The request matches what the browser would
   have sent: the resolved action and method, the form's fields and the
   submitting button's `name`/`value` in document order, encoded as the
   resolved enctype
   (URL-encoded body, multipart body, or for `get` a query string that replaces
   any query already in the `action`).
4. Ignores further submits of the same form while the request is in flight, and
   marks the target `aria-busy="true"` for its duration. The request carries a
   deadline — `data-paste-form-timeout` in decimal milliseconds on the form,
   default 30,000: positive integers through 4294967295 are honored, the
   literal `0` opts out, and malformed, fractional, blank or overflowing
   input falls back to the default rather than disabling the deadline
   silently — so a stalled request cannot hold the busy state forever.
5. On an HTML response of any status whose final URL, after any redirect, is
   on the page's origin, replaces the target's content with the response body,
   initializes forms inside it, and moves focus to the first `[role="alert"]`
   or `[role="status"]` in the new content when one exists.
6. On any failure after transmission — a network error, timeout, or abort,
   or a completed response the form cannot place (a non-HTML reply, or an HTML
   reply whose final URL left the page's origin) — clears the busy state, then
   fires `paste.ui.form:failed`, a bubbling, cancelable event whose
   `detail.reason` is `"error"`, `"timeout"`, `"abort"`, or `"response"`. Then
   exactly one of:
   - a listener called `preventDefault()` → the listener owns the failure UX;
     nothing else happens;
   - the method is `get`, or the form carries `data-paste-form-idempotent` →
     the form resubmits natively, reproducing the browser's own submission;
   - otherwise → a `role="alert"` notice (`paste-ui-form-failure`) is appended
     inside the form, focused, and says the submission may have been received —
     an honest outcome for a POST whose delivery is uncertain.
7. Only when the request could not be transmitted at all — `paste.io` returned
   no request — does the module submit natively unconditionally; nothing was
   sent, so nothing can be duplicated.

A resubmission after transmission can repeat a request the server already
processed, which is why it is gated rather than automatic. `data-paste-form-idempotent`
is the site's declaration that the endpoint collapses replays itself — an
idempotency key, a natural dedup, or a safe operation; the attribute alone does
not make a replay safe. The default failure notice is honest about the
uncertainty and preserves all entered values and server-rendered messages; a
listener that prevents the event takes responsibility for the visible outcome.
A module-created notice replaces only itself and is cleared when the next
submission is accepted for transmission.

---

## FormField (Base Trait)

Base contract for all form fields.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | yes | Field name |

`dataAttributes` on Input, Button, and Textarea accept only names matching
`[a-z0-9][a-z0-9._-]*`; other names fail construction
(`IllegalArgumentException`, including through `copy`).

---

## Input

Text input field.

### Properties

Inherits from `FormField`, plus:

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `type` | string | no | `"text"` | Input type (text, email, password, etc.) |
| `id` | string | no | `null` | Element id; `label` links to it |
| `label` | string | no | `null` | Label text; carries `*` when required |
| `description` | string | no | `null` | Help text below the input |
| `value` | string | no | `""` | Current value |
| `placeholder` | string | no | `null` | Placeholder text |
| `required` | boolean | no | `false` | Required attribute and label marker |
| `disabled` | boolean | no | `false` | Disabled attribute |
| `maxLength` | int | no | `null` | Maximum length |
| `pattern` | string | no | `null` | Validation pattern |
| `autocomplete` | string | no | `null` | Autocomplete hint |
| `errors` | Seq[string] | no | empty | Validation messages below the input |
| `dataAttributes` | Map | no | `{}` | Custom `data-*` attributes |

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
<div class="paste-ui-formfield paste-ui-formfield-input {errors.nonEmpty ? 'has-error' : ''}">
  {label && <label {id && for="{id}"}>{label}{required && <span class="required">*</span>}</label>}

  <input
    type="{type}"
    {id && id="{id}"}
    name="{name}"
    value="{value}"
    {placeholder && placeholder="{placeholder}"}
    {required && 'required'}
    {disabled && 'disabled'}
    {maxLength && maxlength="{maxLength}"}
    {pattern && pattern="{pattern}"}
    {autocomplete && autocomplete="{autocomplete}"}
    {dataAttributes.map(([k,v]) => `data-${k}="${v}"`)}
  >

  {description && <p class="paste-ui-formfield-description">{description}</p>}
  {errors.map(e => <p class="paste-ui-formfield-error">{e}</p>)}
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
| `id` | string | no | `null` | Element id; `label` links to it |
| `label` | string | no | `null` | Label text; carries `*` when required |
| `description` | string | no | `null` | Help text below the textarea |
| `value` | string | no | `""` | Current value |
| `placeholder` | string | no | `null` | Placeholder text |
| `rows` | int | no | `4` | Number of visible rows |
| `required` | boolean | no | `false` | Required attribute and label marker |
| `disabled` | boolean | no | `false` | Disabled attribute |
| `maxLength` | int | no | `null` | Maximum length |
| `errors` | Seq[string] | no | empty | Validation messages below the textarea |
| `dataAttributes` | Map | no | `{}` | Custom `data-*` attributes |

### HTML Output

```html
<div class="paste-ui-formfield paste-ui-formfield-textarea {errors.nonEmpty ? 'has-error' : ''}">
  {label && <label {id && for="{id}"}>{label}{required && <span class="required">*</span>}</label>}

  <textarea
    {id && id="{id}"}
    name="{name}"
    rows="{rows}"
    {placeholder && placeholder="{placeholder}"}
    {maxLength && maxlength="{maxLength}"}
    {required && 'required'}
    {disabled && 'disabled'}
    {dataAttributes.map(([k,v]) => `data-${k}="${v}"`)}
  >{value}</textarea>

  {description && <p class="paste-ui-formfield-description">{description}</p>}
  {errors.map(e => <p class="paste-ui-formfield-error">{e}</p>)}
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

| Template | Twirl |
|----------|-------|
| Input | `paste.surface.components.formfield.html.input` |
| Button | `paste.surface.components.formfield.html.button` |
| Textarea | `paste.surface.components.formfield.html.textarea` |
| Hidden | `paste.surface.components.formfield.html.hidden` |
| Form | `paste.surface.components.formfield.html.form` |
| IoReplyFragmentTarget | `paste.surface.components.html.ioReplyFragmentTarget` |
