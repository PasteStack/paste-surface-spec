# Heroscroll Element

Hero sections with an optional background parallax, an image fade and a
content fade as the hero scrolls away. The hero reads correctly without the
module; the effects are enhancements on top.

## Module

```
paste-elements/modules/heroscroll/
├── heroscroll.js
├── heroscroll.scss     (stylesheet module paste.ui.heroscroll)
└── _mixin.scss         (mixin paste-ui-heroscroll)
```

## JavaScript

**Module:** `paste.ui.heroscroll`

**Dependencies:**
- `paste.util`
- `paste.dom`
- `paste.event`
- `paste.has`
- `paste.ui.utilities.animation-frame`
- `paste.ui.utilities.mediaquery`
- `polyfills.getcomputedstyle`

There is no JavaScript API and no application event. The module binds once,
when it is defined.

### Activation

Every element carrying the `paste-ui-hero` class, with its first
`.paste-ui-hero-image` and `.paste-ui-hero-content` descendants. No data
attribute activates it: the `data-paste-hero` and `data-paste-parallax`
attributes Surface emits are markers the module does not read.

### Attributes

| Attribute | On | Description |
|-----------|----|-------------|
| `force-full-height` | image | The image's inline height follows the viewport height — geometry, applied at bind and on resize whatever the motion preference. On touch devices it is re-applied only when the viewport width or the screen orientation changes |
| `data-hero-image-fixed` | image | No parallax background position |
| `data-hero-image-fade` | image | The image fades as the hero leaves the viewport |
| `data-hero-min-opacity` | image | Plain decimal from 0 to 1 (`0.25`, `.25`, `1.`), read untrimmed; the fade never writes an opacity below it. Any other spelling, or a value above 1, means 0 |

### Navigation

Use ordinary anchors, such as `<a href="#details">Details</a>`, and an `id`
on the destination. Author `tabindex="-1"` when the destination should take
focus. Heroscroll does not handle clicks or navigation. The former
`data-hero-hashclick` attribute has no behavior and should be removed.

### Behaviour

- The content fade (a hero with both content and an image), the image fade
  and the parallax are owned inline writes: releasing an effect puts back the
  authored inline value unless another writer replaced it since. The
  parallax writes one layer, `50% <offset>px` with
  `background-attachment: fixed`; a px vertical `background-position` is its
  base, a percentage or keyword contributes none.
- The effects run only while `prefers-reduced-motion` is observable and not
  `reduce`, as `paste.ui.utilities.mediaquery` reports it; an unobservable
  preference counts as reduced.
- Touch devices (`paste.has`) get the `paste-ui-hero-touch` class and no
  motion effects; a resize listener is bound there only for
  `force-full-height`.
- `paste-ui-heroscroll-loaded` is added to the root element and to `body`
  whenever the module is defined, with or without heroes.
- Work runs in one phased animation-frame request per frame: reads before
  writes, and nothing while the effects stand down except resize geometry.

## Mixin parameters

`@include paste-ui-heroscroll(...)`; `heroscroll.scss` includes it with the
defaults.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `$height` | `80%` | Hero height |
| `$content-width` | `976px` | Content column width |
| `$content-padding-x` | `20px` | Side padding once the viewport is narrower than the column |

## CSS Classes

| Class | Description |
|-------|-------------|
| `.paste-ui-hero` | Hero section: `position: relative`, `overflow: hidden`, `$height` tall |
| `.paste-ui-hero-content-wrap` | Optional table wrapper that centers the content vertically |
| `.paste-ui-hero-content` | Content column |
| `.paste-ui-hero-image` | Absolutely positioned covering background image the module drives |
| `.paste-ui-hero-basicimage` | The same presentation, never discovered by the module |
| `.paste-ui-hero-touch` | Added by the module on touch devices |

Any other child of the hero sits in its normal flow beside the full-height
content wrap: before the wrap it pushes the content down, after it the hero's
`overflow: hidden` clips it. An image sequence's skip control is such a child,
so the page positions it out of flow (see
[components](../view_models/components.md#hero)).

## Example

```html
<section class="paste-ui-hero" id="hero-main">
  <div class="paste-ui-hero-image" force-full-height data-hero-image-fade></div>
  <div class="paste-ui-hero-content">
    <h1>Welcome</h1>
    <p>Scroll down to see the effect</p>
  </div>
</section>
```

The image's `background-image` and the hero's height are page CSS.

## Surface Component

In `paste-surface-scala`, use the `Hero` component:

```scala
@import com.pastestack.surface.view_models.components.Hero

@paste.surface.components.html.hero(Hero(
  name = "main",
  showImage = true
)) {
  <h1>Welcome</h1>
}
```

The hero section carries its `id` and `tabindex="-1"` so native fragment
links can focus it.

`showImage` emits the `paste-ui-hero-image` element; `disableParallax` emits
`paste-ui-hero-basicimage` instead, which the module never discovers. A hero
carrying an `imageSequence` keeps `paste-ui-hero-image` as the sequence host
and adds `data-hero-image-fixed`, so the parallax never writes the
sequence's frames. There is no `parallax` or `fullHeight` parameter: height is
the mixin's `$height` or page CSS, and `force-full-height` is authored markup.

The mixin applies to the caller's hero root selector; `heroscroll.scss` selects `.paste-ui-hero`. Internal hero part classes remain the markup contract. Place custom includes inside the root selector; definition imports alone emit nothing.
