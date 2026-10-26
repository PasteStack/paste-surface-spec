# Smoothscroll

Optional `paste.ui.smoothscroll` enhances ordinary same-document anchors.
Plain anchor clicks use 500 ms cubic motion and immediately push the fragment
without native fragment navigation, synthetic hashchange or focus reassignment.
Back and Forward remain browser history operations.

`init()` discovers links without duplicate bindings. `scrollTo(element,
duration)` moves only; omitted duration is 500 ms and zero lands immediately.
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
required; the enhancement does not promise that side effect.

A legacy `smoothscroll` event with no payload resolves the current URL fragment and pushes at completion.
