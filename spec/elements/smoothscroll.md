# Smoothscroll

Optional `paste.ui.smoothscroll` moves declared same-document anchors, as the
original Jawbone module did. A `data-paste-smoothscroll` container — a
`SectionNav(smoothscroll = true)` declares it on its own `<nav>` — delegates
its links' clicks, including links inserted later, and moves them with
500 ms cubic motion instead of the native fragment scroll, pushing the
fragment at completion with no synthetic hashchange. Any other link, an
undeclared section nav's included, stays native. Back and Forward remain
browser history operations.

`init()` discovers containers without duplicate bindings.
`scrollTo(element, duration)` moves only; with the default motion, omitted
duration is 500 ms and zero lands immediately. The older
`scrollTo(id, verticalOffset)` accepts an id without `#` and pushes history
at completion. The Paste `smoothscroll` event accepts
`{newURL, verticalOffset, updateHash}`: an omitted or undefined offset is no
offset; omitted updateHash defaults true; false suppresses the write.
Boolean strings retain their case-insensitive interpretation. An event with
no payload resolves the current URL fragment.

Without an explicit offset, movement aims at the clearance native fragment
navigation keeps — the target's `scroll-margin-top` plus the root's
`scroll-padding-top` (a percentage is of the viewport) — or, when it writes
the fragment and the page declares neither, at the section nav's:
`--paste-ui-section-nav-clearance` resolved as a length when the root sets
it, else the first section nav's box. The push runs from the scroll
position the movement started from, a movement it replaced included, so
Back returns there, and a fragment the address already names is not pushed
again.

Once the fragment is written, a same-address `location.replace()` runs the
platform's own fragment steps: focus, the sequential focus navigation
starting point and `:target` follow as with native navigation, and the
platform's scroll to the fragment is the landing, so a `:target`-only
clearance holds; an explicit offset is held over it. It adds no history
entry and no hashchange; Chromium and WebKit fire popstate, and Firefox then
reports the entry's `history.state` as `null`. Focus the visitor moved
during the motion stays theirs, and `:target` then does not follow.

Wheel input stops motion where it is and cancels any pending completion
write; a native navigation, or one that moves the document, supersedes it.
New movement replaces unfinished movement; reduced motion lands
immediately. Modified clicks, downloads, foreign destinations, other
browsing contexts, missing targets, a declared disclosure nav's toggles and
a section chosen from its open panel stay native.

CSS smooth movement remains sufficient when these additional timing and
history contracts are not needed.

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
