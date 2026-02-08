# Presenters

Presenters are **OPTIONAL**. They orchestrate complex pages and enable JSON/HTML responses.

## When to Use Presenters

| Scenario | Use Presenter? |
|----------|----------------|
| Simple static site | No — use ViewModels directly in templates |
| Site with JSON API | Yes — `present()` for HTML, `presentAsJson()` for API |
| AJAX partials | Yes — return partial HTML |
| Shared logic across routes | Yes — centralize in presenter |
| Testable presentation | Yes — unit test presenters |

## PagePresenter (Base)

```scala
trait PagePresenter[T] {
  def present(): T
  def presentAsJson(): String  // Override for proper JSON
}
```

## PageViewModel

Standard page data.

```scala
case class PageViewModel(
  pageMeta: PageMeta,
  cssIncludes: CSSInclude,
  jsIncludes: JSInclude
)
```

## HomePageViewModel

Home page with heroes.

```scala
case class HomePageViewModel(
  pageMeta: PageMeta,
  mainHero: Hero,
  sections: Seq[Hero],
  cssIncludes: CSSInclude,
  jsIncludes: JSInclude
)
```

## Example: HomePagePresenter

```scala
class HomePagePresenter(
  siteConfig: SiteConfig,
  assetConfig: AssetConfig,
  customModules: Seq[String] = Seq.empty
) extends PagePresenter[HomePageViewModel] {
  
  override def present(): HomePageViewModel = {
    HomePageViewModel(
      pageMeta = PageMetaFactory.forHomePage(siteConfig),
      mainHero = HeroFactory.forHomePage("main"),
      sections = Seq(HeroFactory.forSection("features")),
      cssIncludes = IncludesFactory.forDirectCSS(Seq("/css/main.css")),
      jsIncludes = IncludesFactory.forPasteJam(assetConfig, customModules)
    )
  }
}
```

## Usage in Route

```scala
// HTML response
def home() = {
  val vm = new HomePagePresenter(config.site, config.assets).present()
  Ok(views.html.home(vm))
}

// JSON response
def homeJson() = {
  val json = new HomePagePresenter(config.site, config.assets).presentAsJson()
  Ok(json).as("application/json")
}
```

## Simple Sites (No Presenter)

For a site whose pages need no orchestration, skip presenters entirely:

```scala
// In Twirl template directly:
@paste.surface.components.html.hero(Hero("main", showImage = true)) {
  <h1>Welcome</h1>
}
```
