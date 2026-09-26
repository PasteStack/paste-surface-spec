# Includes (Asset ViewModels)

## AssetInclude (Base)

Base contract for direct asset injection — one tag per listed path.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `debugMode` | boolean | no | `false` | Use source files instead of `.min.` files |
| `pasteIncludes` | string[] | no | `[]` | List of asset paths to include |

`debugMode` applies to direct mode only: JAM markup is decided by the
paste-assetgraph build, not by an include — see
[JAM Rendering](#jam-rendering) below.

---

## CSSInclude

CSS asset injection — direct file links only.

### Properties

Inherits from `AssetInclude`; adds none.

### Example (Scala)

```scala
trait AssetInclude {
  def debugMode: Boolean
  def pasteIncludes: Seq[String]
}

case class CSSInclude(
  debugMode: Boolean = false,
  pasteIncludes: Seq[String] = Seq.empty
) extends AssetInclude
```

### HTML Output

```html
<!-- Debug mode: use source files -->
<link rel="stylesheet" href="/css/styles.css" type="text/css">

<!-- Prod mode (debugMode=false): auto-append .min -->
<link rel="stylesheet" href="/css/styles.min.css" type="text/css">
```

The path rewrite matches the extension against the base only: a query or
fragment rides along untouched, and a path already minified or ending in
another extension is emitted as given — never `foo.min.min.css`.

---

## JSInclude

JavaScript asset injection — direct script tags only.

### Properties

Inherits from `AssetInclude`.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `async` | boolean | no | `false` | Load scripts asynchronously |
| `defer` | boolean | no | `true` | Defer script execution |

### Example (Scala)

```scala
case class JSInclude(
  debugMode: Boolean = false,
  pasteIncludes: Seq[String] = Seq.empty,
  async: Boolean = false,
  defer: Boolean = true
) extends AssetInclude
```

### HTML Output

```html
<!-- Debug mode: source files -->
<script src="/js/app.js" type="text/javascript" defer></script>

<!-- Prod mode: minified -->
<script src="/js/app.min.js" type="text/javascript" defer></script>
```

### Usage Examples

```scala
// Direct file paths; the page owns nothing but the tag list
JSInclude(pasteIncludes = Seq("/js/paste.js", "/js/app.js"))
CSSInclude(pasteIncludes = Seq("/css/site.css"))
```

---

## JAM Rendering

JAM is not a mode of the includes — it is the layout's job. A JAM page
carries a `Jam` (the paste-assetgraph event: `css`, `js`, `inline`, `sync`,
`media` — module names only) and the per-render page object of the language's
paste-assetgraph runtime; the root layout:

1. records the jam once — `JamIncludes.record(jam, page)`;
2. emits the CSS dump in `<head>` — `JamIncludes.dump(AssetType.Css, page)`;
3. emits the JS dump at the end of `<body>` —
   `JamIncludes.dump(AssetType.Js, page)`.

Both dumps render from the same page object, so modules an earlier dump
already delivered are not repeated in a later one.

Implementations MUST NOT build JAM URLs, timestamps, version tags, or
dependency lists: URL format, dependency expansion, inlining and markup are
owned by paste-assetgraph — see
[JAM_SPEC.md](https://gitlab.com/tomshley/brands/global/tware/tech/products/paste/paste-assetgraph/-/blob/develop/JAM_SPEC.md)
for the URL and markup contract.

The application creates and owns the paste-assetgraph `Paste` instance and
passes a fresh page object into each render — the layout augments the page,
it never owns the application lifecycle:

```scala
// App-owned, created once at startup:
val assetgraph = Paste.fromClasspath()

// Per render — a fresh page object:
val page = assetgraph.page()

// In <head> — record once, then the css dump:
page.jam(css = jam.css, js = jam.js, inline = jam.inline, sync = jam.sync, media = jam.media)
val headContent = page.dump(AssetType.Css)

// At the end of <body>:
val scriptIncludes = page.dump(AssetType.Js)
```

A page can also dump both types in one event — `page.dump()` emits the css
markup first, then the js — equivalent to the two typed dumps back to back.

`record` tolerates an empty jam (it records nothing) but a non-empty jam
with no page MUST fail the render with a clear error naming the missing
page rather than emit nothing: a silently missing tag is the failure this
contract exists to prevent. `dump` with no page emits nothing.

Recording and dumping are partial operations: they MUST NOT finish the page.
Finish belongs to the root layout — `paste.surface` layouts call
`page.finish()` after the JS dump, before `</body>` — which makes the
library verify every jammed module reached a dump of its type. Jams are
queued per type (and css is tracked per `media`), so a jam whose type never
reaches a dump fails the render at finish naming the module instead of
silently dropping its tag. Custom root layouts MUST call `page.finish()`
the same way; the call is idempotent, so a host-side finish after the
layout adds nothing.

### HTML Output

JAM markup is produced by paste-assetgraph (the shape below is assetgraph's
output, not something the surface composes):

```html
<!-- CSS dump in <head> -->
<link rel="stylesheet" href="/paste/1770465409/site.theme+v1.0.min.css"/>

<!-- JS dump at the end of <body>: inlined runtime + async loader -->
<script type="text/javascript">…paste runtime source…
;
paste.config({packagesUrl:'/paste/71f8e72a3d6b/'});</script>
<script type="text/javascript">(function(d,r){d('paste.dom').isLoading=d('paste.event').isLoading=!0;r('/paste/1770462000/paste.dom+v2.0~paste.event+v1.0.min.js');})(paste.define,paste.require);</script>
```

### Why Cacheable URLs?

paste-assetgraph produces path-based URLs rather than query strings
(`?modules=...`). Whether a CDN caches a query-string URL depends on its
configuration; the path form avoids relying on query-key configuration at
all:

- CDN cacheable with long TTL
- The timestamp segment and per-module `+vN.0` tags — carrying the version's
  full content hash as `+vN.0-h{hash}` under paste-assetgraph's default
  `jam.hash-urls` policy — bust the cache when any delivered module is
  rebuilt
- The path names the exact filtered group in dependency order, so a module
  already delivered on the page is never fetched twice

---

## Template Paths

| Include | Twirl | Jinja/Nunjucks |
|---------|-------|----------------|
| CSS include | `paste.surface.includes.html.css` | `paste/surface/includes/css.html` |
| JS include | `paste.surface.includes.html.js` | `paste/surface/includes/js.html` |

Both renderers take `(include)` and emit direct-mode tags only — they never
see the page object. JAM markup comes from `JamIncludes.record` /
`JamIncludes.dump`, which layouts call directly.

## Manifest Integration

The module names, versions, timestamps and dependencies behind a JAM page
come from the `paste-assetgraph` manifest — see *Manifest Structure* in
[JAM_SPEC.md](https://gitlab.com/tomshley/brands/global/tware/tech/products/paste/paste-assetgraph/-/blob/develop/JAM_SPEC.md).

Templates should support both:

1. **Direct includes** — Static paths for simple sites
2. **JAM** — A `Jam` event plus the page object, recorded and dumped by the
   root layout for sites using assetgraph

## Migration

- `jamVersion`, `jamModuleVersions` and `JSInclude.jamUrl` are removed
  (breaking): surfaces no longer compose JAM URLs — a versioned URL names the
  exact filtered group paste-assetgraph expands and serves.
- `jamModules`, `jamInline`, `jamMedia`, `jamSync` and `useJam` are removed
  from the includes (breaking): JAM intent is a `Jam` value the layout
  records on the page object, not a mode of an include.
- `PageViewModel` and `HomePageViewModel` carry a `jam: Jam = Jam()` field;
  the JAM factories (`forPasteJam`, `forForms`, `forCssJam`) return `Jam`.
