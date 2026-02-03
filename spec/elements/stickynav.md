# Stickynav Element

Navigation bar that sticks to the top of the viewport on scroll.

## Module

```
paste-elements/modules/stickynav/
├── stickynav.js
├── stickynav.scss
└── _variables.scss
```

## JavaScript API

**Module:** `paste.ui.stickynav`

**Dependencies:**
- `paste.dom`
- `paste.event`
- `paste.ui.throttle`

### Activation

Elements with `data-paste-stickynav` attribute are automatically initialized.

```html
<nav data-paste-stickynav>
  <a href="#about">About</a>
  <a href="#contact">Contact</a>
</nav>
```

### Data Attributes

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-paste-stickynav` | - | Enable sticky behavior (required) |
| `data-paste-stickynav-offset` | number | Offset from top in pixels |
| `data-paste-stickynav-hide-on-scroll` | `"true"` | Hide when scrolling down |

### Methods

```javascript
paste.ui.stickynav.init();    // Re-initialize
paste.ui.stickynav.update();  // Force position update
```

## SCSS Variables

```scss
$paste-stickynav-height: 50px !default;
$paste-stickynav-background: #fff !default;
$paste-stickynav-border-color: rgba(0, 0, 0, 0.1) !default;
$paste-stickynav-shadow: 0 2px 4px rgba(0, 0, 0, 0.1) !default;
$paste-stickynav-transition: transform 0.3s ease !default;
```

## CSS Classes

| Class | Description |
|-------|-------------|
| `.paste-stickynav` | Base sticky nav styles |
| `.paste-stickynav--stuck` | Applied when nav is stuck |
| `.paste-stickynav--hidden` | Applied when hidden on scroll |

## Example

```html
<nav class="paste-stickynav" 
     data-paste-stickynav 
     data-paste-stickynav-hide-on-scroll="true">
  <div class="paste-container">
    <a href="/">Logo</a>
    <ul>
      <li><a href="#about">About</a></li>
      <li><a href="#services">Services</a></li>
      <li><a href="#contact">Contact</a></li>
    </ul>
  </div>
</nav>
```
