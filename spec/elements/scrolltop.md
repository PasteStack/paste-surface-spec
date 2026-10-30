# Scrolltop

Optional `paste.ui.scrolltop` element: a declared anchor to the page the
visitor is already on returns to the top without a reload.

## Module

    paste-elements/modules/scrolltop/
    └── scrolltop.js        (JavaScript module paste.ui.scrolltop)

No stylesheet. Declaration is `data-paste-scrolltop` on the anchor itself:

```html
<a href="/" data-paste-scrolltop>…</a>
```

## Contract

A plain click on a declared anchor whose resolved URL equals the current
origin, pathname and search — with no fragment or a bare `#` — navigates to
the empty fragment. The browser performs the scroll to the top, records the
history entry and restores the scroll position on traversal exactly as any
fragment navigation does. The module then rewrites the entry's address
without the `#` (`history.replaceState`), so the address bar keeps the
page's clean URL.

Without JavaScript the same anchor navigates to the page and lands at the
top; the enhancement only removes the reload and the stray `#`.

Everything else stays native: modified or secondary clicks, downloads,
other targets, `referrerpolicy`, `ping`, `noreferrer`, different paths or
searches (`?x` is a real navigation), and any non-empty fragment. Fragments
stay native fragment navigation, or [smoothscroll](smoothscroll.md)'s inside
a declared container. The module calls neither smoothscroll nor scrollspy;
scrollspy reacts to the resulting scroll on its own.

CSS owns how the scroll looks on this path: `scroll-behavior` animates the
return to the top, `scroll-margin-top`/`scroll-padding-top` own clearance
and `prefers-reduced-motion` rules apply automatically.

## Surface

`Logo(scrollTop = true)` emits `data-paste-scrolltop` on its own anchor. See
the Logo scenarios in `features/components.feature`.
