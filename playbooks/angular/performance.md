# Angular Enterprise Performance

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

## Core Performance Patterns

- Lazy load large modules and routes
- Memoize expensive computations
- Use async streams and chunked response handling
- Keep the critical path small and fast

## Scaling Advice

- Profile regularly and remove bottlenecks
- Move heavy work off the main thread where possible
- Use caching and CDNs for static assets
- Optimize database queries and pagination

## Production Deployment

- Enable build optimizer and minification
- Use compression and asset caching
- Add health checks and failure recovery
- Monitor latency and error rates in production

## AI Prompting Examples

- "Create an Angular enterprise architecture guide with standalone components and RxJS state management."
- "Explain why lazy loaded modules are essential for Angular scalability."
- "Recommend Angular API layer patterns for typed HttpClient usage."
