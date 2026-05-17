# ArchitectOS Performance Standards

Performance is an architectural concern, not an afterthought. These standards define required patterns for frontend, backend, database, and infrastructure performance across all ArchitectOS projects.

## Core Performance Targets

| Metric | Target | Critical Threshold |
|---|---|---|
| API p95 response time | < 200ms | > 500ms requires investigation |
| Frontend LCP | < 2.5s | > 4s is unacceptable |
| Frontend FID / INP | < 100ms | > 300ms requires optimization |
| Frontend CLS | < 0.1 | > 0.25 requires fix |
| Database query p95 | < 50ms | > 200ms requires indexing review |
| Memory per pod | < 512MB | > 1GB requires profiling |

---

## Frontend Performance

### Code Splitting

Every route must be lazy-loaded. Never import page-level components directly into the router.

```typescript
// ✅ Route-level lazy loading
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/features/dashboard/DashboardView.vue'),
  },
  {
    path: '/orders',
    component: () => import('@/features/orders/OrdersView.vue'),
  },
]

// ❌ Eager loading kills initial bundle size
import DashboardView from '@/features/dashboard/DashboardView.vue'
```

### Component-Level Performance

```typescript
// ✅ Memoize expensive computed values
const sortedOrders = computed(() =>
  orders.value.slice().sort((a, b) => b.createdAt - a.createdAt)
)

// ✅ Virtualize large lists — never render 1000+ DOM nodes
import { useVirtualList } from '@vueuse/core'
const { list, containerProps, wrapperProps } = useVirtualList(items, {
  itemHeight: 60,
})

// ✅ Debounce user input before triggering searches
import { useDebounceFn } from '@vueuse/core'
const debouncedSearch = useDebounceFn((query: string) => {
  fetchResults(query)
}, 300)

// ❌ Anti-pattern: new function on every render
<Button @click="() => doThing(item.id)" />  // creates new fn each render

// ✅ Prefer stable references
const handleClick = (id: string) => doThing(id)
```

### Image and Asset Optimization

```html
<!-- ✅ Always specify width/height to prevent layout shift -->
<img
  src="/hero.webp"
  width="1200"
  height="630"
  alt="Dashboard screenshot"
  loading="lazy"
  decoding="async"
/>

<!-- ✅ Use srcset for responsive images -->
<img
  srcset="/hero-400.webp 400w, /hero-800.webp 800w, /hero-1200.webp 1200w"
  sizes="(max-width: 600px) 400px, (max-width: 1000px) 800px, 1200px"
  src="/hero-1200.webp"
  alt="..."
/>
```

Rules:
- Serve images in WebP or AVIF format
- Use a CDN for all static assets in production
- Set `Cache-Control: immutable` on hashed asset filenames
- Never block render with synchronous scripts
- Inline critical CSS for above-the-fold content

### Bundle Optimization

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['vue', 'vue-router', 'pinia'],
          charts: ['chart.js'],
          forms: ['vee-validate', 'zod'],
        },
      },
    },
    // Warn when chunk exceeds 500kB gzipped
    chunkSizeWarningLimit: 500,
  },
})
```

---

## Backend Performance

### Async I/O — Non-Negotiable

Never block the event loop. All I/O must be asynchronous.

```typescript
// ✅ Async database calls
const user = await userRepository.findById(id)

// ✅ Parallel independent operations
const [user, orders, permissions] = await Promise.all([
  userRepository.findById(userId),
  orderRepository.findByUserId(userId),
  permissionRepository.findByUserId(userId),
])

// ❌ Sequential when parallel is possible
const user = await userRepository.findById(userId)
const orders = await orderRepository.findByUserId(userId)  // waited for no reason
```

### Caching Strategy

```typescript
// ✅ Cache-aside pattern with Redis
async getUser(id: string): Promise<User> {
  const cacheKey = `user:${id}`
  const cached = await this.cache.get<User>(cacheKey)
  if (cached) return cached

  const user = await this.userRepository.findById(id)
  if (!user) throw new NotFoundException()

  await this.cache.set(cacheKey, user, { ttl: 300 }) // 5 min TTL
  return user
}

