# Architecture Review — Reference Standards

## Architecture rules

**Thin controllers**
Controllers receive input, call one service method, return output. No if/else, no database calls, no business logic.

```typescript
// ✅
@Post()
create(@Body() dto: CreateUserDto) {
  return this.userService.create(dto)
}

// ❌ — logic in controller
@Post()
async create(@Body() dto: CreateUserDto) {
  const existing = await this.db.users.findOne({ email: dto.email })
  if (existing) throw new ConflictException()
  return this.db.users.save(dto)
}
```

**Service layer owns business logic**
```typescript
// ✅ — logic in service, controller just delegates
async create(dto: CreateUserDto): Promise<UserResponse> {
  const existing = await this.userRepo.findByEmail(dto.email)
  if (existing) throw new ConflictError('Email already registered')
  const user = User.create(dto)
  await this.userRepo.save(user)
  return UserResponse.fromDomain(user)
}
```

**Repository interfaces**
```typescript
// ✅ — interface in domain, implementation in infrastructure
export interface UserRepository {
  findById(id: string): Promise<User | null>
  findByEmail(email: string): Promise<User | null>
  save(user: User): Promise<void>
}
```

## Security rules

**Input validation at boundaries**
```typescript
// ✅ NestJS
class CreateUserDto {
  @IsEmail() email: string
  @MinLength(8) password: string
}

// ✅ Zod
const schema = z.object({ email: z.string().email(), password: z.string().min(8) })

// ✅ Pydantic
class CreateUser(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
```

**Authorization on mutations**
```typescript
// ✅
@Patch(':id')
@UseGuards(JwtAuthGuard)
async update(@Param('id') id: string, @Request() req, @Body() dto: UpdateDto) {
  return this.service.update(id, dto, req.user)
}

// Service checks ownership:
if (resource.userId !== actor.userId) throw new ForbiddenError()
```

**No sensitive fields in responses**
```typescript
// ✅ — use response DTO, exclude password hash
return UserResponse.fromDomain(user) // maps only safe fields

// ❌
return user // exposes passwordHash, internalFlags, etc.
```

## Testing rules

**Behavior-focused test names**
```typescript
// ✅
it('should throw ConflictError when email is already registered')
it('should return 404 when user does not exist')

// ❌
it('calls findByEmail once')
it('works correctly')
```

**Mock at boundaries**
```typescript
// ✅ — mock the repository, not internal service methods
const userRepo = { findByEmail: jest.fn(), save: jest.fn() }
const service = new UserService(userRepo)

// ❌ — mocking internals
jest.spyOn(service, 'hashPassword')
```

## Performance rules

**No N+1 queries**
```typescript
// ❌ N+1
const orders = await orderRepo.findAll()
for (const order of orders) {
  order.items = await itemRepo.findByOrder(order.id)
}

// ✅ join or batch load
const orders = await orderRepo.findAllWithItems()
```

**Paginate all collections**
```typescript
// ✅
findAll(page = 1, limit = 20): Promise<PaginatedResult<User>> {
  return this.repo.findAndCount({ take: limit, skip: (page - 1) * limit })
}

// ❌ — unbounded query
findAll(): Promise<User[]> {
  return this.repo.find()
}
```
