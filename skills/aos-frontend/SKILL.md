---
name: aos-frontend
description: Reviews frontend code for component design, CSS architecture, performance, accessibility, state management, bundle size, and internationalisation readiness. Reports FAIL/WARN/PASS with file references and concrete fixes. Use when user asks to review UI code, component design, frontend architecture, or says "check my React/Vue components".
---

# /aos-frontend

Select the files to review (or describe the component), then run `/aos-frontend`.

For targeted reviews: `/aos-frontend components` · `/aos-frontend styles` · `/aos-frontend performance` · `/aos-frontend a11y`

For UX and interaction design review, follow up with `/aos-ux`.

---

## What gets checked

### Component design
- [ ] Single responsibility — one concern per component
- [ ] Props are minimal, typed, and have sensible defaults
- [ ] No prop drilling deeper than two levels — use context or a state manager
- [ ] Presentational components contain no business logic or data fetching
- [ ] Container/smart components handle data; presentational ones handle display
- [ ] No side effects directly in render — use `useEffect` / `onMounted` / watchers

### CSS and styling
- [ ] Styling approach is consistent — no mixing of inline styles, CSS modules, and global styles in the same component
- [ ] No magic numbers — use design tokens or CSS custom properties
- [ ] No hardcoded colours — all colours from the theme
- [ ] Class names describe purpose, not appearance (`card-header`, not `blue-bold-text`)
- [ ] No `!important` except in reset or utility layers
- [ ] No styles that break in dark mode if the project supports it

### Responsive design
- [ ] Mobile-first — base styles apply to mobile, media queries add complexity
- [ ] Breakpoints use design-system values, not arbitrary pixel values
- [ ] No fixed-width containers that break on small screens
- [ ] Touch targets ≥ 44×44px on all interactive elements

### Accessibility (WCAG 2.1 AA)
- [ ] Interactive elements are keyboard-accessible (focusable, Enter/Space activatable)
- [ ] All images have meaningful `alt` text — decorative images use `alt=""`
- [ ] Form inputs have associated `<label>` elements
- [ ] Colour is not the only means of conveying information
- [ ] Focus indicator visible on all interactive elements — never `outline: none` without a replacement
- [ ] ARIA attributes used only when native semantics are insufficient
- [ ] Dynamic content changes announced via `aria-live` regions

### Performance and bundle size
- [ ] No unused imports — tree-shaking must work
- [ ] Large components and routes lazy-loaded (`React.lazy` / Vue `defineAsyncComponent`)
- [ ] Expensive computations memoised (`useMemo` / `computed`)
- [ ] Event handlers stabilised — not re-created on every render (`useCallback`)
- [ ] Images optimised and served in modern formats (WebP/AVIF), with `width` and `height` to prevent layout shift
- [ ] No heavy libraries (moment.js, lodash full bundle) where lighter alternatives exist
- [ ] Third-party scripts loaded with `async` or `defer`

### State management
- [ ] Local state for UI-only concerns (open/closed, hover, form draft)
- [ ] Global state only for cross-component shared domain data
- [ ] No derived state stored — compute from the source of truth
- [ ] Async state always has loading, error, and data fields

### Error and loading states
- [ ] Every async operation has a loading indicator
- [ ] Every async operation has a user-visible error state with a retry action
- [ ] Empty states handled — no blank screens
- [ ] Error boundaries wrap component trees that may throw

### Internationalisation readiness
- [ ] No hardcoded user-facing strings — all text goes through the i18n function (even if only one locale is supported today)
- [ ] Date and number formatting uses locale-aware APIs (`Intl.DateTimeFormat`, `Intl.NumberFormat`)
- [ ] No string concatenation to build sentences — use template keys with placeholders
- [ ] Layout does not break when text expands by 30% (common in German/French translations)

---

## Output format

```
[FAIL] Accessibility — input missing associated label
File: src/components/LoginForm.vue:24
Fix: add <label for="email">Email address</label> and id="email" on the input
Standard: WCAG 2.1 SC 1.3.1 (Info and Relationships)

[FAIL] i18n — hardcoded English string in button
File: src/components/ProductCard.tsx:34
Fix: replace "Add to cart" with t('product.addToCart')

[WARN] Performance — expensive filter inside render, not memoised
File: src/components/ProductList.tsx:18
Fix: const filtered = useMemo(() => products.filter(p => p.active), [products])

[WARN] Bundle — moment.js imported for date formatting
File: src/utils/format.ts:2
Fix: replace with date-fns (tree-shakeable) or native Intl.DateTimeFormat

[PASS] Component design — 12 checks passed

Summary: 2 FAIL · 2 WARN · 12 PASS
```

---

## Full standards reference

See [REFERENCE.md](REFERENCE.md) for annotated code examples for each rule.
