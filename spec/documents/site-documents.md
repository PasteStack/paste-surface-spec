# Site Documents

The origin-level documents every paste site answers: `robots.txt` and
`sitemap.xml`. They are rendered from a declared model, never shipped as
static files — a checked-in `sitemap.xml` drifts from the routes, and a
checked-in `robots.txt` hardcodes a host a preview or local response would
then serve as fact.

The spec defines the contract; each language surface renders it; the site
supplies only the model — its origin, its public page inventory, and its
crawl policy.

## Endpoints

| Path | Content type | Source |
|------|--------------|--------|
| `/robots.txt` | `text/plain; charset=UTF-8` | `SiteDocuments.robotsTxt` |
| `/sitemap.xml` | `text/xml; charset=UTF-8` | `SiteDocuments.sitemapXml` |

Both are served under the site's baseline response headers; the binding
does not set or replace them.

## SiteDocuments

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `canonicalOrigin` | string | yes | — | Absolute `http`/`https` origin the documents advertise — scheme and host, no trailing slash. Names where the site should be indexed from, independent of which host answered. |
| `indexablePaths` | string list | yes | — | Paths the site wants indexed, each starting with `/`. Order is preserved in the sitemap. |
| `uncrawlablePaths` | string list | no | `[]` | Path prefixes cooperative crawlers must not fetch — token-bearing, transient, or non-content namespaces. Each starts with `/`. |

### Invariants

A surface enforces these at model construction, not at request time:

- `canonicalOrigin` parses as an absolute URI whose scheme is `http` or
  `https` and whose host is non-empty. A leading or trailing slash is
  normalized away — the value never ends with `/` when rendered.
- Every path in both lists begins with `/`.
- No `indexablePaths` entry may begin with an `uncrawlablePaths` entry.
  RFC 9309 matching is literal path-prefix — `Disallow: /contact` also
  covers `/contact/…` and `/contactform` — so the overlap check is a
  `startsWith`, not a segment match.

## robots.txt

Rendered deterministically:

```text
User-agent: *
Allow: /
{for each path in uncrawlablePaths:}Disallow: {path}

Sitemap: {canonicalOrigin}/sitemap.xml
```

The `Sitemap:` line is derived, never declared — the origin in the file is
always the configured one, so an alternate host cannot serve a stale
pointer.

## sitemap.xml

Rendered deterministically:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>{canonicalOrigin}{path}</loc></url>
  …
</urlset>
```

- One `<url>` per `indexablePaths` entry, in order.
- `<loc>` text is XML-escaped (`&`, `<`, `>`, `"`, `'`).
- No `lastmod` is emitted unless the model is later extended with honest
  per-page content dates — stamping a render time trains crawlers to
  ignore the field.

## Site content pages

Conventions rather than rendered documents: a paste site SHOULD answer
`/privacy` and `/terms` as rendered pages when it collects personal data
or publishes terms. Their copy is site-owned — legal text is never
surface content — so they enter `indexablePaths` like any other page.

### Example (Scala)

```scala
final case class SiteDocuments(
  canonicalOrigin: String,
  indexablePaths: Seq[String],
  uncrawlablePaths: Seq[String] = Seq.empty
) {
  val robotsTxt: String = …
  val sitemapXml: String = …
}
```

```scala
val documents = SiteDocuments(
  canonicalOrigin = config.canonicalOrigin,   // e.g. https://{site.domain}
  indexablePaths = Seq("/", "/privacy", "/terms"),
  uncrawlablePaths = Seq("/contact")
)
```

### Example (TypeScript)

```typescript
interface SiteDocuments {
  canonicalOrigin: string;
  indexablePaths: string[];
  uncrawlablePaths?: string[];
}
```
