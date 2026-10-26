# Apply

`paste.ui.form.form_apply` restores the original JSON submission flow: submit a form, display the returned
message, clear successful text entry and mark the field a server error names.
Activation is `form.paste-ui-apply`, with independent state for every form.
Surface selects it with `FormSubmission.Apply`; IDs remain caller-owned
references rather than an activation mechanism.

It depends on `paste.ui.form.form_validity` for native validity reflection. It also respects
earlier event cancellation, `data-not-allowed`, `novalidate` and
`formnovalidate`. A missing SubmitEvent submitter API, image submitter, or browser
that cannot include the submitting button leaves submission native. POST, UTF-8 and self-targeted submissions use the enhancement;
unsupported declarations keep native submission. Submitter overrides apply.
Native FormData supplies successful controls, including repeated names,
selects, checked controls and the submitter. URL-encoded bodies normalize line
breaks; multipart stays native. A fresh GUID is added under `_` only when the
form has no such field. The request runs through Paste IO.

Successful HTTP replies use `{ "success": { "message": "Saved" } }`. Errors
use `{ "error": { "message": "Fix email", "param": "email" } }`. Messages
are text, never executable HTML. Success clears text-like inputs, textareas
and file selections; other controls keep their state. Hidden values remain
intact so tokens survive a second submit, and hidden controls receive the
original `change` notification on initialization and successful submission. Failure preserves entered values. Matching
field parents receive `.paste-ui-apply-error`.

The form carries `.paste-ui-apply-busy` and `aria-busy="true"` during its
request, whose deadline is `data-paste-form-timeout` in decimal milliseconds
(default 30,000, `0` for none). A second submit is blocked until it
settles. Transport errors and unusable replies display a failure message;
there is no automatic replay of a transmitted request. The default module
does not autosave or replace HTML.

An immediately preceding associated `label[for]` receives
`.paste-ui-apply-label-hidden` while its text-like input is focused or nonempty.
The optional `paste-ui-apply` mixin/default stylesheet hides its ink with
opacity while preserving the accessible label. Wrapping labels stay visible.
Success/failure paragraphs use `.paste-ui-apply-success`/`-failure` and
`role="status"`/`"alert"`. `init(root)` initializes new forms once.

This keeps the original submission/message flow. The documented differences
fix fixed-ID collisions, text-node label selection, unsafe message placement,
overwritten repeated names, erased tokens and a request with no failure exit.

For HTML submission replies use [FormSubmission.Html](../components/formfield/form.md).
For deferred GET content use [lazy_loader](lazy-loader.md).

Forms declaring `rel="noreferrer"` remain native; XHR cannot preserve that
submission referrer policy.
