# Contributing to ArchitectOS

Thank you for your interest in contributing to ArchitectOS! We welcome contributions from developers of all skill levels. This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Contribution Guidelines](#contribution-guidelines)
- [Standards and Conventions](#standards-and-conventions)
- [Testing](#testing)
- [Documentation](#documentation)
- [Review Process](#review-process)
- [Community](#community)

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Show empathy towards other contributors
- Help create a positive community

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Git
- VS Code (recommended) with ESLint and Prettier extensions
- Docker and Docker Compose (for running examples)

### Setup

1. **Fork the repository**

   ```bash
   git clone https://github.com/your-username/architect-os.git
   cd architect-os
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Set up development environment**

   ```bash
   # Copy environment file
   cp .env.example .env.local

   # Install git hooks
   npm run prepare
   ```

4. **Run tests**

   ```bash
   npm test
   ```

5. **Start development**
   ```bash
   npm run dev
   ```

## Development Workflow

### 1. Choose an Issue

- Check the [issue tracker](https://github.com/architect-os/architect-os/issues) for open issues
- Look for issues labeled `good first issue` or `help wanted`
- Comment on the issue to indicate you're working on it

### 2. Create a Branch

```bash
# Create and switch to a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/issue-number-description
```

### 3. Make Changes

- Follow the [standards and conventions](#standards-and-conventions)
- Write tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 4. Commit Changes

```bash
# Stage your changes
git add .

# Commit with conventional commit message
git commit -m "feat: add new Vue component scaffold

- Add component template with TypeScript support
- Include comprehensive tests
- Update documentation

Closes #123"
```

### 5. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create a pull request on GitHub
```

## Contribution Guidelines

### Types of Contributions

- **Bug fixes**: Fix issues in existing code
- **Features**: Add new functionality
- **Documentation**: Improve docs, guides, examples
- **Standards**: Create new standards or improve existing ones
- **Scaffolds**: Build new project templates
- **Playbooks**: Write implementation guides
- **Tools**: Develop CLI tools or utilities

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

Examples:

```
feat: add Vue 3 enterprise scaffold
fix: resolve TypeScript compilation error in auth service
docs: update API documentation for user endpoints
```

### Pull Request Guidelines

- **Title**: Clear, descriptive title following conventional commit format
- **Description**: Detailed explanation of changes
- **Testing**: Describe how changes were tested
- **Breaking Changes**: Note any breaking changes
- **Screenshots**: Include screenshots for UI changes
- **Checklist**: Ensure all items are checked

PR Template:

```markdown
## Description

Brief description of the changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)

<!-- Add screenshots here -->

## Checklist

- [ ] Code follows ArchitectOS standards
- [ ] Tests are included
- [ ] Documentation is updated
- [ ] Breaking changes are documented
```

## Standards and Conventions

### Code Standards

All code must follow ArchitectOS standards:

- **TypeScript**: Strict mode, no `any` types
- **Vue**: Composition API, TypeScript
- **Naming**: camelCase for variables/functions, PascalCase for components/classes
- **Imports**: Grouped and ordered (built-in, external, internal)
- **Documentation**: JSDoc/TSDoc for public APIs

### File Organization

```
src/
├── components/     # Reusable UI components
├── composables/    # Vue composables
├── views/         # Page components
├── stores/        # Pinia stores
├── services/      # API services
├── types/         # TypeScript definitions
├── utils/         # Utility functions
└── styles/        # Global styles
```

### Component Structure

```vue
<template>
  <!-- Template content -->
</template>

<script setup lang="ts">
import { ref, computed } from "vue";

// Props
interface Props {
  // Define props
}

const props = withDefaults(defineProps<Props>(), {
  // Default values
});

// Emits
const emit = defineEmits<{
  // Define events
}>();

// Reactive data
const data = ref();

// Computed properties
const computedValue = computed(() => {
  // Computation
});

// Methods
const method = () => {
  // Implementation
};
</script>

<style scoped>
/* Component styles */
</style>
```

## Testing

### Testing Strategy

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test component interactions
- **E2E Tests**: Test complete user journeys

### Testing Frameworks

- **Vitest**: Unit testing for Vue components
- **Vue Test Utils**: Component testing utilities
- **Playwright**: End-to-end testing

### Writing Tests

```typescript
// Component test example
import { describe, it, expect } from "vitest";
import { mount } from "@vue/test-utils";
import MyComponent from "./MyComponent.vue";

describe("MyComponent", () => {
  it("renders correctly", () => {
    const wrapper = mount(MyComponent, {
      props: {
        /* props */
      },
    });

    expect(wrapper.text()).toContain("Expected text");
  });

  it("emits event on click", async () => {
    const wrapper = mount(MyComponent);

    await wrapper.trigger("click");

    expect(wrapper.emitted("click")).toBeTruthy();
  });
});
```

### Test Coverage

Aim for >80% code coverage. Focus on:

- Happy path scenarios
- Error conditions
- Edge cases
- Business logic

## Documentation

### Documentation Types

- **README**: Project overview and setup
- **API Docs**: Public API documentation
- **Guides**: Implementation guides and tutorials
- **Standards**: Coding and architecture standards
- **Examples**: Code examples and use cases

### Documentation Standards

- Use Markdown format
- Include code examples
- Keep documentation up to date
- Use consistent formatting
- Include table of contents for long documents

## Review Process

### Automated Checks

All PRs must pass:

- **Linting**: ESLint rules
- **Type Checking**: TypeScript compilation
- **Tests**: Unit and integration tests
- **Security**: Security scanning
- **Formatting**: Prettier formatting

### Code Review

- At least one maintainer review required
- Review focuses on:
  - Code quality and standards compliance
  - Test coverage and quality
  - Documentation completeness
  - Security considerations
  - Performance implications

### Review Checklist

- [ ] Code follows ArchitectOS standards
- [ ] TypeScript types are correct
- [ ] Tests are comprehensive
- [ ] Documentation is updated
- [ ] Security considerations addressed
- [ ] Performance impact assessed
- [ ] Breaking changes documented

## Community

### Communication

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General discussions and questions
- **Pull Request Comments**: Code review discussions

### Getting Help

- Check existing issues and documentation first
- Use GitHub Discussions for questions
- Join our community chat (if available)

### Recognition

Contributors are recognized through:

- GitHub contributor statistics
- Mention in release notes
- Contributor spotlight (for significant contributions)

## Additional Resources

- [ArchitectOS Standards](standards/)
- [Vue Playbook](playbooks/vue/)
- [Testing Guide](docs/testing.md)
- [API Documentation](docs/api/)
- [Security Guidelines](standards/security/)

Thank you for contributing to ArchitectOS! Your contributions help make software development more standardized, secure, and efficient.
