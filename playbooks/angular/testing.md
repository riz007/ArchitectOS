# Angular Enterprise Testing

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

## Testing Pattern

- Use unit tests for core business logic
- Use integration tests for service/API interactions
- Use end-to-end tests for critical user journeys
- Mock external systems for reliability

## Scaling Advice

- Organize tests by feature to reduce complexity
- Keep test helpers reusable and small
- Use parallel test execution in CI
- Gate releases on complete test suites

## Production Deployment

- Run tests in CI before deployment
- Enforce coverage thresholds for critical modules
- Validate production build artifacts in smoke tests
- Capture test results and performance metrics

## AI Prompting Examples

- "Create an Angular enterprise architecture guide with standalone components and RxJS state management."
- "Explain why lazy loaded modules are essential for Angular scalability."
- "Recommend Angular API layer patterns for typed HttpClient usage."
