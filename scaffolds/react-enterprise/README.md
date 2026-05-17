# React Enterprise Scaffold

Production-ready React 18 + TypeScript enterprise application template following ArchitectOS standards.

## Stack

| Concern | Technology |
|---|---|
| UI Framework | React 18 with functional components and hooks |
| Language | TypeScript (strict mode) |
| Build tool | Vite |
| Server state | TanStack Query (React Query) v5 |
| Client state | Zustand |
| Routing | React Router v6 |
| Forms | React Hook Form + Zod |
| HTTP | Axios with interceptors |
| Styling | Tailwind CSS |
| Unit tests | Vitest + Testing Library |
| E2E tests | Playwright |
| Linting | ESLint + TypeScript rules |
| Formatting | Prettier |
| Git hooks | Husky + lint-staged |

## Quick Start

```bash
# From the ArchitectOS repo
./tools/cli/scaffold.sh react-enterprise my-app

# Or manually
cd scaffolds/react-enterprise
cp .env.example .env.local
npm install
npm run dev
```

## Project Structure

```
src/
├── modules/              # Feature modules — organized by domain
│   ├── auth/
│   │   ├── api/          # API calls for this module
│   │   ├── components/   # Module-specific components
│   │   ├── hooks/        # Module-specific hooks (useLogin, useLogout)
│   │   ├── types/        # Module-specific types
│   │   └── index.ts      # Public API for the module
│   ├── dashboard/
│   └── users/
├── shared/               # Shared across modules
│   ├── api/              # Axios client, interceptors, error handling
│   ├── components/       # Reusable UI components (Button, Input, Modal)
│   ├── hooks/            # Reusable hooks (useDebounce, usePagination)
│   ├── types/            # Shared type definitions
│   └── utils/            # Pure utility functions
├── app/
│   ├── App.tsx
│   ├── providers.tsx     # QueryClient, Router, ErrorBoundary providers
│   └── main.tsx
├── routes/
│   └── index.tsx         # Route definitions with lazy loading
└── styles/
    └── globals.css

tests/
├── unit/                 # Vitest unit tests (co-located or here)
└── e2e/                  # Playwright E2E tests
```

## Architecture Patterns

### Module structure

Each module in `src/modules/` owns its API, components, hooks, and types. Modules expose a public API via `index.ts` and do not import from each other's internals.

```
modules/users/
├── api/
│   └── usersApi.ts       # axios calls — no business logic
├── components/
│   ├── UserList.tsx
│   └── UserForm.tsx
├── hooks/
│   ├── useUsers.ts       # useQuery / useMutation wrappers
│   └── useCreateUser.ts
├── types/
│   └── user.ts
└── index.ts              # export { useUsers, UserList, ... }
```

### API hook pattern

```tsx
// modules/users/hooks/useUsers.ts
import { useQuery } from '@tanstack/react-query'
import { usersApi } from '../api/usersApi'
import type { User } from '../types/user'

export function useUsers() {
  return useQuery<User[]>({
    queryKey: ['users'],
    queryFn: usersApi.list,
    staleTime: 5 * 60 * 1000,
  })
}
```

### Component pattern

```tsx
// modules/users/components/UserList.tsx
import { useUsers } from '../hooks/useUsers'

export function UserList() {
  const { data: users, isLoading, error } = useUsers()

  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage error={error} />

  return (
    <ul>
      {users?.map(user => (
        <li key={user.id}>{user.email}</li>
      ))}
    </ul>
  )
}
```

### Centralized API client

```ts
// shared/api/apiClient.ts
import axios from 'axios'
import { useAuthStore } from '@/modules/auth'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15000,
})

apiClient.interceptors.request.use(config => {
  const token = useAuthStore.getState().accessToken
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

apiClient.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      await useAuthStore.getState().refreshToken()
      return apiClient.request(error.config)
    }
    return Promise.reject(error)
  }
)
```

## Environment Variables

```env
# .env.example
VITE_API_BASE_URL=http://localhost:3000/api
VITE_APP_TITLE={{PROJECT_NAME}}
```

## Commands

```bash
npm run dev          # Start development server (http://localhost:5173)
npm run build        # Build for production
npm run preview      # Preview production build
npm run test         # Run unit tests
npm run test:ui      # Run unit tests with UI
npm run test:e2e     # Run Playwright E2E tests
npm run test:coverage # Generate coverage report
npm run lint         # Lint source files
npm run lint:fix     # Auto-fix linting issues
npm run type-check   # TypeScript type check
npm run format       # Format with Prettier
```

## Playbook

See [React Playbook](../../playbooks/react/) for full architectural guidance.
