# Vue Enterprise Testing

## Preferred Stack

- Vitest
- Vue Test Utils
- Playwright
- Testing Library
- Mock Service Worker (MSW)

## Avoid

- brittle tests tied to implementation details
- testing only happy paths
- skipping integration or E2E coverage
- relying solely on snapshots
- ignoring test coverage for shared utilities

## Recommended Structure

```
src/
  modules/
    auth/
      __tests__/
      store.test.ts
      component.test.ts
  tests/
    e2e/
    integration/
    unit/
```

### Pattern

- Use unit tests for individual functions and components
- Use integration tests for composables and services
- Use E2E tests for user journeys
- Mock network requests with MSW
- Keep tests fast and deterministic

## Scaling Advice

- Group tests by feature to keep suites manageable
- Use data builders for consistent fixtures
- Keep test setup reusable across modules
- Use `vitest` watch mode during development
- Gate deploys behind test pipelines and coverage thresholds

## Production Deployment

- Run unit, integration, and E2E tests in CI
- Fail deploys if coverage drops below target
- Use headless browser runs for E2E tests in pipeline
- Include smoke tests for critical routes and auth flows
- Validate production build artifacts before release

## Code Examples

### Component unit test

```ts
// src/modules/auth/__tests__/LoginForm.test.ts
import { mount } from "@vue/test-utils";
import { describe, it, expect } from "vitest";
import LoginForm from "../components/LoginForm.vue";

describe("LoginForm", () => {
  it("renders login button", () => {
    const wrapper = mount(LoginForm);
    expect(wrapper.text()).toContain("Sign In");
  });
});
```

### Store test

```ts
// src/modules/auth/__tests__/authStore.test.ts
import { setActivePinia, createPinia } from "pinia";
import { describe, it, expect, beforeEach } from "vitest";
import { useAuthStore } from "../store";

beforeEach(() => {
  setActivePinia(createPinia());
});

describe("auth store", () => {
  it("starts unauthenticated", () => {
    const store = useAuthStore();
    expect(store.isAuthenticated).toBe(false);
  });
});
```

### API integration test

```ts
// tests/integration/authApi.test.ts
import { describe, it, expect } from "vitest";
import { setupServer } from "msw/node";
import { rest } from "msw";
import { authApi } from "@/modules/auth/api/authApi";

const server = setupServer(
  rest.post("/auth/login", (req, res, ctx) => {
    return res(
      ctx.json({
        accessToken: "token",
        user: { id: "1", email: "user@example.com" },
      }),
    );
  }),
);

beforeAll(() => server.listen());
afterAll(() => server.close());
afterEach(() => server.resetHandlers());

describe("authApi", () => {
  it("logs in successfully", async () => {
    const response = await authApi.login({
      email: "user@example.com",
      password: "password",
    });
    expect(response.accessToken).toBe("token");
  });
});
```

### E2E test

```ts
// tests/e2e/login.spec.ts
import { test, expect } from "@playwright/test";

test("user can log in", async ({ page }) => {
  await page.goto("/auth/login");
  await page.fill('[data-testid="email"]', "user@example.com");
  await page.fill('[data-testid="password"]', "password");
  await page.click('[data-testid="submit"]');
  await expect(page).toHaveURL("/dashboard");
});
```

## AI Prompting Examples

- "Create a testing strategy for a Vue enterprise app using Vitest and Playwright."
- "Generate an example Vitest unit test for a Pinia auth store."
- "Suggest a CI pipeline that runs unit, integration, and E2E tests before deployment."
