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
