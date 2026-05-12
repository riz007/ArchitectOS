# Java Enterprise API Layer

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

## Recommended Pattern

- Centralize HTTP and API clients in shared services
- Use typed request/response models
- Keep components/controllers thin and delegate work to services
- Handle errors and validation at the boundary

## Scaling Advice

- Version API contracts where needed
- Keep feature APIs small and composable
- Use pagination and filtering for large datasets
- Cache repeated reads with consistent invalidation

## Production Deployment

- Enforce HTTPS and auth on all endpoints
- Use centralized logging and tracing for API requests
- Validate and sanitize all external input
- Use rate limiting and circuit breakers when needed

## Code Examples

### Spring Boot controller example
```java
// src/main/java/com/example/auth/controller/AuthController.java
@RestController
@RequestMapping("/api/auth")
public class AuthController {
  private final AuthService authService;
  public AuthController(AuthService authService) { this.authService = authService; }
  @PostMapping("/login")
  public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
    return ResponseEntity.ok(authService.login(request));
  }
}
```

### Service layer example
```java
// src/main/java/com/example/auth/service/AuthService.java
@Service
public class AuthService {
  public AuthResponse login(LoginRequest request) {
    // auth logic
  }
}
```

### Externalized configuration
```yaml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USER}
    password: ${DATABASE_PASSWORD}
```

## AI Prompting Examples

- "Create a Java enterprise playbook for Spring Boot with layered architecture."
- "Explain Java backend state management using Spring beans and caching."
- "Generate deployment guidance for Spring Boot microservices in Kubernetes."
