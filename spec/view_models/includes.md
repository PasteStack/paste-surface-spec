# Includes (Asset ViewModels)

## AssetInclude (Base)

Base contract for asset injection.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `debugMode` | boolean | no | `false` | Enable debug/unminified assets |
| `pasteIncludes` | string[] | no | `[]` | List of asset paths to include |

---

## CSSInclude

CSS asset injection.

### Properties

Inherits from `AssetInclude`.

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

<!-- Or with manifest lookup -->
<link rel="stylesheet" href="{manifest.lookup(include)}" type="text/css">
```

---

## JSInclude

JavaScript asset injection.

### Properties

Inherits from `AssetInclude`.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `async` | boolean | no | `false` | Load scripts asynchronously |
| `defer` | boolean | no | `true` | Defer script execution |
| `jamModules` | Seq[string] | no | empty | Module names for the JAM request; non-empty selects JAM mode |
| `jamVersion` | string | no | `""` | The path's single cache segment: asset build version or manifest group timestamp |
| `jamModuleVersions` | Map[string, string] | no | empty | Per-module versions from the asset manifest, appended as `+v{version}` |

### Example (Scala)

```scala
case class JSInclude(
  debugMode: Boolean = false,
  pasteIncludes: Seq[String] = Seq.empty,
  async: Boolean = false,
  defer: Boolean = true,
  // JAM mode: cacheable path /paste/{version}/{modules}.js
  jamModules: Seq[String] = Seq.empty,
  jamVersion: String = "",
  jamModuleVersions: Map[String, String] = Map.empty
) extends AssetInclude {
  def useJam: Boolean = jamModules.nonEmpty

  def jamUrl: String = {
    val modules = jamModules.sorted
      .map(module => jamModuleVersions.get(module).fold(module)(version => s"$module+v$version"))
      .mkString("~")
    val suffix = if (debugMode) ".js" else ".min.js"
    s"/paste/$jamVersion/$modules$suffix"
  }
}
```

### JAM Path Contract

The JAM server owns this path shape: one immutable version segment, then the
module list, then the extension. Implementations MUST NOT add further path
segments — the server treats everything after the version segment as the module
list, so an extra segment is parsed as part of the first module name and that
module is silently dropped from the response.

```
/paste/{version}/{module}[+v{version}]{~{module}[+v{version}]}*[.min].{js|css}
```

- `{version}` is the group's cache key: the asset build version, or the manifest's
  group timestamp when the caller composes the path from a manifest.
- Modules are separated by `~`. A comma is accepted for backward compatibility.
- A per-module `+v{version}` suffix is optional; the server strips it. Supply it
  from the asset manifest so a single changed module invalidates the path.
- Modules are sorted so the same set always produces the same cacheable path.

### HTML Output

**Direct mode** (individual files):
```html
<!-- Debug mode: source files -->
<script src="/js/app.js" type="text/javascript" defer></script>

<!-- Prod mode: minified -->
<script src="/js/app.min.js" type="text/javascript" defer></script>
```

**JAM mode** (dependency resolution via cacheable URL):
```html
<!-- Cacheable path: /paste/{version}/{modules}.js -->
<script src="/paste/2025.02.02/paste.dom~paste.ui.heroscroll.min.js" type="text/javascript" defer></script>

<!-- Debug mode -->
<script src="/paste/2025.02.02/paste.dom~paste.ui.heroscroll.js" type="text/javascript" defer></script>

<!-- Composed from a manifest: group timestamp plus per-module versions -->
<script src="/paste/1770465409/paste.dom+v1.0~paste.ui.heroscroll+v3.0.min.js" type="text/javascript" defer></script>
```

### Usage Examples

```scala
// Direct mode - specify file paths
JSInclude(pasteIncludes = Seq("/js/paste.js", "/js/app.js"))

// JAM mode - cacheable URL keyed by the asset build version
JSInclude(
  jamModules = Seq("paste.dom", "paste.ui.heroscroll"),
  jamVersion = "2025.02.02"
)
// Output: /paste/2025.02.02/paste.dom~paste.ui.heroscroll.min.js

// JAM mode with debug
JSInclude(
  jamModules = Seq("paste.dom", "paste.ui.heroscroll"),
  jamVersion = "2025.02.02",
  debugMode = true
)
// Output: /paste/2025.02.02/paste.dom~paste.ui.heroscroll.js

// JAM mode with manifest data - per-module versions invalidate one module
JSInclude(
  jamModules = Seq("paste.dom", "paste.ui.heroscroll"),
  jamVersion = "1770465409",
  jamModuleVersions = Map("paste.dom" -> "1.0", "paste.ui.heroscroll" -> "3.0")
)
// Output: /paste/1770465409/paste.dom+v1.0~paste.ui.heroscroll+v3.0.min.js
```

### Why Cacheable URLs?

Query strings (`?modules=...`) are not cached by CDNs. Path-based URLs are:
- CDN cacheable with long TTL
- Version in path enables cache busting on deploy
- Checksum ensures content integrity

---

## Manifest Integration

When using `paste-assetgraph`, assets are resolved via manifest:

```json
{
  "version": "2025.02.02.1",
  "assets": {
    "paste.js": {
      "path": "/static/js/paste.abc123.min.js",
      "dependencies": [],
      "hash": "abc123"
    },
    "paste.dom": {
      "path": "/static/js/paste.dom.def456.min.js", 
      "dependencies": ["paste"],
      "hash": "def456"
    }
  }
}
```

Templates should support both:
1. **Direct includes** — Static paths for simple sites
2. **Manifest lookup** — Dynamic resolution for sites using assetgraph
