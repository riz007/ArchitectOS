# Java Enterprise State Management

## Preferred Stack

- Java 21
- Spring Boot
- Maven or Gradle
- Spring Security
- Spring Data JPA
- Lombok optional
- OpenAPI

## Avoid

- God services
- static mutable state
- business logic in controllers
- direct JDBC in controllers
- hardcoded configuration values

## Recommended Structure

```
src/main/java/com/example/
  modules/
    auth/
      controller/
      service/
      dto/
      entity/
    users/
  config/
  common/
    exception/
    mapper/
    security/
src/main/resources/
  application.yml
```

## Core Patterns

- Use request-scoped state and dependency injection
- Keep shared mutable state isolated behind service boundaries
- Use caching layers for expensive reads
- Keep session or request context minimal

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

- "Create a Java enterprise playbook for Spring Boot with layered architecture."
- "Explain Java backend state management using Spring beans and caching."
- "Generate deployment guidance for Spring Boot microservices in Kubernetes."
