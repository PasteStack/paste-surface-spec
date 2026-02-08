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
  
  val PASTE_CORE = Seq("paste", "paste.dom", "paste.event")
  val PASTE_UI = Seq("paste.ui.heroscroll", "paste.ui.stickynav")
  
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

```html
<!-- JAM URL: /paste/{version}/{checksum}/{modules}.min.js -->
<script src="/paste/2025.02.02/abc123/paste,paste.dom,paste.event,paste.ui.heroscroll.min.js" defer></script>
```
