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

Creates direct asset includes and JAM events, aggregating module names.

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `forPasteJam` | additionalModules? | Jam | Paste core + UI modules |
| `forForms` | — | Jam | Paste core + form modules |
| `forCssJam` | modules | Jam | CSS modules |
| `forDirectJS` | paths, debugMode? | JSInclude | Direct file paths |
| `forDirectCSS` | paths, debugMode? | CSSInclude | Direct file paths |

### Example (Scala)

```scala
object IncludesFactory {
  val PASTE_CORE = Seq("paste", "paste.dom", "paste.event", "paste.util")
  val PASTE_UI = Seq("paste.ui.heroscroll", "paste.ui.stickynav", "paste.ui.smoothscroll")
  val PASTE_FORMS = Seq("paste.ui.autogrow")

  def forPasteJam(additionalModules: Seq[String] = Seq.empty): Jam =
    Jam(js = PASTE_CORE ++ PASTE_UI ++ additionalModules)

  def forForms(): Jam =
    Jam(js = PASTE_CORE ++ PASTE_FORMS)

  def forCssJam(modules: Seq[String]): Jam =
    Jam(css = modules)

  def forDirectJS(paths: Seq[String], debugMode: Boolean = false): JSInclude =
    JSInclude(pasteIncludes = paths, debugMode = debugMode)

  def forDirectCSS(paths: Seq[String], debugMode: Boolean = false): CSSInclude =
    CSSInclude(pasteIncludes = paths, debugMode = debugMode)
}
```

### Output

Jams carry module names only — no versions, timestamps or composed URLs.
Rendering them is the per-render page object's job: the layout records the
jam and emits the page's dumps, and the markup shape and URL format are
owned by paste-assetgraph. The full contract is stated in
[`view_models/includes.md`](../view_models/includes.md).
