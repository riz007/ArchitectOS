# ArchitectOS Git Standards

Git discipline keeps history useful, reviews efficient, and deployments safe. These standards apply to all ArchitectOS projects regardless of team size.

## Branch Strategy

ArchitectOS uses trunk-based development with short-lived feature branches.

```
main                    ← always deployable, protected
├── feature/AUTH-123-oauth-login     ← merged within 1-2 days
├── bugfix/CART-456-price-rounding
├── hotfix/SEC-789-jwt-expiry-fix
└── release/2.4.0      ← release candidates only
```

### Branch Naming

```
{type}/{ticket-id}-{short-description}

Types: feature | bugfix | hotfix | chore | docs | release

# Examples
feature/AUTH-123-oauth2-google-login
bugfix/CART-456-fix-price-calculation
hotfix/SEC-789-patch-jwt-validation
chore/deps-bump-typescript-5.4
docs/api-update-user-endpoints
release/2.4.0
```

Rules:
- Lowercase only
- Hyphens between words, never underscores or spaces
- Include ticket ID when one exists
- Keep description under 40 characters
- Delete branches immediately after merge

---

## Commit Standards

Follow [Conventional Commits](https://www.conventionalcommits.org/) exactly.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to use |
|---|---|
| `feat` | New feature for the user |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace — no logic change |
| `refactor` | Refactoring — no feature change, no bug fix |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `chore` | Build process, dependencies, tooling |
| `ci` | CI/CD configuration |
| `build` | Build system changes |
| `revert` | Reverting a previous commit |

### Scope

Use the affected module, feature, or layer:

```
feat(auth): add OAuth2 Google login
fix(cart): correct price rounding for discounted items
perf(db): add index on orders.created_at
test(users): add integration tests for user service
chore(deps): bump typescript from 5.3 to 5.4
ci(github-actions): add security scan step to CI
```

### Good Commit Messages

```
# ✅ Describes the why, not just the what
feat(auth): add refresh token rotation to prevent session hijacking

Previously, refresh tokens were reusable indefinitely. This change
invalidates a refresh token on use and issues a new one, limiting
the attack window if a token is compromised.

Closes AUTH-456

# ✅ Short, clear, present tense
fix(api): return 409 instead of 500 for duplicate email registration

# ❌ Vague
fix: fix bug

# ❌ Past tense
feat(auth): added Google login

# ❌ Uppercase, period-terminated
Fix: Updated the user service.
```

### Commit Scope Rules

- Keep each commit atomic — one logical change per commit
- Never mix refactoring with feature changes in the same commit
- Never commit broken code, even to a feature branch
- Squash "WIP" and "fixup" commits before pushing for review

---

## Pull Request Standards

### Size Limits

| PR Type | Max changed lines | Max files |
|---|---|---|
| Feature | 400 | 20 |
| Bug fix | 200 | 10 |
| Refactor | 600 | 30 |
| Dependency bump | No limit | No limit |

Split large PRs into vertical slices (complete feature segments), not horizontal layers.

### PR Title

Follow the same Conventional Commits format as commit messages:

```
feat(auth): add OAuth2 Google login
fix(cart): correct price calculation for discounted items
```

### PR Description Template

```markdown
## What

Short summary of the change and why it was needed.

## How

Key decisions made. Notable implementation choices. Links to docs or ADRs if relevant.

## Testing

- [ ] Unit tests added / updated
- [ ] Integration tests added / updated
- [ ] Manual testing completed (describe scenario)

## Checklist

- [ ] No secrets committed
- [ ] No debug/console logs left in
- [ ] Migrations are reversible
- [ ] Performance impact considered
- [ ] Security implications considered
```

### Review Requirements

- Minimum 1 approval from a team member before merge (2 for `main`-branch direct changes)
- All CI checks must pass
- No unresolved review comments
- Author resolves their own comments (not reviewers)

---

## Protected Branch Rules

```yaml
# GitHub Branch Protection for `main`
protection_rules:
  main:
    require_pull_request_reviews:
      required_approving_review_count: 1
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
    require_status_checks:
      strict: true
      contexts:
        - ci/lint
        - ci/type-check
        - ci/tests
        - ci/security-scan
    enforce_admins: true
    restrict_pushes: true
    allow_force_pushes: false
    allow_deletions: false
```

---

## Git Hooks

Use Husky to enforce standards locally before code reaches CI.

```bash
# .husky/pre-commit
npx lint-staged

# .husky/commit-msg
npx commitlint --edit "$1"
```

```json
// .lintstagedrc
{
  "*.{ts,tsx,vue,js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,css,scss,md,yaml,yml}": ["prettier --write"],
  "*.ts": ["bash -c 'tsc --noEmit'"]
}
```

```js
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'chore', 'ci', 'build', 'revert',
    ]],
    'subject-max-length': [2, 'always', 72],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-full-stop': [2, 'never', '.'],
  },
}
```

---

## Merge Strategy

- Use **Squash and Merge** for feature branches — keeps main history clean
- Use **Merge Commit** for release branches — preserves release boundary
- Never use **Rebase and Merge** unless the team explicitly adopts a linear-history policy

### After Merge

```bash
# Delete the remote branch
git push origin --delete feature/AUTH-123-oauth-login

# Delete local branch
git branch -d feature/AUTH-123-oauth-login

# Update local main
git checkout main && git pull
```

---

## Tagging and Releases

Follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

```bash
# Create annotated tag
git tag -a v2.4.0 -m "Release 2.4.0

- feat: OAuth2 Google login
- feat: Subscription tier management
- fix: Price rounding in cart
- perf: Added index on orders.created_at"

git push origin v2.4.0
```

| Increment | When |
|---|---|
| MAJOR | Breaking API or behavior change |
| MINOR | Backwards-compatible new feature |
| PATCH | Backwards-compatible bug fix |

---

## `.gitignore` Requirements

Every project must ignore the following categories:

```gitignore
# Secrets and environment
.env
.env.local
.env.*.local
*.pem
*.key
*.p12
secrets/

# Dependencies
node_modules/
__pycache__/
.venv/
target/
.gradle/

# Build output
dist/
build/
.next/
.nuxt/
out/

# IDE
.idea/
.vscode/
*.swp
*.swo
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Coverage and test artifacts
coverage/
.nyc_output/
htmlcov/

# OS
.DS_Store
```

---

## Revert Policy

When a commit breaks `main`:

1. Revert immediately — do not attempt to fix-forward while the build is broken
2. Use `git revert` (not `git reset`) to preserve history
3. Open a new PR with the proper fix after the revert lands

```bash
git revert <commit-sha>
git push origin main  # requires admin bypass or emergency process
```
