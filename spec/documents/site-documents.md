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
| `uncrawlablePaths` | string list | no | `[]` | Path prefixes cooperative crawlers must not fetch — token-bearing, transient, or non-content namespaces. Each starts with `/`; literal prefixes only. |

### Invariants

A surface enforces these at model construction, not at request time:

- `canonicalOrigin` is an absolute `http`/`https` origin — scheme, host,
  and an optional port, with no userinfo, path, query, or fragment. The
  rendered documents concatenate paths onto it, so a value carrying
  components would emit URLs nobody declared. A trailing slash is
  normalized away — the value never ends with `/` when rendered.
- Every path in both lists is RFC 3986 path syntax: it begins with `/`,
  every raw character is an unreserved, sub-delim, `:` or `@` character
  or the `/` separator, and every `%` leads a complete two-hex-digit
  escape. Malformed escapes and illegal raw characters are refused — a
  path that fails here renders a broken URL no matter how the document
  is escaped.
- Reject literal or percent-encoded `.` and `..` path segments in both lists
  before overlap validation or rendering. Normalize percent escapes once and
  compare the same canonical paths that the documents emit.
- No `indexablePaths` entry may overlap an `uncrawlablePaths` entry.
  The comparison is on the path a crawler sees: encodings of
  unreserved characters decode before the test (so `/%63ontact` IS
  `/contact` to RFC 9309), and so do the operator escapes — a rule
  declaring `/path/foo-%24` matches the URI `/path/foo-$`, so both
  spellings compare in one form. Remaining escapes compare in
  canonical uppercase-hex form (an encoded `/` is not the separator
  it spells), and the test itself is a literal prefix —
  `Disallow: /contact` also covers `/contact/…` and `/contactform`.
- `uncrawlablePaths` entries are literal prefixes only: `*` and `$` are
  refused, because both are matching operators inside a Disallow rule —
  a declared `/contact*` would silently cover more than the overlap
  invariant verifies. A literal `*` or `$` path that must be excluded
  is declared percent-encoded (`%2A`, `%24`).

## robots.txt

Rendered deterministically:

```text
User-agent: *
{for each path in uncrawlablePaths:}Disallow: {path}

Sitemap: {canonicalOrigin}/sitemap.xml
```

No blanket `Allow` rule is emitted — a path matched by no rule is
allowed by default, and an unconditional `Allow: /` would tie on
length with a declared `Disallow: /` and win, silently unexcluding
the root. The `Sitemap:` line is derived, never declared — the origin
in the file is always the configured one, so an alternate host cannot
serve a stale pointer.

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
