# Vuetify 3 — Reference Patterns

## Form validation (complete example)

```vue
<template>
  <v-form ref="form" @submit.prevent="handleSubmit">
    <v-text-field
      v-model="email"
      label="Email address"
      type="email"
      :rules="emailRules"
      autocomplete="email"
      required
    />

    <v-text-field
      v-model="password"
      label="Password"
      :type="showPassword ? 'text' : 'password'"
      :rules="passwordRules"
      :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
      @click:append-inner="showPassword = !showPassword"
    />

    <v-btn
      type="submit"
      color="primary"
      :loading="saving"
      block
    >
      Create account
    </v-btn>
  </v-form>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const form = ref()
const email = ref('')
const password = ref('')
const saving = ref(false)
const showPassword = ref(false)

const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+\..+/.test(v) || 'Enter a valid email address',
]

const passwordRules = [
  (v: string) => !!v || 'Password is required',
  (v: string) => v.length >= 8 || 'Password must be at least 8 characters',
]

async function handleSubmit() {
  const { valid } = await form.value.validate()
  if (!valid) return

  saving.value = true
  try {
    await createAccount({ email: email.value, password: password.value })
  } finally {
    saving.value = false
  }
}
</script>
```

---

## Responsive grid

```vue
<template>
  <v-container>
    <v-row>
      <!-- Full width on xs, half on md, third on lg -->
      <v-col
        cols="12"
        md="6"
        lg="4"
        v-for="product in products"
        :key="product.id"
      >
        <ProductCard :product="product" />
      </v-col>
    </v-row>
  </v-container>
</template>
```

---

## Server-side data table

```vue
<template>
  <v-data-table-server
    :headers="headers"
    :items="rows"
    :items-length="totalRows"
    :loading="loading"
    :items-per-page="pageSize"
    item-value="id"
    @update:options="onPageChange"
  >
    <template #item.status="{ item }">
      <v-chip :color="statusColor(item.status)" size="small">
        {{ item.status }}
      </v-chip>
    </template>

    <template #item.actions="{ item }">
      <v-btn icon="mdi-pencil" variant="text" @click="edit(item)" />
      <v-btn icon="mdi-delete" variant="text" color="error" @click="confirmDelete(item)" />
    </template>
  </v-data-table-server>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const loading = ref(false)
const rows = ref([])
const totalRows = ref(0)
const pageSize = ref(25)

async function onPageChange({ page, itemsPerPage, sortBy }) {
  loading.value = true
  try {
    const result = await fetchOrders({ page, itemsPerPage, sortBy })
    rows.value = result.data
    totalRows.value = result.total
  } finally {
    loading.value = false
  }
}
</script>
```

---

## Theme configuration

```typescript
// src/plugins/vuetify.ts
import { createVuetify } from 'vuetify'

export default createVuetify({
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        colors: {
          primary:    '#1E40AF',
          secondary:  '#6B7280',
          error:      '#DC2626',
          warning:    '#D97706',
          success:    '#16A34A',
          info:       '#0284C7',
          surface:    '#FFFFFF',
          background: '#F9FAFB',
        },
      },
      dark: {
        colors: {
          primary:    '#60A5FA',
          surface:    '#1F2937',
          background: '#111827',
        },
      },
    },
  },
})
```

**Colours in templates — tokens, not hex**
```vue
<!-- ✅ — respects dark mode automatically -->
<v-btn color="primary">Save</v-btn>
<v-card color="surface">...</v-card>
<v-icon color="error">mdi-alert</v-icon>

<!-- ❌ — hardcoded hex breaks dark mode -->
<v-btn style="background-color: #1E40AF">Save</v-btn>
```

---

## Dialog pattern

```vue
<template>
  <v-dialog v-model="open" max-width="480">
    <v-card>
      <v-card-title>Confirm deletion</v-card-title>
      <v-card-text>
        This will permanently delete <strong>{{ item?.name }}</strong>.
        This action cannot be undone.
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" @click="open = false">Cancel</v-btn>
        <v-btn color="error" :loading="deleting" @click="doDelete">Delete</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
```

---

## Auto-import setup (Vite + tree-shaking)

```typescript
// vite.config.ts
import Components from 'unplugin-vue-components/vite'
import { VuetifyResolver } from 'unplugin-vue-components/resolvers'
import AutoImport from 'unplugin-auto-import/vite'

export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [VuetifyResolver()],
    }),
    AutoImport({
      imports: ['vue', 'vue-router', 'pinia'],
    }),
  ],
})
```

---

## Lazy rendering long lists

```vue
<template>
  <v-list>
    <v-lazy
      v-for="notification in notifications"
      :key="notification.id"
      :options="{ threshold: 0.5 }"
      min-height="64"
    >
      <v-list-item
        :title="notification.title"
        :subtitle="notification.createdAt"
        :prepend-icon="notification.icon"
      />
    </v-lazy>
  </v-list>
</template>
```

---

## Vuetify 2 vs 3 migration traps

| Vuetify 2 (❌) | Vuetify 3 (✅) |
|---|---|
| `v-simple-table` | `v-table` |
| `outlined` prop | `variant="outlined"` |
| `text` prop on `v-btn` | `variant="text"` |
| `v-text-field solo` | `variant="solo"` |
| `$vuetify.breakpoint` | `useDisplay()` composable |
| `v-data-table :server-items-length` | `v-data-table-server` |
