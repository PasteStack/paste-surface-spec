# Heroscroll Element

Hero section with optional parallax scrolling effect.

## Module

```
paste-elements/modules/heroscroll/
├── heroscroll.js
├── heroscroll.scss
└── _variables.scss
```

## JavaScript API

**Module:** `paste.ui.heroscroll`

**Dependencies:**
- `paste.dom`
- `paste.event`
- `paste.ui.throttle`

### Activation

Elements with `data-paste-hero` attribute are automatically initialized.

```html
<section data-paste-hero="main" data-paste-parallax="true">
  <h1>Welcome</h1>
</section>
```

### Data Attributes

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-paste-hero` | string | Hero identifier (required) |
| `data-paste-parallax` | `"true"` / `"false"` | Enable parallax effect |

### Methods

```javascript
paste.ui.heroscroll.init();           // Re-initialize heroes
paste.ui.heroscroll.updateParallax(); // Force parallax update
```

## SCSS Variables

```scss
$paste-hero-min-height: 50vh !default;
$paste-hero-min-height-full: 100vh !default;
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.paste-ui-hero` | Base hero styles |
| `.paste-ui-hero-full` | Full viewport height |
| `.paste-ui-hero-parallax` | Parallax background positioning |

## Example

```html
<section class="paste-ui-hero paste-ui-hero-full" 
         data-paste-hero="main" 
         data-paste-parallax="true"
         style="background-image: url('/images/hero.jpg')">
  <div class="paste-container">
    <h1>Welcome to Our Site</h1>
    <p>Scroll down to see the parallax effect</p>
  </div>
</section>
```

## Surface Component

In `paste-surface-scala`, use the `Hero` component:

```scala
@import com.pastestack.surface.view_models.components.Hero

@paste.surface.components.html.hero(Hero(
  name = "main",
  parallax = true,
  fullHeight = true
)) {
  <h1>Welcome</h1>
}
```
