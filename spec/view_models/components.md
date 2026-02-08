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

## SectionNav

In-page navigation bar with anchor links to page sections. Integrates with `paste.ui.smoothscroll` (auto-intercepts anchor clicks, updates URL via pushState) and `paste.ui.stickynav` (makes nav fixed on scroll past trigger point).

### ViewModel: NavItem

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `label` | string | yes | - | Display text |
| `targetId` | string | yes | - | Target section element ID (without `#`) |
| `cssClass` | string | no | `""` | Additional CSS class on the `<li>` |

### ViewModel: SectionNav

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `items` | Seq[NavItem] | yes | - | Navigation link items |
| `sticky` | boolean | no | `true` | Emit `data-paste-sticky-nav` attribute |
| `cssClass` | string | no | `""` | Additional CSS class on the `<nav>` |

### Example (Scala)

```scala
case class NavItem(
  label: String,
  targetId: String,
  cssClass: String = ""
)

case class SectionNav(
  items: Seq[NavItem],
  sticky: Boolean = true,
  cssClass: String = ""
)
```

### HTML Output

```html
<nav class="paste-ui-section-nav {cssClass}"
     data-paste-sticky-nav>
  <ul class="paste-ui-section-nav-items">
    <li class="paste-ui-section-nav-item {item.cssClass}">
      <a href="#{item.targetId}">{item.label}</a>
    </li>
  </ul>
</nav>
```

When `sticky=false`, the `data-paste-sticky-nav` attribute is omitted.

---

## Template Paths

| Component | Twirl | Jinja/Nunjucks |
|-----------|-------|----------------|
| Hero | `paste.surface.components.html.hero` | `paste/surface/components/hero.html` |
| Address | `paste.surface.components.html.address` | `paste/surface/components/address.html` |
| SectionNav | `paste.surface.components.html.sectionNav` | `paste/surface/components/section-nav.html` |
