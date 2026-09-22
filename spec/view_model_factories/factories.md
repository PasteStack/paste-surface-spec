# View Model Factories

Factories create ViewModels from configuration and domain data.

## PageMetaFactory

Creates `PageMeta` from site configuration.

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `create` | config, title, description?, keywords?, url?, fbSiteType? | PageMeta | Full control |
| `forHomePage` | config | PageMeta | Home page defaults |
| `forArticle` | config, title, description, url | PageMeta | Article with og:article |

### Example (Scala)

```scala
object PageMetaFactory {
  case class SiteConfig(
    siteName: String,
    domainName: String,
    themeColor: String = "",
    defaultDescription: String = "",
    defaultKeywords: String = ""
  )
  
  def forHomePage(config: SiteConfig): PageMeta = PageMeta(
    siteName = config.siteName,
    title = config.siteName,
    description = config.defaultDescription,
    url = config.domainName,
    themeColor = config.themeColor,
    fbSiteType = Some("website")
  )
}
```

---

## HeroFactory

Creates `Hero` ViewModels for common use cases.

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `forHomePage` | name? | Hero | Main hero with parallax + sticky target |
| `forSection` | name, withImage? | Hero | Section hero, parallax disabled |
| `forFullBleed` | name | Hero | Full bleed image, no content |

---

## IncludesFactory

Creates asset includes, aggregating JAM modules.

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `forPasteJam` | config, additionalModules?, moduleVersions? | JSInclude | Paste core + UI via JAM |
| `forForms` | config, moduleVersions? | JSInclude | Paste core + form modules |
| `forDirectJS` | paths, debugMode? | JSInclude | Direct file paths |
| `forDirectCSS` | paths, debugMode? | CSSInclude | Direct file paths |

### Example (Scala)

```scala
object IncludesFactory {
  case class AssetConfig(
    version: String,
    debugMode: Boolean = false
  )

  val PASTE_CORE = Seq("paste", "paste.dom", "paste.event", "paste.util")
  val PASTE_UI = Seq("paste.ui.heroscroll", "paste.ui.stickynav", "paste.ui.smoothscroll")

  def forPasteJam(
    config: AssetConfig,
    additionalModules: Seq[String] = Seq.empty,
    moduleVersions: Map[String, String] = Map.empty
  ): JSInclude = {
    JSInclude(
      debugMode = config.debugMode,
      jamModules = PASTE_CORE ++ PASTE_UI ++ additionalModules,
      jamVersion = config.version,
      jamModuleVersions = moduleVersions
    )
  }
}
```

### Output

The JAM path shape is owned by the JAM server and stated in
[`view_models/includes.md`](../view_models/includes.md). An application that
loads a `paste-assetgraph` manifest gets the composed path (and per-module
versions) from the Manifest runtime; a factory built from static config emits the
same shape keyed by the asset build version. Format:
`/paste/{version}/{module+version~...}.min.js`

- **Timestamp**: Unix epoch seconds (max of all modules' timestamps)
- **Modules**: `module+vN.0` format, `~` (tilde) separated (Pekko HTTP rejects commas in path segments)
- **Sorted**: Modules are sorted alphabetically

```html
<!-- JAM URL: /paste/{timestamp}/{module+vN.0~module+vN.0~...}.min.js -->
<script src="/paste/1770465408/paste+v1.0~paste.dom+v1.0~paste.event+v1.0~paste.ui.heroscroll+v1.0~paste.ui.smoothscroll+v1.0~paste.ui.stickynav+v1.0~paste.util+v1.0.min.js" defer></script>
```

> **Compatibility:** an earlier `paste-surface-scala` `JSInclude.jamUrl` inserted a
> second path segment (`/paste/{version}/{checksum}/{modules}.min.js`). The server
> reads everything after the version segment as the module list, so that shape
> silently dropped the first module from the response. Implementations MUST emit a
> single version segment.
