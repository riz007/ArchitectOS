# ArchitectOS Accessibility Standards

All user-facing applications must meet **WCAG 2.1 Level AA** compliance. Accessibility is not optional and must be validated before shipping any UI feature.

## Compliance Targets

| Standard | Requirement |
|---|---|
| WCAG 2.1 Level AA | Mandatory for all products |
| Keyboard navigation | 100% of interactive elements reachable |
| Screen reader support | Tested with NVDA + Chrome, VoiceOver + Safari |
| Color contrast | 4.5:1 for normal text, 3:1 for large text |
| Focus indicators | Visible on all interactive elements |

---

## Semantic HTML First

Correct HTML structure is the foundation. Do not use `div` when a semantic element exists.

```html
<!-- ❌ Div soup — no semantic meaning -->
<div class="header">
  <div class="nav">
    <div class="nav-item" onclick="go('/home')">Home</div>
  </div>
</div>
<div class="main">
  <div class="article">
    <div class="title">Post Title</div>
    <div class="content">...</div>
  </div>
</div>

<!-- ✅ Semantic structure -->
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/home">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>
<main>
  <article>
    <h1>Post Title</h1>
    <p>Content here.</p>
  </article>
</main>
```

### Landmark Regions

Every page must have these landmarks:

```html
<header>   <!-- Site header, logo, primary nav -->
<nav>      <!-- Navigation (use aria-label when multiple navs exist) -->
<main>     <!-- Primary content — one per page -->
<aside>    <!-- Related secondary content -->
<footer>   <!-- Site footer -->
```

---

## ARIA Usage

Use ARIA only when semantic HTML is insufficient. Incorrect ARIA is worse than no ARIA.

### Roles and Labels

```html
<!-- ✅ Label interactive elements -->
<button aria-label="Close dialog">
  <svg aria-hidden="true">...</svg>
</button>

<!-- ✅ Describe relationships -->
<div role="dialog" aria-labelledby="dialog-title" aria-describedby="dialog-desc">
  <h2 id="dialog-title">Confirm Deletion</h2>
  <p id="dialog-desc">This action cannot be undone.</p>
</div>

<!-- ✅ Live regions for dynamic updates -->
<div aria-live="polite" aria-atomic="true" class="sr-only">
  {{ statusMessage }}
</div>

<!-- ❌ Redundant ARIA — button role is implicit on <button> -->
<button role="button">Submit</button>
```

### Required ARIA Patterns

| Component | Required ARIA |
|---|---|
| Modal dialog | `role="dialog"`, `aria-labelledby`, `aria-modal="true"` |
| Alert/error | `role="alert"` or `aria-live="assertive"` |
| Loading state | `aria-busy="true"` on the container |
| Expandable | `aria-expanded="true/false"` on the trigger |
| Required field | `aria-required="true"` |
| Invalid field | `aria-invalid="true"`, `aria-describedby` pointing to error |
| Progress | `role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax` |
| Icon button | `aria-label` on button, `aria-hidden="true"` on icon |

---

## Forms

Forms are the highest-impact accessibility surface. Every input must be correctly labelled and have visible error messaging.

```html
<!-- ✅ Fully accessible form field -->
<div class="form-field">
  <label for="email">
    Email address
    <span aria-hidden="true" class="required-indicator">*</span>
  </label>
  <input
    id="email"
    type="email"
    name="email"
    autocomplete="email"
    aria-required="true"
    aria-invalid="true"
    aria-describedby="email-error"
    value="bad-email"
  />
  <p id="email-error" role="alert" class="error-text">
    Enter a valid email address.
  </p>
</div>
```

Rules:
- Every `<input>` must have an associated `<label>` (never rely on `placeholder` alone)
- `placeholder` must not be the only label — placeholders disappear on focus
- Group related fields with `<fieldset>` and `<legend>`
- Announce form submission success/errors via `aria-live` or focus management

```html
<!-- ✅ Radio group with fieldset/legend -->
<fieldset>
  <legend>Notification preference</legend>
  <label><input type="radio" name="notif" value="email"> Email</label>
  <label><input type="radio" name="notif" value="sms"> SMS</label>
  <label><input type="radio" name="notif" value="none"> None</label>
</fieldset>
```

---

## Keyboard Navigation

All interactive elements must be operable by keyboard alone, in logical tab order.

```typescript
// ✅ Vue: Keyboard-accessible custom dropdown
<script setup lang="ts">
const open = ref(false)

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Escape') {
    open.value = false
    triggerRef.value?.focus()  // Return focus to trigger
  }
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    focusNextOption()
  }
  if (e.key === 'ArrowUp') {
    e.preventDefault()
    focusPreviousOption()
  }
}
</script>
```

