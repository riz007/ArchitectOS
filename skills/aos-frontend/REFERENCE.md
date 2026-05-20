# Frontend Design — Reference Standards

## Component design

**Single responsibility — container vs presentational**
```tsx
// ✅ — presentational: accepts data as props, emits events
function ProductCard({ product, onAddToCart }: ProductCardProps) {
  return (
    <div className="product-card">
      <img src={product.imageUrl} alt={product.name} />
      <h3>{product.name}</h3>
      <span>{formatCurrency(product.price)}</span>
      <button onClick={() => onAddToCart(product.id)}>Add to cart</button>
    </div>
  )
}

// ❌ — component fetches its own data (two responsibilities)
function ProductCard({ productId }: { productId: string }) {
  const [product, setProduct] = useState(null)
  useEffect(() => { fetch(`/api/products/${productId}`).then(...) }, [])
  return <div>...</div>
}
```

**No prop drilling**
```tsx
// ❌ — user passed through three levels, each component must know about it
<Page user={user}>
  <Header user={user}>
    <Avatar user={user} />
  </Header>
</Page>

// ✅ — context breaks the chain
const UserContext = createContext<User | null>(null)

function Avatar() {
  const user = useContext(UserContext)
  return <img src={user?.avatarUrl} alt={user?.name} />
}
```

---

## CSS architecture

**Design tokens — no magic values**
```css
/* ✅ — from the design system */
.button {
  background: var(--color-primary-500);
  padding: var(--spacing-2) var(--spacing-4);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
}

/* ❌ — magic numbers that diverge from the design system over time */
.button {
  background: #3b82f6;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
}
```

**CSS Modules — scoped by default**
```tsx
// ✅ — hash-scoped class names, no global collision risk
import styles from './ProductCard.module.css'
return <div className={styles.card}>

// ❌ — global .card collides with every other .card in the app
return <div className="card">
```

---

## Accessibility

**Label association (WCAG 1.3.1)**
```html
<!-- ✅ — explicit for/id association -->
<label for="email">Email address</label>
<input id="email" type="email" autocomplete="email" />

<!-- ✅ — wrapping label (implicit association) -->
<label>
  Password
  <input type="password" autocomplete="current-password" />
</label>

<!-- ❌ — no programmatic association; screen readers announce "edit text" -->
<p>Email address</p>
<input type="email" />
```

**ARIA — use sparingly, native first (WCAG 4.1.2)**
```html
<!-- ✅ — use native semantics -->
<button type="button">Close dialog</button>

<!-- ✅ — ARIA only when native semantics won't work -->
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm deletion</h2>
</div>

<!-- ❌ — redundant ARIA on native element -->
<button role="button" aria-label="button">Submit</button>
```

**Keyboard navigation**
```tsx
// ✅ — custom interactive element handles both click and keyboard
function DropdownToggle({ label, onClick }: Props) {
  return (
    <div
      role="button"
      tabIndex={0}
      onClick={onClick}
      onKeyDown={e => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault()
          onClick()
        }
      }}
    >
      {label}
    </div>
  )
}
```

---

## Performance

**Lazy-load routes and heavy components**
```tsx
// ✅ React
const SettingsPage = React.lazy(() => import('./pages/Settings'))
<Suspense fallback={<PageSkeleton />}>
  <SettingsPage />
</Suspense>

// ✅ Vue
const SettingsPage = defineAsyncComponent(() => import('./pages/Settings.vue'))
```

**Memoisation**
```tsx
// ✅ — memoised filter only recalculates when products change
const activeProducts = useMemo(
  () => products.filter(p => p.status === 'active' && p.stock > 0),
  [products]
)

// ✅ — stable callback reference, prevents child re-renders
const handleDelete = useCallback(
  (id: string) => dispatch(deleteProduct(id)),
  [dispatch]
)

// ❌ — new function reference every render → every child re-renders
const handleDelete = (id: string) => dispatch(deleteProduct(id))
```

---

## State management

**Local vs global state**
```tsx
// ✅ — UI state stays local
const [isMenuOpen, setIsMenuOpen] = useState(false)

// ✅ — shared domain data in global store
const { currentUser } = useAuthStore()

// ❌ — UI state in global store creates unnecessary coupling
const isMenuOpen = useGlobalStore(s => s.headerMenuOpen)
```

**No derived state**
```tsx
// ❌ — count can diverge from items
const [items, setItems] = useState<Product[]>([])
const [count, setCount] = useState(0)

// ✅ — derive from the single source of truth
const [items, setItems] = useState<Product[]>([])
const count = items.length
```

---

## Error and loading states

```tsx
// ✅ — all three states explicitly handled
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error, refetch } = useUser(userId)

  if (isLoading) return <ProfileSkeleton />
  if (error)     return <ErrorMessage message="Could not load profile" onRetry={refetch} />
  if (!user)     return <EmptyState message="User not found" />

  return <Profile user={user} />
}

// ❌ — renders nothing on error, crashes on null access
function UserProfile({ userId }: { userId: string }) {
  const { data: user } = useUser(userId)
  return <Profile user={user} />  // user may be undefined
}
```
