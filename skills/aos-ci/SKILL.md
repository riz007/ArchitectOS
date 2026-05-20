---
name: aos-ci
description: Sets up the ArchitectOS automated PR review engine — a GitHub Action that calls Claude to review every PR against ArchitectOS standards and posts FAIL/WARN findings as a PR comment. Use when user asks to set up automated code review, CI integration, or says "add ArchitectOS to my CI pipeline".
---

# /aos-ci

Set up automated PR review powered by Claude in your GitHub repository.

## What it does

Every time a PR is opened or updated:
1. The GitHub Action runs `tools/cli/pr-review.js`
2. It diffs the changed source files against the base branch
3. Claude reviews the diff against ArchitectOS standards
4. The result is posted as a PR comment with `[FAIL]` / `[WARN]` findings
5. The check fails if there are any `[FAIL]` findings, blocking the merge

## Setup

### Step 1 — Add the workflow file

Copy `.github/workflows/aos-pr-review.yml` from this repo to your project's `.github/workflows/` directory.

Or run: `/aos-ci setup` and the skill will create it for you.

### Step 2 — Add the review script

Copy `tools/cli/pr-review.js` and `tools/cli/package.json` to your project.

```
your-project/
├── .github/
│   └── workflows/
│       └── aos-pr-review.yml    ← add this
└── tools/
    └── cli/
        ├── pr-review.js         ← add this
        └── package.json         ← add this
```

### Step 3 — Add the API key secret

In your GitHub repository: **Settings → Secrets and variables → Actions → New repository secret**

```
Name:  ANTHROPIC_API_KEY
Value: sk-ant-...
```

Get your key at console.anthropic.com.

### Step 4 — Push and open a PR

The action runs automatically. Check the **Actions** tab to see it run, and the PR comments for the review output.

---

## What gets reviewed

| Category | Checks |
|---|---|
| Architecture | Business logic in services, thin controllers, DTOs, feature structure |
| Type safety | No `any`, typed parameters, no unsafe type assertions |
| Security | Parameterised queries, input validation, auth guards, no hardcoded secrets, IDOR prevention |
| Testing | New tests for new behaviour, meaningful test names, correct mocking |
| Performance | No N+1 patterns, pagination on collections |
| Code quality | DRY, single responsibility, no dead code, no debug statements |

---

## Review output example

```markdown
## ArchitectOS Review

### [FAIL] Security — missing auth guard on PATCH /users/:id
**File:** `src/users/users.controller.ts:42`
**Issue:** Any authenticated user can update any user's profile — IDOR vulnerability.
**Fix:**
  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(@Param('id') id: string, @Request() req, @Body() dto: UpdateUserDto) {
    if (id !== req.user.id) throw new ForbiddenException()
    return this.users.update(id, dto)
  }

### [WARN] Testing — no test for the duplicate email case
**File:** `src/users/user.service.ts:67`
**Issue:** New branch that throws ConflictError has no test coverage.
**Fix:** Add: it('should throw ConflictError when email is already registered')

---
**Summary:** 1 failure · 1 warning · REQUEST CHANGES
```

---

## Disabling the review

To skip the review on a specific PR, add this to the PR description:

```
<!-- aos-skip-review -->
```

To disable the action entirely, delete or comment out `.github/workflows/aos-pr-review.yml`.

---

## Cost

Each PR review uses approximately 3 000–8 000 input tokens and 500–1 500 output tokens with Claude Sonnet. At current pricing this is < $0.05 per review.

## Full reference

See [REFERENCE.md](REFERENCE.md) for setup examples, customisation, and troubleshooting.
