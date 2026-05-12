# Java Enterprise Architecture

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
