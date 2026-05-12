# React Enterprise Architecture

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

### Why this structure?

- Keeps domain features isolated
- Makes reusable behavior easy to share
- Separates infrastructure from presentation
- Enables lazy loading and modular growth

## Scaling Advice

- Use feature modules so new domains can be added without broad refactors
- Keep service boundaries small and focused
- Use lazy loading for large modules
- Prefer encapsulated feature contracts over shared global state

## Production Deployment

- Build artifacts with optimization enabled
- Use environment-specific configuration for API endpoints and credentials
- Serve production assets from CDN or edge locations when appropriate
- Add health and metrics endpoints for observability
- Protect secrets and avoid exposing runtime internals

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
