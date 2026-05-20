# UI/UX — Reference Patterns

## Loading states

**Skeleton screens over isolated spinners**
```html
<!-- ✅ — skeleton preserves layout, reduces cumulative layout shift -->
<template v-if="loading">
  <div class="skeleton skeleton--title"></div>
  <div class="skeleton skeleton--text"></div>
  <div class="skeleton skeleton--text skeleton--short"></div>
</template>
<template v-else>
  <h2>{{ article.title }}</h2>
  <p>{{ article.body }}</p>
</template>

<!-- ❌ — spinner collapses layout; page jumps when content loads -->
<Spinner v-if="loading" />
<div v-else>{{ article.body }}</div>
```

**Button loading state**
```html
<!-- ✅ — disabled prevents double-submit, label confirms action in progress -->
<v-btn
  type="submit"
  color="primary"
  :disabled="saving"
  :loading="saving"
>
  {{ saving ? 'Saving…' : 'Save changes' }}
</v-btn>
```

---

## Error states

**Inline error with a retry action**
```html
<!-- ✅ — error appears in context with a recovery path -->
<div v-if="error" role="alert" class="error-banner">
  <p>Could not load your orders.</p>
  <button @click="retry">Try again</button>
</div>

<!-- ❌ — toast disappears in 3s; user has no recovery action -->
<Toast :message="error" />
```

**Field validation error — appears after blur**
```html
<!-- ✅ — error triggers on blur, not on every keystroke -->
<div class="field">
  <label for="email">Email address</label>
  <input
    id="email"
    v-model="email"
    type="email"
    @blur="validateEmail"
    :aria-describedby="emailError ? 'email-error' : undefined"
  />
  <span v-if="emailError" id="email-error" role="alert" class="field-error">
    Enter a valid email address
  </span>
</div>

<!-- ❌ — validates on every keystroke; shows error while still typing -->
<input v-model="email" @input="validateEmail" />
```

---

## Empty states

**Empty list with explanation and next action**
```html
<!-- ✅ -->
<div v-if="orders.length === 0" class="empty-state">
  <img src="/illustrations/empty-orders.svg" alt="" aria-hidden="true" />
  <h2>No orders yet</h2>
  <p>When you place an order, it will appear here.</p>
  <a href="/shop" class="btn-primary">Browse products</a>
</div>

<!-- ❌ — user has no idea what to do -->
<p v-if="orders.length === 0">No items found.</p>
```

---

## Forms

**Visible labels — never placeholder-only**
```html
<!-- ✅ -->
<div class="field">
  <label for="fullName">Full name</label>
  <input
    id="fullName"
    type="text"
    placeholder="Jane Smith"
    autocomplete="name"
  />
</div>

<!-- ❌ — label disappears on focus; fails WCAG 3.3.2 -->
<input type="text" placeholder="Full name" />
```

**Confirmation after successful submission**
```html
<!-- ✅ — confirms the outcome and the next step -->
<div role="status" aria-live="polite" class="success-banner">
  Your profile has been updated.
  <a href="/dashboard">Back to dashboard</a>
</div>

<!-- ❌ — user does not know if anything happened -->
<!-- (no feedback after form submission) -->
```

---

## Destructive action confirmation

```html
<!-- ✅ — two-step confirmation for irreversible actions -->
<button @click="showConfirm = true" class="btn-danger">Delete account</button>

<v-dialog v-model="showConfirm" max-width="420">
  <v-card>
    <v-card-title>Delete your account?</v-card-title>
    <v-card-text>
      This will permanently delete all your data and cannot be undone.
    </v-card-text>
    <v-card-actions>
      <v-spacer />
      <v-btn variant="text" @click="showConfirm = false">Cancel</v-btn>
      <v-btn color="error" :loading="deleting" @click="deleteAccount">
        Yes, delete my account
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
```

---

## Visual hierarchy

**One primary action per view**
```html
<!-- ✅ — clear primary/secondary weight -->
<div class="actions">
  <button class="btn-primary">Save changes</button>
  <button class="btn-secondary">Discard</button>
</div>

<!-- ❌ — three equal-weight CTAs compete; user is paralysed -->
<div class="actions">
  <button class="btn-primary">Save changes</button>
  <button class="btn-primary">Save and publish</button>
  <button class="btn-primary">Export</button>
</div>
```

---

## Microcopy cheat sheet

| ❌ Vague or technical | ✅ Outcome-focused |
|---|---|
| Submit | Save changes |
| Confirm | Yes, delete project |
| An error occurred | Couldn't save — check your connection and try again |
| Processing | Saving your changes… |
| OK | Got it |
| Invalid input | Enter a date after today |
| 403 Forbidden | You don't have permission to view this page |
| null | No results for "vuetify form" — try a shorter search |
