# Rendering a View Model

A presenter builds one view model per request outcome. The same view model is
rendered as a full page, as an IO reply fragment, or as JSON, chosen from the
request headers. Every rendering comes from the same view model and the same
templates: the page template embeds the IO reply fragment template, so an IO
reply fragment is exactly the markup a full page would have placed in its
target. Nothing is rendered twice, and a form keeps working as an ordinary
browser POST without JavaScript.

```
Route -> Presenter -> ViewModel -> Page            (layout + IO reply fragment template)  text/html
                                -> IoReplyFragment (IO reply fragment template only)      text/html
                                -> JSON            (consumer-supplied encoder)            application/json
```

Validation messages, form-level errors and success state are fields of the view
model, so all three renderings show the same outcome.

## Selecting the rendering

| Request headers | Rendering |
|---|---|
| `Accept` lists `application/json` and does not list `text/html`, ignoring any range with `q=0` | JSON |
| otherwise, `X-Requested-With` equals `XMLHttpRequest` (value compared case-insensitively) | IO reply fragment |
| otherwise | Page |

- JSON is chosen only when the client explicitly asks for it and cannot take
  HTML. Browser navigations always list `text/html`, so they get the page.
- A media range whose `q` is `0` is not acceptable and is ignored; an
  unparseable `q` leaves the range acceptable.
- A range with no media type (for example a bare `;`) is ignored.
- `paste.io` sends `X-Requested-With: XMLHttpRequest` on every request, which is
  how the `paste.ui.form` Element receives IO reply fragments.
- Other media-range parameters are ignored; only the presence of the two media
  types is read. `*/*` lists neither.

## Response rules

- **Status.** One outcome has one status code in every rendering: a validation
  failure that renders the page with `400` renders the IO reply fragment and
  the JSON with `400` too.
- **Content type.** Page and IO reply fragment are `text/html; charset=utf-8`.
  JSON is `application/json`.
- **Vary.** Every negotiated response carries `Vary: X-Requested-With, Accept`,
  so a cache never serves one rendering in place of another.
- **IO reply fragment body.** The IO reply fragment template's output alone:
  no layout, no `<html>`, `<head>` or `<body>`, no asset includes, no inline
  script.
- **JSON body.** The view model encoded by an encoder the consumer supplies.
  Surface does not choose a JSON library. When the presenter supplies no encoder,
  the implementation reports the request as not acceptable and the application
  responds `406`.
- **Redirects.** Browsers follow a redirect from a background request with the
  request headers intact, so the redirect target renders its own IO reply
  fragment. The `paste.ui.form` Element places that response like any other
  when the redirect stays on the page's origin; a redirect off the page's
  origin, a non-HTML response, or a network failure makes it resubmit
  natively.

## Framework bindings

An implementation may also ship a binding for a web framework — a directive
set, middleware or equivalent — that applies the selection and response rules
above. The binding carries no rules of its own: it reads the same headers,
renders through the same presentation, and answers the same status, content
type and `Vary`. `paste-surface-pekko` is the Pekko HTTP binding of the Scala
implementation.

## IO reply fragment targets

An IO reply fragment lands in an element marked with its name:

```html
<div class="paste-ui-io-reply-fragment-target {cssClass}" data-paste-io-reply-fragment-target="{name}">
  <!-- IO reply fragment template output -->
</div>
```

The page template renders the target and places the IO reply fragment
template inside it. The IO reply fragment rendering returns only the inner
markup. `name` is nonblank, carries no whitespace, and is unique on the page.

### ViewModel: IoReplyFragmentTarget

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | - | Target name; `data-paste-io-reply-fragment-target` value |
| `cssClass` | string | no | `""` | Additional CSS classes on the target |

Construction rejects a blank `name` or one containing whitespace
(`IllegalArgumentException`, including through `copy`).

## IO reply fragment envelope

A separate JSON reply for updating named targets outside a form submit, such
as autosave or paging a list. It is applied only on success.

A success reply:

```json
{
  "meta": { "code": 200, "message": "OK", "time": 1790131202.32 },
  "data": {
    "fragments": { "{name}": { "markup": "<p>...</p>", "js": ["..."], "css": ["..."] } },
    "variables": { "{variable}": "{value}" }
  }
}
```

A failure reply:

```json
{
  "meta": {
    "code": 400,
    "message": "Bad Request",
    "time": 1790131202.32,
    "error_type": "param_error",
    "error_code": 400,
    "error_detail": ""
  },
  "data": {}
}
```

- **`meta`** always carries `code` (the HTTP status), `message` (its standard
  reason phrase) and `time` (epoch seconds, fractional). `error_type`,
  `error_code` and `error_detail` appear only when an error code is set;
  `error_detail` defaults to `""`. The error types are `param_error` (`400`) and
  `authorization_error` (`403`).
- **Fragments.** `markup` is required. `js` and `css` are optional lists of
  module names; the `paste.ui.io-reply-fragment-envelope` Element does not
  load them.
- **Names.** Fragment names follow the target name rule and are distinct.
  Variable names are distinct, nonblank, and carry no whitespace, `,` or `=`.
- **Variables** are string values written onto bound attributes; the Element
  ignores any other value.
- **On failure** the status and `meta.code` are the failure code (`400` to
  `599`), and `data` is empty: no fragments, no variables.
- The body is `application/json` and carries the same `Vary` header as the
  negotiated renderings.

### Element contract: `paste.ui.io-reply-fragment-envelope`

`paste.ui.io-reply-fragment-envelope.apply(envelope, status, root)` applies an
envelope when `status` and `meta.code` are both `200`, and otherwise changes
nothing.

- Each `data.fragments[name].markup` replaces the content of every
  `[data-paste-io-reply-fragment-target="{name}"]` in `root` (default: the
  document), `root` itself included when it carries the attribute.
- Each element in `root`, `root` included, carrying
  `data-paste-io-reply-fragment-bind="{attribute}={variable},..."` has
  `attribute` set to `data.variables[variable]` for every variable present in
  the envelope.
- It returns the number of target elements whose content was replaced, or
  `0` when nothing was applied.
- An entry named in the envelope with no matching target is skipped.
- It places markup only: Elements inside the placed markup, `paste.ui.form`
  included, are not enhanced.
