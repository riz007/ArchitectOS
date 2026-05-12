# Vue Enterprise State Management

## Preferred Stack

- Pinia
- Vue Query
- VueUse
- TypeScript
- Composition API

## Avoid

- massive stores containing unrelated domain state
- prop drilling through deep component trees
- duplicate state across modules
- storing derived state instead of computing it
- using global event buses for app state

## Recommended Structure

```
src/
  modules/
    auth/
      store.ts
      types.ts
    products/
      store.ts
      types.ts
  shared/
    stores/
    composables/
  stores/
    rootStore.ts
    themeStore.ts
    featureStores.ts
```

### Pattern

- Keep one Pinia store per feature
- Expose composables for reusable state logic
- Use Vue Query for remote data and caching
- Use typed DTOs and selectors

## Scaling Advice

- Use feature-level stores instead of a single app store
- Keep state normalized for lists and map lookups
- Use computed properties for derived state
- Persist only essential values to local storage
- Use query keys consistently with Vue Query
- Load feature stores lazily when routes are visited

## Production Deployment

- Avoid storing secrets or raw tokens in persisted state
- Use httpOnly cookies for refresh token handling if possible
- Initialize state from secure server-side data on first load
- Clear state on logout and auth failures
- Include telemetry around store hydration and failures

## Code Examples

### Feature store

```ts
// src/modules/auth/store.ts
import { defineStore } from "pinia";
import { AuthService } from "./services/authService";

export const useAuthStore = defineStore("auth", {
  state: () => ({
    user: null as User | null,
    accessToken: "" as string,
    refreshToken: "" as string,
    loading: false as boolean,
  }),
  getters: {
    isAuthenticated: (state) => !!state.user,
    userRole: (state) => state.user?.role ?? "guest",
  },
  actions: {
    async login(credentials: LoginCredentials) {
      this.loading = true;
      try {
        const response = await new AuthService().login(credentials);
        this.user = response.user;
        this.accessToken = response.accessToken;
        this.refreshToken = response.refreshToken;
      } finally {
        this.loading = false;
      }
    },
    logout() {
      this.user = null;
      this.accessToken = "";
      this.refreshToken = "";
    },
  },
});
```

### Reusable composable

```ts
// src/shared/composables/useAuthGuard.ts
import { computed } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/modules/auth/store";

export function useAuthGuard() {
  const authStore = useAuthStore();
  const router = useRouter();

  const isAuthenticated = computed(() => authStore.isAuthenticated);

  const requireAuth = async () => {
    if (!isAuthenticated.value) {
      await router.push({ name: "Login" });
    }
  };

  return { isAuthenticated, requireAuth };
}
```

## AI Prompting Examples

- "Create a scalable Vue state management plan using Pinia and Vue Query with one store per feature."
- "Explain why direct API calls in components are an anti-pattern for Vue state management."
- "Generate a Pinia store design for auth state that supports token refresh and login/logout flows."
