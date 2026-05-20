# Multi-Agent Generation — Reference

Complete worked example generating a `product` feature on NestJS + Vue 3.

---

## Architecture Agent output

```
## Architecture Plan: product

### Domain Model
- Entity: Product
  - id: UUID (auto-generated)
  - name: string — display name, max 200 chars
  - description: string — rich text, max 5000 chars
  - priceCents: number — price in smallest currency unit (no floats)
  - stock: number — available inventory
  - status: 'active' | 'draft' | 'archived'
  - createdAt: Date
  - updatedAt: Date

### API Contract
POST   /api/products                — create product (admin only)
GET    /api/products                — list products (paginated, public)
GET    /api/products/:id            — get one product (public)
PATCH  /api/products/:id            — update product (admin only)
DELETE /api/products/:id            — soft-delete product (admin only)

### Business Rules
- price: must be > 0
- stock: cannot go below 0
- status transitions: draft → active → archived (no reverse)
- archived products are excluded from public listing
- name must be unique per tenant

### Module Boundaries
- ProductsModule owns: Product entity, ProductRepository, ProductService
- Depends on: AuthModule (for guards)
```

---

## Backend Agent output (NestJS)

**`create-product.dto.ts`**
```typescript
import { IsString, IsInt, IsPositive, MinLength, MaxLength, IsOptional, IsEnum } from 'class-validator'

export class CreateProductDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  name: string

  @IsString()
  @IsOptional()
  @MaxLength(5000)
  description?: string

  @IsInt()
  @IsPositive()
  priceCents: number

  @IsInt()
  @Min(0)
  stock: number
}
```

**`product-response.dto.ts`**
```typescript
import { Product } from '../entities/product.entity'

export class ProductResponseDto {
  id: string
  name: string
  description: string | null
  priceCents: number
  stock: number
  status: string
  createdAt: Date

  static fromEntity(p: Product): ProductResponseDto {
    const dto = new ProductResponseDto()
    dto.id          = p.id
    dto.name        = p.name
    dto.description = p.description ?? null
    dto.priceCents  = p.priceCents
    dto.stock       = p.stock
    dto.status      = p.status
    dto.createdAt   = p.createdAt
    return dto
  }
}
```

**`product.service.ts`**
```typescript
import { Injectable } from '@nestjs/common'
import { CreateProductDto } from './dto/create-product.dto'
import { UpdateProductDto } from './dto/update-product.dto'
import { ProductRepository } from './repositories/product.repository'
import { ProductResponseDto } from './dto/product-response.dto'
import { ConflictError, NotFoundError } from '../../shared/errors'

@Injectable()
export class ProductService {
  constructor(private readonly products: ProductRepository) {}

  async create(dto: CreateProductDto): Promise<ProductResponseDto> {
    const existing = await this.products.findByName(dto.name)
    if (existing) throw new ConflictError('A product with this name already exists')

    const product = await this.products.save({
      ...dto,
      status: 'draft',
    })
    return ProductResponseDto.fromEntity(product)
  }

  async findAll(page = 1, limit = 20): Promise<{ data: ProductResponseDto[]; total: number }> {
    const [items, total] = await this.products.findActive({ page, limit })
    return { data: items.map(ProductResponseDto.fromEntity), total }
  }

  async findOne(id: string): Promise<ProductResponseDto> {
    const product = await this.products.findById(id)
    if (!product) throw new NotFoundError(`Product ${id} not found`)
    return ProductResponseDto.fromEntity(product)
  }

  async update(id: string, dto: UpdateProductDto): Promise<ProductResponseDto> {
    const product = await this.products.findById(id)
    if (!product) throw new NotFoundError(`Product ${id} not found`)

    const updated = await this.products.update(id, dto)
    return ProductResponseDto.fromEntity(updated)
  }

  async remove(id: string): Promise<void> {
    const product = await this.products.findById(id)
    if (!product) throw new NotFoundError(`Product ${id} not found`)
    await this.products.update(id, { status: 'archived' })
  }
}
```

**`product.service.spec.ts`**
```typescript
import { ProductService } from './product.service'
import { ConflictError, NotFoundError } from '../../shared/errors'

function makeProduct(overrides = {}) {
  return {
    id: crypto.randomUUID(),
    name: 'Test Widget',
    priceCents: 1000,
    stock: 10,
    status: 'active',
    createdAt: new Date(),
    ...overrides,
  }
}

describe('ProductService', () => {
  let service: ProductService
  let products: jest.Mocked<ProductRepository>

  beforeEach(() => {
    products = {
      findByName: jest.fn(),
      findById: jest.fn(),
      findActive: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
    }
    service = new ProductService(products)
  })

  describe('create', () => {
    it('should create and return a product', async () => {
      products.findByName.mockResolvedValue(null)
      products.save.mockResolvedValue(makeProduct({ name: 'Widget Pro' }))

      const result = await service.create({ name: 'Widget Pro', priceCents: 999, stock: 5 })
      expect(result.name).toBe('Widget Pro')
    })

    it('should throw ConflictError when name is already taken', async () => {
      products.findByName.mockResolvedValue(makeProduct())
      await expect(service.create({ name: 'Test Widget', priceCents: 999, stock: 5 }))
        .rejects.toThrow(ConflictError)
    })
  })

  describe('findOne', () => {
    it('should return the product when it exists', async () => {
      const product = makeProduct()
      products.findById.mockResolvedValue(product)
      const result = await service.findOne(product.id)
      expect(result.id).toBe(product.id)
    })

    it('should throw NotFoundError when product does not exist', async () => {
      products.findById.mockResolvedValue(null)
      await expect(service.findOne('unknown-id')).rejects.toThrow(NotFoundError)
    })
  })
})
```

