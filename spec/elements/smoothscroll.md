# Smoothscroll Element

Smooth scrolling for anchor links.

## Module

```
paste-elements/modules/smoothscroll/
└── smoothscroll.js
```

## JavaScript API

**Module:** `paste.ui.smoothscroll`

**Dependencies:**
- `paste.dom`
- `paste.event`

### Activation

Automatically intercepts anchor links (`<a href="#section">`).

```html
<a href="#about">Go to About</a>

<section id="about">
  <h2>About Us</h2>
</section>
```

### Data Attributes

| Attribute | Values | Description |
|-----------|--------|-------------|
| `data-paste-smoothscroll` | `"false"` | Disable for specific link |
| `data-paste-smoothscroll-offset` | number | Offset from target in pixels |
| `data-paste-smoothscroll-duration` | number | Animation duration in ms |

### Methods

```javascript
paste.ui.smoothscroll.init();                    // Re-initialize
paste.ui.smoothscroll.scrollTo(element, offset); // Scroll to element
paste.ui.smoothscroll.scrollToId(id, offset);    // Scroll to ID
```

### Configuration

```javascript
paste.ui.smoothscroll.config = {
  duration: 500,        // Animation duration (ms)
  offset: 0,            // Global offset (px)
  easing: 'easeInOut'   // Easing function
};
```

## Example

```html
<!-- Navigation with smooth scroll -->
<nav>
  <a href="#hero">Home</a>
  <a href="#about" data-paste-smoothscroll-offset="100">About</a>
  <a href="#contact">Contact</a>
  <a href="/other-page" data-paste-smoothscroll="false">Other Page</a>
</nav>

<!-- Sections -->
<section id="hero">...</section>
<section id="about">...</section>
<section id="contact">...</section>
```
