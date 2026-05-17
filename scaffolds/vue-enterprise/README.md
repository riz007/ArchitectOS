# Vue Enterprise Scaffold

A production-ready Vue 3 + TypeScript enterprise application template with comprehensive tooling, testing, and best practices.

## Features

- 🚀 **Vue 3** with Composition API
- 📝 **TypeScript** for type safety
- 🎨 **Tailwind CSS** for styling
- 📱 **Responsive design** with mobile-first approach
- 🔐 **Authentication** with JWT
- 🏪 **Pinia** for state management
- 🧪 **Comprehensive testing** (Unit, E2E)
- 📦 **Docker** containerization
- 🚢 **CI/CD** pipeline ready
- 📊 **Monitoring** and logging
- 🔒 **Security** best practices
- ♿ **Accessibility** compliant

## Quick Start

```bash
# Clone the scaffold
npx skills add riz007/ArchitectOS
# then run: /aos-scaffold vue my-app
cd my-app

# Install dependencies
npm install

# Set up environment
cp .env.example .env.local

# Start development server
npm run dev
```

## Project Structure

```
src/
├── components/           # Reusable UI components
│   ├── ui/              # Base UI components (Button, Input, etc.)
│   └── features/        # Feature-specific components
├── composables/         # Vue composables
├── views/              # Page components
├── router/             # Vue Router configuration
├── stores/             # Pinia stores
├── services/           # API services
├── types/              # TypeScript type definitions
├── utils/              # Utility functions
├── styles/             # Global styles and Tailwind config
├── locales/            # Internationalization
└── assets/             # Static assets

public/                 # Public assets
tests/                  # Test files
├── unit/              # Unit tests
├── integration/       # Integration tests
└── e2e/               # End-to-end tests

docs/                   # Documentation
scripts/               # Build and utility scripts
```

## Core Technologies

### Frontend Framework

- **Vue 3** with Composition API
- **TypeScript** for type safety
- **Vite** for fast development and building

### State Management

- **Pinia** for centralized state management
- **VueUse** for essential composables

### UI & Styling

- **Tailwind CSS** for utility-first styling
- **Headless UI** for accessible components
- **Heroicons** for consistent iconography

### HTTP Client

- **Axios** with interceptors for API calls
- **Automatic token refresh**
- **Request/response logging**

### Form Handling

- **Vue Formulate** for complex forms
- **Yup** for validation schemas

### Testing

- **Vitest** for unit testing
- **Vue Test Utils** for component testing
- **Playwright** for E2E testing
- **Testing Library** for accessible testing

### Code Quality

- **ESLint** with Vue and TypeScript rules
- **Prettier** for code formatting
- **Husky** for git hooks
- **Commitlint** for conventional commits

## Development Workflow

### 1. Development Server

```bash
npm run dev
```

Starts the development server with hot reload at `http://localhost:3000`.

### 2. Building for Production

```bash
npm run build
```

Builds the application for production in the `dist/` directory.

### 3. Preview Production Build

```bash
npm run preview
```

Serves the production build locally for testing.

### 4. Running Tests

```bash
# Unit tests
npm run test:unit

# E2E tests
npm run test:e2e

# All tests
npm run test

# Test coverage
npm run test:coverage
```

### 5. Code Quality

```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Type checking
npm run type-check

# Format code
npm run format
```

## Environment Configuration

Create a `.env.local` file with the following variables:

```env
# Application
VITE_APP_TITLE="My Enterprise App"
VITE_APP_VERSION="1.0.0"

# API
VITE_API_BASE_URL="http://localhost:3001/api"
VITE_API_TIMEOUT=10000

# Authentication
VITE_AUTH_TOKEN_KEY="auth_token"
VITE_REFRESH_TOKEN_KEY="refresh_token"

# Features
VITE_ENABLE_ANALYTICS=true
VITE_ENABLE_ERROR_REPORTING=true
```

## Authentication Flow

The scaffold includes a complete authentication system:

1. **Login/Register** forms with validation
2. **JWT token** management with automatic refresh
3. **Protected routes** with role-based access
4. **Password reset** functionality
5. **Social login** integration points

## API Integration

### Service Layer Pattern

