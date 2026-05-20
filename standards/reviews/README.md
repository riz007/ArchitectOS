# ArchitectOS Code Review Standards

Code review is the primary quality gate. Reviews should be fast, constructive, and focused on correctness — not style (that is the linter's job).

---

## Review Goals

1. **Catch bugs** before they reach production
2. **Enforce architecture** standards from `standards/` and `playbooks/`
3. **Share knowledge** across the team
4. **Maintain security** and prevent vulnerabilities

Reviews are not about personal preference. If a standard exists, reference it. If no standard exists, make a suggestion (not a demand) or raise it as a team discussion.

---

## AI-Assisted Review

Before human review, run the automated skill commands to surface mechanical issues immediately:

| Command | What it checks |
|---|---|
| `/aos-review` | Architecture, type safety, security, naming, API design |
| `/aos-audit` | Deep security audit — auth, CSRF, IDOR, secrets, headers |
| `/aos-codereview` | Full PR decision with BLOCK/REQUEST/NIT verdict |
| `/aos-frontend` | Component design, accessibility, performance, bundle size |
| `/aos-ux` | Usability, loading/error states, microcopy, motion |
| `/aos-qa` | Test pyramid, isolation, coverage, snapshot hygiene |
| `/aos-pragmatic` | DRY, orthogonality, fail fast, broken windows |
| `/aos-refactor` | Complexity, naming, duplication, refactoring patterns |

For automated PR review on every push: see `/aos-ci` to set up the GitHub Action.

---

## Reviewer Responsibilities

### Time Expectations

| PR size | First review within |
|---|---|
| < 100 lines | 4 hours |
| 100–400 lines | 1 business day |
| > 400 lines | 2 business days |

Never leave a PR without a response for more than 2 business days. Even "I'll review this tomorrow" unblocks the author.

### What to Check

#### 1. Correctness

- Does the code do what the PR description says?
- Are edge cases handled?
- Does error handling cover realistic failure modes?
- Are async operations properly awaited?
- Are race conditions possible?

#### 2. Security

- Are all inputs validated at the boundary?
- Is there any path to SQL injection, XSS, CSRF, or IDOR?
- Are secrets passed through environment variables, not hardcoded?
- Are authorization checks in place for every sensitive operation?

See `standards/security/README.md` and run `/aos-audit` for specifics.

#### 3. Architecture

- Does the change follow the repository's layering conventions?
- Is business logic in services, not in controllers or components?
- Is there unnecessary coupling between modules?
- Does this introduce circular dependencies?

#### 4. Performance

- Are there N+1 query risks?
- Is there unbounded data loading without pagination?
- Are expensive operations cached where appropriate?

#### 5. Tests

- Are unit tests present for new business logic?
- Do tests assert behaviour, not implementation?
- Are edge cases and error conditions covered?

---

## Comment Classification

Use these labels consistently across all reviews. They remove ambiguity about what must be actioned.

| Label | Meaning | Must fix before merge? |
|---|---|---|
| `[BLOCK]` | Correctness bug, security issue, or breaking change | Yes |
| `[REQUEST]` | Missing test, unclear design, or improvable code — important but not blocking | Author's call |
| `nit:` | Minor naming, formatting, or style point | No |
| `[praise]` | Pattern worth reinforcing | No action |

```
[BLOCK] This endpoint has no authorization check. Any authenticated user
can delete any other user's data. Add @UseGuards(JwtAuthGuard) and verify
req.user.id === targetUserId before the delete.

[REQUEST] Consider caching this result in Redis with a 5-minute TTL.
The database hit on every request will become a bottleneck at scale.

nit: variable name 'd' — 'discountPercent' would read better.

[praise] Clean use of the repository pattern here — easy to swap the
implementation for testing without touching the service.
```

---

## Giving Feedback Effectively

- **Reference standards**, not personal preference. "This violates the layering rule in `standards/architecture/README.md`" is more objective than "I don't like this."
- **Propose solutions**, not just problems. "This is wrong" is less useful than "This is wrong because X — you could fix it by doing Y."
- **Ask questions when uncertain.** "Is there a reason for this approach?" opens dialogue rather than assuming the author is wrong.
- **Praise good decisions.** This reinforces patterns you want repeated.
- **Separate nits from blockers.** A PR should not be blocked on formatting.

---

## Author Responsibilities

### Before Requesting Review

- [ ] Self-review your own diff before assigning reviewers
- [ ] Run `/aos-review` and fix any `[FAIL]` findings
- [ ] CI is green
- [ ] PR description is complete (what, how, testing done)
- [ ] No debug logs, commented-out code, or development TODOs left in
- [ ] No secrets in the diff
- [ ] Related documentation updated if applicable

### Responding to Reviews

- Respond to every comment, even with "Done" or "Fixed in X"
- Do not silently apply changes without acknowledging feedback
- If you disagree, explain why — do not just ignore the comment
- Do not merge until all `[BLOCK]` comments are resolved

---

## Review Anti-Patterns

### For Reviewers

| Anti-pattern | Why it's harmful |
|---|---|
| Nitpicking style that the linter handles | Wastes time on automatable checks |
| Approving without reading | Gives false confidence |
| Leaving vague comments like "This is bad" | Author has no direction |
| Blocking on preference, not standards | Creates subjective gatekeeping |
| Reviewing architecture for the first time at PR stage | Architecture must be aligned before implementation |

### For Authors

| Anti-pattern | Why it's harmful |
|---|---|
| Giant PRs that are impossible to review | Reviewers rubber-stamp or miss bugs |
| Pushing commits during review without flagging | Invalidates in-progress reviews |
| Merging without resolving blockers | Breaks review process trust |
| Not self-reviewing before requesting review | Wastes reviewer time on obvious issues |

---

## Architecture Review (Pre-Implementation)

For changes that cross module boundaries, introduce new dependencies, or affect multiple teams, do a lightweight architecture review **before writing code**.

A one-page document covering:

1. **Problem** — what is being solved?
2. **Options considered** — at least two alternatives evaluated
3. **Chosen approach** — what and why
4. **Trade-offs** — what is given up
5. **Impact** — what breaks or changes for consumers

This prevents wasted implementation work and large-scale review conflicts.

---

## Review Checklist (Quick Reference)

```markdown
## Code Review Checklist

### Correctness
- [ ] Logic matches PR description
- [ ] Edge cases handled
- [ ] Error paths handled
- [ ] No floating promises

### Security
- [ ] Inputs validated at boundary
- [ ] Authorization checks in place
- [ ] No secrets hardcoded
- [ ] No SQL injection, XSS, or CSRF risk
- [ ] IDOR checks on resource access

### Architecture
- [ ] Follows layering conventions
- [ ] Business logic in services, not controllers or UI
- [ ] No circular dependencies introduced

### Performance
- [ ] No N+1 queries
- [ ] Collections paginated
- [ ] Cache invalidated where needed

### Tests
- [ ] New logic has tests
- [ ] Edge cases covered
- [ ] Tests are behaviour-focused

### Dependencies
- [ ] New packages actively maintained
- [ ] Licences compatible
- [ ] No new HIGH/CRITICAL vulnerabilities

### Housekeeping
- [ ] No debug logs
- [ ] No commented-out code
- [ ] Docs updated if needed
- [ ] .env.example updated for new env vars
```
