# Throttle Utility

Event throttling utility for performance optimization.

## Module

```
paste-elements/modules/throttle/
└── throttle.js
```

## JavaScript API

**Module:** `paste.ui.throttle`

**Dependencies:** None (core utility)

### Usage

```javascript
var throttledFn = paste.ui.throttle(callback, delay, context);
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | function | Function to throttle |
| `delay` | number | Minimum time between calls (ms) |
| `context` | string | Optional context identifier |

### Example

```javascript
paste.define(
  'mymodule',
  ['paste.ui.throttle'],
  function(module, throttle) {
    
    var onScroll = throttle(function() {
      console.log('Scrolled');
    }, 100, 'scroll-handler');
    
    window.addEventListener('scroll', onScroll);
  }
);
```

### Internal Use

Used by other Paste elements:
- `heroscroll` — throttles parallax updates
- `stickynav` — throttles scroll position checks
- `smoothscroll` — throttles scroll animation frames

## Note

This is a **utility module**, not a UI element. It has no SCSS component.
