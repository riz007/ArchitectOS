# ArchitectOS Frontend Rules

ESLint configuration and custom rules for enforcing ArchitectOS frontend standards.

## Installation

```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-vue eslint-plugin-import eslint-plugin-prettier
```

## Configuration

### `.eslintrc.js`

```javascript
module.exports = {
  root: true,
  env: {
    browser: true,
    es2022: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "@typescript-eslint/recommended-requiring-type-checking",
    "plugin:vue/vue3-recommended",
    "plugin:import/recommended",
    "plugin:import/typescript",
    "prettier",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
    project: "./tsconfig.json",
    tsconfigRootDir: __dirname,
    extraFileExtensions: [".vue"],
  },
  plugins: ["@typescript-eslint", "vue", "import"],
  settings: {
    "import/resolver": {
      typescript: {
        alwaysTryTypes: true,
      },
    },
  },
  rules: {
    // TypeScript Rules
    "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/prefer-nullish-coalescing": "error",
    "@typescript-eslint/prefer-optional-chain": "error",
    "@typescript-eslint/no-unnecessary-type-assertion": "error",
    "@typescript-eslint/no-floating-promises": "error",

    // Vue Rules
    "vue/multi-word-component-names": "off", // Allow single word components in feature folders
    "vue/component-definition-name-casing": ["error", "PascalCase"],
    "vue/component-name-in-template-casing": ["error", "PascalCase"],
    "vue/require-default-prop": "error",
    "vue/require-prop-types": "error",
    "vue/no-unused-vars": "error",
    "vue/no-unused-components": "error",
    "vue/no-use-v-if-with-v-for": "error",
    "vue/require-v-for-key": "error",
    "vue/no-duplicate-attributes": "error",
    "vue/html-self-closing": [
      "error",
      {
        html: {
          void: "always",
          normal: "never",
          component: "always",
        },
        svg: "always",
        math: "always",
      },
    ],

    // Import Rules
    "import/order": [
      "error",
      {
        groups: [
          "builtin",
          "external",
          "internal",
          "parent",
          "sibling",
          "index",
        ],
        "newlines-between": "always",
        alphabetize: {
          order: "asc",
          caseInsensitive: true,
        },
      },
    ],
    "import/no-unresolved": "error",
    "import/no-cycle": "error",
    "import/no-unused-modules": "error",
    "import/no-deprecated": "warn",

    // General Rules
    "no-console": ["error", { allow: ["warn", "error"] }],
    "no-debugger": "error",
    "prefer-const": "error",
    "no-var": "error",
    "object-shorthand": "error",
    "prefer-arrow-callback": "error",
    "prefer-template": "error",
    "template-curly-spacing": "off", // Conflicts with prettier
    "arrow-spacing": "off", // Conflicts with prettier
    "comma-dangle": "off", // Conflicts with prettier
    quotes: "off", // Conflicts with prettier
    semi: "off", // Conflicts with prettier

    // Security Rules
    "no-eval": "error",
    "no-implied-eval": "error",
    "no-new-func": "error",
    "no-script-url": "error",

    // Custom ArchitectOS Rules
    "architect-os/no-direct-api-calls-in-components": "error",
    "architect-os/require-error-boundaries": "error",
    "architect-os/no-business-logic-in-components": "warn",
    "architect-os/require-loading-states": "warn",
  },
  overrides: [
    // Vue Files
    {
      files: ["*.vue"],
      rules: {
        "@typescript-eslint/no-unused-vars": "off", // Vue handles this
      },
    },

    // Test Files
    {
      files: ["**/*.test.ts", "**/*.test.js", "**/*.spec.ts", "**/*.spec.js"],
      env: {
        jest: true,
      },
      rules: {
        "@typescript-eslint/no-explicit-any": "off",
        "no-console": "off",
      },
    },

    // Config Files
    {
      files: ["*.config.js", "*.config.ts", "vite.config.*", "vitest.config.*"],
      rules: {
        "@typescript-eslint/no-var-requires": "off",
        "no-console": "off",
      },
    },
  ],
};
```

## Custom ESLint Rules

### `no-direct-api-calls-in-components`

Prevents direct API calls in Vue components. Business logic should be in composables or services.

```javascript
// eslint-plugin-architect-os/rules/no-direct-api-calls-in-components.js
module.exports = {
  meta: {
    type: "problem",
    docs: {
      description: "Disallow direct API calls in Vue components",
      category: "Best Practices",
      recommended: true,
    },
    messages: {
      noDirectApiCall:
        "Direct API calls are not allowed in components. Use composables or services instead.",
    },
  },
  create(context) {
    return {
      CallExpression(node) {
        // Check if this is a Vue component file
        if (!context.getFilename().endsWith(".vue")) return;

        // Check for axios, fetch, or api client calls
        const callee = node.callee;
        if (
          (callee.type === "MemberExpression" &&
            callee.object.name === "axios") ||
          (callee.type === "Identifier" &&
            ["fetch", "apiClient"].includes(callee.name))
        ) {
          context.report({
            node,
            messageId: "noDirectApiCall",
          });
        }
      },
    };
  },
};
```

### `require-error-boundaries`

Requires error boundaries for complex component trees.

