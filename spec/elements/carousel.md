# Carousel

`paste.ui.carousel` restores the original discrete-paging carousel. Its native baseline is
ordinary authored slide content; JavaScript adds discrete paging without
cloning content. Root `.paste-ui-carousel` contains `.paste-ui-carousel-wrap`
and `.paste-ui-carousel-items` with direct `.paste-ui-carousel-item` children.

| Declaration | Behavior |
| --- | --- |
| `data-paste-carousel-name` | Named instance on `paste.ui.carousel`; absent/empty uses a GUID |
| `data-paste-carousel-autocycle` | Millisecond interval, 1–2147483647; absent/0 disables; empty/true retains the original 5000 ms |
| `data-paste-carousel-indicate` | Numbered page buttons |
| `data-paste-carousel-count` | Current/total page counter |
| `data-paste-carousel-slide-width="variable"` | Equal authored slide widths; otherwise one full-width slide per page |
| `data-paste-carousel-controlsparent` | Literal id of the arrow/pause controls container; absent/missing uses the root |
| `data-paste-carousel-animation-enabled` | Reflect actual left transitions as `.paste-ui-carousel-animating` |
| `data-paste-carousel-broadcast-moves` | Original `carouselMove` event |
| `data-paste-carousel-previous-label`, `-next-label`, `-pause-label` | Control text; defaults Previous, Next, Pause |

Instances retain `goTo(index, force, skipAnimation)`, `register(object)` and
`dispose()`, plus `el`, `wrapper`, `guid`, `current`, `type`, `total`, `slides`,
`carouselName` and `autoCycleInterval`. `current` is the zero-based page;
`total` remains the original slide count. `goTo` clamps finite indexes and
returns false for an unchanged/disposed/invalid request and undefined after a handled move, matching the
original. A duplicate authored
name leaves the later carousel static rather than replacing the first instance.

Initialization waits for assets to finish loading, including when this module
arrives after document completion. `carouselsBuilt` fires after discovery.
Optional `carouselMove` fires for a non-forced move with the instance payload.
These retain Paste Event's original document dispatch target for a window
context; subscribe on document. No analytics dependency remains.

Pointer movement retains the original directional thresholds: over 125 px for
viewports at most 600 px, otherwise over 300 px, once per gesture. Vertical
motion remains native. Resize measurements support full and equal-variable
slide widths; zero-width/hidden roots do not create invalid page arithmetic.

Generated controls are native buttons with type=button and boundary disabled
state; the original arrows were already buttons, now with explicit type and
text labels. Indicators and counters remain direct children of the root even
when arrows use an external controls container. Indicator list items retain
`.paste-ui-carousel-indicator-item` and its `-active` class; the nested button
uses `.paste-ui-carousel-indicator-button`. The counter retains separate
`-counter-current`, `-counter-divider` and `-counter-total` spans under
`.paste-ui-carousel-counter` for styling. They count pages, fixing the original
multi-slide mode mismatch. Auto-cycle includes a pause button, pauses during hover/focus,
including a separate controls container, pauses while the document is hidden,
and respects reduced motion. Off-page slides become inert; disposal restores
their authored inert state. Disposal cancels scheduled frames/timers,
observers, listeners and generated controls, and restores authored positioning.

The old `events`, `resizeSub` and `broadcastEvent` fields were internal cleanup
handles exposed on instances. Cleanup is now private so observer-backed resize
and complete disposal share one owner; callers use the retained `dispose()`
and document events. This is an explicit implementation-field change, not a
promise of source compatibility with arbitrary instance mutation.

`modules/carousel/_mixin.scss` exports `paste-ui-carousel($duration: .35s,
$easing: ease)` without emitting CSS on import. The default stylesheet applies
it under `.paste-ui-carousel`. Full and variable modes share the same authored
markup. Only the enhanced state clips the track; without JS the slides remain
available. Reduced motion disables the transition.
