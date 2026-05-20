---
name: aos-frontend
description: Reviews frontend code for component design, CSS architecture, performance, accessibility, and state management. Reports FAIL/WARN/PASS with file references and concrete fixes. Use when user asks to review UI code, component design, frontend architecture, or says "check my React/Vue components".
---

# /aos-frontend

Select the files to review (or describe the component), then run `/aos-frontend`.

For targeted reviews: `/aos-frontend components` · `/aos-frontend forms` · `/aos-frontend styles` · `/aos-frontend performance`

## What gets checked

### Component design
- [ ] Single responsibility — one concern per component
- [ ] Props are minimal, typed, and have sensible defaults
- [ ] No prop drilling deeper than two levels — use context or a state manager
- [ ] Presentational components contain no business logic or data fetching
- [ ] Container/smart components handle data; presentational ones handle display

### CSS and styling
- [ ] Styling approach is consistent — no mixing of inline styles, CSS modules, and global styles in the same component
- [ ] No magic numbers — use design tokens or CSS custom properties
- [ ] No hardcoded colours — all colours from the theme
- [ ] Class names describe purpose, not appearance (`card-header`, not `blue-bold-text`)
- [ ] No `!important` except in reset or utility layers

### Responsive design
- [ ] Mobile-first — base styles apply to mobile, media queries add complexity
- [ ] Breakpoints use design-system values, not arbitrary pixel values
- [ ] No fixed-width containers that break on small screens
- [ ] Touch targets ≥ 44×44px on all interactive elements

### Accessibility
- [ ] Interactive elements are keyboard-accessible (focusable and activatable with Enter/Space)
- [ ] All images have meaningful `alt` text — decorative images use `alt=""`
- [ ] Form inputs have associated `<label>` elements
- [ ] Colour is not the only means of conveying information
- [ ] Focus indicator visible on all interactive elements
- [ ] ARIA attributes used only when native semantics are insufficient

### Performance
- [ ] No unused imports — tree-shaking must work
- [ ] Large components lazy-loaded (`React.lazy` / Vue `defineAsyncComponent`)
- [ ] Expensive computations memoized (`useMemo` / `computed`)
- [ ] Event handlers stabilised — not re-created on every render (`useCallback`)
- [ ] Images optimised and served in modern formats (WebP/AVIF)
- [ ] No layout thrashing — DOM reads and writes batched

### State management
- [ ] Local state for UI-only concerns (open/closed, hover, form draft)
- [ ] Global state only for cross-component shared domain data
- [ ] No derived state stored — compute from source of truth
- [ ] Async state always has loading, error, and data fields

### Error and loading states
- [ ] Every async operation has a loading indicator
- [ ] Every async operation has a user-visible error state
- [ ] Empty states handled — no blank screens
- [ ] Error boundaries wrap component trees that may throw

## Output format

```
[FAIL] Accessibility — input missing associated label
File: src/components/LoginForm.vue:24
Fix: add <label for="email">Email address</label> and id="email" on the input
Standard: WCAG 2.1 SC 1.3.1 (Info and Relationships)

[WARN] Performance — expensive filter inside render, not memoised
File: src/components/ProductList.tsx:18
Fix: const filtered = useMemo(() => products.filter(p => p.active), [products])

[PASS] Component design — 12 checks passed

Summary: 1 FAIL · 1 WARN · 12 PASS
```

## Full standards reference

See [REFERENCE.md](REFERENCE.md) for annotated code examples for each rule.