```javascript
// eslint-plugin-architect-os/rules/require-error-boundaries.js
module.exports = {
  meta: {
    type: "problem",
    docs: {
      description: "Require error boundaries for complex components",
      category: "Best Practices",
      recommended: true,
    },
    messages: {
      requireErrorBoundary:
        "Complex components should be wrapped in error boundaries.",
    },
  },
  create(context) {
    return {
      "Program:exit"() {
        const filename = context.getFilename();

        // Only check Vue component files
        if (!filename.endsWith(".vue")) return;

        const sourceCode = context.getSourceCode();
        const text = sourceCode.getText();

        // Simple heuristic: if component has more than 5 methods or complex logic
        const methodCount = (text.match(/const \w+ = \(\) =>/g) || []).length;
        const asyncCount = (text.match(/async/g) || []).length;

        if (methodCount > 5 || asyncCount > 3) {
          // Check if ErrorBoundary is imported
          const hasErrorBoundary = text.includes("ErrorBoundary");

          if (!hasErrorBoundary) {
            context.report({
              loc: { line: 1, column: 0 },
              messageId: "requireErrorBoundary",
            });
          }
        }
      },
    };
  },
};
```

### `no-business-logic-in-components`

Warns when business logic is placed in components instead of composables.

```javascript
// eslint-plugin-architect-os/rules/no-business-logic-in-components.js
module.exports = {
  meta: {
    type: "problem",
    docs: {
      description: "Disallow business logic in Vue components",
      category: "Best Practices",
      recommended: true,
    },
    messages: {
      noBusinessLogic:
        "Business logic should be extracted to composables. Components should only handle UI concerns.",
    },
  },
  create(context) {
    const businessLogicPatterns = [
      /if.*\..*===.*\{/,
      /for.*of.*\{/,
      /\.map\(/,
      /\.filter\(/,
      /\.reduce\(/,
      /new Date\(/,
      /Math\./,
      /JSON\.parse/,
      /JSON\.stringify/,
    ];

    return {
      "Program:exit"() {
        if (!context.getFilename().endsWith(".vue")) return;

        const sourceCode = context.getSourceCode();
        const text = sourceCode.getText();

        // Check for business logic patterns in script setup
        const scriptSetupMatch = text.match(
          /<script setup[^>]*>([\s\S]*?)<\/script>/,
        );
        if (!scriptSetupMatch) return;

        const scriptContent = scriptSetupMatch[1];

        for (const pattern of businessLogicPatterns) {
          if (pattern.test(scriptContent)) {
            // Check if it's in a composable call
            const line = scriptContent
              .split("\n")
              .find((line) => pattern.test(line));
            if (
              line &&
              !line.includes("use") &&
              !line.includes("ref(") &&
              !line.includes("computed(")
            ) {
              context.report({
                loc: { line: 1, column: 0 },
                messageId: "noBusinessLogic",
              });
              break;
            }
          }
        }
      },
    };
  },
};
```

### `require-loading-states`

Requires loading states for async operations.

```javascript
// eslint-plugin-architect-os/rules/require-loading-states.js
module.exports = {
  meta: {
    type: "problem",
    docs: {
      description: "Require loading states for async operations",
      category: "Best Practices",
      recommended: true,
    },
    messages: {
      requireLoadingState: "Async operations should have loading states.",
    },
  },
  create(context) {
    return {
      CallExpression(node) {
        if (!context.getFilename().endsWith(".vue")) return;

        // Check for async function calls
        if (
          node.callee.type === "Identifier" &&
          node.callee.name.startsWith("use")
        ) {
          // This is likely a composable call, check if it returns loading state
          const sourceCode = context.getSourceCode();
          const text = sourceCode.getText();

          // Look for loading state usage
          const hasLoadingState =
            text.includes("loading") || text.includes("isLoading");

          if (!hasLoadingState) {
            context.report({
              node,
              messageId: "requireLoadingState",
            });
          }
        }
      },
    };
  },
};
```

## Prettier Configuration

### `.prettierrc`

```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "vueIndentScriptAndStyle": false
}
```

## VS Code Integration

### `.vscode/settings.json`

```json
{
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue"
  ],
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[vue]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

## Git Hooks

### `.husky/pre-commit`

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

### `.lintstagedrc`

```json
{
  "*.{js,ts,vue}": ["eslint --fix", "prettier --write"],
  "*.{json,css,scss,md}": ["prettier --write"]
}
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18"
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
```

## Rule Enforcement

These rules are automatically enforced through:

1. **Pre-commit hooks**: Prevent commits with linting errors
2. **CI/CD pipeline**: Fail builds with rule violations
3. **VS Code integration**: Real-time feedback during development
4. **Custom rules**: Enforce ArchitectOS-specific patterns

## Extending Rules

To add new custom rules:

1. Create rule file in `eslint-plugin-architect-os/rules/`
2. Export rule from `eslint-plugin-architect-os/index.js`
3. Add to ESLint configuration
4. Update documentation

## Common Issues

### False Positives

- Custom rules may have false positives
- Use ESLint disable comments for legitimate exceptions
- Document exceptions in code comments

### Performance

- ESLint can be slow on large codebases
- Use `.eslintignore` to exclude generated files
- Configure caching for better performance

### Integration

- Ensure all team members use same VS Code settings
- Set up pre-commit hooks on all machines
- Keep ESLint and Prettier versions in sync
