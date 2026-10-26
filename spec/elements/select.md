# Native select appearance

`paste.ui.select` generalizes the original branded-select behavior. The native select
remains the control. JavaScript reflects the selected option's visible label
into an authored sibling; CSS supplies the custom face. It does not build a
menu, intercept clicks, copy values into hidden inputs, or own selection.

```html
<label>Shipping region
  <span class="paste-ui-select">
    <select name="region" required data-paste-select>
      <option value="">Choose a region</option>
      <option value="ct">Connecticut</option>
      <option value="ny" label="New York">New York State</option>
    </select>
    <span data-paste-select-value aria-hidden="true"></span>
  </span>
</label>
```

Load `paste.ui.select` and `modules/select/select.scss` for the custom face.
Without JavaScript the real select stays visible and usable. The browser owns
focus, keyboard/pointer interaction, disabled/required behavior, form values
and reset. The displayed label is not the submitted value. The decorative
sibling is excluded from the accessible name.

The select carries `data-paste-select`. Its next element sibling must carry
`data-paste-select-value`; intervening whitespace is harmless. The module
writes only that sibling's `textContent` and the select's
`data-paste-select-ready` marker. It handles initial selection, native change,
and completed, uncancelled form reset, including external `form=` controls.
No selected option means empty reflected text. Multiple selects, listboxes
(`size > 1`), and missing companions keep their native appearance.

Authored changes to options, selection, companion markup, or form association
can be refreshed with the inherited `init(parent)` operation. Include the root
select itself or a containing subtree. Repeated initialization adds no
duplicate listeners. Programmatic value assignment dispatches no native
change event; the caller dispatches change or invokes `init` after its update.
The module observes no mutations, runs no polling, and measures no geometry.

CSS hides the select's paint only when its prepared companion can be shown.
The select keeps its layout box and remains the pointer and keyboard target.
Hidden declarations stay hidden; hiding a companion exposes the real control.
Forced-colors mode also uses the native control. Browsers without the required
CSS selector support retain the native appearance. Focus-visible and disabled
presentation follow the native select through adjacent-sibling selectors.

`modules/select/_mixin.scss` emits nothing on import. Apply
`paste-ui-select($background, $border, $focus, $padding)` within the authored
wrapper selector. The emitting stylesheet chooses `.paste-ui-select` using
`$paste-prefix`. Behavioral markers retain their documented names when the
caller chooses a different styling selector.

Changes from the original are explicit: the wrapper and generic `.value`
class become module-owned declarations; next-element adjacency allows normal
HTML formatting; `option.label` follows the browser's displayed label; text
is never parsed as markup; reset is reflected after the native default action.
The old unconditional body `keyup` listener is unnecessary for this native
selection contract. The original contract delegated these events to the body; this module binds
only eligible controls during `init`, so dynamically inserted controls require
`init` before their changes are reflected. Empty pages acquire no select event
listeners. Brand artwork, typography and colors remain caller CSS.

## Surface Scala

`formfield.html.select(field: Select)(options: Html)` emits the same structure.
`Select` carries native attributes, label, feedback and optional data
attributes. Options, optgroups, values and `selected` defaults are ordinary
option markup in the content slot. There is no second selection model:

```scala
@paste.surface.components.formfield.html.select(
  Select("region", label = Some("Shipping region"), required = true,
    dataAttributes = Map("paste-select" -> ""))
) {
  <option value="">Choose a region</option>
  <option value="ct" selected>Connecticut</option>
}
```

Without a declared id the label wraps the select. With a caller-owned id it
uses `for`. Descriptions and errors require that id for feedback association.
Surface emits neither the runtime ready marker nor event handlers. Omit the
`paste-select` data attribute for an ordinary select without the enhancement.