```typescript
// services/api.ts
import axios from "axios";

class ApiClient {
  private instance = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL,
    timeout: import.meta.env.VITE_API_TIMEOUT,
  });

  // Request/Response interceptors
  // Authentication headers
  // Error handling
}

export const apiClient = new ApiClient();
```

### Resource Services

```typescript
// services/userService.ts
export class UserService {
  async getUsers(params: UserQuery) {
    return apiClient.get("/users", { params });
  }

  async createUser(data: CreateUserDto) {
    return apiClient.post("/users", data);
  }

  // ... other CRUD operations
}
```

## Component Architecture

### Base Components

Reusable UI components following design system principles:

- **Button** - Multiple variants and sizes
- **Input** - Text, email, password, etc.
- **Select** - Dropdown with search
- **Modal** - Dialog overlays
- **Table** - Data tables with sorting/pagination
- **Form** - Form wrapper with validation

### Feature Components

Feature-specific components organized by domain:

```
components/features/
├── auth/
│   ├── LoginForm.vue
│   ├── RegisterForm.vue
│   └── PasswordReset.vue
├── dashboard/
│   ├── StatsCard.vue
│   ├── RecentActivity.vue
│   └── Charts.vue
└── users/
    ├── UserList.vue
    ├── UserForm.vue
    └── UserProfile.vue
```

## State Management

### Pinia Stores

```typescript
// stores/auth.ts
export const useAuthStore = defineStore("auth", () => {
  const user = ref<User | null>(null);
  const isAuthenticated = computed(() => !!user.value);

  const login = async (credentials: LoginCredentials) => {
    // Login logic
  };

  const logout = async () => {
    // Logout logic
  };

  return {
    user,
    isAuthenticated,
    login,
    logout,
  };
});
```

### Composables

```typescript
// composables/useApi.ts
export function useApi<T>(url: string, options = {}) {
  const data = ref<T | null>(null);
  const loading = ref(false);
  const error = ref(null);

  const execute = async () => {
    // API call logic
  };

  return {
    data: readonly(data),
    loading: readonly(loading),
    error: readonly(error),
    execute,
  };
}
```

## Testing Strategy

### Unit Tests

```typescript
// components/ui/Button.test.ts
import { describe, it, expect } from "vitest";
import { mount } from "@vue/test-utils";
import Button from "./Button.vue";

describe("Button", () => {
  it("renders slot content", () => {
    const wrapper = mount(Button, {
      slots: { default: "Click me" },
    });
    expect(wrapper.text()).toBe("Click me");
  });

  it("emits click event", async () => {
    const wrapper = mount(Button);
    await wrapper.trigger("click");
    expect(wrapper.emitted("click")).toBeTruthy();
  });
});
```

### E2E Tests

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from "@playwright/test";

test("user can login", async ({ page }) => {
  await page.goto("/login");
  await page.fill('[data-testid="email"]', "user@example.com");
  await page.fill('[data-testid="password"]', "password");
  await page.click('[data-testid="login-button"]');

  await expect(page).toHaveURL("/dashboard");
  await expect(page.locator('[data-testid="welcome-message"]')).toContainText(
    "Welcome",
  );
});
```

## Deployment

### Docker

```dockerfile
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI/CD

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18"
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm run test

  deploy:
    if: github.ref == 'refs/heads/main'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: docker build -t my-app .
      - run: docker push my-registry/my-app
```

## Security Features

- **Content Security Policy** (CSP)
- **XSS protection** with input sanitization
- **CSRF protection** with tokens
- **Secure headers** with Helmet
- **Input validation** with Yup schemas
- **Rate limiting** for API endpoints
- **Audit logging** for sensitive operations

## Performance Optimizations

- **Code splitting** with dynamic imports
- **Lazy loading** for routes and components
- **Image optimization** with lazy loading
- **Bundle analysis** and optimization
- **Caching strategies** for static assets
- **Service worker** for offline functionality

## Monitoring & Analytics

- **Error tracking** with Sentry
- **Performance monitoring** with Web Vitals
- **User analytics** with Google Analytics
- **Logging** with structured logs
- **Health checks** for services

## Contributing

1. Follow the established patterns and conventions
2. Write tests for new features
3. Update documentation
4. Ensure code passes all checks
5. Use conventional commits

## License

This scaffold is part of the ArchitectOS project and follows its licensing terms.
