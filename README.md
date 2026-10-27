# paste-surface-spec

Language-agnostic specification for PasteStack Surface Rendering Layer.

## Overview

This specification defines the contracts for rendering HTML templates using PasteStack. Implementations:

- **Scala/Twirl** → `paste-surface-scala` ✓
- **Pekko HTTP binding** → `paste-surface-pekko` (shipped with the Scala implementation)
- **Python/Jinja** → `paste-surface-python` (planned)
- **Basic HTML** → Use `paste-assetgraph` directly (no surface needed)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ Level 4: paste-surface-*                                        │
│   Templated UI (Scala/Twirl, Python/Jinja)                      │
├─────────────────────────────────────────────────────────────────┤
│ Level 3: paste-surface-spec (this repo)                         │
│   Contract for how elements get templated                        │
├─────────────────────────────────────────────────────────────────┤
│ Level 2: paste-elements                                          │
│   UI behaviors (JS + SCSS only, YUI-style modules)               │
├─────────────────────────────────────────────────────────────────┤
│ Level 1: paste-assetgraph                                        │
│   Asset pipeline (Rust binary; renders JAM markup, owns URLs and │
│   the manifest)                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## MVP Pattern

Inspired by Model-View-Presenter pattern:

```
Route -> Presenter -> ViewModelFactory -> ViewModel -> Template
                           ↓
                      (or JSON)
```

**Presenters are optional.** Simple sites use ViewModels directly in templates.

## Specification Contents

### View Models

- [Page](spec/view_models/page.md) — PageMeta (SEO, meta tags)
- [Components](spec/view_models/components.md) — Hero, Address
- [Includes](spec/view_models/includes.md) — CSS/JS asset injection; JAM markup rendered by paste-assetgraph

### View Model Factories

- [Factories](spec/view_model_factories/factories.md) — PageMetaFactory, HeroFactory, IncludesFactory

### Presenters (Optional)

- [Presenters](spec/presenters/presenters.md) — PagePresenter, HomePagePresenter

### Layouts

- [Web Base Layout](spec/layouts/webbase.md) — Base HTML structure

### Rendering

- [Rendering a View Model](spec/rendering/rendering.md) — Page/IO reply fragment/JSON from one view model

### Components

- [Original enhancements](spec/elements/original-enhancements.md) — character filtering, autosave, image upload, rich tooltips, native submit guards, select navigation, fixed-slot sorting and text reflection
- [Multistate](spec/elements/multistate.md) — the radio/selected-panel/history port and its Surface markup
- [Select](spec/elements/select.md) — native selection with an optional custom CSS face; generalized from the original branded select

- [Hero, Address](spec/view_models/components.md)
- [Forms](spec/components/formfield/form.md) — Form, Input, Button, Textarea, Select, Hidden

### Config

- [Configuration](spec/config/config.md) — SurfaceConfig, loading from resources

## Directory Structure

```
spec/
├── view_models/
│   ├── page.md           # PageMeta
│   ├── components.md     # Hero, Address
│   └── includes.md       # CSSInclude, JSInclude (JAM via paste-assetgraph)
├── view_model_factories/
│   └── factories.md      # PageMetaFactory, HeroFactory, IncludesFactory
├── presenters/
│   └── presenters.md     # PagePresenter (optional)
├── layouts/
│   └── webbase.md        # Base HTML layout
├── rendering/
│   └── rendering.md      # Page/IO reply fragment/JSON rendering contract
├── components/
│   └── formfield/
│       └── form.md       # Form, Input, Button, Textarea, Hidden
└── config/
    └── config.md         # SurfaceConfig
```

## Relationship: Elements → Components

```
paste-elements (JS + SCSS)          paste-surface-* (Templates)
─────────────────────────           ────────────────────────────
modules/heroscroll/heroscroll.js →  components/hero.html
modules/stickynav/stickynav.js   →  components/hero.html (data attrs)
modules/autogrow/autogrow.js     →  components/formfield/textarea.html
modules/form/form_validity/form_validity.js →  native form validity
modules/form/form_apply/form_apply.js →  form.paste-ui-apply
modules/form/form_html/form_html.js →  form.paste-ui-formhtml
modules/form/form_autosave/form_autosave.js →  form[data-ui-autosave], declared reply targets and bindings
modules/*/*.scss                 →  (bundled CSS)
```

**Elements** = JS behaviors + SCSS styles  
**Components** = Template implementations that use elements

## License

Apache License, Version 2.0. See `LICENSE` and `NOTICE.md`.
