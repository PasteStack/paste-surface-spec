# Multistate

`paste.ui.multistate` ports the original native-radio, selected-panel and history
implementation. A radio change updates the selected markers; CSS determines
what those markers show. The address records the selection with `pushState`.
There is no click interception or separate Surface selection model.

## Markup and CSS

One radio represents each key/value. Several panels may share that pair.
Arrange controls, labels and panels as siblings for the original selector:

```css
input[data-multistate-key]:checked ~ [data-multistate-state] { display: block; }
```

The marker in that rule is supplied by JavaScript. This complete example also
supplies native group names and value-specific reveal rules for the baseline:

```html
<style>
  .profile-view > [data-multistate-value] { display: none; }
  .profile-view > input:checked + label { font-weight: bold; }
  #profile-view-overview:checked ~ [data-multistate-value="overview"],
  #profile-view-details:checked ~ [data-multistate-value="details"],
  .profile-view > input[data-multistate-key]:checked ~ [data-multistate-state] {
    display: block;
  }
</style>
<fieldset class="profile-view">
  <legend>Profile view</legend>
  <input id="profile-view-overview" type="radio" name="profile-view" data-multistate-key="view" value="overview" checked>
  <label for="profile-view-overview">Overview</label>
  <input id="profile-view-details" type="radio" name="profile-view" data-multistate-key="view" value="details">
  <label for="profile-view-details">Details</label>
  <div data-multistate-key="view" data-multistate-value="overview">Overview panel</div>
  <div data-multistate-key="view" data-multistate-value="details">Details panel</div>
</fieldset>
```

The browser owns grouping, activation, arrow keys, focus and form values. Keep
controls focusable and labelled. Existing names and ids remain authored.
For original markup that omits them, Elements supplies a name of
`key + '$' + moduleGuid` and missing GUID ids. Generated ids do not create a
label association for the author. Without JavaScript, unnamed radios have no
exclusive group and no selected-panel marker is supplied.

Independent instances need different state keys, native names and ids.
Repeating a key/value across separate radio strips is not a mirroring contract.
The original trigger table holds one radio per pair. Marked content is optional:
a radio-only dimension still participates in state and history.

The module stylesheet hides marked panels; the page owns its reveal rules.
The enhanced marker is `data-multistate-state="value"`, accompanied by
`multistate-state-{key}-{value}`. Keys and values in the class suffix are URI
encoded so whitespace is not passed to `classList` as part of one token.

## State and history

On initialization, valid fragment selections win and every other dimension
uses its authored checked default. A radio change carries the other current
selections forward and preserves foreign key/value data from the fragment.
Serialization may reorder or normalize those foreign tokens; it does not
promise byte-for-byte fragment preservation.

A change calls `pushState` before updating/announcing the reflected state,
matching the original contract. This creates an entry without fragment navigation or native
`hashchange`. If the browser refuses the write, the selected panel still follows
the radio. Back and Forward read the address, not a foreign history-state object.
Both `popstate` and `hashchange` stay subscribed; duplicate unchanged transitions
produce no additional notification.

A later explicit state fragment selects the dimensions it names and clears
omitted dimensions. A plain anchor, including an explicit `#`, leaves the
selection alone. Back to an address with no fragment restores authored defaults.
Keys and values are URI encoded and decoded; malformed URI tokens are ignored.
Author valid Unicode strings; no nonstandard surrogate encoding is supplied.

## Public surface and lifecycle

The original optional API remains: `initialize(force)`, `events.multistatepop`,
`getCurrentState()`, `serializeState(dict)` and `deserializeState(string)`.
The public state and event payload share the current dictionary, as in the original;
treat them as read-only observations. A changed transition replaces that object.
Dictionaries have no prototype, so prototype-shaped names remain ordinary keys.
There is no snapshot-copying layer or queued reentrant-transition protocol.

`initialize(true)` disposes previous change subscriptions and reflection,
rescans declarations, and resolves the current fragment and authored defaults.
The module observes radio changes and history, not native form reset. It adds
no reset listener, timer, automatic reset history entry or mirrored-strip adapter.

## Surface binding

Use ordinary sibling inputs, labels and panels in the page template (Twirl in
Scala). The generic `formfield.input` template wraps each field and does not emit
this sibling structure or a checked default. No new component or Scala state
model is needed. Surface preserves the authored attributes and order; Elements
owns runtime markers and history.