**`products.controller.ts`**
```typescript
import { Controller, Get, Post, Patch, Delete, Param, Body, Query, UseGuards, ParseUUIDPipe } from '@nestjs/common'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { AdminGuard } from '../auth/admin.guard'
import { ProductService } from './product.service'
import { CreateProductDto } from './dto/create-product.dto'
import { UpdateProductDto } from './dto/update-product.dto'

@Controller('api/products')
export class ProductsController {
  constructor(private readonly products: ProductService) {}

  @Post()
  @UseGuards(JwtAuthGuard, AdminGuard)
  create(@Body() dto: CreateProductDto) {
    return this.products.create(dto)
  }

  @Get()
  findAll(@Query('page') page = 1, @Query('limit') limit = 20) {
    return this.products.findAll(Number(page), Number(limit))
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.products.findOne(id)
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateProductDto) {
    return this.products.update(id, dto)
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.products.remove(id)
  }
}
```

---

## Frontend Agent output (Vue 3)

**`types/product.ts`**
```typescript
export interface Product {
  id: string
  name: string
  description: string | null
  priceCents: number
  stock: number
  status: 'active' | 'draft' | 'archived'
  createdAt: string
}

export interface ProductsPage {
  data: Product[]
  total: number
}

export interface CreateProductPayload {
  name: string
  description?: string
  priceCents: number
  stock: number
}
```

**`api/productsApi.ts`**
```typescript
import type { Product, ProductsPage, CreateProductPayload } from '../types/product'

const BASE = '/api/products'

export const productsApi = {
  async list(page = 1, limit = 20): Promise<ProductsPage> {
    const res = await fetch(`${BASE}?page=${page}&limit=${limit}`)
    if (!res.ok) throw new Error('Failed to load products')
    return res.json()
  },

  async get(id: string): Promise<Product> {
    const res = await fetch(`${BASE}/${id}`)
    if (!res.ok) throw new Error('Product not found')
    return res.json()
  },

  async create(payload: CreateProductPayload): Promise<Product> {
    const res = await fetch(BASE, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    if (!res.ok) throw new Error('Failed to create product')
    return res.json()
  },

  async update(id: string, payload: Partial<CreateProductPayload>): Promise<Product> {
    const res = await fetch(`${BASE}/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    if (!res.ok) throw new Error('Failed to update product')
    return res.json()
  },
}
```

**`composables/useProducts.ts`**
```typescript
import { ref, onMounted } from 'vue'
import { productsApi } from '../api/productsApi'
import type { Product } from '../types/product'

export function useProducts(initialPage = 1) {
  const products = ref<Product[]>([])
  const total = ref(0)
  const page = ref(initialPage)
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function load() {
    loading.value = true
    error.value = null
    try {
      const result = await productsApi.list(page.value)
      products.value = result.data
      total.value = result.total
    } catch (e) {
      error.value = e instanceof Error ? e.message : 'Unknown error'
    } finally {
      loading.value = false
    }
  }

  onMounted(load)

  return { products, total, page, loading, error, refresh: load }
}
```

**`components/ProductList.vue`**
```vue
<template>
  <div>
    <div v-if="loading" class="product-list--loading">
      <ProductSkeleton v-for="n in 6" :key="n" />
    </div>

    <div v-else-if="error" class="product-list--error">
      <p>{{ error }}</p>
      <button @click="refresh">Try again</button>
    </div>

    <div v-else-if="products.length === 0" class="product-list--empty">
      <p>No products available yet.</p>
    </div>

    <ul v-else class="product-list">
      <li v-for="product in products" :key="product.id">
        <ProductCard :product="product" />
      </li>
    </ul>

    <Pagination :total="total" v-model:page="page" @update:page="refresh" />
  </div>
</template>

<script setup lang="ts">
import { useProducts } from '../composables/useProducts'
const { products, total, page, loading, error, refresh } = useProducts()
</script>
```

---

## Agent coordination pattern

The four agents share context through a structured handoff:

```
Architecture Agent
  → outputs: architecture-plan.md (domain model, API contract, business rules)

Backend Agent
  → receives: architecture-plan.md
  → outputs: all backend source files

Frontend Agent
  → receives: architecture-plan.md (API contract section)
  → outputs: all frontend source files

Review Agent
  → receives: all generated files
  → outputs: /aos-review report; fixes any FAIL findings inline
```

Each agent is given a focused system prompt scoped to its responsibility. This prevents the frontend agent from making backend architecture decisions, and vice versa.
