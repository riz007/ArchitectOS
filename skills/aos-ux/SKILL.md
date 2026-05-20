---
name: aos-ux
description: Reviews UI implementation for usability, interaction design, accessibility, empty/error/loading states, microcopy quality, motion, keyboard-only navigation, and dark mode support. Reports FAIL/WARN/PASS. Use when user asks to review UX, audit usability, check user experience, or says "does this feel right for users".
---

# /aos-ux

Select files, describe the flow, or paste a screenshot path. Then run `/aos-ux`.

For targeted reviews: `/aos-ux forms` · `/aos-ux navigation` · `/aos-ux onboarding` · `/aos-ux mobile` · `/aos-ux motion`

---

## What gets checked

### Loading states
- [ ] Loading indicator appears within 100ms of a user action
- [ ] Skeleton screens used for content areas — not just a spinner
- [ ] Long operations (> 3s) show progress indication or estimated time
- [ ] Buttons disabled and relabelled ("Saving…") during submission

### Error states
- [ ] Errors appear inline, near the cause — not only in a toast
- [ ] Error messages explain what happened AND what the user should do next
- [ ] Recoverable errors have a retry action
- [ ] Field-level validation errors appear after blur, not on every keystroke
- [ ] Network errors distinguished from validation errors in copy

### Empty states
- [ ] Empty lists explain why they are empty and offer a next action
- [ ] First-time users see onboarding guidance, not a blank page
- [ ] Search with no results shows what was searched and suggests an alternative

### Forms
- [ ] Labels are always visible — no placeholder-as-label pattern
- [ ] Required fields are marked, with a legend explaining the mark
- [ ] Help text appears below the input; error text replaces it (same position)
- [ ] Successful submission confirms what happened and what comes next
- [ ] `autocomplete` attributes set where browser autofill is appropriate
- [ ] Tab order follows visual layout — no logical jumps when using keyboard only

### Navigation
- [ ] Current location is visually indicated in the nav
- [ ] Breadcrumbs present on pages more than two levels deep
- [ ] Back navigation is available and goes where the user expects
- [ ] Destructive actions require explicit confirmation
- [ ] Skip-to-content link provided for keyboard users

### Visual hierarchy
- [ ] One primary CTA per view — no competing equal-weight buttons
- [ ] Page title is the first `<h1>` and matches the nav label
- [ ] Visual weight guides the eye to the most important element first
- [ ] Whitespace separates sections without needing horizontal rules

### Microcopy
- [ ] Button labels describe the outcome ("Save changes", not "Submit")
- [ ] Destructive actions are explicit ("Delete account", not "Confirm")
- [ ] No developer jargon, error codes, or HTTP status numbers in user-facing text
- [ ] Tone is consistent across the product
- [ ] Success, error, and empty-state messages written from the user's perspective

### Responsiveness
- [ ] Layout tested at 320px, 768px, and 1280px
- [ ] No horizontal scroll at any viewport width
- [ ] Touch targets ≥ 44×44px on mobile
- [ ] Mobile nav uses a bottom bar or hamburger — not a full desktop nav

### Motion and animation
- [ ] Animations serve a purpose (orient, feedback, delight) — no decoration-only motion
- [ ] `prefers-reduced-motion` media query respected — disable or tone down animations for users who opt out
- [ ] Transitions ≤ 300ms for UI feedback; > 500ms transitions feel sluggish
- [ ] No content that flashes more than 3 times per second (seizure risk — WCAG 2.3.1)

### Keyboard-only navigation
- [ ] Every interactive element reachable and operable by keyboard alone
- [ ] Focus trap active inside dialogs and drawers — Tab stays within the overlay
- [ ] Focus returned to the trigger element when a dialog closes
- [ ] Custom widgets (dropdowns, date pickers, tabs) follow ARIA Authoring Practices keyboard patterns

### Dark mode
- [ ] If the product supports dark mode: all colours use theme tokens, not hardcoded hex
- [ ] Images and icons legible in both modes
- [ ] No white text on light background in dark mode (check CSS variables)
- [ ] `prefers-color-scheme` media query used to set the initial theme

---

## Output format

```
[FAIL] Forms — placeholder used as the only label on the email input
File: src/pages/LoginPage.vue:12
Fix: add a visible <label> above the input; placeholder can remain as a hint
Impact: screen readers and password managers cannot identify the field

[FAIL] Motion — no prefers-reduced-motion check on the page transition animation
File: src/components/PageTransition.tsx:8
Fix:
  @media (prefers-reduced-motion: reduce) {
    .page-transition { transition: none; }
  }

[WARN] Empty state — no CTA on the empty orders list
File: src/components/OrderList.tsx:44
Fix: add a "Browse products" button with a short explanatory sentence

[WARN] Keyboard — focus not returned to trigger button after dialog closes
File: src/components/DeleteDialog.tsx:52
Fix: call triggerRef.current?.focus() in the onClose handler

Summary: 2 FAIL · 2 WARN · 10 PASS
```

---

## Full reference

See [REFERENCE.md](REFERENCE.md) for annotated examples of every pattern.
