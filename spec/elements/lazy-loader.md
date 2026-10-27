# Lazy HTML content

`paste.ui.lazy_loader` restores caller-triggered deferred HTML loading.
An element's `data-lazy-load` contains the trusted HTML URL. It is independent
of forms, autosave and external JavaScript loading.

The original public names remain:

- `load_all_content(parent)` requests declared descendants, in document order.
- `load_visible_content(parent)` requests only descendants whose `offsetWidth`
  and `offsetHeight` are positive. This is layout visibility, not viewport entry.
- `load_lazy_content(element)` explicitly requests that declaration, even if hidden.
- `set_init_new_content(callback)` replaces the content initializer. On success
  it receives the element as both its argument and `this`.

The module performs no automatic scan and installs no observers or listeners.
The original caller invoked visible loading on startup and `hashchange`; its
radio tabs invoked it after changing visibility. The owning page supplies that
wiring. Content insertion alone neither loads scripts nor initializes unrelated
modules. A caller can initialize `paste.ui.form.form_validity` or its own graphs in the hook.

Successful string replies replace `innerHTML`, remove `data-lazy-load`, then
invoke the hook. Pending loads of one element are deduplicated. Failure or a
request deadline — `data-lazy-load-timeout` in decimal milliseconds on the
element, default 30,000, `0` for none — leaves the declaration for an
explicit retry. A response for
an older authored URL cannot overwrite a changed declaration. No background
retry, polling or request on scroll is added.

Surface's `LazyContent(url, id, cssClass)(fallback)` emits the declaration and
useful initial content. For example, an application module depending on
`paste.ui.lazy_loader` can request visible content after its own state change:

```javascript
lazy_loader.load_visible_content(document.getElementById('dashboard'));
```

Use the literal authored dashboard id; the library introduces no global id.
Loading the module alone does not select a page's visibility events.
