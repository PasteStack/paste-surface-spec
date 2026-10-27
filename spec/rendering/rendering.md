# Rendering a View Model

A presenter builds one view model per request outcome. The same view model is
rendered as a full page, as an IO reply fragment, or as JSON, chosen from the
request headers. Every rendering comes from the same view model and the same
templates: the page template embeds the IO reply fragment template, so an IO
reply fragment is exactly the markup a full page would have placed in its
target. Nothing is rendered twice. Anchors navigate and forms submit as
ordinary HTML without JavaScript; fragment reception is independent of either trigger.

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
  how the shared `paste.ui.utilities.io-html-fragment` operation receives fragments.
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
  fragment. The `paste.ui.form.form_html` Element places that response like any other
  when the redirect stays on the page's origin; a redirect off the page's
  origin is a response it cannot place, so it takes the failure path —
  `paste.ui.formhtml:failed` and the gated replay rule — like any other failure
  after transmission.

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
<div class="paste-ui-io-reply-fragment-target {cssClass}" data-paste-io-reply-fragment-target="{name}" data-paste-io-reply-fragment-format="{format}">
  <!-- IO reply fragment template output -->
</div>
```

The page template renders the target and places the IO reply fragment
template inside it. The IO reply fragment rendering returns only the inner
markup. `name` is nonblank, carries no whitespace, and is unique on the page.

The target renders idle. If it contains a form using the background-submit
enhancement, `paste.ui.form.form_html` adds `paste-ui-formhtml-busy`; the shared operation adds
`aria-busy="true"` and `paste-ui-io-html-fragment-busy`
to the target while its request is pending, and clears them when that request
settles. These are runtime markers, not additional Surface model fields;
unrelated target classes remain. See the [form contract](../components/formfield/form.md)
for submission, failure and ownership behavior.

### ViewModel: IoReplyFragmentTarget

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | - | Target name; `data-paste-io-reply-fragment-target` value |
| `cssClass` | string | no | `""` | Additional CSS classes on the target |
| `format` | enum | no | `Html` | `Html` / `Json`; emits `html` / `json` for the request Accept header |

Construction rejects a blank `name` or one containing whitespace
(`IllegalArgumentException`, including through `copy`). The format must be set;
unknown enum values are unrepresentable. Hand-authored markup may omit the
format attribute for HTML preference; an invalid value refuses enhancement.

## IO reply fragment envelope

A JSON representation of rendered fragments, usable for forms, article links,
explicit loads and autosave. Request owners decide what status acknowledges
their operation; representation and save acknowledgment are separate facts.

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
  module names; `paste.ui.form.form_autosave` does not
  load them.
- **Names.** Fragment names follow the target name rule and are distinct.
  Variable names are distinct, nonblank, and carry no whitespace, `,` or `=`.
- **Variables** are string values written onto bound attributes; the Element
  ignores any other value.
- **Error outcomes.** `render(status, fragments, variables, time, title)` may
  carry rendered validation/error markup at the actual HTTP status. Status must
  be 200–599 and permit a body (204, 205 and 304 are rejected). The
  metadata-only `failure` helper retains empty `data` and optional error fields.
  It cannot stand in for a renderable form-validation reply.
- **Title.** `data.title` is an optional string used by fragment navigation.
  It does not change form or autosave success policy.
- The body is `application/json` and carries the same `Vary` header as the
  negotiated renderings.

### Autosave reply contract

`paste.ui.form.form_autosave` applies its own successful reply when HTTP status and
`meta.code` are both `200`. Failures leave declared reply targets unchanged.
The response must contain an object `data`; it may acknowledge a save without
containing markup or variables.

- The original `data.modules[name].markup` replaces every live
  `data-update-contents="name"` target in the document.
- Surface's `data.fragments[name].markup` replaces every live
  `data-paste-io-reply-fragment-target="name"` target. The existing Scala
  `IoReplyFragmentEnvelope` serializer still emits this format.
- Fragments apply in own-key order (integer-like names first), querying each
  name after earlier writes so newly introduced targets can be found and
  detached targets are skipped. original modules precede Surface fragments.
- After markup, `data-update-attribute="attribute=variable,..."` receives
  present string, number or boolean variables. Surface's
  `data-paste-io-reply-fragment-bind` receives present string variables only.
  Surface bindings follow original bindings; later declared pairs win an overlap.
- Missing targets and malformed entries are ignored. Markup is trusted HTML;
  it does not load `js`/`css` assets or initialize placed enhancements.

Variable names in the Surface serializer reject Java whitespace, Unicode space
characters and U+FEFF, plus `,` and `=`, so binding-name trimming cannot change
an accepted key. Malformed DOM attribute names are skipped locally; valid
sibling bindings continue. Unrelated DOM exceptions still propagate.

## Shared HTML fragment operation

`paste.ui.utilities.io-html-fragment` is a caller-triggered utility. Forms,
marked links and lazy loading use its `load(target, options)` operation. Autosave
uses `apply(data)` after independently acknowledging its successful save.
The utility does not discover triggers, submit forms, navigate, initialize other
modules, execute scripts, load envelope assets or keep a content cache.

`load` accepts `url`, optional `method` (GET), `body`, `contentType`, and `timeout`
(30,000 milliseconds; zero disables it). `prepare()` may supply the request's
`url`, `method`, `body` and `contentType` after reserving the target; forms use
this because constructing FormData can synchronously dispatch `formdata`.
`onStart()` runs immediately before transmission. Optional `beforePlace()` runs
after the response markup is validated and immediately before its DOM write;
link navigation uses it to establish the destination URL for relative resources.
`onDone(response, status, xhr)` runs after placement and release. `onFailed(reason, sent)` runs after release;
reasons are `unsupported`, `busy`, `request`, `response`, `error`, `timeout`,
`abort`, `stale` and `superseded`. Completion callbacks are required. A caller may provide
`deferFailure(reason, complete)` to retain the target until its owned failure
decision runs; it must call `complete()`. Form replay uses this for one task
so native navigation can take precedence. Supersession still retires that decision. The returned
operation has `cancel()` for silent cancellation; a refused start returns null.
An optional `isCurrent()` predicate lets an explicit caller invalidate its own
request before placement. XHR timeout and terminal handlers are set before send.

Only HTTP(S) requests on the page origin and responses whose final URL is on
that origin are eligible. The target must remain in the document. A missing
required capability or malformed target format leaves callers their native
fallback. A caller must supply a real element target, valid options and trusted
HTML: this operation is an HTML sink, not a sanitizer.

The target's `data-paste-io-reply-fragment-format` is `html` by default (also
when omitted), or `json`. `html` sends `Accept: text/html, application/json`;
`json` sends `Accept: application/json`. Both accept either response format.
An invalid declaration refuses the enhancement. `paste.io` supplies
`X-Requested-With: XMLHttpRequest`. Servers retain the full-page rendering at
the same URL and send `Vary: X-Requested-With, Accept`. Cache policy belongs to
the endpoint: public article fragments may be cached; personalized or token
bearing responses need their own policy. The browser utility adds no cache.

A `text/html` response replaces the target's inner markup. An `application/json`
response must contain `data.fragments[targetName].markup` as a string; only
that named target is replaced, and its descendant/root bindings receive
`data.variables`. Empty markup is valid. JSON scalar strings, including an empty
string, are not HTML replies. Malformed JSON, an absent matching fragment, a bodyless status (204, 205 or 304), another content type or an
off-origin final URL is an unusable reply.
The default accepts 2xx responses. `acceptResponse(status, xhr)` lets the
request owner decide before placement: form HTML accepts rendered error
responses, including 422 validation messages in either representation; lazy
loading keeps error replies retryable without replacing its fallback. `data.title` is optional and
used only by fragment navigation. `js` and `css` metadata remain inert.

One pending load owns its target and excludes new overlapping loads, including
ancestor/descendant targets. The target carries `aria-busy="true"` and
`paste-ui-io-html-fragment-busy`; settlement restores its prior aria value and
preserves a pre-existing busy class. A committed independent `apply(data)` write
supersedes outstanding overlapping loads. Those operations are released and
aborted, and their later replies cannot overwrite the new content. Supersession
is not a transport failure: adapters perform no failure UI or native replay.
This is a commit-order guarantee, not a global newest-request protocol.

`apply(data)` preserves the original autosave envelope behavior: own-key order,
original modules before Surface fragments, every matching live target across the
document, and a fresh target scan after each name. Bindings run after markup;
the original vocabulary accepts strings/numbers/booleans and Surface accepts strings. Missing or
malformed entries are ignored. Autosave still requires HTTP 200 and meta.code
200 to acknowledge the sent snapshot; later edits remain dirty. It applies
reply markup only while the originating form is still in the document.

## Fragment navigation

Load `paste.ui.fragment_navigation` for explicitly marked anchors:

```html
<a href="/articles/example" data-paste-io-reply-fragment="article">Read article</a>
<div data-paste-io-reply-fragment-target="article">Existing article</div>
```

The `href` is the complete navigable page URL. With no enhancement it navigates
normally. With enhancement, an ordinary primary activation requests and places
the target's representation. After validating the reply, it pushes the authored
URL (retaining its hash) immediately before placing markup. A later eligible
link supersedes this module's earlier request.
A missing or ambiguous target, modifiers, non-primary buttons, downloads,
referrer-policy declarations, noreferrer, ping, non-self browsing targets
(including base target), credentials, cross-origin
URLs and same-document links remain native. Names are matched literally, not
interpreted as selectors. Forms never acquire link navigation behavior.
`data-paste-io-reply-fragment-timeout` on the anchor declares the request
deadline in decimal milliseconds, default 30,000, `0` for none.

Committing the URL before placement lets native relative iframe, image and CSS
resource URLs resolve against the destination. If placement then fails, native
navigation replaces that new history entry instead of adding another. Wrapped
JSON may supply `data.title`; without it the title stays unchanged. Focus and
scroll move to the link's fragment ID when present, otherwise the target.
Back/Forward across paths or queries reloads the server's full page at the new
URL; hash-only traversal remains native. This works after a reload as well as
within the original enhanced document. There is no client page cache or router.
Redirected replies fall back to native navigation, preserving redirect-supplied
hashes and other browser redirect semantics that XHR does not expose. A
transmitted failure falls back to normal navigation to the authored href;
a later native navigation, including a hash-only change, cancels the pending enhancement. Busy target refusals
are ignored until their owner settles. Stale/superseded responses never navigate.

The utility leaves inserted markup's initialization to its caller. Form HTML
submission reinitializes its own replacement forms and validity. Lazy loading
retains `set_init_new_content` and its explicit single/all/visible load APIs.
Fragment navigation places document markup; other optional enhancements are
not automatically discovered or initialized by a global lifecycle system.
Newly inserted ordinary forms and links retain their native behavior.

