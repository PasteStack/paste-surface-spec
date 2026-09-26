# Includes (Asset ViewModels)

## AssetInclude (Base)

Base contract for asset injection.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `debugMode` | boolean | no | `false` | Enable debug/unminified assets (direct mode only) |
| `pasteIncludes` | string[] | no | `[]` | List of asset paths to include (direct mode) |
| `jamModules` | string[] | no | `[]` | JAM module names; non-empty selects JAM mode |
| `jamInline` | boolean | no | `false` | Force the group's markup inline in JAM mode |

`debugMode` applies to direct mode only: in JAM mode minification is decided
by the paste-assetgraph build, not by the include.

---

## CSSInclude

CSS asset injection.

### Properties

Inherits from `AssetInclude`.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `jamMedia` | string | no | none | Stylesheet media for the JAM group (e.g. `print`) |

### Example (Scala)

```scala
trait AssetInclude {
  def debugMode: Boolean
  def pasteIncludes: Seq[String]
  def jamModules: Seq[String]
  def jamInline: Boolean
  final def useJam: Boolean = jamModules.nonEmpty
}

case class CSSInclude(
  debugMode: Boolean = false,
  pasteIncludes: Seq[String] = Seq.empty,
  jamModules: Seq[String] = Seq.empty,
  jamInline: Boolean = false,
  jamMedia: Option[String] = None
) extends AssetInclude
```

### HTML Output

```html
<!-- Direct mode, debug: use source files -->
<link rel="stylesheet" href="/css/styles.css" type="text/css">

<!-- Direct mode, prod (debugMode=false): auto-append .min -->
<link rel="stylesheet" href="/css/styles.min.css" type="text/css">
```

In JAM mode the emitted markup is produced by paste-assetgraph — see
[JAM Mode Rendering](#jam-mode-rendering) below.

---

## JSInclude

JavaScript asset injection.

### Properties

Inherits from `AssetInclude`.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `async` | boolean | no | `false` | Load scripts asynchronously (direct mode only) |
| `defer` | boolean | no | `true` | Defer script execution (direct mode only) |
| `jamSync` | boolean | no | `false` | Emit a synchronous script tag in JAM mode |

### Example (Scala)

```scala
case class JSInclude(
  debugMode: Boolean = false,
  pasteIncludes: Seq[String] = Seq.empty,
  async: Boolean = false,
  defer: Boolean = true,
  jamModules: Seq[String] = Seq.empty,
  jamInline: Boolean = false,
  jamSync: Boolean = false
) extends AssetInclude
```

### JAM Mode Rendering

A non-empty `jamModules` selects JAM mode. Rendering an include in JAM mode
delegates to the per-render page object of the language's paste-assetgraph
runtime:

- a CSS include records one jam event (`css = jamModules`, `inline =
  jamInline`, `media = jamMedia`) and emits that page's CSS dump;
- a JS include records one jam event (`js = jamModules`, `inline = jamInline`,
  `sync = jamSync`) and emits that page's JS dump.

The CSS include renders in `<head>` and the JS include at the end of `<body>`
**from the same page object**, so modules an earlier dump already delivered
are not repeated in a later one.

Implementations MUST NOT build JAM URLs, timestamps, version tags, or
dependency lists: URL format, dependency expansion, inlining and markup are
owned by paste-assetgraph — see
[JAM_SPEC.md](https://gitlab.com/tomshley/brands/global/tware/tech/products/paste/paste-assetgraph/-/blob/develop/JAM_SPEC.md)
for the URL and markup contract.

The application creates and owns the paste-assetgraph `Paste` instance and
passes a fresh page object into each render — the include renderers augment
the page, they never own the application lifecycle:

```scala
// App-owned, created once at startup:
val assetgraph = Paste.fromClasspath()

// Per render — a fresh page object:
val page = assetgraph.page()

// In <head>, from the CSS include:
page.jam(css = cssInclude.jamModules, inline = cssInclude.jamInline, media = cssInclude.jamMedia)
val headContent = page.dumpCss()

// At the end of <body>, from the JS include:
page.jam(js = jsInclude.jamModules, inline = jsInclude.jamInline, sync = jsInclude.jamSync)
val scriptIncludes = page.dumpJs()
```

An include is a partial renderer: it MUST NOT finish the page. Finish belongs
to the root layout — `paste.surface` layouts call `page.finish()` after the
JS include, before `</body>` — which makes the library verify every jammed
module reached a dump of its type. Jams are queued per type (and css is
tracked per `media`), so a css jam that lands below the head's css dump
fails the render at finish naming the module instead of silently dropping
its tag: completion detects the omission, it cannot move the tag back into
`<head>` — css bound for `<head>` has to be jammed before that dump. Custom
root layouts MUST call `page.finish()` the same way; the call is idempotent,
so a host-side finish after the layout adds nothing.

### HTML Output

**Direct mode** (individual files):
```html
<!-- Debug mode: source files -->
<script src="/js/app.js" type="text/javascript" defer></script>

<!-- Prod mode: minified -->
<script src="/js/app.min.js" type="text/javascript" defer></script>
```

**JAM mode** — markup produced by paste-assetgraph (the shape below is
assetgraph's output, not something the include composes):

```html
<!-- CSS include dump in <head> -->
<link rel="stylesheet" href="/paste/1770465409/site.theme+v1.0.min.css"/>

<!-- JS include dump at the end of <body>: inlined runtime + async loader -->
<script type="text/javascript">…paste runtime source…
;
paste.config({packagesUrl:'/paste/71f8e72a3d6b/'});</script>
<script type="text/javascript">(function(d,r){d('paste.dom').isLoading=d('paste.event').isLoading=!0;r('/paste/1770462000/paste.dom+v2.0~paste.event+v1.0.min.js');})(paste.define,paste.require);</script>
```

### Usage Examples

```scala
// Direct mode - specify file paths
JSInclude(pasteIncludes = Seq("/js/paste.js", "/js/app.js"))

// JAM mode - module names only; the page dump emits the markup
JSInclude(jamModules = Seq("paste.dom", "paste.ui.heroscroll"))

// JAM mode - inline the group's markup regardless of size
JSInclude(jamModules = Seq("paste.dom"), jamInline = true)
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

Both renderers take `(include, page)`: `page` is the per-render
paste-assetgraph page object and is optional (Scala `Option[PastePage] =
None`). Direct mode ignores it. JAM mode — a non-empty `jamModules` — with no
page MUST fail the render with a clear error naming the missing page rather
than emit nothing: a silently missing script tag is the failure this contract
exists to prevent.

## Manifest Integration

The module names, versions, timestamps and dependencies behind a JAM-mode
include come from the `paste-assetgraph` manifest — see *Manifest Structure*
in
[JAM_SPEC.md](https://gitlab.com/tomshley/brands/global/tware/tech/products/paste/paste-assetgraph/-/blob/develop/JAM_SPEC.md).

Templates should support both:

1. **Direct includes** — Static paths for simple sites
2. **JAM mode** — Module names rendered through the paste-assetgraph page
   object for sites using assetgraph

## Migration

- `jamVersion`, `jamModuleVersions` and `JSInclude.jamUrl` are removed
  (breaking): surfaces no longer compose JAM URLs — a versioned URL names the
  exact filtered group paste-assetgraph expands and serves.
- JAM-mode includes now require a paste-assetgraph page object at render
  time: the caller supplies it, the renderer records on it and emits its dump.
