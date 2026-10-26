# Stickynav Element

Marks each declared nav active after a declared target. CSS owns positioning.
For ordinary sticking at the nav's own slot, use CSS `position: sticky`.

## JavaScript

Module: `paste.ui.stickynav`. Dependencies: `paste.dom`, `paste.event`,
`paste.ui.utilities.animation-frame`. Initializes on DOM readiness. `init()` discovers new navs without duplicate
bindings; `updateSticky()` refreshes current navs synchronously.

Each `[data-paste-sticky-nav]` declares a nav. A nonempty value is a CSS selector
for its target; an empty value uses the first `[data-paste-sticky-target]`.
An absent target uses the nav’s initial document position. Invalid selectors
and self targets leave it alone. A target must remain a
stable in-flow box when the nav changes class.

Valid navs receive `paste-ui-sticky`. When the target bottom reaches the viewport
top they receive `paste-ui-sticky-active`; above that threshold it is removed.
Hidden targets remain inactive. Scroll, resize, load and optional ResizeObserver
reports share one phased frame: target reads precede class changes. Touch is
allowed. Links, navigation and history remain native.

`data-sticky-min-width` on each nav accepts digits only, untrimmed. At or below
that width it stays inactive. Invalid or absent values mean 0.

The stylesheet module `paste.ui.stickynav` contains no rules. Authors own any
fixed header offset and the space left by a fixed nav; the module measures no
header ids, infers no sibling slot and moves no content.

```html
<section data-paste-sticky-target>Hero content</section>
<div class="nav-slot">
  <nav class="sections" data-paste-sticky-nav data-sticky-min-width="768">
    <a href="#about">About</a>
  </nav>
</div>
<section id="about">About</section>
```

```css
.nav-slot, .sections { height: 3rem; }
.sections.paste-ui-sticky-active { position: fixed; top: 0; left: 0; right: 0; }
#about { scroll-margin-top: 3rem; }
```

## Surface and migration

`Hero(stickyNavTarget = true)` emits `data-paste-sticky-target`.
`SectionNav(sticky = true)` emits the empty `data-paste-sticky-nav` marker and
uses that first target; `stickyMinWidth` stays on the nav. Hand-authored navs
can name another target explicitly through the marker value.

Replace old `.sticky-nav-target` activation and root `.paste-fixed-subnav`
styles with the declarations and per-nav class above. `navStuck`/`navUnstuck`
and header-offset measurement are removed. This is an intentional return to
the supplied declared-target/per-nav contract, not the different historical
root-event variant. Without a target, the supplied original’s own-position threshold is retained.
