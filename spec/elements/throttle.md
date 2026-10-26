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
| `id` | any | Optional. Absent or falsy: share by function source plus period. Truthy ids share by property-key coercion |
| `runFirst` | boolean | Optional. Falsy: trailing mode. Truthy: leading mode |

### Behaviour

- **Default mode:** the first call opens a window and runs once at its end
  with that first call's context and arguments. Further calls are discarded.
- **Leading mode (`runFirst`):** the first call runs at once. There is no
  trailing call. Reentry during the callback is still inside the same window.
- **Identity:** wrappers without ids share the original function-source-plus-period key.
  Truthy explicit ids share by property-key coercion: `1` and `"1"` share.
  The opening call owns its function, period and mode.
- **Errors:** a thrown timer registration releases the window and propagates.
  Callback cleanup occurs even when the callback throws. Timers are assumed
  to obey their native asynchronous contract.

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

No paste-elements module depends on it. Frame-based effects use the shared
animation-frame utility; simple input effects run directly.

## Note

The source moved from `modules/throttle/throttle.js` to
`modules/utilities/throttle/throttle.js`; the module name,
`paste.ui.utilities.throttle`, is unchanged (there is no `paste.ui.throttle`).
It has no stylesheet.
