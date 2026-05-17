# ArchitectOS Database Rules

Rules for schema design, query patterns, migrations, and data integrity across PostgreSQL, MySQL, and other relational databases.

---

## Schema Design Rules

### Rule: All Tables Must Have These Columns

```sql
id          UUID PRIMARY KEY DEFAULT gen_random_uuid()
created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

Use `TIMESTAMPTZ` (timestamp with time zone), never `TIMESTAMP` without timezone. Store all timestamps in UTC.

For soft-delete tables, also add:
```sql
deleted_at  TIMESTAMPTZ
```

---

### Rule: Use UUIDs for Primary Keys

```sql
-- ✅ UUID primary key
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- ❌ Auto-increment integer — leaks row count, predictable for enumeration
id SERIAL PRIMARY KEY
```

Exception: high-insert-rate tables where UUID primary key causes index fragmentation. In that case, use `ULID` (lexicographically sortable UUID) or `BIGSERIAL` with the tradeoffs documented.

---

### Rule: Enforce Referential Integrity with Foreign Keys

```sql
-- ✅ Declare the relationship explicitly
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_user
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE RESTRICT   -- or CASCADE depending on the domain rule
  ON UPDATE CASCADE;

-- ❌ user_id column with no FK constraint — orphaned records accumulate silently
```

---

### Rule: Validate Data at the Database Level

Constraints in the database are the last line of defense. ORM validations can be bypassed.

```sql
-- Email uniqueness
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);

-- Non-nullable required fields
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- Domain constraint
ALTER TABLE orders ADD CONSTRAINT chk_orders_positive_total
  CHECK (total_amount >= 0);

-- Status enum
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');
ALTER TABLE orders ALTER COLUMN status TYPE order_status USING status::order_status;
```

---

### Rule: Index Every Foreign Key and Filtered Column

PostgreSQL does not automatically index foreign key columns.

```sql
-- ✅ Index on FK columns used in JOINs
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- ✅ Index on columns used in WHERE clauses
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- ✅ Composite index for multi-column filters (equality columns first)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- ✅ Partial index for sparse data
CREATE INDEX idx_orders_pending ON orders(created_at)
  WHERE status = 'pending';
```

---

### Rule: Naming Conventions

| Object | Convention | Example |
|---|---|---|
| Tables | `snake_case`, plural | `users`, `order_items` |
| Columns | `snake_case` | `user_id`, `created_at` |
| Primary keys | `id` | |
| Foreign keys | `{singular_table}_id` | `user_id`, `order_id` |
| Indexes | `idx_{table}_{columns}` | `idx_users_email` |
| Unique constraints | `uq_{table}_{columns}` | `uq_users_email` |
| Check constraints | `chk_{table}_{rule}` | `chk_orders_positive_total` |
| Foreign key constraints | `fk_{table}_{ref_table}` | `fk_orders_users` |
| Sequences | `{table}_{column}_seq` | |
| Enum types | `{domain}_status` or `{domain}_type` | `order_status` |

---

## Query Rules

### Rule: Never Use SELECT *

Always name the columns you need. `SELECT *` breaks when columns are added or reordered and loads unnecessary data.

```sql
-- ✅ Explicit columns
SELECT id, email, first_name, last_name, role FROM users WHERE id = $1;

-- ❌ Implicit — fragile and potentially slow
SELECT * FROM users WHERE id = $1;
```

---

### Rule: Always Paginate Collection Queries

```sql
-- ✅ Keyset pagination (preferred — O(1) regardless of dataset size)
SELECT id, title, created_at
FROM posts
WHERE (created_at, id) < ($cursor_created_at, $cursor_id)
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- ✅ Offset pagination (acceptable for small datasets)
SELECT id, title, created_at
FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET $offset;

-- ❌ Unbounded query — OOM risk at scale
SELECT * FROM posts ORDER BY created_at DESC;
```

---

### Rule: Use EXPLAIN ANALYZE Before Merging Query Changes

Any change to a query that runs more than 10 times per second must include an `EXPLAIN ANALYZE` output in the PR description.

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT u.id, u.email, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.is_active = true
GROUP BY u.id, u.email
ORDER BY order_count DESC
LIMIT 50;
```

Look for:
- Sequential scans on large tables (add an index)
- Nested loop joins on large tables (consider hash join or indexing)
- Sort operations on large result sets (add an index with the sort direction)
- Estimated row count vs actual rows — large discrepancies indicate stale statistics

