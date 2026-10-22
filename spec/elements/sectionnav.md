# SectionNav Element

In-page navigation bar of fragment links between page sections, with an
optional CSS-only disclosure on narrow viewports.

## Module

    paste-elements/modules/sectionnav/
    ├── sectionnav.scss     (stylesheet module paste.ui.sectionnav)
    └── _mixin.scss         (mixin paste-ui-sectionnav)

No JavaScript file. Every link is an ordinary fragment link the browser
navigates natively. Optional Elements add to it without replacing that:
`paste.ui.smoothscroll` moves keyboard focus to the target after the
navigation lands, `paste.ui.scrollspy` marks the current section's item, and
`paste.ui.stickynav` writes the class a page keys its stuck presentation on.

## Mixin parameters

`@include paste-ui-sectionnav(...)`; `sectionnav.scss` includes it with the
defaults.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `$height` | `50px` | Height of the item row |
| `$background` | `#fff` | Nav and narrow panel background |
| `$border-bottom` | `1px solid rgba(0, 0, 0, 0.1)` | Nav bottom border |
| `$link-padding` | `10px 25px` | Link padding |
| `$link-color` | `#000` | Link color |
| `$link-hover-color` | `#0A56A2` | Link hover color |
| `$font-size` | `0.875rem` | Link font size |
| `$max-width` | `1016px` | Item row maximum width |
| `$breakpoint` | `768px` | Width at which the nav shows as a row |
| `$target-clearance` | `auto` | How far below the viewport top a fragment target lands; see Target clearance |

## CSS Classes

| Class | Description |
|-------|-------------|
| `.paste-ui-section-nav` | Nav container. Hidden below `$breakpoint`, shown at and above it; a disclosure nav shows at every width. |
| `.paste-ui-section-nav-items` | `<ul>` — flex row, centered within `$max-width` |
| `.paste-ui-section-nav-item` | `<li>` — one item |
| `.paste-ui-section-nav-link` | The item's link |
| `.paste-ui-section-nav-disclosure` | On the nav: opts into the narrow-viewport disclosure |
| `.paste-ui-section-nav-panel` | The disclosure panel; it carries the panel id and opens while it is the `:target` |
| `.paste-ui-section-nav-toggle` | Open and close links; `-open` and `-close` select which |
| `.paste-ui-section-nav-toggle-icon` | Decorative icon inside a toggle |
| `.paste-ui-visually-hidden` | Accessible text kept out of view |

## Target clearance

The mixin emits a zero-specificity rule for fragment targets, and for the hero
a hash click last scrolled to that has no id (heroscroll reaches it by
`scrollIntoView`, not as a target, and marks it `paste-ui-hero-destination`
until the next hash click):

```css
:where(:target, .paste-ui-hero-destination) {
  scroll-margin-top: var(--paste-ui-section-nav-clearance, 51px);
}
```

`auto` is the nav's own box, `$height` plus the first width in
`$border-bottom` (51px with the defaults). The browser reads it whenever it
scrolls to a fragment — a link, or a page loaded with one — so a section
lands just below a fixed or sticky nav instead of under it. Back and Forward
restore each entry's own scroll position instead. Any `scroll-margin-top` the
page writes for its targets wins. When more fixed chrome sits above the
targets, such as a site header the nav sticks beneath, the page sets the
custom property to the total:

```css
:root { --paste-ui-section-nav-clearance: calc(3.5rem + 51px); }
```

A target's `scroll-margin-top` adds to the scroller's `scroll-padding-top`, so a
page that clears its chrome with `scroll-padding-top` sets the custom property
to `0px` (or passes `$target-clearance: null`), and the clearance is not
counted twice. `scroll-margin-top` also grows a scroll-snap area, so on a page
that snaps, the current target and the marked hero can rest the clearance lower
than their neighbours; a snapping page clears its chrome with
`scroll-padding-top` and zeroes the custom property.

`$target-clearance: null` leaves targets to the page; a length replaces
`auto`. Smooth motion is not part of the stylesheet: a page wanting it writes
`scroll-behavior` with a `prefers-reduced-motion` rule (see
[smoothscroll](smoothscroll.md)).

## Responsive Behavior

- **Below `$breakpoint`**: a plain nav is `display: none`. A disclosure nav
  shows its open link; the panel is a fixed overlay below the item row that
  opens while it is the `:target`, and
  `html:has(.paste-ui-section-nav-panel:target) { overflow: hidden }` locks
  page scroll while it is open where `:has()` is supported.
- **At and above `$breakpoint`**: the nav is `display: block` and the panel
  is `display: contents`, so the items show as the ordinary row.

## Disclosure

Disclosure state is the URL fragment. The panel carries the target id, the
open link targets `#<panelId>`, and the close link targets the open link's own
`#<panelId>-toggle` id, so both ids must be unique on the page. Every open,
close and section selection is a real fragment navigation in history; a
section link both navigates and closes the panel. There is no Escape or
click-outside dismissal. Click handlers must not intercept these links.

## Stuck presentation and active item

- `paste.ui.stickynav` reads `.sticky-nav-target`, not the nav: once the page
  scrolls to that element's slot (less the height of an optional fixed header
  `#_paste_ui_nav_wrap`) it adds `paste-fixed-subnav` to the root element.
  What changes while stuck is the page's CSS keyed on that class. It reads
  `data-sticky-min-width` from the target, else from `.paste-ui-section-nav`.
  The `data-paste-sticky-nav` attribute Surface emits is a marker no Element
  reads. See [stickynav](stickynav.md).
- `paste.ui.scrollspy` binds to `[data-paste-scrollspy]`, else
  `.paste-ui-section-nav`, and adds `active` to the parent of the current
  section's link; its stylesheet styles `.paste-ui-section-nav-item.active a`.
  It reads `data-spy-min-width` and `data-spy-touch` on the nav.

## Example HTML

```html
<nav class="paste-ui-section-nav" aria-label="Sections">
  <ul class="paste-ui-section-nav-items">
    <li class="paste-ui-section-nav-item"><a class="paste-ui-section-nav-link" href="#about">About</a></li>
    <li class="paste-ui-section-nav-item"><a class="paste-ui-section-nav-link" href="#services">Services</a></li>
    <li class="paste-ui-section-nav-item"><a class="paste-ui-section-nav-link" href="#contact">Contact</a></li>
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

`NavItem` also accepts an optional `href`, emitted verbatim instead of
`#` + `targetId` — for example `NavItem("About", "about", href = Some("/#about"))`
when the nav is rendered on a page that does not contain the target sections.
A link to another document navigates as an ordinary link: `paste.ui.smoothscroll`
gives it no focus handling and `paste.ui.scrollspy` selects only links whose
`href` starts with `#`. Surface renders no CSS, so the target clearance above
comes from the `paste.ui.sectionnav` stylesheet, and a page whose sticky nav
sits under a fixed header sets `--paste-ui-section-nav-clearance`.
