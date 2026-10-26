# Original enhancements

These independently loadable Elements use ordinary authored HTML. Surface
renders their declarations; it does not implement browser behavior, generate
radio groups, or add wrappers merely to activate a module. The namespace is
`paste.ui.*`; the historical attribute names remain valid.

| Element | Surface expression | Owner of behavior |
| --- | --- | --- |
| `allowed_chars` | Input/textarea `dataAttributes` | Typed-character filter; complete-value validity stays native/server-owned. |
| `form.form_autosave` | Form `dataAttributes`, ordinary named fields | Edit detection, request timing, acknowledgement and reply updates. |
| `imageupload` | File input plus authored hidden URI, image and status | File request and paired preview/URI updates. |
| `js_tooltip` | Authored trigger with `data-ui-js-tooltip` | Rich tooltip display; CSS owns its appearance. |
| `multistate` | [sibling radios and selected panels](multistate.md) | Native selection plus the existing history/reflection enhancement. |
| `navigate_on_change` | Authored select with destination-valued options | Browser navigation on an explicitly marked change. |
| `prevent_double_submit` | Input/button `dataAttributes` | Pending native navigation, separate from a background form request. |
| `select` | [Native select and decorative label](select.md), or Surface `Select` | Reflect the selected option's visible label; native selection and form semantics remain intact. |
| `sortable` | Authored group, fixed blocks, draggable content slots | Swap slot contents; surrounding order fields stay fixed. |
| `update_text_on_input_change` | Input/textarea `dataAttributes`, authored output | Text substitution, retaining surrounding markup. |

Most declarations use the existing Surface components. The generic `Select`
field renders the native select and companion used by the select enhancement.
Existing generic fields can supply the attributes they support. Use raw markup
in a template's content slot for checked radios, paired uploads or
particular sibling layouts that a wrapped form-field template cannot express.
IDs and native radio names are caller-owned and unique in their required scope.

## Character filtering and text reflection

```html
<label for="account-reference">Reference</label>
<input id="account-reference" name="reference" pattern="[0-9]+"
       data-allowed-char-expr="[0-9]">
<label for="account-name">Name</label>
<input id="account-name" name="name" value="Ada"
       data-update-variable-name="accountName"
       data-update-variable-default="Guest">
<p data-update-variable-names="accountName">Hello <strong>%(accountName)s</strong>.</p>
```

`allowed_chars.initialize(force)` binds the original keypress filter and can
force a re-scan. Denied characters use `data-disallowed-char-expr`; both rules
may be present. This does not sanitize paste or composition. Malformed regexes
leave editing native; shortcuts and deletion remain available.

Text reflection supports `init(parent)`, `setVariable(name, value)` and
`updateOutputs(force)`. The latter applies staged values. Initialization reads
native input values; empty values use the declared default, then `??`. Zero is
a value. Unchecking a checkbox clears its old value. Variables are explicitly
page-named: use distinct names for independent outputs. A radio's own native
checked value supplies the value; no wrapper or name inference occurs.

Only text-node `%(name)s` placeholders are substituted. Authored markup stays
in place, and field values remain literal text. Attributes, scripts, styles and
textarea contents are not templates. Optional `data-original-value` is trusted
page-authored template HTML, parsed once when the output is bound.

## Autosave

Load `paste.ui.form.form_autosave`. There is no top-level autosave alias.
Requests carry a deadline — `data-autosave-timeout` in decimal milliseconds
on the form, default 30,000, `0` for none; a timed-out save stays unacknowledged
and retries only on a subsequent edit/change/blur, as other failed requests do.

```html
<form action="/profile" method="post"
      data-ui-autosave="displayName,bio" data-autosave-action="/profile/draft">
  <input name="csrf" type="hidden" value="server-token">
  <label>Name <input name="displayName" value="Ada"></label>
  <label>Bio <textarea name="bio"></textarea></label>
  <button type="submit">Save profile</button>
</form>
<div data-update-contents="draft-status" role="status"></div>
```

Only listed field names trigger saves. The request is a POST containing native
FormData for the complete form, including successful unmonitored fields. The
first edit, change and blur save immediately; later typing uses a fixed
ten-second window, not a resetting debounce. One request runs per form. A
successful acknowledgement covers its sent values; edits made while it was
pending remain dirty and get a later save. A failed request stays dirty and
waits for the next edit/change/blur to retry. Navigation and ordinary form
submission remain native; unload is not a delivery guarantee.

The form carries `autosaving` during transmission and `not-autosaving` when
idle. `not-autosaved` marks current unacknowledged values; a form whose ordinary
and autosave actions are identical also starts unacknowledged. No IDs or
`data-autosave-form-id` bookkeeping attributes are generated. `init(parent)`
discovers added forms/fields without duplicating existing subscriptions.

