# Angular Enterprise State Management

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

## Core Patterns

- Use one store or request-scoped state per feature
- Keep state transitions explicit and predictable
- Prefer derived state over duplicated values
- Use composition and hooks/services for reuse

## Scaling Advice

- Keep feature stores or service state small and focused
- Normalize collections and avoid nested state blobs
- Use lazy hydration for large state sets
- Persist only minimal authenticated session data

## Production Deployment

- Avoid persisting secrets in local or shared state
- Initialize state from secure server-side sources
- Evict or invalidate stale cache data on changes
- Clear transient state on logout or session expiry

## AI Prompting Examples

- "Create an Angular enterprise architecture guide with standalone components and RxJS state management."
- "Explain why lazy loaded modules are essential for Angular scalability."
- "Recommend Angular API layer patterns for typed HttpClient usage."
