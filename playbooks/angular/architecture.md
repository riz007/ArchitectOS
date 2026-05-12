# Angular Enterprise Architecture

## Preferred Stack

- Angular 17
- TypeScript
- Standalone Components
- RxJS
- NgRx or Signals
- Angular Router
- Angular CLI

## Avoid

- NgZone-heavy operations in templates
- global services for unrelated features
- direct DOM access
- large shared modules without boundaries
- using mutable shared state

## Recommended Structure

```
src/
  app/
    modules/
      auth/
        components/
        services/
        stores/
        api/
      dashboard/
    core/
      guards/
      interceptors/
      services/
    shared/
      components/
      directives/
      pipes/
      utils/
    assets/
    environments/
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

### Lazy loaded Angular modules
```ts
// src/app/app.routes.ts
import { Routes } from "@angular/router"

export const routes: Routes = [
  { path: "", loadChildren: () => import("./modules/dashboard/dashboard.module").then(m => m.DashboardModule) },
  { path: "auth", loadChildren: () => import("./modules/auth/auth.module").then(m => m.AuthModule) }
]
```

### Angular HTTP interceptor
```ts
// src/app/core/interceptors/auth.interceptor.ts
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from "@angular/common/http"
import { Injectable } from "@angular/core"
import { Observable } from "rxjs"

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = localStorage.getItem("accessToken")
    const authReq = token ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : req
    return next.handle(authReq)
  }
}
```

### Angular service for auth API
```ts
// src/app/modules/auth/services/auth.service.ts
import { Injectable } from "@angular/core"
import { HttpClient } from "@angular/common/http"
import { Observable } from "rxjs"

@Injectable({ providedIn: "root" })
export class AuthService {
  constructor(private http: HttpClient) {}
  login(credentials: LoginPayload): Observable<AuthResponse> {
    return this.http.post<AuthResponse>("/api/auth/login", credentials)
  }
}
```

## AI Prompting Examples

- "Create an Angular enterprise architecture guide with standalone components and RxJS state management."
- "Explain why lazy loaded modules are essential for Angular scalability."
- "Recommend Angular API layer patterns for typed HttpClient usage."
