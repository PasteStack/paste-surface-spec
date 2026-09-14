# paste-surface-spec

Language-agnostic specification for PasteStack Surface Rendering Layer.

## Overview

This specification defines the contracts for rendering HTML templates using PasteStack. Implementations:

- **Scala/Twirl** → `paste-surface-scala` ✓
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
│   Asset pipeline (Rust binary, JAM URLs, manifest)               │
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
- [Includes](spec/view_models/includes.md) — CSS/JS asset injection with JAM

### View Model Factories

- [Factories](spec/view_model_factories/factories.md) — PageMetaFactory, HeroFactory, IncludesFactory

### Presenters (Optional)

- [Presenters](spec/presenters/presenters.md) — PagePresenter, HomePagePresenter

### Layouts

- [Web Base Layout](spec/layouts/webbase.md) — Base HTML structure

### Components

- [Hero, Address](spec/view_models/components.md)
- [Form Fields](spec/components/formfield/form.md) — Input, Button, Textarea, Hidden

### Config

- [Configuration](spec/config/config.md) — SurfaceConfig, loading from resources

## Directory Structure

```
spec/
├── view_models/
│   ├── page.md           # PageMeta
│   ├── components.md     # Hero, Address
│   └── includes.md       # CSSInclude, JSInclude (JAM)
├── view_model_factories/
│   └── factories.md      # PageMetaFactory, HeroFactory, IncludesFactory
├── presenters/
│   └── presenters.md     # PagePresenter (optional)
├── layouts/
│   └── webbase.md        # Base HTML layout
├── components/
│   └── formfield/
│       └── form.md       # Input, Button, Textarea, Hidden
└── config/
    └── config.md         # SurfaceConfig
```

## Relationship: Elements → Components

```
paste-elements (JS + SCSS)     paste-surface-* (Templates)
─────────────────────────      ────────────────────────────
src/js/heroscroll.js      →    components/hero.html
src/js/stickynav.js       →    components/hero.html (data attrs)
src/js/autogrow.js        →    components/formfield/textarea.html
src/scss/heroscroll.scss  →    (bundled CSS)
```

**Elements** = JS behaviors + SCSS styles  
**Components** = Template implementations that use elements

## License

Apache License, Version 2.0. See `LICENSE` and `NOTICE.md`.
