# paste-surface-spec v0.10.1

**Date:** 2026-10-28

## Changed

- Apache License 2.0 applied consistently: verbatim LICENSE text, NOTICE rename, Apache short header in every first-party source file, corrected license metadata.

---

# paste-surface-spec v0.10.0

**Date:** 2026-10-26

## Added

- `FormSubmission` contract: mutually exclusive `Native` (default),
  `Apply` (POST-only, the original JSON response/label flow) and `Html`
  choices; HTML consumers load `paste.ui.form.form_html` while ordinary
  validity remains `paste.ui.form.form_validity`.
- Shared fragment-transport contract in `spec/rendering/rendering.md`:
  `load` accepts `url`, `method`, `body`, `contentType` and `timeout`,
  with specified failure reasons and element-declared deadlines such as
  `data-paste-io-reply-fragment-timeout`.
- `LazyContent` renderer contract and independent caller-triggered lazy
  HTML loading.
- `spec/elements/select.md`: the generalized `paste.ui.select` with a
  native Select renderer and matching markup contract; native controls
  retain selection and submission.
- `spec/elements/original-enhancements.md` and
  `spec/elements/multistate.md`: contracts for the restored `paste.ui.*`
  elements and the direct multistate port — local selection, default,
  history and URI fixes, generated missing names/ids, radio-only
  dimensions and optional marked content panels.
- Carousel's original options contract, matching the restored Elements
  Carousel behavior.

## Changed

- Multistate rebased on the original source: an explicit state fragment
  clears omitted dimensions while ordinary anchors keep the current
  selection; CSS may provide the complete presentation while the module
  maintains history.
- Marquee durations serialize as plain decimal text so every accepted
  finite positive duration matches Elements' input grammar.
- Documented native validity markers, SectionNav's distinction between
  native fragment navigation and the default smoothscroll/pushState
  composition, explicit structural stylesheet composition, and named
  external library readiness through the existing core loader/JAM.

## Removed

- The mirrored-strip, automatic form-reset, snapshot-copying and queued
  reentrant-transition multistate contracts.
- The `paste.ui.io-reply-fragment-envelope` client contract and its
  public `apply` API: autosave owns its request and reply handling, and
  Surface's serializer and existing wire format remain accepted.

# paste-surface-spec v0.9.0

**Date:** 2026-10-22

## Added

- Image sequence contract (`spec/view_models/components.md`,
  `features/components.feature`): the frame, catalog, scroll-scrub,
  progressive-image and manifest shapes a conforming surface emits —
  declarative markup only, distinct representation sources per frame,
  `Option[BigDecimal]` scrub windows, container-mode attribute omission,
  and the sequenced-hero `data-hero-image-fixed` opt-out from legacy
  parallax.

## Changed

- Element specs (`spec/elements/`): autogrow, heroscroll, sectionnav,
  smoothscroll, stickynav and throttle restated against the hardened
  module behaviour — last-writer style ownership, untrusted observer
  records, terminal teardown, and stand-down to authored static
  presentation when observation is unavailable.
- Form field spec (`spec/components/formfield/form.md`): label–control
  association requires a non-empty control id, matching the surface's
  generated-id validation.

# paste-surface-spec v0.8.0

**Date:** 2026-10-01

## Added

- `NavItem.href` (`spec/view_models/components.md`,
  `spec/elements/sectionnav.md`, `features/components.feature`): an
  optional link emitted verbatim in place of the generated
  `#` + `targetId` fragment. SectionNav remains an in-page anchor nav;
  `href` covers navs rendered on pages that do not contain the target
  sections, where fragment-only links resolve as dead anchors. Verbatim
  links are outside `a[href^="#"]` interception, so smoothscroll and
  scrollspy leave them to ordinary navigation.

# paste-surface-spec v0.7.0

**Date:** 2026-09-30

## Added

- Reduced-motion poster fallback (`spec/view_models/components.md`,
  `features/components.feature`): a sequence model without responsive
  poster candidates still emits a reduced-motion source carrying the
  final poster ahead of the fallback image, so a no-motion reader gets
  the settled frame rather than the first.

## Changed

- Form replay contract (`spec/components/formfield/form.md`): the
  idempotency-key outcomes a page must distinguish are spelled out — a
  stored reply replays, a claimed key with no reply yet is still in
  flight, and an abandoned claim retries cleanly.

## Fixed

- Robots.txt matching rules (`spec/documents/site-documents.md`): path
  overlap is judged on percent-decoded literals, and a whole-site
  disallow carries no `Allow:` line.

# paste-surface-spec v0.6.0

**Date:** 2026-09-28

## Added

- Site documents contract (`spec/documents/site-documents.md`): a paste site
  renders `/robots.txt` and `/sitemap.xml` from a declared `SiteDocuments`
  model — canonical origin, indexable page inventory, and crawl-disallowed
  prefixes — instead of shipping static files that drift from the routes or
  hardcode a host. The spec pins the endpoint and content-type contract,
  the construction-time model invariants (absolute http(s) origin,
  slash-prefixed paths, no indexable path under a disallow prefix per RFC
  9309 literal-prefix matching), the derived `Sitemap:` line, no `lastmod`
  without honest dates, and the `/privacy` and `/terms` page convention.

# paste-surface-spec v0.5.0

**Date:** 2026-09-25

## Changed

- JAM rendering on includes (`spec/view_models/includes.md`): the layout
  records the jam once with `JamIncludes.record(jam, page)` and dumps per
  type — `JamIncludes.dump(AssetType.Css, page)` in `<head>` and
  `JamIncludes.dump(AssetType.Js, page)` at the end of `<body>`. One scoped
  dump emits `css`, `js` or `all`; `page.dump()` with no type renders the css
  markup first, then the js.
- Includes factories (`spec/view_model_factories/factories.md`) return `Jam`
  values carrying the css and js module lists instead of include view models.
- `CSSInclude` and `JSInclude` now describe plain `<link>`/`<script>` file
  includes only; their JAM fields were removed.

## Added

- Page finish (`spec/view_models/includes.md`, `spec/layouts/webbase.md`):
  root layouts end with `page.finish()`, which fails the render naming any
  jammed module that never reached a dump of its type. Includes remain
  partial renderers and must not finish; the call is idempotent so a
  host-side finish after the layout is safe.
- Hash-qualified asset URLs under the `jam.hash-urls` policy, and
  caller-supplied JSON encoding for presenters (`spec/presenters`).

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

- Form component: view model, HTML output, and the `paste.ui.form.form_validity` Element
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

- Licensed under the Apache License, Version 2.0 (`LICENSE`, `NOTICE`).

# paste-surface-spec v0.1.0

**Date:** 2026-02-07

## Initial Release

- Added OpenAPI spec and versioning documentation
- Corrected hero CSS class names in heroscroll spec (`.paste-ui-hero-*`)
- Added BDD feature files for component conventions
- Specs for: elements, layouts, view models, presenters, factories, config, includes
