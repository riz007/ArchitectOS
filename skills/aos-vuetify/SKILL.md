---
name: aos-vuetify
description: Reviews Vuetify 3 + Vue 3 code for correct component usage, Material Design 3 patterns, form validation, theme customisation, and performance. Reports FAIL/WARN/PASS. Use when user asks to review Vuetify components, build Vuetify UI, or says "check my Vuetify code".
---

# /aos-vuetify

Select files to review or describe what you are building, then run `/aos-vuetify`.

For targeted reviews: `/aos-vuetify forms` · `/aos-vuetify tables` · `/aos-vuetify theme` · `/aos-vuetify layout`

## What gets checked

### Component usage
- [ ] Vuetify components used where they exist — no custom reimplementation of `v-btn`, `v-card`, `v-dialog`, etc.
- [ ] `v-model` wired correctly on form components (`v-text-field`, `v-select`, `v-checkbox`, `v-autocomplete`)
- [ ] `density` prop set appropriately: `default`, `comfortable`, or `compact`
- [ ] Correct variant used: `outlined`, `filled`, `underlined`, `solo`, `plain`, `elevated`, `tonal`
- [ ] No mixing of Vuetify 2 and Vuetify 3 API patterns

### Forms and validation
- [ ] Validation rules are arrays of functions that return `string | true`
- [ ] `v-form` wraps all inputs with a `ref` for programmatic `validate()` / `reset()` calls
- [ ] `validate()` called and awaited before every submit — form never submits in invalid state
- [ ] Error messages are user-readable — not field names or error codes
- [ ] `clearable` prop added on search and filter inputs

### Layout and grid
- [ ] `v-container`, `v-row`, `v-col` used for layout — no manual CSS grid/flexbox overriding Vuetify's system
- [ ] Responsive `cols`, `sm`, `md`, `lg`, `xl` props set on `v-col`
- [ ] `v-spacer` used inside `v-row` / `v-toolbar` instead of margin hacks

### Data tables
- [ ] `v-data-table` or `v-data-table-server` used for tabular data — no hand-rolled `<table>`
- [ ] `items-per-page` set with a sensible default (10 or 25)
- [ ] `:loading` prop handles the loading state
- [ ] `item-value` set to a unique key — never the index
- [ ] Server-side sorting and filtering used for large datasets via `:server-items-length`

### Theme and styling
- [ ] Colours reference theme tokens (`primary`, `secondary`, `error`, `success`, `surface`) — no hardcoded hex values
- [ ] Custom theme defined in `createVuetify({ theme })` — not scattered CSS variable overrides
- [ ] `v-theme-provider` used to scope dark/light variants to a section
- [ ] No `!important` overriding Vuetify's internal classes in scoped styles

### Dialogs and overlays
- [ ] `v-dialog` has `max-width` set (prevents full-screen on desktop)
- [ ] Dialogs closeable via the `×` button AND by clicking the overlay
- [ ] `v-overlay` used for custom overlays — not a `position:fixed` div
- [ ] Focus trap inside dialog is intact — do not break Vuetify's built-in focus management

### Performance
- [ ] Vuetify imported with tree-shaking (components explicitly listed or using the auto-import plugin)
- [ ] Large datasets in `v-data-table` use virtual scrolling or server-side pagination
- [ ] `v-lazy` wraps off-screen items in long scrollable lists

## Output format

```
[FAIL] Forms — form submits without awaiting validate()
File: src/views/RegisterView.vue:38
Fix:
  const { valid } = await form.value.validate()
  if (!valid) return
  await register(fields)

[WARN] Theme — hardcoded hex colour #1976D2 instead of a theme token
File: src/components/AppHeader.vue:15
Fix: use color="primary" prop or var(--v-theme-primary) in CSS

Summary: 1 FAIL · 1 WARN · 11 PASS
```

## Full reference

See [REFERENCE.md](REFERENCE.md) for complete code examples for every pattern.
