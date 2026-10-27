# Presenters

Presenters are **OPTIONAL**. They orchestrate complex pages and enable JSON/HTML responses.

## When to Use Presenters

| Scenario | Use Presenter? |
|----------|----------------|
| Simple static site | No — use ViewModels directly in templates |
| Site with JSON API | Yes — `present()` for HTML, `presentAsJson(encoder)` for API |
| AJAX partials | Yes — render the same view model as an [IO reply fragment](../rendering/rendering.md) |
| Shared logic across routes | Yes — centralize in presenter |
| Testable presentation | Yes — unit test presenters |

## Rendering

One view model renders as a full page, an IO reply fragment, or JSON, chosen
from the request headers; see
[Rendering a View Model](../rendering/rendering.md). The IO reply fragment is
what `paste.ui.form.form_html` swaps into its target on a background submit, so a
presenter that re-renders after a failed submit needs no separate partial
template.

## PagePresenter (Base)

```scala
trait PagePresenter[T] {
  def present(): T
  def presentAsJson(encoder: ViewModelJson[T]): String
}
```

`presentAsJson` takes a `ViewModelJson[T]` encoder supplied by the host — the
library does not choose a JSON serializer. The legacy no-arg
`presentAsJson()` is deprecated and throws; migrate by passing an encoder.

## PageViewModel

Standard page data.

```scala
case class PageViewModel(
  pageMeta: PageMeta,
  cssIncludes: CSSInclude,
  jsIncludes: JSInclude,
  jam: Jam = Jam()
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
  jsIncludes: JSInclude,
  jam: Jam = Jam()
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
      jsIncludes = JSInclude(),
      jam = IncludesFactory.forPasteJam(customModules)
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

// JSON response — the host supplies the encoder
def homeJson(encoder: ViewModelJson[HomePageViewModel]) = {
  val json = new HomePagePresenter(config.site, config.assets).presentAsJson(encoder)
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
