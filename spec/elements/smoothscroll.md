# Smoothscroll Element

Keyboard focus for native same-document fragment links. The browser owns the
navigation and the scroll; the page's CSS owns motion and clearance.

## Module

```
paste-elements/modules/smoothscroll/
└── smoothscroll.js
```

## JavaScript

**Module:** `paste.ui.smoothscroll`

**Dependencies:**
- `paste.dom`
- `paste.event`

There is no JavaScript API: no methods, no configuration object and no events.
The module binds once, when it is defined, to the markup already in the page.

### Activation

One click listener on each `[data-paste-smoothscroll]` element and on each
`.paste-ui-section-nav`. The attribute is a presence marker on a link
container; its value is not read, so `data-paste-smoothscroll="false"` is
still a declaration. To leave a link out, put it outside every declared
container.

```html
<nav data-paste-smoothscroll>
  <a href="#about">About</a>
  <a href="#contact">Contact</a>
</nav>

<section id="about">...</section>
<section id="contact">...</section>
```

### Behaviour

- The click is never prevented and history is never written. The browser
  updates the address, `:target`, history and `hashchange`, reveals a target
  inside a closed `<details>` or `hidden="until-found"` where it supports
  that, and scrolls by the page's CSS. A page loaded with a fragment, and Back
  and Forward, are entirely native.
- After a primary click on a same-document fragment link whose fragment
  resolves to an element, the module waits for the navigation to land — the
  `hashchange` for a new fragment, the next task for the fragment already
  current — and focuses the target with `preventScroll`. A fragment resolves
  as the browser resolves it: an element with that id, else the first
  `<a name>` with it, the raw fragment before its percent-decoded form. In a
  quirks-mode document some engines also match a name regardless of case (the
  first such anchor, even ahead of an exact match; Chromium for most letters,
  WebKit for ASCII letters only) and others do not; there a name that matches
  once each code point is folded to the lowercase of its uppercase form counts
  too, and focus follows the element the browser made its `:target`, provided
  its id or folded name answers the fragment. Chromium also matches a few pairs
  that fold differently (some ligatures, Greek letters with diacritics); those
  take no focus. A target that cannot take focus borrows `tabindex="-1"` until
  focus moves elsewhere; an authored `tabindex` is kept.
- No focus handling for: modified or non-primary clicks, `download` links,
  links opening another browsing context, links to another document
  (protocol, host, port, path or query differ), fragments naming no element,
  links inside `.paste-ui-section-nav-disclosure`, and clicks a later handler
  prevents. Back and Forward move no focus.

There are no `data-paste-smoothscroll-offset` or
`data-paste-smoothscroll-duration` attributes and no animation loop.

## CSS

Motion and clearance are the page's CSS, and they apply with JavaScript
disabled too:

```css
html { scroll-behavior: smooth; }
@media (prefers-reduced-motion: reduce) {
  html { scroll-behavior: auto; }
}
```

The `paste.ui.sectionnav` stylesheet supplies a zero-specificity
`scroll-margin-top` on `:where(:target)` that clears a fixed or sticky
section nav (see [sectionnav](sectionnav.md)). A page without it sets
`scroll-margin-top` on its targets or `scroll-padding-top` on the scrolling
element; a page with it that uses `scroll-padding-top` sets
`--paste-ui-section-nav-clearance: 0px`, since the two add.

A section that takes focus shows the user agent's focus ring wherever the
engine draws one (keyboard use everywhere, mouse clicks in some engines). A
page that wants no ring on borrowed focus can write:

```css
:where(:target[tabindex="-1"]:focus) { outline: none; }
```

## Example

```html
<nav data-paste-smoothscroll>
  <a href="#hero">Home</a>
  <a href="#about">About</a>
  <a href="#contact">Contact</a>
</nav>
<a href="/other-page">Other page</a>

<section id="hero">...</section>
<section id="about">...</section>
<section id="contact">...</section>
```

The link to `/other-page` sits outside the declared container; a link to
another document inside it would be left to the browser as well.
