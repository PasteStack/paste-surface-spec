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
val cssIncludes = IncludesFactory.forCssJam(Seq("site.theme"))
val jsIncludes = IncludesFactory.forPasteJam()
```

The app owns the paste-assetgraph `Paste` instance — created once, e.g.
`val assetgraph = Paste.fromClasspath()` — and hands each render a fresh
`assetgraph.page()`. In the page template the page arrives as a parameter and
goes to both include renderers, which record their jam events on it and dump
markup from it:

```scala
@(cssIncludes: CSSInclude, jsIncludes: JSInclude, page: PastePage)

@* headContent — records the css jam event, emits page.dumpCss() *@
@paste.surface.includes.html.css(cssIncludes, Some(page))

@* scriptIncludes — records the js jam event, emits page.dumpJs() *@
@paste.surface.includes.html.js(jsIncludes, Some(page))
```
