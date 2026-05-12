# Java Enterprise Testing

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

- "Create a Java enterprise playbook for Spring Boot with layered architecture."
- "Explain Java backend state management using Spring beans and caching."
- "Generate deployment guidance for Spring Boot microservices in Kubernetes."
