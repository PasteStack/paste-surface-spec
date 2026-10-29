# Smoothscroll

Optional `paste.ui.smoothscroll` enhances ordinary same-document anchors.
By default, plain anchor clicks use 500 ms cubic motion and immediately push the fragment
without native fragment navigation, synthetic hashchange or focus reassignment.
Back and Forward remain browser history operations.

`init()` discovers links without duplicate bindings. `scrollTo(element,
duration)` moves only; with the default motion, omitted duration is 500 ms
and zero lands immediately.
The older `scrollTo(id, verticalOffset)` accepts an id without `#`, uses the
section-nav height when offset is omitted, and pushes history at completion.

Existing `[data-paste-smoothscroll]` and `.paste-ui-section-nav` containers
delegate clicks, including links inserted later. These legacy clicks use the
section-nav offset and completion history. The Paste `smoothscroll` event
accepts `{newURL, verticalOffset, updateHash}`. Offset defaults to zero;
omitted updateHash defaults true; false suppresses the write. Boolean strings
retain their case-insensitive interpretation.

Wheel input cancels motion and any pending completion write. New movement
replaces unfinished movement; reduced motion lands immediately. Modified
clicks, downloads, foreign destinations, other browsing contexts and missing
targets stay native.

CSS smooth movement remains sufficient when these additional timing/history
contracts are not needed. Use native anchors when native target focus is
required; the default motion does not promise that side effect.

A legacy `smoothscroll` event with no payload resolves the current URL fragment and pushes at completion.

## Native motion

A page selects native motion with a root custom property:

```css
:root { --paste-smoothscroll-motion: native; }
```

The property must be in CSS that applies before the module runs: the module
reads the root's computed value once, when it initializes. Any other value,
none, or a host that cannot report computed style keeps the 500 ms cubic
motion described above, so existing pages are unchanged.

With native motion the module steps aside rather than reimplementing the
platform. Link clicks are not intercepted: the browser performs the same
fragment navigation it always does, so `scroll-behavior`, `scroll-margin-top`,
`scroll-padding-top`, reduced-motion rules, `:target` styling, focus and
scroll-restore all behave exactly as authored. `init()`, `scrollTo()` and the
`smoothscroll` event remain for programmatic callers:

- `scrollTo(element, duration)` calls `scrollIntoView()` and ignores the
  duration; CSS owns the motion.
- `scrollTo(id, verticalOffset)` and the event route through the platform's
  own fragment navigation when `updateHash` is not false — a real navigation,
  so the hash updates, `:target` applies, focus moves and history entries are
  native. `updateHash: false` calls `scrollIntoView()` only. `verticalOffset`
  is ignored; the offset is CSS-owned.

Because nothing is intercepted, no completion timing, focus or cancellation
machinery exists on this path: the browser owns the whole operation, exactly
as it does without JavaScript.
