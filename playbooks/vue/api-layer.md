# Vue Enterprise API Layer

## Preferred Stack

- Axios
- Vue Query
- TypeScript
- Zod or Yup for validation
- composables for request logic

## Avoid

- direct API calls from components
- repeating endpoint URLs across the app
- synchronous API calls in lifecycle hooks
- stale API state without cache invalidation
- mixing UI logic with request logic

## Recommended Structure

```
src/
  modules/
    auth/
      api/
        authApi.ts
      services/
        authService.ts
  shared/
    api/
      apiClient.ts
      requestHelpers.ts
    composables/
      useApi.ts
  types/
    api.ts
```

### Pattern

- Centralize HTTP client configuration in `shared/api/apiClient.ts`
- Create feature-specific API adapters per module
- Wrap requests in service methods
- Use typed request and response DTOs
- Use Vue Query for remote data fetching and mutation

## Scaling Advice

- Keep API services small and focused on a single resource
- Use retry/circuit-breaker logic for external endpoints
- Use pagination and filtering on large collections
- Add a request cache layer for repeated reads
- Keep API contract definitions versioned and documented

## Production Deployment

- Use separate environment variables for `VITE_API_BASE_URL`
- Enforce HTTPS for all API traffic
- Add request timeout and retry policies
- Add structured error handling for 4xx/5xx responses
- Use a gateway or proxy for auth token validation

## Code Examples

### API client

```ts
// src/shared/api/apiClient.ts
import axios from 'axios'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json'
  }
})

apiClient.interceptors.request.use(config => {
  const token = localStorage.getItem('accessToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

apiClient.interceptors.response.use(
  response => response,
  error => {
    return Promise.reject(error)
  }
)
```

### Feature API adapter

```ts
// src/modules/auth/api/authApi.ts
import { apiClient } from '@/shared/api/apiClient'

export const authApi = {
  login(payload: LoginPayload) {
    return apiClient.post<AuthResponse>('/auth/login', payload)
  },
  refresh() {
    return apiClient.post<RefreshResponse>('/auth/refresh')
  }
}
```

### Vue Query composable

```ts
// src/shared/composables/useQuery.ts
import { useQuery, useMutation } from '@tanstack/vue-query'

export function useFetchUsers() {
  return useQuery(['users'], () => apiClient.get<User[]>('/users'))
}

export function useCreateUser() {
  return useMutation((payload: CreateUserDto) => apiClient.post<User>('/users', payload))
}
```

## AI Prompting Examples

- "Define a Vue API layer with Axios and Vue Query that keeps components free of direct network calls."
- "Create a typed API client for Vue 3 and show how to attach auth headers centrally."
- "Recommend an API folder layout for a Vue feature module named `products`."
