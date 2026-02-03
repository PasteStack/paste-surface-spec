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

### Example (Scala)

```scala
case class JSInclude(
  debugMode: Boolean = false,
  pasteIncludes: Seq[String] = Seq.empty,
  async: Boolean = false,
  defer: Boolean = true,
  // JAM mode: cacheable path /paste/{version}/{checksum}/{modules}.js
  jamModules: Seq[String] = Seq.empty,
  jamVersion: String = "",
  jamChecksum: String = ""
) extends AssetInclude {
  def useJam: Boolean = jamModules.nonEmpty
  
  def jamUrl: String = {
    val modules = jamModules.sorted.mkString(",")
    val suffix = if (debugMode) ".js" else ".min.js"
    s"/paste/$jamVersion/$jamChecksum/$modules$suffix"
  }
}
```

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
<!-- Cacheable path: /paste/{version}/{checksum}/{modules}.js -->
<script src="/paste/2025.02.02/abc123/paste.dom,paste.ui.heroscroll.min.js" type="text/javascript" defer></script>

<!-- Debug mode -->
<script src="/paste/2025.02.02/abc123/paste.dom,paste.ui.heroscroll.js" type="text/javascript" defer></script>
```

### Usage Examples

```scala
// Direct mode - specify file paths
JSInclude(pasteIncludes = Seq("/js/paste.js", "/js/app.js"))

// JAM mode - cacheable URL with version/checksum
JSInclude(
  jamModules = Seq("paste.dom", "paste.ui.heroscroll"),
  jamVersion = "2025.02.02",
  jamChecksum = "abc123"
)
// Output: /paste/2025.02.02/abc123/paste.dom,paste.ui.heroscroll.min.js

// JAM mode with debug
JSInclude(
  jamModules = Seq("paste.dom", "paste.ui.heroscroll"),
  jamVersion = "2025.02.02",
  jamChecksum = "abc123",
  debugMode = true
)
// Output: /paste/2025.02.02/abc123/paste.dom,paste.ui.heroscroll.js
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
