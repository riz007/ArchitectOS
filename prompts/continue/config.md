# ArchitectOS Continue.dev Configuration

[Continue](https://continue.dev) is the leading open-source AI coding assistant for VS Code and JetBrains. Use this guide to configure Continue for ArchitectOS projects.

## Setup

### 1. Install Continue

Install from the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=Continue.continue) or [JetBrains Marketplace](https://plugins.jetbrains.com/plugin/22707-continue).

### 2. Configure System Prompt

Open `~/.continue/config.json` (or via the Continue sidebar → Settings) and add the ArchitectOS system prompt:

```json
{
  "models": [
    {
      "title": "Claude (ArchitectOS)",
      "provider": "anthropic",
      "model": "claude-sonnet-4-6",
      "systemMessage": "You are an expert software engineer operating within the ArchitectOS framework. Apply these rules to every suggestion and generation:\n\n## Architecture\n- Business logic belongs in services — not controllers, route handlers, or components\n- Controllers must be thin — delegate to service immediately\n- Never access the database from a controller or component\n- Use DTOs for all API inputs and outputs — never expose entity objects\n- Feature-based folder organization: group by domain, not by technical layer\n- Repository interfaces abstract data access — implementations are injected\n\n## Code Quality\n- Explicit, strongly typed code — no `any` in TypeScript\n- Single Responsibility Principle — one module, one job\n- Early returns to reduce nesting — max 3 levels\n- Functions under 20 lines — extract when they grow\n- No commented-out code, debug logs, or unresolved TODOs\n\n## Security\n- Validate all inputs at system boundaries using Zod, class-validator, or Pydantic\n- Parameterized queries only — never concatenate user input into SQL\n- Secrets from environment variables only — never hardcoded\n- Authorization checks on every non-public endpoint\n- Strip sensitive fields from API responses\n\n## Testing\n- Unit tests for all new business logic\n- Test behavior, not implementation\n- Mock at system boundaries only\n- Include edge cases and error paths\n\n## Response Behavior\n- Generate complete, runnable implementations — no pseudocode\n- Include all required imports\n- Flag security concerns before providing a solution\n- If a request conflicts with ArchitectOS standards, say so and propose a compliant alternative"
    }
  ],
  "contextProviders": [
    {
      "name": "file",
      "params": {}
    },
    {
      "name": "code",
      "params": {}
    },
    {
      "name": "docs",
      "params": {}
    },
    {
      "name": "diff",
      "params": {}
    },
    {
      "name": "folder",
      "params": {}
    }
  ],
  "slashCommands": [
    {
      "name": "architect-review",
      "description": "Review code against ArchitectOS standards",
      "prompt": "Review the selected code against ArchitectOS standards. Check: 1) Architecture layering (is business logic in the right layer?), 2) Security (input validation, auth, secrets), 3) Type safety, 4) Test coverage, 5) Naming and organization. Report issues with specific references to standards and propose concrete fixes."
    },
    {
      "name": "architect-scaffold",
      "description": "Scaffold a new feature following ArchitectOS patterns",
      "prompt": "Scaffold a complete feature following ArchitectOS standards. Include: controller (thin), service (business logic), repository interface, DTOs for input/output, unit tests. Ask me for the feature name and target stack if not provided."
    },
    {
      "name": "architect-security",
      "description": "Security review against ArchitectOS security rules",
      "prompt": "Perform a security review of the selected code against ArchitectOS security standards. Check for: input validation gaps, SQL injection risks, missing authorization, hardcoded secrets, sensitive data exposure, CSRF/XSS vulnerabilities. Report each issue with severity (High/Medium/Low) and a concrete fix."
    },
    {
      "name": "architect-test",
      "description": "Generate tests following ArchitectOS testing standards",
      "prompt": "Generate comprehensive tests for the selected code following ArchitectOS standards. Include: unit tests for business logic, edge cases, error paths. Use descriptive test names that describe behavior. Mock at system boundaries, not internal collaborators."
    }
  ]
}
```

### 3. Project-Level Context (`.continue/config.json`)

For project-specific context, create `.continue/config.json` in your project root:

```json
{
  "contextProviders": [
    {
      "name": "file",
      "params": {
        "nRetrieve": 10
      }
    }
  ],
  "docs": [
    {
      "title": "ArchitectOS Standards",
      "startUrl": "https://github.com/riz007/ArchitectOS/blob/main/standards/coding/README.md",
      "rootUrl": "https://github.com/riz007/ArchitectOS"
    }
  ]
}
```

## Slash Command Reference

| Command | Description |
|---|---|
| `/architect-review` | Review selected code against all ArchitectOS standards |
| `/architect-scaffold` | Scaffold a new feature with controller, service, repository, DTOs, tests |
| `/architect-security` | Security-focused review against ArchitectOS security rules |
| `/architect-test` | Generate behavior-focused unit tests for selected code |

## Recommended Keybindings

Add to VS Code `keybindings.json`:

```json
[
  {
    "key": "ctrl+shift+r",
    "command": "continue.acceptDiff"
  },
  {
    "key": "ctrl+shift+a",
    "command": "continue.focusContinueInput"
  }
]
```

## Context Providers Reference

| Provider | Purpose | Usage |
|---|---|---|
| `@file` | Include specific file in context | `@file src/modules/users/user.service.ts` |
| `@folder` | Include entire folder | `@folder src/modules/auth` |
| `@code` | Include specific symbol | `@code UserService.create` |
| `@diff` | Include staged git diff | `@diff` |
| `@docs` | Search indexed docs | `@docs ArchitectOS Standards` |

## Tips for ArchitectOS Projects

1. **Use `@folder` for feature context** — include the entire domain folder to give the model full architectural context before asking it to modify or extend code.

2. **Use `@diff` before asking for review** — it gives the model exactly what changed, not the whole file.

3. **Run `/architect-security` on auth flows** — before every PR touching authentication or authorization code.

4. **Chain scaffold then test** — `/architect-scaffold` to build the feature, then `/architect-test` on the generated service to produce coverage.
