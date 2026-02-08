# Component ViewModels

## Hero

Hero section with optional parallax and sticky nav targeting.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | - | Unique identifier for the hero section |
| `noContent` | boolean | no | `false` | If true, hero has no content slot |
| `showImage` | boolean | no | `false` | Show background image |
| `disableParallax` | boolean | no | `false` | Disable parallax effect |
| `stickyNavTarget` | boolean | no | `false` | Target for sticky nav scroll |

### Example (Scala)

```scala
case class Hero(
  name: String,
  noContent: Boolean = false,
  showImage: Boolean = false,
  disableParallax: Boolean = false,
  stickyNavTarget: Boolean = false
)
```

### HTML Output

```html
<section class="paste-ui-hero" 
         id="hero-{name}"
         data-paste-hero="{name}"
         data-paste-parallax="{!disableParallax}"
         data-paste-sticky-target="{stickyNavTarget}">
  <div class="paste-ui-hero-content">
    <!-- content slot -->
  </div>
</section>
```

---

## Address

Physical address display.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `street1` | string | yes | - | Primary street address |
| `street2` | string | no | `null` | Secondary street address |
| `locality` | string | yes | - | City/locality |
| `region` | string | yes | - | State/region code |
| `regionTitle` | string | no | `null` | Full region name |
| `postalCode` | string | yes | - | Postal/ZIP code |
| `countryCode` | string | yes | - | Country code (e.g., "USA") |

### Example (Scala)

```scala
case class Address(
  street1: String,
  locality: String,
  region: String,
  postalCode: String,
  countryCode: String,
  street2: Option[String] = None,
  regionTitle: Option[String] = None
)
```

### HTML Output

```html
<address class="paste-ui-address" itemscope itemtype="http://schema.org/PostalAddress">
  <span itemprop="streetAddress">{street1}</span>
  {street2 && <span itemprop="streetAddress">{street2}</span>}
  <span itemprop="addressLocality">{locality}</span>,
  <span itemprop="addressRegion" title="{regionTitle}">{region}</span>
  <span itemprop="postalCode">{postalCode}</span>
  <span itemprop="addressCountry">{countryCode}</span>
</address>
```

---

## Template Paths

| Component | Twirl | Jinja/Nunjucks |
|-----------|-------|----------------|
| Hero | `paste.surface.components.html.hero` | `paste/surface/components/hero.html` |
| Address | `paste.surface.components.html.address` | `paste/surface/components/address.html` |
