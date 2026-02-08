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
| `forPasteJam` | config, additionalModules? | JSInclude | Paste core + UI via JAM |
| `forForms` | config | JSInclude | Paste core + form modules |
| `forDirectJS` | paths, debugMode? | JSInclude | Direct file paths |
| `forDirectCSS` | paths, debugMode? | CSSInclude | Direct file paths |

### Example (Scala)

```scala
object IncludesFactory {
  case class AssetConfig(
    version: String,
    checksum: String,
    debugMode: Boolean = false
  )
  
  val PASTE_CORE = Seq("paste", "paste.dom", "paste.event", "paste.util")
  val PASTE_UI = Seq("paste.ui.heroscroll", "paste.ui.stickynav", "paste.ui.smoothscroll")
  
  def forPasteJam(config: AssetConfig, additionalModules: Seq[String] = Seq.empty): JSInclude = {
    JSInclude(
      debugMode = config.debugMode,
      jamModules = PASTE_CORE ++ PASTE_UI ++ additionalModules,
      jamVersion = config.version,
      jamChecksum = config.checksum
    )
  }
}
```

### Output

The `paste-assetgraph` Manifest runtime generates the actual JAM URL. Format: `/paste/{timestamp}/{module+version~...}.min.js`

- **Timestamp**: Unix epoch seconds (max of all modules' timestamps)
- **Modules**: `module+vN.0` format, `~` (tilde) separated (Pekko HTTP rejects commas in path segments)
- **Sorted**: Modules are sorted alphabetically

```html
<!-- JAM URL: /paste/{timestamp}/{module+vN.0~module+vN.0~...}.min.js -->
<script src="/paste/1770465408/paste+v1.0~paste.dom+v1.0~paste.event+v1.0~paste.ui.heroscroll+v1.0~paste.ui.smoothscroll+v1.0~paste.ui.stickynav+v1.0~paste.util+v1.0.min.js" defer></script>
```

> **Note:** `paste-surface-scala` `JSInclude.jamUrl` still uses the legacy format (`/paste/{version}/{checksum}/{modules}.min.js` with comma separator and bare module names). It should be migrated to use `paste-assetgraph` `Manifest.jamJsUrl` instead.
