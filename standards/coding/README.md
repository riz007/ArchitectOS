# ArchitectOS Coding Standards

This document outlines the coding standards and best practices that all code in ArchitectOS projects must follow. These standards ensure consistency, maintainability, security, and scalability across all projects.

## Table of Contents

- [General Principles](#general-principles)
- [Language-Specific Standards](#language-specific-standards)
- [Code Organization](#code-organization)
- [Naming Conventions](#naming-conventions)
- [Documentation](#documentation)
- [Error Handling](#error-handling)
- [Testing](#testing)

## General Principles

### 1. Readability First

Code should be written for humans first, computers second. Prioritize clarity and maintainability over cleverness.

```typescript
// ❌ Bad: Clever but confusing
const x = arr.reduce((a, b) => a + b, 0) / arr.length;

// ✅ Good: Clear and readable
const average =
  numbers.reduce((sum, number) => sum + number, 0) / numbers.length;
```

### 2. DRY (Don't Repeat Yourself)

Avoid code duplication. Extract common functionality into reusable functions, classes, or modules.

### 3. Single Responsibility Principle

Each function, class, or module should have one clear responsibility.

### 4. Fail Fast

Validate inputs early and fail fast with clear error messages.

### 5. Explicit Over Implicit

Be explicit about intentions. Avoid magic numbers, implicit conversions, and hidden dependencies.

## Language-Specific Standards

### TypeScript/JavaScript

#### Type Safety

- Use strict TypeScript configuration
- Avoid `any` type except in migration scenarios
- Prefer union types over optional properties when appropriate
- Use branded types for domain-specific types

```typescript
// ✅ Good: Branded type for type safety
type UserId = string & { readonly __brand: "UserId" };

// ❌ Bad: Plain string, easy to mix up
type UserId = string;
```

#### Async/Await

- Prefer async/await over Promises
- Handle errors appropriately in async functions
- Use Promise.allSettled for parallel operations when some may fail

#### Modules

- Use ES6 modules
- Prefer named exports over default exports
- Group related exports

### Python

#### Type Hints

- Use type hints for all function parameters and return values
- Use modern typing features (Union, Optional, etc.)
- Enable strict mypy checking

```python
from typing import Optional, List

def get_user(user_id: str) -> Optional[dict]:
    # Implementation
    pass
```

#### Error Handling

- Use specific exception types
- Avoid bare except clauses
- Use context managers for resource management

### Java

#### Modern Java Features

- Use records for immutable data
- Prefer streams over loops
- Use text blocks for multi-line strings

```java
// ✅ Good: Record for data class
public record User(String id, String name, String email) {}

// ❌ Bad: Traditional class with boilerplate
public class User {
    private final String id;
    private final String name;
    private final String email;

    public User(String id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    // getters...
}
```

## Code Organization

### File Structure

- Group related functionality in modules
- Use index files for clean imports
- Separate concerns (business logic, infrastructure, presentation)

### Function Organization

- Keep functions small (under 20 lines preferred)
- Extract complex conditions into well-named functions
- Use early returns to reduce nesting

```typescript
// ❌ Bad: Deep nesting
function processUser(user) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        // do something
      }
    }
  }
}

// ✅ Good: Early returns
function processUser(user) {
  if (!user) return;
  if (!user.isActive) return;
  if (!user.hasPermission) return;

  // do something
}
```

## Naming Conventions

### General Rules

- Use descriptive names that explain purpose
- Avoid abbreviations unless widely understood
- Use consistent casing

### TypeScript/JavaScript

- **Variables/Functions**: camelCase
- **Classes/Types**: PascalCase
- **Constants**: SCREAMING_SNAKE_CASE
- **Files**: kebab-case.ts

### Python

- **Variables/Functions**: snake_case
- **Classes**: PascalCase
- **Constants**: SCREAMING_SNAKE_CASE
- **Files**: snake_case.py

### Java

- **Variables/Methods**: camelCase
- **Classes**: PascalCase
- **Constants**: SCREAMING_SNAKE_CASE
- **Files**: PascalCase.java

## Documentation

### Code Comments

- Explain why, not what
- Keep comments up to date
- Use JSDoc/TSDoc for public APIs

```typescript
/**
 * Calculates the total price including tax
 * @param items - Array of items with price and quantity
 * @param taxRate - Tax rate as decimal (e.g., 0.08 for 8%)
 * @returns Total price including tax
 */
function calculateTotal(items: Item[], taxRate: number): number {
  // Implementation
}
```

### README Files

- Include setup instructions
- Document API usage
- Provide examples

## Error Handling

### Consistent Error Patterns

- Use custom error classes for domain-specific errors
- Include context in error messages
- Log errors appropriately

```typescript
class ValidationError extends Error {
  constructor(field: string, value: any) {
    super(`Invalid value for ${field}: ${value}`);
    this.name = "ValidationError";
  }
}
```

### Validation

- Validate inputs at system boundaries
- Use schema validation libraries
- Provide clear validation error messages

## Testing

### Test Structure

- Unit tests for individual functions
- Integration tests for component interactions
- End-to-end tests for critical user journeys

### Test Naming

- Describe behavior, not implementation
- Use descriptive test names

```typescript
// ✅ Good: Behavior-focused
describe("User registration", () => {
  it("should create user account when valid data provided", () => {
    // test implementation
  });
});

// ❌ Bad: Implementation-focused
describe("UserService", () => {
  it("should call createUser method", () => {
    // test implementation
  });
});
```

### Test Coverage

- Aim for 80%+ code coverage
- Focus on critical business logic
- Include edge cases and error scenarios

## Enforcement

These standards are enforced through:

- ESLint/TSLint rules
- Pre-commit hooks
- CI/CD pipelines
- Code review checklists

See the [validation rules](../rules/) for automated enforcement.
