# React Enterprise API Layer

## Preferred Stack

- React 18
- TypeScript
- Vite
- React Query
- Zustand or Redux Toolkit
- React Router
- React Hook Form

## Avoid

- massive global stores
- direct API calls inside components
- prop drilling
- mixing presentation and domain logic
- using class components for new code

## Recommended Structure

```
src/
  modules/
    auth/
      components/
      hooks/
      services/
      api/
      types/
    dashboard/
  shared/
    components/
    hooks/
    services/
    utils/
  app/
    App.tsx
    index.tsx
  routes/
  state/
  styles/
```

## Recommended Pattern

- Centralize HTTP and API clients in shared services
- Use typed request/response models
- Keep components/controllers thin and delegate work to services
- Handle errors and validation at the boundary

## Scaling Advice

- Version API contracts where needed
- Keep feature APIs small and composable
- Use pagination and filtering for large datasets
- Cache repeated reads with consistent invalidation

## Production Deployment

- Enforce HTTPS and auth on all endpoints
- Use centralized logging and tracing for API requests
- Validate and sanitize all external input
- Use rate limiting and circuit breakers when needed

## Code Examples

### React route setup
```ts
// src/routes/index.tsx
import { createBrowserRouter } from "react-router-dom"

export const router = createBrowserRouter([
  { path: "/", element: <HomePage /> },
  { path: "/login", element: <LoginPage /> }
])
```

### Centralized API client
```ts
// src/shared/api/apiClient.ts
import axios from "axios"

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15000,
  headers: { "Content-Type": "application/json" }
})

apiClient.interceptors.request.use(config => {
  const token = localStorage.getItem("accessToken")
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

export default apiClient
```

### React Query auth hook
```ts
// src/modules/auth/hooks/useLogin.ts
import { useMutation } from "@tanstack/react-query"
import authApi from "@/modules/auth/api/authApi"

export function useLogin() {
  return useMutation(credentials => authApi.login(credentials))
}
```

## AI Prompting Examples

- "Generate a React enterprise architecture with TypeScript, Vite, React Query, and module-based folders."
- "Suggest a React state management approach that avoids prop drilling and keeps components dumb."
- "Create a production deployment checklist for a React Vite app."
