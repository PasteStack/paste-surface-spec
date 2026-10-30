# Component ViewModels

## Hero

Hero section with optional parallax and sticky nav targeting.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | - | Unique identifier for the hero section |
| `noContent` | boolean | no | `false` | If true, hero has no content slot |
| `showImage` | boolean | no | `false` | Show background image |
| `disableParallax` | boolean | no | `false` | Disable parallax effect |
| `stickyNavTarget` | boolean | no | `false` | Target for sticky nav scroll |
| `imageSequence` | [ImageSequence](#imagesequence) | no | `None` | Render a scroll-driven image sequence as the hero's media |

### Example (Scala)

```scala
final case class Hero(
  name: String,
  noContent: Boolean = false,
  showImage: Boolean = false,
  disableParallax: Boolean = false,
  stickyNavTarget: Boolean = false,
  imageSequence: Option[ImageSequence] = None
)
```

Construction rejects an empty `name` or one carrying whitespace or a leading
`#` — the name becomes the section id, a fragment target resolved by exact id.
A hero carrying an `imageSequence` derives a `#{name}-image-catalog` selector
(and `#{name}-image-skip` with an intro skip), so its `name` must also be a
plain identifier (see the generated-selector rule
below). A null `imageSequence` option or a null sequence inside it is likewise
rejected at construction. Releases up to 0.8.0 validated no hero name and
`Hero` was not `final`; both are construction-time changes for existing
callers.

The ids a hero derives are reserved on the page: `{name}`,
`{name}-content-wrap` and `{name}-content`, `{name}-image` with an image or a
sequence, `{name}-image-catalog` with a sequence, and `{name}-image-skip`
with an intro that declares a skip. Surface validates their syntax, not their uniqueness.

An image sequence enhances the hero's existing media without replacing its
identity: the `<section>` itself carries the scrub declaration, and the
established `<i id="{name}-image" class="paste-ui-hero-image">` element stays
the image host and gains the sequence attributes; the sequence's `cssClass`
joins the section's classes, since the section is the scope root. The catalog
follows the host as its sibling; no wrapper claims the media id and no second
image layer competes for the pixels. With an intro that declares a skip, the
skip control is the section's first child, ahead of the host and the content: the hero's first
tab stop, so focus the skip hands to the section continues into the content
instead of crossing it twice. The control is in the hero's normal flow until
the page positions it (Surface ships no CSS); without that rule a revealed
skip pushes the content down by its own height until the intro ends.
`paste-ui-hero-with-image` reflects declared media — `showImage` or an image sequence — and the parallax
attribute is omitted while a sequence reads scroll position itself. The host
declares `data-hero-image-fixed` so the parallax writer, which discovers the
image by class rather than by that attribute, leaves the sequence's frame
presentation alone. Under `disableParallax` the host keeps the
`paste-ui-hero-basicimage` class heroscroll never discovers, so no hero effect
runs over the sequence and `data-hero-image-fixed` is not emitted. The sequence's scrub subject defaults to the section
(the scope); a declared `scrub.subject` still wins.

### HTML Output

An ordinary hero:

```html
<section class="paste-ui-hero paste-ui-hero-with-image sticky-nav-target"
         id="{name}" tabindex="-1"
         data-paste-hero="{name}"
         data-paste-parallax="true"
         data-paste-sticky-target="true">
  <i id="{name}-image" class="paste-ui-hero-image"></i>
  <div id="{name}-content-wrap" class="paste-ui-hero-content-wrap">
    <div id="{name}-content" class="paste-ui-hero-content">
      <!-- content slot -->
    </div>
  </div>
</section>
```

A sequenced hero (`imageSequence = Some(...)`):

```html
<section class="paste-ui-hero paste-ui-hero-with-image"
         id="{name}" tabindex="-1"
         data-paste-hero="{name}"
         data-paste-scrollscrub
         data-scrub-start="top top"
         data-scrub-end="bottom top">
  <!-- only with an intro whose skip is true: -->
  <button type="button" id="{name}-image-skip" class="paste-ui-imagesequence-skip" hidden>{intro.skipLabel}</button>
  <i id="{name}-image" class="paste-ui-hero-image"
     data-paste-imagesequence="#{name}-image-catalog"
     data-paste-progressiveresolution
     data-hero-image-fixed
     aria-hidden="true"></i>
  <script id="{name}-image-catalog" type="application/json">{catalog}</script>
  <div id="{name}-content-wrap" class="paste-ui-hero-content-wrap">
    <div id="{name}-content" class="paste-ui-hero-content">
      <!-- content slot -->
    </div>
  </div>
</section>
```

`data-paste-parallax` and `data-paste-sticky-target` are presence/absence
attributes — emitted only when their conditions hold, never with a `false`
value. The same holds for `data-hero-image-fixed` on a sequenced hero:
heroscroll discovers the image element by its `paste-ui-hero-image` class,
not by the parallax attribute, so omitting `data-paste-parallax` alone does
not keep the parallax writer off the sequence's frame presentation — the
established fixed opt-out does.

---

## ImageSequence

Scroll-driven pre-rendered image sequence, declared to the `paste.ui.imagesequence`
element. Surface emits the declarative wrapper: a scrollscrub scope, a host
element whose authored CSS image is the baseline, an inert
`script[type="application/json"]` frame catalog, and — only when an intro
declares one — a hidden skip control. Without JavaScript, with reduced motion, or
before the element binds, the authored CSS presentation is the component: no
blank box, no layout shift, and the element never touches scroll position or
layout.

### ViewModel: ScrollScrub

The scrub relationship a scope declares — the `paste.ui.scrollscrub` /
`paste.ui.utilities.scrollrange` grammar carried verbatim into `data-scrub-*`
attributes.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `start` | string | no | `"top bottom"` | Two edge anchors — each `top`, `center`, or `bottom` — for subject edge meeting root edge at progress 0; emitted as `data-scrub-start` |
| `end` | string | no | `"bottom top"` | The same pair at progress 1; emitted as `data-scrub-end` |
| `windowStart` | `Option[BigDecimal]` | no | `None` | Fraction of the measured span where progress starts; supplied only with `windowEnd` |
| `windowEnd` | `Option[BigDecimal]` | no | `None` | Fraction where progress completes; within 0 to 1 and exceeding `windowStart` |
| `mode` | `ScrubMode` | no | `None` | `Element` or `Container` — a closed enum whose `wireName` (`element`/`container`) is emitted as `data-scrub-mode`; absent is the module's own default |
| `root` | string | no | `None` | Root selector, emitted as `data-scrub-root`; the literal `viewport` is the Element's keyword for the page viewport (its default). A declared root must contain the subject, or the Element leaves the baseline standing |
| `subject` | string | no | `None` | Subject selector, emitted as `data-scrub-subject`; absent is the scope itself |

`ScrollScrub.EnterExit` is the default pair (`top bottom` → `bottom top`);
`ScrollScrub.TopExit` is `top top` → `bottom top`, the sticky hero's traverse.
A declared window emits `data-scrub-window` as two space-separated fractions.

### ViewModel: ImageRepresentation

One resolved representation of an image: `src` (nonblank), `width` and `height`
(positive intrinsic dimensions). Upgrade rungs are this value — never a nested
frame — so a rung cannot carry its own rungs.

### ViewModel: ImageSequenceFrame

One catalog frame: `src`, `width`, `height`, and `upgrades`, a sequence of
`ImageRepresentation` for sharper variants. Supplied rungs may arrive unordered;
`sortedUpgrades` is the serialized order. Construction rejects a rung whose
width and height do not both strictly exceed the base's and every preceding
rung's — the Element refuses a rung that grows in one dimension only — and a
rung whose aspect ratio differs from the frame's by more than one percent — a
resolution step is the same content, never a different crop. A `src` must be
non-empty after JavaScript's whitespace trim and carry no control characters.

### ViewModel: ImageSequenceCatalog

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `frames` | Seq[ImageSequenceFrame] | yes | - | Non-empty frame list in display order |

One resource carries exactly one intrinsic size: construction rejects the
same `src` appearing with different `width`/`height` anywhere in the
catalog — across frames, or between a frame's base and its own upgrades —
because the Element refuses that declaration at bind time. The same `src`
with identical dimensions is legal reuse; distinct sources keep their own
genuine dimensions. Sources compare by the identity the WHATWG URL parser
gives them against any http(s) document base, without knowing that base:
surrounding spaces are dropped, dot segments (including `%2e` spellings)
are removed one segment at a time, so `x//../a.webp` is `x/a.webp` and
not `a.webp`, a `..` at a path's root is dropped, and an http, https, ws,
wss or ftp URL compares with its scheme and host lower-cased and its
default port omitted. A relative `src`'s leading `..` climbs a base
Surface does not know, so it stays distinct. Anything else compares as
written — a backslash, a third slash before the host, another scheme, a
host or path character the browser would decode or percent-encode — and
the Element, which resolves against the real document base, still
rejects aliases only that resolution reveals. The same identity is used
inside a frame, whose representation sources must be distinct, and
across an adaptive manifest's tiers.

`toJson` produces the embedded catalog: `{ "frames": [ { "src", "width",
"height", "upgrades": [ { "src", "width", "height" } ] } ] }`. The output is
HTML-safe for a `script[type="application/json"]` block: every `<`, `>`, `&`
and line separator a value could carry is a unicode escape, so a `src` reading
literally `</script>` can never terminate the data block.

### Adaptive manifest import

`AdaptiveImageSequenceManifest` (`view_model_factories`) is the supported
adapter for the version-1 tiered producer format — a document carrying
`schemaVersion: 1`, a positive `count`, and a nonempty `sizes` array of
`{ "width", "height", "frames": [ { "src" } ] }` tiers. `parseJson` validates
and orders the tiers by intrinsic width; `toCatalog(resolveSource)` emits one
catalog frame per declared index whose base is the narrowest tier and whose
`upgrades` are each wider tier in ascending order:

```json
{ "schemaVersion": 1, "count": 2,
  "sizes": [
    { "width": 480, "height": 270,
      "frames": [ { "src": "480/a.webp" }, { "src": "480/b.webp" } ] },
    { "width": 960, "height": 540,
      "frames": [ { "src": "960/a.webp" }, { "src": "960/b.webp" } ] } ] }
```

normalizes to catalog frames `{ "src": "480/a.webp", "width": 480,
"height": 270, "upgrades": [ { "src": "960/a.webp", "width": 960,
"height": 540 } ] }` (and likewise for `b.webp`), with `resolveSource`
applied to every `src`. URL resolution is the caller's policy — absolute
URIs, `data:` URIs, and protocol-relative sources pass through verbatim when
the resolver says so; the adapter invents no base, origin, or fetch
behaviour. Only `schemaVersion` 1 is supported; the declared `count` must
match every tier's frame count. Parsing rejects duplicate JSON property names
and any trailing JSON value after the manifest: an input is exactly one
unambiguous document. Tier geometry is validated at parse with the frame's own
ladder rules, and a frame `src` repeated across tiers is rejected there too,
so those defects raise `InvalidManifest` rather than failing at render. Members
other than `schemaVersion`, `count`, `sizes`, `width`, `height`, `frames` and
`src` are ignored.

### ViewModel: ImageSequenceIntro

The finite introductory playback the sequence owns — a declared range on a
declared clock, with an authored skip unless `skip` is false, never a general
autoplay. Field names mirror the `data-sequence-intro-*` attributes.

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `durationMs` | int | yes | - | Positive intro duration — a typed `ImageSequenceIntro` is an actual intro; `None` on `ImageSequence` is the no-intro declaration. The module's zero-duration convention disables hand-authored intros and needs no model counterpart. Declared first, so positional construction reads duration, from, to |
| `from` | int | no | `None` | Catalog index the intro starts at; nonnegative and within the catalog |
| `to` | int | no | `None` | Catalog index the intro ends at; nonnegative and within the catalog; absent means the last index |
| `easing` | `IntroEasing` | no | `EaseInOut` | `Linear` or `EaseInOut` — a closed enum whose `wireName` (`linear`/`ease-in-out`) is emitted |
| `skipLabel` | string | no | `"Skip intro"` | Label on the authored skip control; non-null, and carrying a visible character when `skip` is true — a label of spaces, zero-width or format characters names nothing |
| `bufferMs` | int | no | `None` | Nonnegative authored startup lead; emitted as `data-sequence-intro-buffer-ms` |
| `skip` | boolean | no | `true` | Emit the skip control and `data-sequence-intro-skip`. `false` emits neither and reserves no `-skip` id; the intro still ends on scroll, a hidden document, reduced motion, failure or completion. Declared last, so positional construction is unchanged |

### ViewModel: ImageSequence

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `catalog` | [ImageSequenceCatalog](#viewmodel-imagesequencecatalog) | yes | - | The frame catalog, embedded as an inert JSON block |
| `cssClass` | string | no | `""` | Additional CSS classes on the scope root |
| `scrub` | [ScrollScrub](#viewmodel-scrollscrub) | no | `ScrollScrub.TopExit` | The scroll relationship the scope declares |
| `from` | int | no | `None` | Catalog index at scroll progress 0; within the catalog; emitted as `data-sequence-from` |
| `to` | int | no | `None` | Catalog index at progress 1; may be lower than `from` for reverse playback |
| `intro` | [ImageSequenceIntro](#viewmodel-imagesequenceintro) | no | `None` | One finite intro before scroll ownership |
| `resolution` | boolean | no | `true` | Emit `data-paste-progressiveresolution`: displayed frames may resolve sharper representations under the CSS policy |
| `scrubBufferFrames` | int | no | `None` | Nonnegative authored scrub gate; emitted as `data-sequence-scrub-buffer-frames` |
| `playback` | SequencePlayback | no | `Direct` | `Direct` or `Queued(framesPerSecond = 30)`; queued rate is integer 1..120 |

Construction rejects every invalid value above — blank or non-positive frame
fields, duplicate rung widths or widths that do not exceed the base width,
mismatched rung aspect, one source at two intrinsic sizes, an anchor pair that
is not two edge tokens, a half-declared or out-of-range window, blank
selectors, a catalog index outside the frames, a non-positive duration or
negative buffer, a null `Option` container or a null enum instance, a null
`skipLabel`, and a `skipLabel` with no visible character when `skip` is true.
Unordered rung widths are accepted — construction sorts them ascending. These
are configuration errors (`IllegalArgumentException`), including through
`copy`.

`ScrollScrub` `root` and `subject` are caller-owned selectors: Surface
validates only that they are nonblank and emits them verbatim; existence,
uniqueness and full selector syntax are the DOM/browser boundary's to resolve
or reject. A window bound must be exactly representable as a double, the
precision the Element parses. The selectors Surface itself manufactures are
different — an id interpolated into a generated `#id` selector the Element
parses (an imagesequence `mediaId`, and the `name` of a hero carrying a
sequence) must be a plain identifier matching `^[A-Za-z_][A-Za-z0-9_-]*$`,
rejected at construction otherwise. Ids emitted only as element ids, link
fragments, IDREFs or `:target` (a plain hero `name`, a nav `targetId` or
`panelId`) are resolved by exact id and need only be nonempty, without
whitespace or a leading `#` — a leading `#` there is a selector passed where an
id is wanted. A form field `id`, paired only with its label's `for` and never
written after a `#`, follows HTML's own rule: nonempty and without whitespace
(see [form](../components/formfield/form.md)). Surface checks the syntax of
every id; uniqueness on the page is the page's.

### HTML Output

The Twirl source is
`src/main/twirl/paste/surface/components/imagesequence.scala.html` with
signature `@(sequence: ImageSequence, mediaId: MediaId)`.
`MediaId` is the validated rendered-block identity — its construction enforces
the plain-identifier rule above, so every `#id` selector the template emits is
syntactically sound without escaping:

```html
<div id="{mediaId}"
     class="paste-ui-imagesequence-scope {cssClass}"
     data-paste-scrollscrub
     data-scrub-mode="{scrub.mode}"
     data-scrub-root="{scrub.root}"
     data-scrub-subject="{scrub.subject}"
     data-scrub-start="{scrub.start}"
     data-scrub-end="{scrub.end}"
     data-scrub-window="{windowStart windowEnd}">
    <!-- only with an intro whose skip is true: -->
    <button type="button" id="{mediaId}-skip" class="paste-ui-imagesequence-skip" hidden>{intro.skipLabel}</button>
    <i id="{mediaId}-host"
       class="paste-ui-imagesequence"
       data-paste-imagesequence="#{mediaId}-catalog"
       data-paste-progressiveresolution
       data-sequence-from="{from}"
       data-sequence-to="{to}"
       data-sequence-scrub-buffer-frames="{scrubBufferFrames}"
       data-sequence-intro-trigger="ready"
       data-sequence-intro-duration-ms="{intro.durationMs}"
       data-sequence-intro-easing="{intro.easing}"
       data-sequence-intro-skip="#{mediaId}-skip"
       data-sequence-intro-from="{intro.from}"
       data-sequence-intro-to="{intro.to}"
       data-sequence-intro-buffer-ms="{intro.bufferMs}"
       aria-hidden="true"></i>
    <script id="{mediaId}-catalog" type="application/json">{catalog.toJson}</script>
</div>
```

- `Queued` emits `data-sequence-playback="queued"` and `data-sequence-playback-fps`; `Direct` omits both. See Ordered playback below for runtime semantics.
- `data-scrub-mode`, `data-scrub-root`, `data-scrub-subject` and
  `data-scrub-window` appear only when the model declares them. The endpoint, buffer
  and intro attributes appear only when their values are supplied; the skip
  button and its `-intro-skip` attribute appear only with an `intro` whose
  `skip` is true, and
  `data-sequence-intro-trigger="ready"` is the fixed contract the intro emits
  (the clock starts when the buffered set can paint).
- The skip button is the scope's first child, ahead of the host, so it is the
  scene's first tab stop. It has no presentation of its own: the page
  positions `.paste-ui-imagesequence-skip` out of flow over the media (for
  example `position: absolute` in a `position: relative` scope), or a
  revealed skip takes flow space until the intro ends.
- The intro starts only while the scroll progress is still 0, its authored
  start, so an intro belongs on a range whose start is where the page opens —
  `ScrollScrub.TopExit` on a scene in the first viewport. Under
  `ScrollScrub.EnterExit` progress 0 means the subject has not entered the
  viewport: a scene already in view ends the intro at once.
- `{mediaId}`, `{mediaId}-host`, `{mediaId}-catalog` and, with an intro that
  declares a skip, `{mediaId}-skip` are reserved ids on the page. Two sequences naming one
  skip control are both refused by the Element and stay at their baselines.
- Under `ScrubMode.Container` the scope measures the root's own scroll range —
  subject and endpoint anchors do not apply, so `data-scrub-subject`,
  `data-scrub-start` and `data-scrub-end` are omitted entirely while
  `data-scrub-mode`, `data-scrub-root` and `data-scrub-window` still declare.
- The host is a decorative `<i>` with `aria-hidden="true"`: the sequence is
  presentational and the surrounding authored content carries the meaning. Its
  baseline image is authored in CSS (`background-image`), so media conditions —
  reduced motion included — pick the image as content before the element runs.
- The catalog block is `application/json`, inert data — never executable
  configuration — and its text is HTML-safe by construction (see
  [ImageSequenceCatalog](#viewmodel-imagesequencecatalog)).
- The renderer emits no runtime state and no frame-fetching configuration; the
  element owns decoding, readiness and load scheduling.

### Element Contract

The Element `paste.ui.imagesequence` reads `[data-paste-imagesequence]` — a
`#id` reference to one `script[type="application/json"]` catalog — and honours
`data-sequence-scrub`, `-from`, `-to`, `data-image-property`,
`data-paste-progressiveresolution`, `data-sequence-intro-*` and
`data-sequence-scrub-buffer-frames`. It finds its `paste.ui.scrollscrub` scope
through `data-sequence-scrub` or the nearest ancestor scope, and reads
geometry and resolution policy through `paste.ui.utilities.scrollrange` and
`paste.ui.utilities.imageresolution` — loading neither `paste.ui.scrollscrub`'s
CSS-output entry nor `paste.ui.progressiveresolution` is required, and the
standalone entry skips a sequence-declared host anyway.

The element owns exactly the declared image property and, when one is
declared, the skip control's visibility while an intro runs. The skip is
optional to the Element too: a host without `data-sequence-intro-skip` plays
its intro with direct-mode scroll, a hidden document, reduced motion, failure and completion as its ends. Queued playback preserves a running intro before scroll travel. CSS owns sizing, crop, background position,
aspect and every presentation choice including the `--paste-resolution-max-width`
cap; scroll stays native. A missing scope, an invalid declaration, reduced
motion, or a failed load leaves the authored baseline standing — the baseline
is content, not a placeholder. Catalog sources resolve once against the
document base URL; absolute URLs keep their own origin.

---

## ProgressiveImage

A standalone image that may resolve to a sharper representation, declared to
the `paste.ui.progressiveresolution` element — an ordinary `<img>` whose
authored `src`, `width`, `height` and `alt` are the working baseline, plus an
inert `script[type="application/json"]` descriptor naming the same content at
more pixels. Without JavaScript the authored img is the whole presentation.
When native selection already covers the requirement — `srcset`/`sizes` or a
wrapping `picture` — author that instead and omit the opt-in; the element
passes over a host whose srcset already governs.

### ViewModel: ProgressiveImage

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `mediaId` | `MediaId` | yes | - | The descriptor block's element id — the `#id` the img references |
| `base` | [ImageRepresentation](#viewmodel-imagerepresentation) | yes | - | The authored baseline: its `src`, `width` and `height` are the img's own attributes |
| `alt` | string | yes | - | Text alternative — may be empty for decorative images, never null |
| `upgrades` | list | no | `Seq.empty` | Sharper rungs of the same content — ascending width above the base, matching aspect |
| `cssClass` | string | no | `""` | Additional CSS classes on the img |

Construction rejects a null `mediaId`, `base`, `alt` or `upgrades` collection,
a null rung, and every ladder rule the typed frame enforces — a rung at or
under the base width or height fails the way it would in a catalog. Unordered
rungs are accepted and sorted ascending.

### HTML Output

```html
<img src="/images/still-640.webp"
     width="640" height="360"
     alt="Product still"
     data-paste-progressiveresolution
     data-image-sources="#still-sources">
<script id="still-sources" type="application/json">{
  "src": "/images/still-640.webp",
  "width": 640, "height": 360,
  "upgrades": [{"src": "/images/still-1280.webp", "width": 1280, "height": 720}]
}</script>
```

With no `upgrades` there is nothing to resolve: the img renders without
`data-paste-progressiveresolution`, `data-image-sources` or the descriptor.
The descriptor carries exactly one catalog frame's shape — base plus rungs —
and serializes through the same HTML-safe JSON the catalog uses. The element
reads `--paste-resolution-max-width` from the host's computed style as its
cap; CSS owns that policy and all presentation.

---

## Address

Physical address display.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `street1` | string | yes | - | Primary street address |
| `street2` | string | no | `null` | Secondary street address |
| `locality` | string | yes | - | City/locality |
| `region` | string | yes | - | State/region code |
| `regionTitle` | string | no | `null` | Full region name |
| `postalCode` | string | yes | - | Postal/ZIP code |
| `countryCode` | string | yes | - | Country code (e.g., "USA") |

### Example (Scala)

```scala
case class Address(
  street1: String,
  locality: String,
  region: String,
  postalCode: String,
  countryCode: String,
  street2: Option[String] = None,
  regionTitle: Option[String] = None
)
```

### HTML Output

```html
<address class="paste-ui-address" itemscope itemtype="http://schema.org/PostalAddress">
  <span itemprop="streetAddress">{street1}</span>
  {street2 && <span itemprop="streetAddress">{street2}</span>}
  <span itemprop="addressLocality">{locality}</span>,
  <span itemprop="addressRegion" title="{regionTitle}">{region}</span>
  <span itemprop="postalCode">{postalCode}</span>
  <span itemprop="addressCountry">{countryCode}</span>
</address>
```

---

## Logo

Accessible brand logo with SVG content slot. Provides semantic structure with ARIA labels and screen reader support.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `href` | string | no | `"/"` | Link destination (typically home page) |
| `ariaLabel` | string | yes | - | Accessible label for screen readers |
| `title` | string | yes | - | SVG title element content |
| `width` | int | yes | - | SVG width in pixels |
| `height` | int | yes | - | SVG height in pixels |
| `viewBox` | string | no | `None` | SVG viewBox attribute (e.g., "0 0 194 91") |
| `cssClass` | string | no | `""` | Additional CSS class on the `<a>` |

### Example (Scala)

```scala
case class Logo(
  href: String = "/",
  ariaLabel: String,
  title: String,
  width: Int,
  height: Int,
  viewBox: Option[String] = None,
  cssClass: String = ""
)
```

### Usage

```scala
@paste.surface.components.html.logo(Logo(
  ariaLabel = "Example Site - home",
  title = "Example Site",
  width = 194,
  height = 91,
  viewBox = Some("0 0 194 91")
)) {
  <!-- Site-specific SVG paths -->
  <g clip-path="url(#clip0)">
    <path d="..." fill="#336BA1"/>
  </g>
}
```

### HTML Output

```html
<a href="/" class="paste-ui-logo" aria-label="Example Site - home">
  <svg width="194" height="91" viewBox="0 0 194 91" role="img">
    <title>Example Site</title>
    <!-- Site-specific SVG content -->
  </svg>
</a>
```

---

## SectionNav

In-page navigation bar of ordinary fragment links to page sections. The browser navigates them natively; `tabindex="-1"` makes a destination focusable and the hero renderer supplies it. `smoothscroll = true` declares the nav a `paste.ui.smoothscroll` container (`data-paste-smoothscroll`): its section links then animate and push the fragment at completion, after which focus and `:target` follow as native navigation leaves them, unless the visitor moves focus during the motion. An undeclared nav's links stay native even where `IncludesFactory.defaultIncludes()` loads smoothscroll. Optional Elements add to it: `paste.ui.scrollspy` marks the current section's item, and `paste.ui.stickynav` adds `paste-ui-sticky-active` to each marked nav once its declared target bottom passes the viewport top, for page CSS to key a stuck presentation on (see [sectionnav](../elements/sectionnav.md)).

Where a section lands is CSS, and Surface renders none. The `paste.ui.sectionnav` stylesheet's zero-specificity `:where(:target) { scroll-margin-top: var(--paste-ui-section-nav-clearance, 51px) }` clears the nav itself (51px with the mixin defaults). A page whose sticky nav sits below a fixed header sets `--paste-ui-section-nav-clearance` to the total of both, or sections land under the header; a page that clears its chrome with `scroll-padding-top` instead sets the property to `0px`, since the two add; a page without that stylesheet supplies `scroll-margin-top` (or `scroll-padding-top` on the scroller) itself.

### ViewModel: NavItem

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `label` | string | yes | - | Display text |
| `targetId` | string | yes | - | Target section element ID (without `#`) |
| `cssClass` | string | no | `""` | Additional CSS class on the `<li>` |
| `href` | string | no | - | Link emitted verbatim in place of `#` + `targetId`. Use for navs rendered on pages that do not contain the target sections — e.g. `/#approach` links to the section on the home page. |

### ViewModel: SectionNav

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `items` | Seq[NavItem] | yes | - | Navigation link items |
| `sticky` | boolean | no | `true` | Emit `data-paste-sticky-nav` attribute |
| `stickyMinWidth` | int | no | `0` | Viewport width at or below which `paste.ui.stickynav` stays inactive; emitted as `data-sticky-min-width` when positive |
| `scrollspy` | boolean | no | `false` | Emit `data-paste-scrollspy`, the root `paste.ui.scrollspy` marks active items on |
| `scrollspyMinWidth` | int | no | `0` | Viewport width at or below which `paste.ui.scrollspy` stays inactive; emitted as `data-spy-min-width` when positive |
| `cssClass` | string | no | `""` | Additional CSS class on the `<nav>` |
| `disclosure` | NavDisclosure | no | `None` | Native fragment-controlled mobile panel |
| `scrollspyTouch` | boolean | no | `false` | Emit `data-spy-touch` when scrollspy is enabled |
| `ariaLabel` | string | no | `None` | Optional `aria-label` on the nav |
| `smoothscroll` | boolean | no | `false` | Emit `data-paste-smoothscroll`, declaring the nav a `paste.ui.smoothscroll` container |

The two minimum-width attributes are unprefixed because that is what
`paste.ui.stickynav` and `paste.ui.scrollspy` read; a renderer must emit these exact
names.

A `NavItem` without an `href` renders `#` + `targetId`, so construction then
rejects a `targetId` that is empty, carries whitespace or starts with `#`; an
item with an `href` is not checked, and a null `href` is rejected. Releases up
to 0.8.0 accepted `NavItem("Top", "")` and rendered `href="#"`; that call now
fails, and `NavItem("Top", "", href = Some("#"))` renders the same link.

### Example (Scala)

```scala
case class NavItem(
  label: String,
  targetId: String,
  cssClass: String = "",
  href: Option[String] = None
)

case class SectionNav(
  items: Seq[NavItem],
  sticky: Boolean = true,
  stickyMinWidth: Int = 0,
  scrollspy: Boolean = false,
  scrollspyMinWidth: Int = 0,
  cssClass: String = "",
  disclosure: Option[NavDisclosure] = None,
  scrollspyTouch: Boolean = false,
  ariaLabel: Option[String] = None,
  smoothscroll: Boolean = false
)
```

### HTML Output

```html
<nav class="paste-ui-section-nav {cssClass}"
     data-paste-sticky-nav
     data-sticky-min-width="{stickyMinWidth}"
     data-paste-scrollspy
     data-spy-min-width="{scrollspyMinWidth}"
     data-paste-smoothscroll>
  <ul class="paste-ui-section-nav-items">
    <li class="paste-ui-section-nav-item {item.cssClass}">
      <a class="paste-ui-section-nav-link" href="{item.href, or # + item.targetId when href is unset}">{item.label}</a>
    </li>
  </ul>
</nav>
```

When `sticky=false`, the `data-paste-sticky-nav` attribute is omitted, and likewise
`data-paste-scrollspy` when `scrollspy=false` and `data-paste-smoothscroll` when
`smoothscroll=false`. Each minimum-width attribute is omitted
when its value is `0`.

### ViewModel: NavDisclosure

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `panelId` | string | yes | - | Unique native fragment id; reserve `<panelId>-toggle` too |
| `label` | string | no | `"Menu"` | Accessible open-link text |
| `footer` | trusted HTML | no | `None` | Optional content after the nav items inside the panel |
| `closeLabel` | string | no | `"Close menu"` | Accessible close-link text |

`panelId` must be nonempty, contain no whitespace and not start with `#`.
It is resolved as an exact fragment id, not a CSS selector. The caller owns
uniqueness of both reserved ids. Disclosure adds `.paste-ui-section-nav-disclosure`;
the `.paste-ui-section-nav-panel` carries `id=panelId` and `tabindex="-1"`.
The open anchor has `id=<panelId>-toggle`, `href=#<panelId>`, and
`aria-controls=<panelId>`. The close anchor points back to `#<panelId>-toggle`.
CSS `:target` owns open state, native links own history/focus, and no JavaScript
listener or mirrored `aria-expanded` state is needed. Without disclosure the
list remains directly inside the nav. `ariaLabel` and `scrollspyTouch` map to
`aria-label` and `data-spy-touch`; omit them when absent/false, and emit
`data-spy-touch` only when `scrollspy` is enabled.

---

## Carousel

Discrete paging restored from the original carousel. Load `paste.ui.carousel`
and the optional `modules/carousel/carousel` stylesheet; the mixin is
`paste-ui-carousel`. See [the complete Element contract](../elements/carousel.md).
Without the enhancement all authored slide content remains in normal flow.

| Property | Type | Default | Meaning |
| --- | --- | --- | --- |
| `name` | string | required | Named instance on `paste.ui.carousel`; empty uses a GUID |
| `autoCycleMs` | nonnegative int | `0` | Interval; zero disables cycling |
| `showIndicators` | boolean | false | Numbered page buttons |
| `cssClass` | string | empty | Caller classes |
| `variableWidth` | boolean | false | Equal authored slide widths; otherwise one full-width slide per page |
| `showCounter` | boolean | false | Current/total page counter |
| `animationEnabled` | boolean | false | Reflect actual transitions with the animating class |
| `broadcastMoves` | boolean | false | Original `carouselMove` event |
| `controlsParentId` | optional HTML id | absent | Literal id of an authored arrow/pause controls container; indicators/counter remain in the carousel root |
| `previousLabel`, `nextLabel`, `pauseLabel` | nonblank string | Previous, Next, Pause | Generated control labels |

The renderer emits `.paste-ui-carousel`, an inner `.paste-ui-carousel-wrap`
and `.paste-ui-carousel-items`. The content slot supplies direct
`.paste-ui-carousel-item` children. It emits the declared attributes in the
Element contract, never generated controls or runtime state.

```scala
@paste.surface.components.html.carousel(Carousel("gallery", showIndicators = true)) {
  <article class="paste-ui-carousel-item">One</article>
  <article class="paste-ui-carousel-item">Two</article>
}
```

`CarouselSlide(content, cssClass)` remains a data type; the template's `Html`
content slot owns rendering, and no raw string-to-HTML conversion is implied.

## LazyContent

`LazyContent(url, id = None, cssClass = "")` renders a `div` carrying
`data-lazy-load`, its optional validated HTML id and caller classes. Its `Html`
slot supplies useful initial/fallback content. URL must be nonblank. Load
`paste.ui.lazy_loader` and have the owning page request visible content at its
own visibility transitions. See [lazy loading](../elements/lazy-loader.md).

---

## Marquee

A progressively enhanced list of caller-rendered content slots. Surface emits the native list and configuration for the reusable `paste.ui.marquee` Element; animation and controls belong to the Element, not the Scala renderer. This is independent of Carousel and does not prescribe logos or other site-specific content.

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `label` | string | yes | - | Nonblank accessible name on the list's `aria-label` |
| `durationSeconds` | double | no | `45.0` | Positive, finite seconds per animation cycle; emitted as `data-paste-marquee-duration` |
| `pauseLabel` | string | no | `"Pause motion"` | Nonblank pause action text; initial button text and `data-paste-marquee-pause-label` |
| `resumeLabel` | string | no | `"Resume motion"` | Nonblank resume action text; `data-paste-marquee-resume-label` |
| `cssClass` | string | no | `""` | Additional CSS classes on the root `<div>` |

### Example (Scala)

```scala
final case class Marquee(
  label: String,
  durationSeconds: Double = 45.0,
  pauseLabel: String = "Pause motion",
  resumeLabel: String = "Resume motion",
  cssClass: String = ""
)
```

The model constructor uses `require` to reject blank or null `label`, `pauseLabel`, and `resumeLabel`, and non-positive, NaN, or infinite `durationSeconds`. These are configuration errors (`IllegalArgumentException`), including when using `copy`, rather than runtime domain errors.

### Content Slots and Usage

The Twirl source is `src/main/twirl/paste/surface/components/marquee.scala.html` with signature `@(marquee: Marquee)(items: Seq[Html])`:

```scala
@paste.surface.components.html.marquee(Marquee(label = "Partners"))(items)
```

`items` is a sequence of trusted, caller-rendered `play.twirl.api.Html` slots, not raw user input. Callers escape untrusted content in their own templates before supplying the rendered slots. Surface escapes all model strings through Twirl and preserves each supplied Html slot without escaping it again.

### HTML Output

With default configuration and two slots:

```html
<div class="paste-ui-marquee"
     data-paste-marquee
     data-paste-marquee-duration="45.0"
     data-paste-marquee-pause-label="Pause motion"
     data-paste-marquee-resume-label="Resume motion">
  <ul class="paste-ui-marquee-items" role="list" aria-label="Partners">
    <li class="paste-ui-marquee-item"><!-- first trusted Html slot --></li>
    <li class="paste-ui-marquee-item"><!-- second trusted Html slot --></li>
  </ul>
  <button class="paste-ui-marquee-toggle" type="button" hidden disabled>Pause motion</button>
</div>
```

- The root has class `paste-ui-marquee`, followed by `cssClass` only when nonempty, and a boolean `data-paste-marquee` attribute.
- The root has exactly two direct element children: one `ul.paste-ui-marquee-items` and one `button.paste-ui-marquee-toggle`. The list always has `role="list"` and `aria-label=label`.
- Each supplied slot has exactly one direct `li.paste-ui-marquee-item` wrapper and is rendered exactly once in supplied order. Empty slots still receive a wrapper; an empty sequence produces an empty list, and a single slot produces one list item. Slots may themselves contain multiple elements.
- The button has native `type="button"`, `hidden`, and `disabled` attributes, with plain `pauseLabel` text. The renderer does not emit `aria-pressed`, generated IDs, inline scripts, runtime state, or duplicate tracks/items.

### Element Enhancement and Fallback

The JavaScript and CSS module names are both `paste.ui.marquee`. The CSS works with this plain HTML contract and does not depend on a Surface runtime. With CSS but no JavaScript, the wrapping list exposes every original item; without CSS, the native list remains readable. The renderer never hides, clones, or moves content.

The Element binds each `[data-paste-marquee]` root when the module evaluates. There is no imperative control API: the authored toggle is the only pause control, eligibility is reevaluated through the Element's own `ResizeObserver` and `MutationObserver` when the list's item collection changes, and the binding lives as long as the page.

Animation is permitted only when all of the following hold:

- The Element CSS, `ResizeObserver`, and `matchMedia` are available, motion is not disabled, and the user does not prefer reduced motion.
- There are at least two noninteractive items of equal rendered width.
- For item count `N`, item width `width`, gap `gap`, and viewport width `viewportWidth`, the cycle distance `N * (width + gap)` is at least `viewportWidth + width`, so an item can reset fully outside the viewport.

CSS custom properties set equal cell width with `--paste-marquee-item-width` (default `13.5rem`) and spacing with `--paste-marquee-gap` (default `1rem`). CSS-driven individual transform animations use phase offsets over the configured duration, defaulting to 45 seconds per cycle. They reset only while fully outside the viewport; DOM order stays fixed and no copies are created. JavaScript sets up observers and controls, not an animation tick loop; timing does not lock movement to refresh-rate pixels.

| Element state | Presentation | Toggle |
|---------------|--------------|--------|
| `running` | Eligible original items animate with CSS | Visible, enabled, plain `pauseLabel` text |
| `paused` | User-paused, static wrapping list exposes all originals | Visible, enabled, plain `resumeLabel` text while enhancement remains eligible |
| `static` | Motion disabled, reduced motion, missing capabilities, insufficient coverage, fewer than two items, unequal widths, or interactive content | Hidden and disabled |

The Element owns `data-paste-marquee-state` (`running`, `paused`, or `static`) on the root. A user pause restores the readable list rather than freezing partly clipped items. Resume restarts animation, not the previous animation position. The changing action labels do not use `aria-pressed`. Focus within an item restores a static readable state; links and forms remain usable in fallback rather than being animated. Dynamic reduced-motion preference changes are respected.

The Element never clones, reorders, or removes the authored items, and it leaves unrelated attributes and style properties untouched. Browser checks must exercise both plain HTML and equivalent Surface-rendered output, including native fallback, reduced motion, the authored pause/resume toggle, and item-collection changes.

---

## Template Paths

| Component | Twirl | Jinja/Nunjucks |
|-----------|-------|----------------|
| Hero | `paste.surface.components.html.hero` | `paste/surface/components/hero.html` |
| ImageSequence | `paste.surface.components.html.imagesequence` | `paste/surface/components/imagesequence.html` |
| ProgressiveImage | `paste.surface.components.html.progressiveImage` | `paste/surface/components/progressive-image.html` |
| Address | `paste.surface.components.html.address` | `paste/surface/components/address.html` |
| Logo | `paste.surface.components.html.logo` | `paste/surface/components/logo.html` |
| SectionNav | `paste.surface.components.html.sectionNav` | `paste/surface/components/section-nav.html` |
| Carousel | `paste.surface.components.html.carousel` | `paste/surface/components/carousel.html` (paste.ui.carousel) |
| Marquee | `paste.surface.components.html.marquee` | `paste/surface/components/marquee.html` |

Marquee duration serialization uses a plain decimal, including small or large
positive finite values; a renderer must not emit exponent notation.

## Ordered playback

ImageSequence.playback defaults to SequencePlayback.Direct, preserving immediate
scroll ownership. SequencePlayback.Queued(framesPerSecond = 30) emits
data-sequence-playback="queued" and data-sequence-playback-fps (integer 1..120).
Hand-authored queued markup may omit the rate for 30 fps. Invalid modes or rates
are rejected; a rate requires queued mode.

Queued playback retains a running intro and then advances through the scroll
range from the displayed completed intro endpoint to the latest scroll destination.
Without a completed intro, travel starts at the authored scroll start. Different
intro and scroll endpoints are connected by every intervening catalog frame. It advances
at most one catalog index per presentation pass and waits for readiness.
Input updates the remaining destination; it does not accumulate obsolete input
events. Playback continues after input stops, reverses from its current cursor,
and rests when the destination is reached. A pending frame wakes on resource
completion rather than an idle frame loop. Intro readiness remains bounded;
an intro unable to finish retires at its declared duration plus 15 seconds.
Starting after navigation or skipping an intro preserves the existing startup
and history rules. Reduced motion retains the static baseline. A hidden
document retires its intro and suspends queued travel until fresh measurement.

This policy changes presentation only. Native scrolling and authored layout
remain in charge of visibility; leaving a section does not force it to stay
onscreen. Resource limits, resolution selection and readiness gates remain
in force. Failed frames may prevent an ordered path completing; the last usable
image remains. Queue completion does not imply decoded-cache eviction.


## Fragment targets and links

`IoReplyFragmentTarget(name, cssClass = "", format = Html)` renders a named
replacement target. `IoReplyFragmentFormat` is `Html` or `Json`; output is
`data-paste-io-reply-fragment-format="html|json"`. Hand-authored omission selects
HTML preference. Null/unknown format and invalid target names are rejected.

`IoReplyFragmentLink(href, target, cssClass = "")` renders an ordinary anchor
whose `data-paste-io-reply-fragment` identifies the target. Href must be nonblank;
target uses the same name validation. No ID or inline handler is generated.
Loading `paste.ui.fragment_navigation` enables the optional request. The href
must also render a full page for native navigation.

See [rendering](../rendering/rendering.md) for headers, representations,
placement, error statuses, history, cancellation and lifecycle.
