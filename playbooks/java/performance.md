# Java Enterprise Performance

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

- "Create a Java enterprise playbook for Spring Boot with layered architecture."
- "Explain Java backend state management using Spring beans and caching."
- "Generate deployment guidance for Spring Boot microservices in Kubernetes."
