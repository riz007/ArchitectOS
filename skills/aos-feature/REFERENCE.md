# Gen Feature — Stack Patterns

## NestJS

```typescript
// dto/create-user.dto.ts
import { IsEmail, IsString, MinLength, MaxLength } from 'class-validator'

export class CreateUserDto {
  @IsEmail()
  email: string

  @IsString()
  @MinLength(8)
  password: string

  @IsString()
  @MaxLength(100)
  firstName: string

  @IsString()
  @MaxLength(100)
  lastName: string
}
```

```typescript
// services/user.service.ts
@Injectable()
export class UserService {
  constructor(
    @Inject(USER_REPOSITORY) private readonly users: UserRepository,
    private readonly passwords: PasswordService,
  ) {}

  async create(dto: CreateUserDto): Promise<UserResponseDto> {
    const existing = await this.users.findByEmail(dto.email)
    if (existing) throw new ConflictError('Email already registered')

    const hash = await this.passwords.hash(dto.password)
    const user = User.create({ ...dto, passwordHash: hash })
    await this.users.save(user)
    return UserResponseDto.fromDomain(user)
  }

  async findById(id: string): Promise<UserResponseDto> {
    const user = await this.users.findById(id)
    if (!user) throw new NotFoundError('User not found')
    return UserResponseDto.fromDomain(user)
  }
}
```

```typescript
// controllers/users.controller.ts
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly userService: UserService) {}

  @Post()
  @HttpCode(201)
  create(@Body() dto: CreateUserDto) {
    return this.userService.create(dto)
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.userService.findById(id)
  }
}
```

```typescript
// services/user.service.spec.ts
describe('UserService', () => {
  let service: UserService
  let users: jest.Mocked<UserRepository>
  let passwords: jest.Mocked<PasswordService>

  beforeEach(() => {
    users = { findByEmail: jest.fn(), findById: jest.fn(), save: jest.fn() }
    passwords = { hash: jest.fn().mockResolvedValue('hashed') }
    service = new UserService(users, passwords)
  })

  it('should throw ConflictError when email is already registered', async () => {
    users.findByEmail.mockResolvedValue(existingUser)
    await expect(service.create(createDto)).rejects.toThrow(ConflictError)
  })

  it('should create and return user when email is not taken', async () => {
    users.findByEmail.mockResolvedValue(null)
    users.save.mockResolvedValue(undefined)
    const result = await service.create(createDto)
    expect(result.email).toBe(createDto.email)
    expect(users.save).toHaveBeenCalledOnce()
  })
})
```

---

## FastAPI

```python
# schemas/user.py
from pydantic import BaseModel, EmailStr, Field

class CreateUserRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    first_name: str = Field(max_length=100)
    last_name: str = Field(max_length=100)

class UserResponse(BaseModel):
    id: str
    email: str
    first_name: str
    last_name: str

    @classmethod
    def from_domain(cls, user: User) -> "UserResponse":
        return cls(id=user.id, email=user.email,
                   first_name=user.first_name, last_name=user.last_name)
```

```python
# services/user_service.py
class UserService:
    def __init__(self, repo: UserRepository, passwords: PasswordService) -> None:
        self._repo = repo
        self._passwords = passwords

    async def create(self, dto: CreateUserRequest) -> UserResponse:
        if await self._repo.find_by_email(dto.email):
            raise ConflictError("Email already registered")
        hash_ = await self._passwords.hash(dto.password)
        user = User.create(email=dto.email, password_hash=hash_,
                           first_name=dto.first_name, last_name=dto.last_name)
        await self._repo.save(user)
        return UserResponse.from_domain(user)
```

```python
# routers/users.py
router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    body: CreateUserRequest,
    service: UserService = Depends(get_user_service),
    _: TokenPayload = Depends(require_auth),
) -> UserResponse:
    return await service.create(body)
```

---

## Vue 3 composable

```typescript
// composables/useUsers.ts
export function useUsers() {
  const users = ref<User[]>([])
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const fetchUsers = async () => {
    loading.value = true
    error.value = null
    try {
      users.value = await usersApi.list()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  onMounted(fetchUsers)

  return { users: readonly(users), loading: readonly(loading), error: readonly(error), refetch: fetchUsers }
}
```

---

## React hook

```typescript
// hooks/useUsers.ts
export function useUsers() {
  return useQuery<User[]>({
    queryKey: ['users'],
    queryFn: usersApi.list,
    staleTime: 5 * 60 * 1000,
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: usersApi.create,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
  })
}
```
