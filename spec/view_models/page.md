# Page ViewModels

## PageMeta

Page-level metadata for SEO and HTML head content.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `siteName` | string | yes | - | Site name for meta tags |
| `title` | string | yes | - | Page title |
| `description` | string | yes | - | Meta description |
| `keywords` | string | no | `""` | Meta keywords (comma-separated) |
| `url` | string | no | `""` | Canonical URL |
| `themeColor` | string | no | `""` | Theme color for mobile browsers |
| `fbSiteType` | string | no | `null` | Facebook Open Graph site type |
| `domainName` | string | no | `""` | Domain name for structured data |

### Example (Scala)

```scala
case class PageMeta(
  siteName: String,
  title: String,
  description: String,
  keywords: String = "",
  url: String = "",
  themeColor: String = "",
  fbSiteType: Option[String] = None,
  domainName: String = ""
)
```

### Example (TypeScript)

```typescript
interface PageMeta {
  siteName: string;
  title: string;
  description: string;
  keywords?: string;
  url?: string;
  themeColor?: string;
  fbSiteType?: string;
  domainName?: string;
}
```

### HTML Output

```html
<head>
  <title>{title} — {siteName}</title>
  <meta name="description" content="{description}">
  <meta name="keywords" content="{keywords}">
  <meta name="theme-color" content="#{themeColor}">
  <link rel="canonical" href="{canonicalUrl}">
  
  <!-- Omit both URL tags when canonicalUrl is empty. -->
  <meta property="og:url" content="{canonicalUrl}">

  <!-- Open Graph -->
  <meta property="og:site_name" content="{siteName}">
  <meta property="og:title" content="{title}">
  <meta property="og:description" content="{description}">
  <meta property="og:type" content="{fbSiteType}">
</head>
```

### URL resolution

The authored `url` is retained. Both layouts derive one `canonicalUrl`: empty
stays empty; absolute http(s) URLs retain their scheme; scheme-relative
`//host/path` and legacy `host/path` use HTTPS. Both layouts emit the same
canonical link and `og:url`, omitting both for an empty value. The factory's
bare-domain default remains valid. Reject malformed or non-http(s) URLs,
credentials, and ports above 65535 at construction, including `copy`.
International hosts use punycode. Layouts must not prepend a scheme again.
