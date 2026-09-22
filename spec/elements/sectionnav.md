# SectionNav Element

In-page navigation bar for anchor-link scrolling between page sections.

## Module

    paste-elements/modules/sectionnav/
    ├── sectionnav.scss
    └── _variables.scss

No JavaScript file — behavior comes from `paste.ui.smoothscroll` (anchor link interception + pushState) and `paste.ui.stickynav` (sticky positioning on scroll).

## SCSS Variables

| Variable | Default Value | Source |
|----------|--------------|--------|
| `$paste-section-nav-height` | `$paste-stickynav-height` (50px) | stickynav vars |
| `$paste-section-nav-background` | `$paste-stickynav-background` (#fff) | stickynav vars |
| `$paste-section-nav-border-bottom` | `1px solid $paste-stickynav-border-color` | stickynav vars |
| `$paste-section-nav-link-padding` | `10px 25px` | local |
| `$paste-section-nav-link-color` | `#000` | local |
| `$paste-section-nav-link-hover-color` | `$paste-color-primary` (#0A56A2) | base vars |
| `$paste-section-nav-font-size` | `$paste-font-size-sm` (0.875rem) | base vars |
| `$paste-section-nav-max-width` | `1016px` | local |
| `$paste-section-nav-breakpoint` | `$paste-breakpoint-md` (768px) | base vars |

## CSS Classes

| Class | Description |
|-------|-------------|
| `.paste-ui-section-nav` | Nav container. Hidden below breakpoint, shown above. |
| `.paste-ui-section-nav-items` | `<ul>` — flexbox row, centered with max-width |
| `.paste-ui-section-nav-item` | `<li>` — individual nav item |

When sticky is active, `paste.ui.stickynav` also adds:

| Class | Description |
|-------|-------------|
| `.paste-ui-sticky` | Added on init (from stickynav module) |
| `.paste-ui-sticky-active` | Added when scrolled past trigger point (from stickynav module) |

## Data Attributes

| Attribute | Source Module | Description |
|-----------|-------------|-------------|
| `data-paste-sticky-nav` | `paste.ui.stickynav` | Enables sticky behavior. When no value, stickynav finds `[data-paste-sticky-target]` as trigger. |

## Responsive Behavior

- **Below `$paste-section-nav-breakpoint`** (default 768px): `display: none` — nav is hidden on mobile
- **Above breakpoint**: `display: block` — nav is visible

## Integration with Other Elements

    Hero section (data-paste-sticky-target="true")
        ↓ scroll past hero bottom edge
    SectionNav (data-paste-sticky-nav) → becomes fixed via paste-ui-sticky-active
        ↓ contains anchor links
    <a href="#section-id"> → auto-intercepted by paste.ui.smoothscroll
        ↓ click
    Smooth scroll animation → history.pushState("#section-id")

## Example HTML

```html
<section class="paste-ui-hero"
         data-paste-hero="main"
         data-paste-sticky-target="true">
  <div class="paste-ui-hero-content">
    <h1>Page Title</h1>
  </div>
</section>

<nav class="paste-ui-section-nav" data-paste-sticky-nav>
  <ul class="paste-ui-section-nav-items">
    <li class="paste-ui-section-nav-item"><a href="#about">About</a></li>
    <li class="paste-ui-section-nav-item"><a href="#services">Services</a></li>
    <li class="paste-ui-section-nav-item"><a href="#contact">Contact</a></li>
  </ul>
</nav>

<section id="about">...</section>
<section id="services">...</section>
<section id="contact">...</section>
```

## Surface Component Usage

```scala
@paste.surface.components.html.sectionNav(SectionNav(
  items = Seq(
    NavItem("About", "about"),
    NavItem("Services", "services"),
    NavItem("Contact", "contact")
  )
))
```