Autosave applies its own [reply contract](../rendering/rendering.md#autosave-reply-contract).
Original replies use `data.modules[name].markup` with
`data-update-contents="name"`, and `data-update-attribute="attribute=variable,..."`
with string/number/boolean variables. Surface's existing `data.fragments`
and string-variable bindings also work. Placement delegates to
`paste.ui.utilities.io-html-fragment`; autosave owns acknowledgment. Inserted markup does
not initialize new Elements; the page uses each module's existing entry point.

## Native-submit guard and select navigation

```html
<button type="submit" name="operation" value="purchase"
        data-prevent-double-submit="true">Purchase</button>
<label for="catalog-destination">Browse</label>
<select id="catalog-destination" data-navigate-on-change="true">
  <option value="/catalog">All products</option>
  <option value="/catalog/mills">Mills</option>
</select>
```

The submit guard retains the first submitter's name/value and blocks repeat
native submissions. Disabling occurs after native serialization. A canceled
submission creates no lasting guard. Reset and pageshow release only controls
the guard disabled. Invalid forms and `method="dialog"` submissions (including
a submitter override) never acquire it. `init(parent)` is
available for added markup. Background `paste.ui.form.form_html` submissions retain their
own target reservation until XHR settlement; canceling a submit does not give
this module ownership of that request.

Select navigation uses the browser's normal location navigation, including
native URL/history/hash behavior. `data-navigate-on-change="true"` is explicit
and delegated, so subsequently inserted opted-in controls work. There is no
navigation API or wrapper-click navigation. Ordinary destinations use anchors.

## Image upload

```html
<form action="/photo" method="post" enctype="multipart/form-data">
  <label for="profile-photo">Photo</label>
  <input id="profile-photo" type="file" name="photo" accept="image/*"
         data-image-upload-action="/photo/upload">
  <input type="hidden" name="photoUri" data-image-upload-uri
         data-image-upload-for="profile-photo">
  <img alt="Selected profile photo" src="/images/default-profile.png"
       data-image-upload-preview data-image-upload-for="profile-photo"
       data-image-url-prefix="/uploads">
  <span role="status" data-image-upload-message
        data-image-upload-for="profile-photo"></span>
  <button type="submit">Save photo</button>
</form>
```

All three companions are inside the file's form and name its authored ID.
`bind(fieldOrForm, optionalForm)` binds added markup. The multipart POST sends
the first selected file under `data-image-upload-param` or the input name.
A successful HTTP 200 reply `{ "meta": { "code": 200 }, "data": "photo.png" }`
writes the hidden URI, dispatches a bubbling native `change`, and updates the
preview using its prefix. An empty URI restores `data-image-upload-default-src`
or the original preview source. File and message carry `data-image-upload-loading`
until the reply/preview settles. Failure clears the URI and loading markers and
sets `data-image-upload-error-message`. The optional `paste.ui.imageupload`
stylesheet displays error/loading text; the silent message mixin accepts a
localized loading label. Page markup supplies the accessible status element.
A later selection supersedes the preceding upload.

The file input and ordinary multipart form remain the no-JavaScript baseline.
No iframe transport, form cloning, action rewriting or site-specific loader
asset is required. This is separate from image-resolution selection and
image-sequence playback.

## Rich tooltip and fixed-slot sorting

```html
<button type="button" data-ui-js-tooltip="heading=&lt;b&gt;Details&lt;/b&gt;|body=More information">Help</button>
<div data-paste-sortable>
  <div class="paste-ui-sortable">
    <input type="hidden" name="position" value="1">
    <div draggable="true"><input name="item" value="first"></div>
  </div>
  <div class="paste-ui-sortable">
    <input type="hidden" name="position" value="2">
    <div draggable="true"><input name="item" value="second"></div>
  </div>
</div>
```

Rich tooltip content is trusted authored HTML. Focus and hover expose it;
Escape dismisses it. The `ui-js-tooltip` flyout receives an owned, collision-checked
description ID; existing `aria-describedby` tokens remain intact. `init(parent)`
binds added triggers. The optional stylesheet supplies appearance without
changing global body positioning. Use `title` when plain native help suffices.

Sortable blocks use the `.paste-ui-sortable` class. Each block contains one
draggable slot. The module swaps
the slots' child nodes, preserving values and listeners, while structural order
fields stay put. `bind(parentOrSelector, callbacks)` remains available; callbacks
`dragStart`, `dragEnter`, `dragEnd` receive `(parent, block)` with the slot as
`this`. Rebinding can supply callbacks after declarative initialization. Foreign
drag data is never inserted as markup. Native dragging does not supply a
keyboard/touch reorder UI: consumers needing one must author that alternative.

Image uploads carry a request deadline — `data-image-upload-timeout` in
decimal milliseconds on the field, default 30,000, `0` for none. A timeout
clears loading state,
reports upload failure, clears the paired URI, and permits a subsequent selection.
Native validity reflection requires a callable form prototype checkValidity;
without that capability it leaves the ordinary form untouched.
