# Vue Enterprise Performance

## Preferred Stack

- Vite
- Vue 3
- TypeScript
- Vue Query
- VueUse
- code splitting

## Avoid

- importing large dependencies in the app shell
- rendering expensive templates on every reactivity change
- unnecessary deep component trees
- shipping unused CSS or JS
- storing large blobs in reactive state

## Recommended Structure

```
src/
  modules/
    dashboard/
      views/
      components/
  shared/
    components/
    composables/
    utils/
```

### Pattern

- Keep business logic in composables or services
- Use dynamic imports for route-level and component-level code splitting
- Use computed memoization for expensive derived values
- Use lazy-loading for images and non-critical UI
- Use browser caching and CDN for static assets

## Scaling Advice

- Profile bundle size with `vite build --json`
- Split large modules into smaller feature chunks
- Use `defineAsyncComponent` for heavy widgets
- Use web workers for expensive client-side processing
- Defer nonessential tasks until after initial render

## Production Deployment

- Enable asset hashing and long-term caching
- Serve from a CDN or edge network
- Use compression: gzip or brotli
- Use `preload` for critical assets and `prefetch` for low-priority chunks
- Add security headers and CSP
- Enable client-side error reporting and performance telemetry

## Code Examples

### Lazy route loading

```ts
// src/router/index.ts
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/modules/dashboard/views/DashboardView.vue')
  }
]
```

### Lazy component loading

```ts
import { defineAsyncComponent } from 'vue'

const HeavyChart = defineAsyncComponent(() =>
  import('@/modules/dashboard/components/HeavyChart.vue')
)
```

### Memoized computed values

```ts
const filteredItems = computed(() => {
  return items.value.filter(item => item.isActive)
})
```

### Virtual scrolling helper

```ts
// src/shared/composables/useVirtualList.ts
import { computed, ref } from 'vue'

export function useVirtualList(items, itemHeight, containerHeight) {
  const scrollTop = ref(0)

  const visibleItems = computed(() => {
    const start = Math.floor(scrollTop.value / itemHeight)
    return items.slice(start, start + Math.ceil(containerHeight / itemHeight) + 1)
  })

  return { scrollTop, visibleItems }
}
```

## AI Prompting Examples

- "Recommend Vue performance best practices for an enterprise dashboard app."
- "Generate a code-splitting plan for a Vue 3 application with route-based modules."
- "What are the top performance anti-patterns in Vue stateful components?"
