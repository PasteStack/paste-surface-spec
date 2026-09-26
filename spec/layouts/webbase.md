# Web Base Layout

The base HTML structure for all pages.

## Structure

```
webbase(pageMeta, headContent, navContent, mainContent, footerContent, scriptIncludes)
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pageMeta` | PageMeta | yes | Page metadata (SEO, title, etc.) |
| `headContent` | HTML | no | Additional head content (CSS includes) |
| `navContent` | HTML | no | Navigation content |
| `mainContent` | HTML | yes | Main page content |
| `footerContent` | HTML | no | Footer content |
| `scriptIncludes` | HTML | no | Script includes (JS) |

## HTML Output

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- PageMeta -->
  <title>{pageMeta.title} — {pageMeta.siteName}</title>
  <meta name="description" content="{pageMeta.description}">
  <meta name="keywords" content="{pageMeta.keywords}">
  <meta name="theme-color" content="#{pageMeta.themeColor}">
  <link rel="canonical" href="https://{pageMeta.url}">
  
  <!-- Open Graph -->
  <meta property="og:site_name" content="{pageMeta.siteName}">
  <meta property="og:title" content="{pageMeta.title}">
  <meta property="og:description" content="{pageMeta.description}">
  
  <!-- Head Content (CSS) -->
  {headContent}
</head>
<body>
  <header class="paste-ui-header">
    {navContent}
  </header>
  
  <main class="paste-ui-main">
    {mainContent}
  </main>
  
  <footer class="paste-ui-footer">
    {footerContent}
  </footer>
  
  <!-- Script Includes -->
  {scriptIncludes}
</body>
</html>
```

## CSS Class Conventions

| Class | Element | Description |
|-------|---------|-------------|
| `paste-ui-header` | `<header>` | Page header container |
| `paste-ui-main` | `<main>` | Main content container |
| `paste-ui-footer` | `<footer>` | Page footer container |
| `paste-ui-hero` | `<section>` | Hero section |
| `paste-ui-address` | `<address>` | Address block |

## Template Paths

| Layout | Twirl | Jinja/Nunjucks |
|--------|-------|----------------|
| webbase | `paste.surface.layouts.html.webbase` | `paste/surface/layouts/webbase.html` |

## Usage Example (Twirl)

```scala
@(mainContent: Html)

@paste.surface.layouts.html.webbase(
  PageMeta(
    siteName = "My Site",
    title = "Home",
    description = "Welcome to my site"
  )
) {
  @* headContent *@
  <link rel="stylesheet" href="/css/main.css">
} {
  @* navContent *@
  <nav>...</nav>
} {
  @* mainContent *@
  @mainContent
} {
  @* footerContent *@
  <p>&copy; 2025</p>
} {
  @* scriptIncludes *@
  <script src="/js/main.js"></script>
}
```

## Usage with Factories

```scala
// Load config from resources
val config = SurfaceConfig.load()

// Use factories for ViewModels
val pageMeta = PageMetaFactory.forHomePage(config.site)
val cssIncludes = IncludesFactory.forCssJam(Seq("site.theme"))   // a Jam
val jsIncludes = IncludesFactory.forDirectJS(Seq("/js/main.js"))
```

The JAM factories return `Jam` — the page's jam event (module names only).
Direct factories return `CSSInclude`/`JSInclude` — plain file tags.

## Usage with JAM

For JAM pages use the `jambase` layout instead: it carries the `Jam` and the
per-render paste-assetgraph page object, records the jam once, and emits the
CSS dump in `<head>` and the JS dump at the end of `<body>`:

```scala
@paste.surface.layouts.html.jambase(
  pageMeta,
  cssInclude = IncludesFactory.forDirectCSS(Seq("/css/main.css")),
  jsInclude = JSInclude(),
  page = Some(page),
  jam = IncludesFactory.forPasteJam()
) {
  @* headContent *@
} {
  @* headerContent *@
  <nav>...</nav>
} {
  @* mainContent *@
  @mainContent
} {
  @* footerContent *@
  <p>&copy; 2025</p>
} {
  @* footerScripts *@
}
```

The app owns the paste-assetgraph `Paste` instance — created once, e.g.
`val assetgraph = Paste.fromClasspath()` — and hands each render a fresh
`assetgraph.page()`. The layout records the jam on it (`page.jam(...)`),
emits `page.dump(AssetType.Css)` in the head and `page.dump(AssetType.Js)`
at the end of the body, then finishes.

`page.finish()` is the layout's last statement and renders nothing: the
library verifies every jammed module was dumped — jams are queued per type,
css per `media` — and a module still queued when finish runs fails the
render naming it rather than shipping a page that lost the tag. A failed
finish leaves the page open; repeated finishes return `""`.