---

### Rule: Use Transactions for Multi-Step Writes

Any operation that writes to more than one table must be wrapped in a transaction.

```typescript
// ✅ Transaction ensures atomicity
await dataSource.transaction(async (manager) => {
  const order = await manager.save(Order, orderData)
  await manager.save(OrderItem, items.map(i => ({ ...i, orderId: order.id })))
  await manager.decrement(Product, { id: In(productIds) }, 'stock', 1)
  await manager.save(AuditLog, { action: 'order_created', orderId: order.id })
})

// ❌ No transaction — partial writes leave data in inconsistent state
await orderRepo.save(orderData)
await orderItemRepo.save(items)  // If this fails, order exists without items
```

---

## Migration Rules

### Rule: Every Schema Change Must Be a Migration

Never apply manual schema changes to production. All changes must flow through versioned migrations.

```typescript
// TypeORM migration example
export class AddUserRoleColumn1709123456789 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.addColumn('users', new TableColumn({
      name: 'role',
      type: 'varchar',
      length: '50',
      default: "'user'",
      isNullable: false,
    }))

    await queryRunner.createIndex('users', new TableIndex({
      name: 'idx_users_role',
      columnNames: ['role'],
    }))
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropIndex('users', 'idx_users_role')
    await queryRunner.dropColumn('users', 'role')
  }
}
```

### Rule: Migrations Must Be Reversible

Every migration must implement `down()`. Irreversible migrations must be explicitly documented and approved.

### Rule: Never Drop a Column in the Same Migration That Removes Its Code

**Safe sequence for removing a column:**

1. Deploy code that no longer reads the column (code is compatible with both schemas)
2. Deploy migration that adds `deleted_at` or marks column unused
3. After next deploy cycle: deploy migration that drops the column

This prevents downtime during rolling deployments.

### Rule: Migrations Must Not Lock Tables in Production

For tables larger than 1M rows, use non-locking operations:

```sql
-- ❌ Full table lock during ALTER
ALTER TABLE users ADD COLUMN bio TEXT;

-- ✅ Non-blocking alternative (PostgreSQL 11+)
ALTER TABLE users ADD COLUMN bio TEXT;  -- fine if column allows NULL

-- For adding NOT NULL with a default on a large table:
-- Step 1: add nullable column
ALTER TABLE users ADD COLUMN bio TEXT;
-- Step 2: backfill in batches
UPDATE users SET bio = '' WHERE bio IS NULL AND id > $cursor LIMIT 1000;
-- Step 3: add constraint (after backfill complete)
ALTER TABLE users ALTER COLUMN bio SET NOT NULL;
```

---

## Data Integrity Rules

### Rule: Soft Delete Over Hard Delete for User Data

```sql
-- ✅ Soft delete preserves audit trail
UPDATE users SET deleted_at = NOW() WHERE id = $1;

-- Query active records
SELECT * FROM users WHERE deleted_at IS NULL;

-- ❌ Hard delete loses history and can break foreign key constraints
DELETE FROM users WHERE id = $1;
```

### Rule: Never Mutate Audit Logs

Audit log tables must be append-only:

```sql
-- Revoke UPDATE and DELETE on audit tables
REVOKE UPDATE, DELETE ON audit_events FROM application_role;
```

### Rule: Use Row-Level Security for Multi-Tenant Data

```sql
-- Enable RLS on tenant-scoped tables
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY orders_tenant_isolation ON orders
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## Connection Rules

### Rule: Always Use Connection Pooling

```
# Connection pool sizing formula:
# max_connections = (core_count * 2) + effective_spindle_count
# Application pool = max_connections / number_of_pods - 5 (reserved for admin)

# Example: 16-core server, 3 pods
# max_connections = (16 * 2) + 1 = 33
# Pool per pod = (33 / 3) - 5 = 6
```

```typescript
// TypeORM pool configuration
extra: {
  max: 10,
  min: 2,
  acquire: 30000,
  idle: 10000,
}
```

### Rule: Configure Statement Timeout

Prevent runaway queries from exhausting connection pools:

```sql
-- Set at the application role level
ALTER ROLE app_user SET statement_timeout = '30s';

-- Or per-connection
SET statement_timeout = '30000';  -- 30 seconds
```
