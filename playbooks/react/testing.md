# React Enterprise Testing

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

- "Generate a React enterprise architecture with TypeScript, Vite, React Query, and module-based folders."
- "Suggest a React state management approach that avoids prop drilling and keeps components dumb."
- "Create a production deployment checklist for a React Vite app."
