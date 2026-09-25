# Configuration

Surface configuration should be stored in resources and loaded at startup.

## Config File

**`resources/paste-surface.conf`** (HOCON format):

```hocon
paste.surface {
  site {
    name = "My Site"
    domain = "example.com"
    theme-color = "336699"
    default-description = "Site description"
    default-keywords = "keyword1, keyword2"
  }
  
  assets {
    debug-mode = false
    debug-mode = ${?PASTE_DEBUG}  # Override via env var
  }
}
```

## SurfaceConfig

```scala
case class SurfaceConfig(
  site: SiteConfig,
  assets: AssetConfig
)

// Debug mode applies to direct includes only; JAM-mode markup is decided by
// the paste-assetgraph build.
case class AssetConfig(debugMode: Boolean = false)

object SurfaceConfig {
  def load(): SurfaceConfig = {
    val config = ConfigFactory.load("paste-surface")
    fromTypesafeConfig(config)
  }
  
  def create(siteName: String, domainName: String, ...): SurfaceConfig
}
```

## Usage

```scala
// Load once at app startup
val config = SurfaceConfig.load()

// Use throughout app
val pageMeta = PageMetaFactory.forHomePage(config.site)
val jsIncludes = IncludesFactory.forPasteJam()
```

## Environment Variables

Override config values via environment:

| Env Var | Overrides | Description |
|---------|-----------|-------------|
| `PASTE_DEBUG` | `assets.debug-mode` | Enable debug (source) assets |
