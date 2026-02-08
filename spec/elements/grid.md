# Grid Structure

12-column responsive grid system.

## Module

```
paste-elements/structure/grid/
├── grid.scss
└── _variables.scss
```

## SCSS Variables

```scss
// Grid
$paste-grid-columns: 12 !default;
$paste-grid-gutter: 1.5rem !default;
$paste-grid-gutter-sm: 1rem !default;

// Container max-widths
$paste-container-max-width-sm: 540px !default;
$paste-container-max-width-md: 720px !default;
$paste-container-max-width-lg: 960px !default;
$paste-container-max-width-xl: 1140px !default;
$paste-container-max-width-xxl: 1320px !default;

// Container padding
$paste-container-padding-x: $paste-grid-gutter !default;
```

## CSS Classes

### Container

| Class | Description |
|-------|-------------|
| `.paste-container` | Centered container with max-width |
| `.paste-container-fluid` | Full-width container |

### Row

| Class | Description |
|-------|-------------|
| `.paste-row` | Flex row with negative margins |

### Columns

| Class | Description |
|-------|-------------|
| `.paste-col-{n}` | Column spanning n/12 |
| `.paste-col-{breakpoint}-{n}` | Responsive column |
| `.paste-col-auto` | Auto-width column |

Breakpoints: `sm`, `md`, `lg`, `xl`, `xxl`

## Example

```html
<div class="paste-container">
  <div class="paste-row">
    <div class="paste-col-12 paste-col-md-6 paste-col-lg-4">
      Column 1
    </div>
    <div class="paste-col-12 paste-col-md-6 paste-col-lg-4">
      Column 2
    </div>
    <div class="paste-col-12 paste-col-lg-4">
      Column 3
    </div>
  </div>
</div>
```

## Customization

Override variables before importing:

```scss
$paste-grid-columns: 16;
$paste-grid-gutter: 2rem;
$paste-container-max-width-xl: 1200px;

@import '@pastestack/elements/structure/grid/grid';
```
