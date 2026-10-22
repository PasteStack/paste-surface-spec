# Stickynav Element

Marks the page as stuck once it scrolls past a declared slot, so page CSS can
fix a sub-navigation in place.

## Module

```
paste-elements/modules/stickynav/
├── stickynav.js
└── stickynav.scss      (stylesheet module paste.ui.stickynav; carries no rules)
```

## JavaScript

**Module:** `paste.ui.stickynav`

**Dependencies:**
- `paste.dom`
- `paste.event`
- `paste.has`
- `paste.ui.utilities.animation-frame`

There are no methods. The module binds once, when it is defined.

### Activation

The first `.sticky-nav-target` element in the document. Optionally,
`#_paste_ui_nav_wrap` is a site header fixed or sticky at the top of the
viewport; its height is the offset the nav sticks at (0 without it). Without
a target the page keeps its baseline. No `data-paste-sticky-nav` or
`data-paste-stickynav` attribute is read.

### Behaviour

- When the scroll offset reaches the target's slot less the header's height,
  the module adds `paste-fixed-subnav` to the root element (the element
  `paste.dom.getDocumentBody()` returns: `<html>` in standards mode, `<body>`
  only in quirks mode); scrolling back above removes it.
- The slot is measured without inserting anything: the bottom edge of the
  nearest previous element sibling with an in-flow box, else the parent's
  top. Layout positions are read, so a transform on a sibling does not move
  the threshold. A target with no box of its own (for example
  `display: none` at a breakpoint) does not stick.
- The module never moves, clones or reparents content. What changes while
  stuck is page CSS keyed on the class, for example:

  ```css
  .fixed-nav-content { display: none; }
  .paste-fixed-subnav .fixed-nav-content {
    display: block;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
  }
  ```

- Measurement, the class write and the announcement run in one owned
  animation frame; resize, the document's load and the first scroll mark
  geometry dirty.
- Touch devices (`paste.has`) keep the baseline.

### Attributes

| Attribute | On | Description |
|-----------|----|-------------|
| `data-sticky-min-width` | the target, else `.paste-ui-section-nav` | Whole number of CSS pixels, digits only, read untrimmed; at or below it the nav never sticks, and narrowing to it while stuck unsticks. `"0"` is honored; any other spelling (such as `"768px"`) is ignored and the next source, or 0, applies |

### Events

`navStuck` and `navUnstuck` are kept from the original stickynav as
documented exceptions to the declarative-only rule. They are paste events
dispatched on the document with the target element as payload, fire only on
the transition and only after the class write, so a listener always observes
the class it is told about.

## SCSS

The stylesheet module carries no rules and the module has no mixin or SCSS
variables; the stuck presentation is the page's CSS.

## Example

```html
<header id="_paste_ui_nav_wrap">...</header>
<section class="paste-ui-hero">...</section>
<nav class="paste-ui-section-nav sticky-nav-target" data-sticky-min-width="768">
  <ul class="paste-ui-section-nav-items">
    <li class="paste-ui-section-nav-item"><a href="#about">About</a></li>
    <li class="paste-ui-section-nav-item"><a href="#contact">Contact</a></li>
  </ul>
</nav>
```

```css
#_paste_ui_nav_wrap { position: fixed; top: 0; left: 0; right: 0; height: 3.5rem; }
.paste-fixed-subnav .sticky-nav-target { position: fixed; top: 3.5rem; left: 0; right: 0; }
```

Sections the nav links to clear it through the `paste.ui.sectionnav`
stylesheet's `--paste-ui-section-nav-clearance` (see
[sectionnav](sectionnav.md)); with the header above, the total here is
`calc(3.5rem + 51px)`.

## Surface

Surface's `Hero(stickyNavTarget = true)` puts the `sticky-nav-target` class on
the hero section, so the threshold is the hero's slot; `SectionNav(sticky =
true)` emits `data-paste-sticky-nav`, a marker the module does not read, and
`stickyMinWidth` emits `data-sticky-min-width` on the nav.
