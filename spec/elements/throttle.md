# Throttle Utility

Rate-limits calls to a function: at most one call per window of a declared
period.

## Module

```
paste-elements/modules/utilities/throttle/
└── throttle.js
```

## JavaScript API

**Module:** `paste.ui.utilities.throttle`

**Dependencies:** None

The module value is the function itself. It is a utility for module authors,
not a declarative Element: nothing on the page activates it.

### Usage

```javascript
var throttled = throttle(fn, period, id, runFirst);
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fn` | function | The function to rate-limit |
| `period` | number | Window length in milliseconds |
| `id` | any | Optional. Absent or falsy: the wrapper owns a private window. A string names a window shared by text; any other truthy value names one by identity |
| `runFirst` | boolean | Optional. Falsy: trailing mode. Truthy: leading mode |

### Behaviour

- **Trailing mode:** the first call opens a window; when it ends, `fn` runs
  once with the context and arguments of the latest call made during it.
- **Leading mode:** the first call runs `fn` at once and opens a window. If
  more calls arrive during the window, `fn` runs once more when it ends, with
  the latest call's context and arguments, inside a fresh window — so a steady
  stream runs `fn` once per period.
- **Windows:** wrappers made without an id never share a window, so create
  the wrapper once and reuse it; a fresh wrapper per event is never throttled.
  Every wrapper carrying one truthy id joins that window, and the latest
  call's `fn` is the one its trailing call runs. The opening call fixes the
  window's period and mode.
- **Timers:** a window is open only while its timer is outstanding. When the
  host refuses the timer — by throwing, or by running the callback before
  `setTimeout` returns — the window closes again and `fn` does not run for
  that call; the next call tries again.

### Example

```javascript
paste.define(
  'mymodule',
  ['paste.event', 'paste.ui.utilities.throttle'],
  function (mymodule, event, throttle) {
    var onResize = throttle(function () {
          // measure and update
        }, 100),
        resizeSubscription = new event.Event.Subscription('resize', window, onResize);
    return mymodule;
  }
);
```

### Internal Use

No paste-elements module depends on it: the Elements schedule their work
through `paste.ui.utilities.animation-frame` instead.

## Note

The source moved from `modules/throttle/throttle.js` to
`modules/utilities/throttle/throttle.js`; the module name,
`paste.ui.utilities.throttle`, is unchanged (there is no `paste.ui.throttle`).
It has no stylesheet.
