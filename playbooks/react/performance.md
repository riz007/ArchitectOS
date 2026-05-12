# React Enterprise Performance

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

- "Generate a React enterprise architecture with TypeScript, Vite, React Query, and module-based folders."
- "Suggest a React state management approach that avoids prop drilling and keeps components dumb."
- "Create a production deployment checklist for a React Vite app."
