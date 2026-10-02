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
case class Hero(
  name: String,
  noContent: Boolean = false,
  showImage: Boolean = false,
  disableParallax: Boolean = false,
  stickyNavTarget: Boolean = false,
  imageSequence: Option[ImageSequence] = None
)
```

An image sequence replaces the hero's media: the parallax attribute and the
legacy `<i>` image element are both omitted, because the sequence owns the pixels
and reads scroll position itself. The sequence's media element id is
`{name}-image`, and its progress target defaults to the hero's own `name`.

### HTML Output

```html
<section class="paste-ui-hero" 
         id="hero-{name}"
         data-paste-hero="{name}"
         data-paste-parallax="{!disableParallax}"
         data-paste-sticky-target="{stickyNavTarget}">
  <div class="paste-ui-hero-content">
    <!-- content slot -->
  </div>
</section>
```

---

## ImageSequence

Scroll-driven pre-rendered image sequence. Surface emits a poster that is
readable on its own plus the configuration the Element needs; the Element owns
frame decoding, canvas pixels and scroll subscription. Without JavaScript, with
reduced motion, or before the Element initializes, the `<picture>` poster is the
component: no blank box, no layout shift.

### ViewModel: ImageSequence

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `source` | string | yes | - | Frame source the Element expands into per-frame URLs |
| `posterFirst` | string | yes | - | Poster for the sequence's first frame |
| `posterFinal` | string | yes | - | Poster for the sequence's last frame, used under reduced motion |
| `posterWidth` | int | yes | - | Intrinsic poster width, positive; reserves layout before load |
| `posterHeight` | int | yes | - | Intrinsic poster height, positive |
| `progressTargetId` | string | no | `None` | Plain element id whose scroll progress drives the sequence; no `#`, no whitespace. Defaults to the hero's name when nested in a Hero |
| `range` | string | no | `"top-exit"` | `top-exit` or `enter-exit`: which part of the target's travel maps to the sequence |
| `preload` | string | no | `"auto"` | `auto`, `all`, or `playhead`: `all` paces every frame through the loaders; `playhead` keeps background work inside a window that follows the desired frame, widened by observed transfer rate within the preload budget; `auto` prefetches nothing beyond the buffer horizon |
| `priority` | int | no | `0` | Nonnegative load-priority offset. Bindings share one fetch queue, so this orders competing sequences on a page; a root's own desired frame still outranks its own prefetch |
| `cssClass` | string | no | `""` | Additional CSS classes on the root |
| `intro` | [ImageSequenceIntro](#viewmodel-imagesequenceintro) | no | `None` | Play an intro before scroll takes over |
| `posterSources` | Seq[[ImageSequencePoster](#viewmodel-imagesequenceposter)] | no | empty | Responsive poster candidates: distinct widths, one aspect ratio, any order |
| `posterSizes` | string | no | `"100vw"` | `sizes` attribute for the responsive poster |
| `scrollFrom` | int | no | `None` | Frame index the scroll range starts at |
| `scrollTo` | int | no | `None` | Frame index the scroll range ends at; supplied together with `scrollFrom` |
| `fit` | string | no | `"cover"` | `cover` or `contain`: how each drawn frame fits its box |
| `scrollWindowStart` | double | no | `0.0` | Fraction of the target's travel where playback starts, within 0 and 1 |
| `scrollWindowEnd` | double | no | `1.0` | Fraction of the target's travel where playback completes, within 0 and 1 and exceeding `scrollWindowStart` |

Construction rejects a blank `source`, `posterFirst` or `posterFinal`, a
non-positive poster dimension, an unknown `range` or `preload`, a negative
`priority` or scroll endpoint, one scroll endpoint without the other, a `fit`
that is neither `cover` nor `contain`, a scroll window bound outside 0 to 1,
a window whose end does not exceed its start, a
`progressTargetId` that is blank or carries `#` or whitespace, repeated poster
widths, and poster aspect ratios that disagree by more than one percent. These are configuration errors (`IllegalArgumentException`), including
through `copy`.

### ViewModel: ImageSequenceIntro

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `toFrame` | int | no | `None` | Frame the intro runs to; defaults to the scroll range's start |
| `durationMs` | int | no | `1600` | Positive intro duration |
| `mode` | string | no | `"return"` | `return` hands back to scroll position, `hold` stays on the intro's last frame |
| `trigger` | string | no | `"ready"` | `ready` or `visible`. **Reserved:** the Element starts when ready and does not read this yet |
| `easing` | string | no | `"ease-in-out"` | `linear` or `ease-in-out` |
| `skipLabel` | string | no | `"Skip intro"` | Nonblank label on the skip control. **Reserved:** the control is rendered hidden and no Element wires it yet |

### ViewModel: ImageSequencePoster

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `width` | int | yes | - | Candidate width, positive, used as the `srcset` descriptor |
| `height` | int | yes | - | Candidate height, positive |
| `first` | string | yes | - | First-frame image for this width |
| `finalFrame` | string | yes | - | Last-frame image for this width, used under reduced motion |
| `fallbackFirst` | string | no | `None` | Non-WebP first-frame image |
| `fallbackFinal` | string | no | `None` | Non-WebP last-frame image |

### HTML Output

```html
<div id="{mediaId}"
     class="paste-candidate-imagesequence {cssClass}"
     data-paste-candidate-imagesequence
     data-sequence-source="{source}"
     data-sequence-progress-id="{progressTargetId}"
     data-sequence-range="{range}"
     data-sequence-preload="{preload}"
     data-sequence-priority="{priority}"
     data-sequence-fit="{fit}"
     data-sequence-scroll-window-start="{scrollWindowStart}"
     data-sequence-scroll-window-end="{scrollWindowEnd}"
     data-sequence-scroll-from="{scrollFrom}"
     data-sequence-scroll-to="{scrollTo}"
     data-sequence-intro-mode="{intro.mode}"
     data-sequence-intro-duration-ms="{intro.durationMs}"
     data-sequence-intro-trigger="{intro.trigger}"
     data-sequence-intro-easing="{intro.easing}"
     data-sequence-intro-to-frame="{intro.toFrame}">
  <picture data-sequence-poster>
    <source type="image/webp" media="(prefers-reduced-motion: reduce)" srcset="{final frames}" sizes="{posterSizes}">
    <source type="image/webp" srcset="{first frames}" sizes="{posterSizes}">
    <img src="{fallback or posterFirst}" width="{posterWidth}" height="{posterHeight}" alt="">
  </picture>
  <div class="paste-candidate-imagesequence-surface" data-sequence-media>
    <button type="button" class="paste-candidate-imagesequence-skip" data-sequence-intro-skip hidden>{intro.skipLabel}</button>
  </div>
</div>
```

- The scroll endpoint and intro attributes appear only when their values are
  supplied; the intro block appears only with an `intro`. `-fit` and the
  `-scroll-window-*` attributes always render and carry the effective value,
  which is the Element's default when the caller does not set it.
- Poster candidates are emitted in ascending width regardless of the order they
  were supplied. Non-WebP `<source>` elements appear only when a candidate
  supplies them.
- With no `posterSources` the poster still serves reduced motion: a
  `<source media="(prefers-reduced-motion: reduce)">` carrying `posterFinal`
  precedes the fallback `<img>`, which keeps `posterFirst`. The plain poster
  URLs are format-agnostic, so that source carries no `type`.
- The poster `<img>` carries an empty `alt`: the sequence is presentational, and
  the surrounding hero content carries the meaning.
- The renderer emits no inline script, no runtime state, and no frame URLs; frame
  expansion belongs to the Element.

### Element Contract

The Element reads `[data-paste-candidate-imagesequence]` and honours
`data-sequence-source`, `-progress-id`, `-range`, `-preload`, `-priority`,
`-fit`, `-scroll-window-start`, `-scroll-window-end`, `-scroll-from`,
`-scroll-to`, and the four intro attributes other than `-intro-trigger`.
`-fit` accepts `cover` or `contain` and defaults to `cover`;
`-scroll-window-start` and `-scroll-window-end` are fractions from 0 to 1,
defaulting to 0 and 1, and the end must exceed the start. Every attribute is
optional: an absent attribute takes the Element's default, so a hand-authored
`[data-paste-candidate-imagesequence]` element works with any subset of them
present. The view model's defaults are the Element's defaults — `cover`,
`0.0`, `1.0` — so markup a Surface renderer emits and markup written by hand
mean the same thing. It adds `-priority` to every request it submits, so a
page's sequences load in the order the caller declared; an absent or unusable
value means no offset rather than an error. It owns
media resources and canvas pixels, never page layout or document scrolling, and
under reduced motion it leaves the final-frame poster in place.

The Element is staged in a consuming application under the `paste-candidate`
module namespace and is not published in `paste-elements` yet, which is why the
markup carries `paste-candidate-*` classes. Promoting it renames the class and
marker attribute to the `paste-ui-*` / `data-paste-*` convention, and the
renderer, the Element and every consumer move together in one step.

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

In-page navigation bar with anchor links to page sections. Integrates with `paste.ui.smoothscroll` (auto-intercepts anchor clicks, updates URL via pushState) and `paste.ui.stickynav` (makes nav fixed on scroll past trigger point).

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
| `stickyMinWidth` | int | no | `0` | Viewport width below which `paste.ui.stickynav` stays inactive; emitted as `data-sticky-min-width` when positive |
| `scrollspy` | boolean | no | `false` | Emit `data-paste-scrollspy`, the root `paste.ui.scrollspy` marks active items on |
| `scrollspyMinWidth` | int | no | `0` | Viewport width below which `paste.ui.scrollspy` stays inactive; emitted as `data-spy-min-width` when positive |
| `cssClass` | string | no | `""` | Additional CSS class on the `<nav>` |

The two minimum-width attributes are unprefixed because that is what
`paste.ui.stickynav` and `paste.ui.scrollspy` read; a renderer must emit these exact
names.

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
  cssClass: String = ""
)
```

### HTML Output

```html
<nav class="paste-ui-section-nav {cssClass}"
     data-paste-sticky-nav
     data-sticky-min-width="{stickyMinWidth}"
     data-paste-scrollspy
     data-spy-min-width="{scrollspyMinWidth}">
  <ul class="paste-ui-section-nav-items">
    <li class="paste-ui-section-nav-item {item.cssClass}">
      <a href="{item.href, or # + item.targetId when href is unset}">{item.label}</a>
    </li>
  </ul>
</nav>
```

When `sticky=false`, the `data-paste-sticky-nav` attribute is omitted, and likewise
`data-paste-scrollspy` when `scrollspy=false`. Each minimum-width attribute is omitted
when its value is `0`.

---

## Carousel

Markup contract for a slide carousel: a container plus caller-supplied slides, with attributes describing navigation arrows, optional indicators, and auto-cycling.

This is a renderer-only contract. No Element implements it in `paste-elements` today, so the emitted markup stays static: the classes and data attributes below are the boundary a future Element must honour, not a description of shipped behaviour. Callers needing motion today use [Marquee](#marquee), whose Element exists.

### ViewModel: Carousel

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | yes | - | Unique identifier for the carousel |
| `autoCycleMs` | int | no | `0` | Auto-cycle interval in milliseconds (0 = disabled) |
| `showIndicators` | boolean | no | `false` | Show dot indicators |
| `cssClass` | string | no | `""` | Additional CSS class |

### ViewModel: CarouselSlide

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `content` | string | no | `""` | Slide content |
| `cssClass` | string | no | `""` | Additional CSS class |

### Example (Scala)

```scala
case class Carousel(
  name: String,
  autoCycleMs: Int = 0,
  showIndicators: Boolean = false,
  cssClass: String = ""
)
```

### Usage

```scala
@paste.surface.components.html.carousel(Carousel("hero-carousel", autoCycleMs = 5000, showIndicators = true)) {
  <div class="paste-ui-carousel-item">Slide 1</div>
  <div class="paste-ui-carousel-item">Slide 2</div>
  <div class="paste-ui-carousel-item">Slide 3</div>
}
```

### HTML Output

```html
<div class="paste-ui-carousel"
     data-paste-carousel-name="{name}"
     data-paste-carousel-autocycle="{autoCycleMs}"
     data-paste-carousel-indicate>
  <div class="paste-ui-carousel-items">
    <!-- slide content -->
  </div>
</div>
```

### JS Module

None. An Element named `paste.ui.carousel` would own arrow construction, indicators, and touch handling; until one is published, nothing enhances this markup.

### CSS Classes

| Class | Description |
|-------|-------------|
| `paste-ui-carousel` | Container |
| `paste-ui-carousel-items` | Slide track (flex container) |
| `paste-ui-carousel-item` | Individual slide |
| `paste-ui-carousel-control` | Nav button base |
| `paste-ui-carousel-controls-next` | Next arrow |
| `paste-ui-carousel-controls-prev` | Previous arrow |
| `paste-ui-carousel-controls-inactive` | Disabled arrow state |
| `paste-ui-carousel-indicator` | Indicator dots container |
| `paste-ui-carousel-indicator-item` | Individual dot |
| `paste-ui-carousel-indicator-item-active` | Active dot |
| `paste-ui-carousel-loaded` | Added after initialization |

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

The Element scans `[data-paste-marquee]` on initialization. Public `init(root)` returns the same controller on repeated calls for an initialized root. The controller provides `refresh()`, `pause()`, `resume()`, and `dispose()`. Call `refresh()` after changing the supplied item collection; automatic mutation observation is not required.

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

`dispose()` removes the Element's observers and listeners, restores the attributes and style properties it owns, and leaves original nodes, DOM order, and unrelated attributes and style properties intact. Browser checks must exercise both plain HTML and equivalent Surface-rendered output, including native fallback, reduced motion, pause/resume, refresh, repeated initialization, and disposal.

---

## Template Paths

| Component | Twirl | Jinja/Nunjucks |
|-----------|-------|----------------|
| Hero | `paste.surface.components.html.hero` | `paste/surface/components/hero.html` |
| ImageSequence | `paste.surface.components.html.imagesequence` | `paste/surface/components/imagesequence.html` |
| Address | `paste.surface.components.html.address` | `paste/surface/components/address.html` |
| Logo | `paste.surface.components.html.logo` | `paste/surface/components/logo.html` |
| SectionNav | `paste.surface.components.html.sectionNav` | `paste/surface/components/section-nav.html` |
| Carousel | `paste.surface.components.html.carousel` | `paste/surface/components/carousel.html` (markup only; no Element) |
| Marquee | `paste.surface.components.html.marquee` | `paste/surface/components/marquee.html` |
