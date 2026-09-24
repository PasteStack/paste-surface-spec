# paste-surface-spec v0.4.0

**Date:** 2026-09-24

## Added

- Framework bindings of the rendering contract (`spec/rendering/rendering.md`):
  an implementation may ship a binding for a web framework that applies the
  selection and response rules and carries no rules of its own.
  `paste-surface-pekko` is the first, for Pekko HTTP in the Scala
  implementation.

# paste-surface-spec v0.3.0

**Date:** 2026-09-23

## Added

- Form component: view model, HTML output, and the `paste.ui.form` Element
  contract — how the submission is resolved, which submissions are left to the
  browser, and what happens to each kind of response.
- Rendering contract (`spec/rendering/rendering.md`): one view model rendered
  as a page, an IO reply fragment, or JSON from the request headers; IO reply
  fragment targets; the IO reply fragment envelope and the
  `paste.ui.io-reply-fragment-envelope` Element.
- Presenters link to the rendering contract for IO reply fragments.

## Changed

- `dataAttributes` names on Input, Button and Textarea must match
  `[a-z0-9][a-z0-9._-]*`.

# paste-surface-spec v0.2.1

**Date:** 2026-09-22

## Added

- ImageSequence `fit` and scroll window: `fit`, `scrollWindowStart` and
  `scrollWindowEnd` on the view model, the three data attributes a renderer
  emits for them, and their accepted values, defaults and bounds in the Element
  contract. The Element already honoured all three, so this also closes the gap
  between what the contract listed and what the Element reads.

## Changed

- The Element contract states that every ImageSequence attribute is optional
  and that an absent attribute takes the Element's default, so a hand-authored
  element works with any subset of them present. It also records that the view
  model's defaults are the Element's defaults, making the two authoring routes
  provably equivalent from the specification alone.
- The note on conditional attributes now separates the scroll endpoints and
  intro attributes, which appear only when supplied, from `-fit` and the
  `-scroll-window-*` attributes, which always render the effective value.

# paste-surface-spec v0.2.0

**Date:** 2026-09-22

## Added

- Marquee contract: the markup a renderer emits, the Element's states and fallback
  behaviour, and the browser checks that decide whether it is honoured.
- ImageSequence contract: the poster and configuration a renderer emits, what the
  Element honours — including the load-priority offset that orders competing
  sequences on a page — and the two attributes it does not honour yet, so nobody
  assumes an intro trigger or a working skip control.
- Logo contract, and the SectionNav sticky and scrollspy attributes with the exact
  unprefixed attribute names the Elements read.

## Fixed

- The JAM path contract stated two different shapes in two files. It now states the
  one the server implements: a single version segment, `~`-separated modules, and an
  optional per-module `+v{version}` suffix. A second path segment is refused,
  because the server reads it as part of the first module name.
- The Carousel entry described a `paste.ui.carousel` Element. No Element implements
  it; the entry is now explicitly a renderer-only markup contract.
- Component examples use synthetic, domain-neutral names.

## Licensing

- Licensed under the Apache License, Version 2.0 (`LICENSE`, `NOTICE.md`).

# paste-surface-spec v0.1.0

**Date:** 2026-02-07

## Initial Release

- Added OpenAPI spec and versioning documentation
- Corrected hero CSS class names in heroscroll spec (`.paste-ui-hero-*`)
- Added BDD feature files for component conventions
- Specs for: elements, layouts, view models, presenters, factories, config, includes
