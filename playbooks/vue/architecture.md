# Vue Enterprise Architecture

## Preferred Stack

- Vue 3
- TypeScript
- Vite
- Pinia
- VueUse
- Vue Router
- Vue Query

## Avoid

- massive global stores
- direct API calls inside components
- prop drilling across many levels
- tightly coupled UI and domain logic
- monolithic feature files

## Recommended Structure

```
src/
  modules/
    auth/
      components/
      composables/
      services/
      api/
      types/
    dashboard/
    products/
  shared/
    components/
    composables/
    ui/
    utils/
  composables/
  services/
  router/
  stores/
  types/
```

### Why this structure?

- `modules/` keeps domain features isolated
- `shared/` provides reusable UI and helpers
- `composables/` exposes cross-cutting behavior
- `services/` houses infrastructure and API clients
- `stores/` contains state models and behaviors

## Scaling Advice

- Use feature modules so new domains can be added without affecting the whole app
- Keep each module's store small and focused
- Use lazy-loaded routes and module-level code splitting
- Prefer normalized state for collections and references
- Use Vue Query for caching and background refresh of remote data
- Keep presentation components dumb and move logic into composables

## Production Deployment

- Build with `vite build` and enable production optimizations
- Use environment-specific API endpoints from `import.meta.env`
- Serve assets via CDN and enable long-term caching
- Add a strict Content Security Policy (CSP)
- Enable HTTP/2 or HTTP/3 and gzip/brotli compression
- Use a non-root user in Docker images
- Add runtime health and metrics endpoints for observability

## Code Examples

### Module-based router configuration

```ts
// src/router/index.ts
import { createRouter, createWebHistory } from "vue-router";

const routes = [
  {
    path: "/",
    name: "Home",
    component: () => import("@/modules/dashboard/views/DashboardView.vue"),
  },
  {
    path: "/auth",
    name: "Auth",
    component: () => import("@/modules/auth/views/AuthLayout.vue"),
    children: [
      {
        path: "login",
        name: "Login",
        component: () => import("@/modules/auth/components/LoginForm.vue"),
      },
    ],
  },
];

export const router = createRouter({
  history: createWebHistory(),
  routes,
});
```

### Shared service abstraction

```ts
// src/services/apiClient.ts
import axios from "axios";

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 15000,
  headers: {
    "Content-Type": "application/json",
  },
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    // centralized error handling
    return Promise.reject(error);
  },
);
```

### Module entry point

```ts
// src/modules/auth/services/authService.ts
import { apiClient } from "@/services/apiClient";

export class AuthService {
  login(payload: LoginPayload) {
    return apiClient.post("/auth/login", payload);
  }

  refresh() {
    return apiClient.post("/auth/refresh");
  }
}
```

## AI Prompting Examples

- "Generate a Vue 3 enterprise architecture using TypeScript, Pinia, and Vue Query with a module-based file layout."
- "Suggest a folder structure for a scalable Vue application that avoids prop drilling and direct API access in components."
- "Create a production deployment checklist for a Vue app built with Vite, focusing on security and CDN-ready assets."
