# React Enterprise State Management

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

- "Generate a React enterprise architecture with TypeScript, Vite, React Query, and module-based folders."
- "Suggest a React state management approach that avoids prop drilling and keeps components dumb."
- "Create a production deployment checklist for a React Vite app."
