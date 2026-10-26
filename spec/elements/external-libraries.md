# Named external libraries

Use an app-owned Paste module to declare a library URL as a runtime dependency.
The build graph's `@requires` entries name known modules; JAM requests that
wrapper or its consumer. Surface already provides `Jam(js = Seq("libs.jquery"))`.
There is no separate external-library element or implicit dependency inference.

```javascript
/**
 * @requires paste
 * @module libs/jquery
 */
paste.define('libs.jquery', ['/vendor/jquery.js'], function () {
    'use strict';
    return window.jQuery;
});
```

The application supplies and pins the URL. Consumer factories declare
`libs.jquery` as both a named build requirement and a runtime dependency.
They receive its returned value after the URL dependency loads. A nested
`paste.require` inside a wrapper factory does not defer the wrapper's activation.

The core URL loader does not accept arbitrary script attributes. Keep authored
script elements for libraries whose configuration requires those attributes.