// ✅ Invalidate on write
async updateUser(id: string, dto: UpdateUserDto): Promise<User> {
  const user = await this.userRepository.update(id, dto)
  await this.cache.del(`user:${id}`)
  return user
}
```

Cache TTL guidelines:
- User sessions: 15 minutes
- User profiles: 5 minutes
- Product catalog: 1 hour
- Reference data (countries, categories): 24 hours
- Real-time data (stock, prices): 30 seconds or no cache

### Connection Pooling

Always configure pools. Never create new DB connections per request.

```typescript
// TypeORM
const dataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  extra: {
    max: 20,          // max pool size
    min: 5,           // min pool size
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  },
})

// Prisma
// DATABASE_URL includes pool settings via query string
// DATABASE_URL=postgresql://...?connection_limit=20&pool_timeout=10
```

### Rate Limiting and Backpressure

```typescript
// ✅ Per-route rate limiting
import rateLimit from 'express-rate-limit'

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,  // 10 login attempts per 15 minutes
  standardHeaders: true,
  legacyHeaders: false,
})

const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,  // 100 requests per minute for general API
})

app.post('/auth/login', authLimiter, loginHandler)
app.use('/api', apiLimiter)
```

### Streaming for Large Datasets

```typescript
// ✅ Stream large exports instead of loading into memory
async exportUsers(res: Response): Promise<void> {
  res.setHeader('Content-Type', 'text/csv')
  res.setHeader('Content-Disposition', 'attachment; filename=users.csv')

  const stream = this.userRepository.createQueryStream()
  const csvTransform = new CsvTransformStream()

  stream.pipe(csvTransform).pipe(res)
}

// ❌ Loading 100k records into memory
const users = await this.userRepository.findAll()  // OOM risk
res.json(users)
```

---

## Database Performance

### Indexing Requirements

Every query that filters, sorts, or joins must have a supporting index.

```sql
-- Index on columns used in WHERE clauses
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Composite index for multi-column filters (order matters: equality first)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial index for filtered queries
CREATE INDEX idx_orders_pending ON orders(created_at)
  WHERE status = 'pending';

-- Index for sort-heavy queries
CREATE INDEX idx_products_created_at ON products(created_at DESC);
```

### N+1 Query Prevention

```typescript
// ❌ N+1 — 1 query for orders + N queries for users
const orders = await orderRepo.findAll()
for (const order of orders) {
  order.user = await userRepo.findById(order.userId)  // N queries
}

// ✅ Eager join in a single query
const orders = await orderRepo.find({
  relations: ['user'],
})

// ✅ DataLoader pattern for GraphQL
const userLoader = new DataLoader(async (ids: string[]) => {
  const users = await userRepo.findByIds(ids)
  return ids.map(id => users.find(u => u.id === id))
})
```

### Query Optimization Rules

- Use `SELECT col1, col2` not `SELECT *`
- Always `LIMIT` unbounded queries
- Use `EXPLAIN ANALYZE` before merging slow query fixes
- Paginate results using keyset pagination for large datasets

```sql
-- ✅ Keyset pagination (stable, O(1) regardless of offset)
SELECT * FROM orders
WHERE (created_at, id) < ($last_created_at, $last_id)
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- ❌ Offset pagination degrades at scale
SELECT * FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 10000;
```

---

## Infrastructure Performance

### Horizontal Scaling

Design all stateless services for horizontal scaling from day one.

```yaml
# k8s HorizontalPodAutoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70
```

### Resource Requests and Limits

Every pod must declare resource requests and limits. An unconstrained pod is a DoS risk.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

### CDN and Edge Caching

```
Cache-Control: public, max-age=31536000, immutable   # Hashed static assets
Cache-Control: public, max-age=3600, stale-while-revalidate=60  # API responses
Cache-Control: no-store  # Authenticated, personalized data
```

---

## Observability Requirements

Performance regressions must be detectable before users notice. Every service must expose:

### Required Metrics

```typescript
// Instrument with Prometheus or OpenTelemetry
const httpDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request latency',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.005, 0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5],
})

const dbQueryDuration = new Histogram({
  name: 'db_query_duration_seconds',
  help: 'Database query latency',
  labelNames: ['operation', 'table'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1],
})

const cacheHitRate = new Counter({
  name: 'cache_operations_total',
  help: 'Cache hit/miss counts',
  labelNames: ['result'],  // 'hit' | 'miss'
})
```

### Required Alerts

- p95 API latency > 500ms sustained for 5 minutes
- Error rate > 1% over 5 minutes
- DB connection pool saturation > 80%
- Memory usage > 85% of limit
- Cache hit rate < 60% (indicates cache misconfiguration)