### Focus Management

```typescript
// ✅ Trap focus within modal while open
import { useFocusTrap } from '@vueuse/core'

const modal = ref<HTMLElement>()
const { activate, deactivate } = useFocusTrap(modal)

watch(isOpen, (open) => {
  if (open) {
    nextTick(() => activate())
  } else {
    deactivate()
    triggerButton.value?.focus()  // Return focus to triggering element
  }
})
```

### Keyboard Interaction Patterns

| Component | Keys |
|---|---|
| Button | `Enter`, `Space` to activate |
| Link | `Enter` to follow |
| Checkbox | `Space` to toggle |
| Radio | `Arrow keys` to select within group |
| Select / Listbox | `Arrow keys` to navigate, `Enter` to select |
| Dialog | `Escape` to close, focus trapped inside |
| Tab list | `Arrow keys` to navigate tabs |
| Accordion | `Enter` / `Space` to expand/collapse |
| Date picker | `Arrow keys` for days, `Page Up/Down` for months |

---

## Color and Contrast

```typescript
// ✅ Meet minimum contrast ratios
// Normal text (< 18pt): 4.5:1 minimum
// Large text (≥ 18pt or ≥ 14pt bold): 3:1 minimum
// UI components and icons: 3:1 minimum

// tailwind.config.ts — ensure custom colors meet contrast
const colors = {
  // Use a contrast checker before adding custom colors
  // https://webaim.org/resources/contrastchecker/
  primary: {
    600: '#2563EB',  // ✅ 4.54:1 on white
    700: '#1D4ED8',  // ✅ 6.27:1 on white
  },
  error: {
    600: '#DC2626',  // ✅ 4.81:1 on white
  },
  // ❌ Never rely on color alone to convey state
  // Always pair color with text, icon, or pattern
}
```

Rules:
- Never use color as the only means of conveying information (e.g., red text for errors must also have an error icon or label)
- Provide sufficient contrast in both light and dark modes
- Test with color-blindness simulators (Stark, Colour Oracle)

---

## Images and Media

```html
<!-- ✅ Informative image — describe the content -->
<img src="/chart.png" alt="Bar chart showing Q3 revenue of $2.4M, up 18% from Q2" />

<!-- ✅ Decorative image — hide from screen readers -->
<img src="/decorative-wave.svg" alt="" role="presentation" />

<!-- ✅ Complex image — link to text alternative -->
<figure>
  <img src="/architecture-diagram.png" alt="System architecture diagram" aria-describedby="diagram-desc" />
  <figcaption id="diagram-desc">
    The system consists of a Vue frontend, NestJS API, PostgreSQL database, and Redis cache...
  </figcaption>
</figure>

<!-- ✅ Video — provide captions and transcript -->
<video controls>
  <source src="/demo.mp4" type="video/mp4" />
  <track kind="captions" src="/demo.vtt" srclang="en" label="English" default />
</video>
```

---

## Automated Testing

Automated checks catch ~30% of WCAG issues. Manual testing is also required.

```typescript
// ✅ axe-core integration in Vitest
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

it('should have no accessibility violations', async () => {
  const { container } = render(UserForm)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

```yaml
# .github/workflows/a11y.yml
- name: Accessibility audit
  uses: treosh/lighthouse-ci-action@v10
  with:
    urls: |
      http://localhost:3000/
      http://localhost:3000/login
      http://localhost:3000/dashboard
    budgetPath: .lighthouserc.json
    uploadArtifacts: true
```

### Manual Testing Checklist

Before shipping any UI feature:

- [ ] Tab through entire page without a mouse — all elements reachable
- [ ] Visible focus indicator present on every focused element
- [ ] Screen reader announces all content correctly (test with NVDA or VoiceOver)
- [ ] Form errors are announced and associated with fields
- [ ] Modal/dialog traps focus and returns it on close
- [ ] All images have meaningful alt text or are marked decorative
- [ ] Page works at 200% zoom without content loss
- [ ] Color contrast passes on all text and UI components
- [ ] No content flashes more than 3 times per second (seizure safety)

---

## Skip Links

Every page with repeated navigation must have a skip link as the first focusable element.

```html
<body>
  <a href="#main-content" class="skip-link">Skip to main content</a>

  <header>...</header>
  <nav>...</nav>

  <main id="main-content" tabindex="-1">
    <!-- Page content -->
  </main>
</body>
```

```css
.skip-link {
  position: absolute;
  transform: translateY(-100%);
  transition: transform 0.2s;
}

.skip-link:focus {
  transform: translateY(0);
}
```
