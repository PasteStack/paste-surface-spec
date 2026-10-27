# Forms and Form Fields

Form and form field components. Field view models carry their own validation
messages, so a presenter that re-renders a view model after a failed submit
shows the errors in place. The `paste.ui.form.form_html` Element optionally submits a
[Form](#form) in the background and swaps the returned IO reply fragment into
its target; see [Rendering a View Model](../../rendering/rendering.md). No
JavaScript is needed for field presentation; the optional Elements
`modules/form/form` and `modules/button/button` stylesheets supply the default skins.

## Form

A `<form>` element with a content slot for its fields.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `action` | string | yes | - | Submit URL |
| `method` | string | no | `"post"` | `get` or `post` |
| `enctype` | string | no | `"application/x-www-form-urlencoded"` | `application/x-www-form-urlencoded` or `multipart/form-data` |
| `id` | string | no | `None` | Element id |
| `submission` | enum | no | `Native` | `Native`, `Apply` or `Html`; emit the corresponding enhancement class |
| `errors` | Seq[string] | no | empty | Form-level messages, rendered above the fields |
| `cssClass` | string | no | `""` | Additional CSS classes on the `<form>` |
| `dataAttributes` | Map | no | `{}` | Custom `data-*` attributes |

Construction rejects a blank `action`, a `method` or `enctype` outside the
listed values (an implementation with enumerations makes those
unrepresentable), and a `dataAttributes` name that does not match
`[a-z0-9][a-z0-9._-]*` (`IllegalArgumentException`, including through `copy`).

`Form.id` uses the same optional HTML-id validation as Input and Textarea.
It is not a selector-safe identifier requirement: a leading `#` is a valid
HTML id character here. Callers still own uniqueness.

### HTML Output

```html
<form class="paste-ui-form {submissionClass} {cssClass}"
      id="{id}"
      action="{action}"
      method="{method}"
      enctype="{enctype}"
      accept-charset="utf-8"
      {dataAttributes.map(([k,v]) => `data-${k}="${v}"`)}>
  <ul class="paste-ui-form-errors" role="alert">
    <li>{error}</li>
  </ul>
  <!-- content slot -->
</form>
```

`id` appears only when supplied; the error list appears only when `errors` is
nonempty. `submissionClass` is absent for `Native`, `paste-ui-apply` for `Apply`,
and `paste-ui-formhtml` for `Html`. `Apply` requires POST. IDs serve authored
references and labels; they do not activate an enhancement or limit form count.

### Validation: `paste.ui.form.form_validity`

This restores the original validity-reflection module, separate from submission. When loaded,
it initializes ordinary forms and reflects native validity through
`data-validity-valid="true|false"` on forms and controls. Initial form validity
is reflected; native `invalid` marks the control and form false. A valid
control on change, focusout or keyup is marked true and the form is rechecked.
An invalid edit does not revalidate untouched siblings. Submit rechecks unless
native `novalidate`/`formnovalidate` applies; `data-not-allowed="true"` always
blocks. Native interactive validation remains enabled. It creates an id only
for a form without one, using Paste GUID, and supports idempotent `init(root)`
for newly inserted forms. It performs no IO or HTML loading.

### Apply: `paste.ui.form.form_apply`

`FormSubmission.Apply` emits `paste-ui-apply`. Load `paste.ui.form.form_apply` to submit
that form using the original success/error response contract. See
[Apply](../../elements/apply.md). Each form owns its fields, messages and request.
`FormSubmission.Html` selects the separate HTML response path below. Load the
module corresponding to the chosen submission; do not put both enhancement
classes on one form.

### HTML submission: `paste.ui.form.form_html`

The Element enhances every `form.paste-ui-formhtml` (and legacy `form[data-paste-form]`) that sits inside an
[IO reply fragment target](../../rendering/rendering.md#io-reply-fragment-targets).
Paste loads at the end of the document, after the markup it enhances, so every
form present when the module runs is enhanced immediately. Forms placed by
this module's own reply are enhanced as they are placed. Each form is enhanced
once. The Element exposes no public API.

It depends on `paste.ui.form.form_validity` for validation reflection and blocking. The
historical `data-paste-form-timeout` and `data-paste-form-idempotent` inputs
remain accepted; changing the module does not change server replay guarantees.

On submit it:

1. Reads the submission the way the browser does: the submitting button's
   `formaction`, `formmethod`, `formenctype` and `formtarget` override the
   form's `action`, `method`, `enctype` and `target`; with an empty or missing effective target,
   the document's `<base target>` applies. A nonempty action resolves
   against the document's base URL; an empty one is the document's URL.
2. Leaves the event alone when it was already default-prevented, when the form
   has no enclosing `[data-paste-io-reply-fragment-target]`, when the browser
   does not report the submitting button (`SubmitEvent.submitter`), when the
   submitting button is an image control, when the form has rel="noreferrer", when the method is neither `get` nor
   `post`, when a `post` is encoded as `text/plain`, when the target names a
   browsing context other than `_self`, when the resolved action is not on the
   page's origin, when the browser's `FormData` does not take the submitting
   button (`new FormData(form, submitter)`), when the form's submit would not
   go out as UTF-8 (the first `accept-charset` label the browser recognises,
   read both space-separated and comma-separated, else the document's
   encoding, with UTF-16 sent as UTF-8), or when
   `WeakMap`, `XMLHttpRequest`, `XMLHttpRequest.responseURL`, `FormData`,
   `URLSearchParams` or `URL` is unavailable, or `TextDecoder` is unavailable
   where an `accept-charset` is declared. The browser then submits
   normally. Only same-origin markup is ever placed in the page.
3. Reserves the target before constructing `FormData`, whose synchronous
   `formdata` event may reenter submission. Further submits into the same target,
   an ancestor target or a descendant target are ignored while it is owned.
   Preparation or transmission refusal releases the reservation.
4. Prevents the navigation and sends the request through `paste.io`, which adds
   `X-Requested-With: XMLHttpRequest`. The request matches what the browser would
   have sent: the resolved action and method, the form's fields and the
   submitting button's `name`/`value` in document order, encoded as the
   resolved enctype
   (URL-encoded body, multipart body, or for `get` a query string that replaces
   any query already in the `action`).

   Field names, string values and file names use CRLF-normalized line breaks
   for GET and urlencoded POST; multipart encoding remains native FormData.
   While a transmitted request is pending, its reply target carries
   `aria-busy="true"` and the `paste-ui-formhtml-busy` class. The class clears and the prior aria value is restored when the
   owning request settles, before failure notification or replay. The class is
   on the target, not the form; unrelated classes remain. Preparation alone,
   native/invalid submissions and blocked duplicate submissions introduce no
   additional busy state or reason class. The request carries a
   deadline — `data-paste-form-timeout` in decimal milliseconds on the form,
   default 30,000: positive integers through 4294967295 are honored, the
   literal `0` opts out, and malformed, fractional, blank or overflowing
   input falls back to the default rather than disabling the deadline
   silently — so a stalled request cannot hold the busy state forever.
5. On an HTML or matching named JSON-fragment response of any status whose final URL, after any redirect, is
   on the page's origin, replaces the target's content with the response body,
   initializes forms inside it, and moves focus to the first `[role="alert"]`
   or `[role="status"]` in the new content when one exists.
6. On any failure after transmission — a network error, timeout, or abort,
   or a completed response the form cannot place (an unsupported/malformed reply, or a
   reply whose final URL left the page's origin) — clears the busy state, then
   fires `paste.ui.formhtml:failed`, a bubbling, cancelable event whose
   `detail.reason` is `"error"`, `"timeout"`, `"abort"`, or `"response"`. Then
   exactly one of:
   - a listener called `preventDefault()` → the listener owns the failure UX;
     nothing else happens;
   - the method is `get`, or the form carries `data-paste-form-idempotent` →
     the form resubmits natively, reproducing the browser's own submission;
   - otherwise → a `role="alert"` notice (`paste-ui-formhtml-failure`) is appended
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

An `error` or `abort` during a visitor-initiated departure never replays over
that navigation; the failure event and default notice still apply, including
a download or 204 that leaves the page present. If the visitor stays through
a `beforeunload` prompt, the departure guard expires half a second after tasks
resume unless `pagehide` confirmed departure. A native XHR deadline remains
a `timeout` and keeps the usual replay policy.

The shared `paste.ui.utilities.io-html-fragment` utility owns transport completion
and placement. It configures XHR timeout before send, and also accepts a named
JSON fragment for the enclosing target, including at validation/error statuses.
Set `IoReplyFragmentTarget.format = Json` to request that representation.
A committed replacement supersedes overlapping pending loads; a stale or
superseded form does not publish a failure or resubmit. The shared busy class is
`paste-ui-io-html-fragment-busy`, alongside the form's reason-specific class.
See the [shared operation](../../rendering/rendering.md#shared-html-fragment-operation).

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
| `id` | string | no | `null` | Caller-owned HTML id; required for help or errors; reserves `<id>-feedback` |
| `label` | string | no | `null` | Label text; carries `*` when required; uses `for`/`id` or wraps the control when no id is supplied |
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
<div class="paste-ui-formfield paste-ui-formfield-input has-error">
  <label for="contact-email">Email</label>
  <input id="contact-email" name="email" type="email" value=""
         aria-describedby="contact-email-feedback" aria-invalid="true">
  <div id="contact-email-feedback">
    <p class="paste-ui-formfield-description">Use your contact address.</p>
    <p class="paste-ui-formfield-error">Please check this address.</p>
  </div>
</div>
```

The example above shows a field with a caller-owned id and feedback. A label-only
field with no id instead renders an ordinary wrapping label:

```html
<div class="paste-ui-formfield paste-ui-formfield-input">
  <label>Email<input type="text" name="email" value=""></label>
</div>
```

The optional `required`, `disabled`, `placeholder`, `maxlength`, `pattern`,
`autocomplete` and data attributes retain their property-table meanings;
Textarea emits its supported subset. Labels retain the required-marker span.

The control renders exactly once. With an `id`, its label uses `for="{id}"`.
Without an `id`, a supplied label wraps the control; it must not be an orphan
sibling. A missing label remains missing; renderers do not invent its text.

Descriptions or server errors require a caller-owned id. Reserve that id and
`<id>-feedback` uniquely in the page. The feedback paragraphs share a wrapper
with `id="<id>-feedback"`, the control carries `aria-describedby` pointing to
it, and server errors add `aria-invalid="true"`. With no help/errors, omit the
wrapper and those attributes. Native constraint validation remains independent.
An optional id must be nonempty and have no whitespace; null options/values
are invalid. These invariants apply at construction and through `copy`.
Existing help/error calls without an id must supply one.

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
| `id` | string | no | `null` | Caller-owned HTML id; required for help or errors; reserves `<id>-feedback` |
| `label` | string | no | `null` | Label text; carries `*` when required; uses `for`/`id` or wraps the control when no id is supplied |
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
<div class="paste-ui-formfield paste-ui-formfield-textarea">
  <label for="contact-message">Message</label>
  <textarea id="contact-message" name="message" rows="4"
            aria-describedby="contact-message-feedback">
</textarea>
  <div id="contact-message-feedback">
    <p class="paste-ui-formfield-description">Describe your request.</p>
  </div>
</div>
```

Labels, feedback identity and validation follow the same rules as `Input`, including a wrapping label when no id is supplied.

Preserve the supplied value, including leading blank lines, as escaped text.
HTML consumes one line feed immediately after a textarea start tag, so emit
that line feed before the value without indenting or trimming the value.
The browser's ordinary CR/CRLF-to-LF normalization still applies. The same
value must survive initial parsing, fragment insertion and native form reset.

---

## Select

A native select with an ordinary option/optgroup content slot. See
[native select appearance](../../elements/select.md) for markup and optional
Elements enhancement.

| Property | Type | Required | Default |
| --- | --- | --- | --- |
| `name` | string | yes | — |
| `id`, `label`, `description`, `autocomplete` | optional string | no | absent |
| `required`, `disabled`, `multiple` | boolean | no | false |
| `size` | optional positive integer | no | absent |
| `errors` | sequence of strings | no | empty |
| `dataAttributes` | map of strings | no | empty |

The content slot owns values and `selected` defaults. IDs follow Input's
HTML-id rules; descriptions/errors require one. Attribute names use the same
validated data-attribute contract. With no id the label wraps the control.
For custom appearance, opt in with `dataAttributes = Map("paste-select" -> "")`
and load `paste.ui.select` plus its stylesheet. Surface emits the decorative
`aria-hidden` sibling but never the runtime ready marker or event handlers.

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
| Select | `paste.surface.components.formfield.html.select` |
| Hidden | `paste.surface.components.formfield.html.hidden` |
| Form | `paste.surface.components.formfield.html.form` |
| IoReplyFragmentTarget | `paste.surface.components.html.ioReplyFragmentTarget` |

## Form family module names

Use `paste.ui.form.form_validity` for native validity reflection,
`paste.ui.form.form_apply` for JSON submissions, and `paste.ui.form.form_html`
for HTML reply replacement. Apply and HTML include validity as a dependency.
Choose one submission owner per form. `FormSubmission` and its emitted HTML
remain unchanged: `Native`, `Apply`, and `Html` describe behavior, not file paths.

Load the canonical modules directly. The former top-level form, apply,
formhtml and autosave JavaScript entries have been removed; no compatibility
includes remain. Autosave is `paste.ui.form.form_autosave`, at
`modules/form/form_autosave/form_autosave.js`, with its own trigger and request
lifetime. Its request deadline defaults to 30 seconds, overridden per form by
`data-autosave-timeout`. Forms still require explicit
autosave declarations; loading the module does not opt ordinary forms in.

Existing classes, data attributes and `paste.ui.formhtml:failed` keep their
spelling. The general form stylesheet and field mixins remain in `modules/form`.
Import Apply styles from `modules/form/form_apply/form_apply.scss` or its silent
`_mixin.scss`; the former `modules/apply` forwarding styles have been removed.
