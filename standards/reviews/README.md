# ArchitectOS Code Review Standards

Code review is the primary quality gate. Reviews should be fast, constructive, and focused on correctness — not style (that is the linter's job).

## Review Goals

1. **Catch bugs** before they reach production
2. **Enforce architecture** standards from `standards/` and `playbooks/`
3. **Share knowledge** across the team
4. **Maintain security** and prevent vulnerabilities

Reviews are not about personal preference. If a standard exists, reference it. If no standard exists, make a suggestion (not a demand) or raise it as a team discussion.

---

## Reviewer Responsibilities

### Time Expectations

| PR size | First review within |
|---|---|
| < 100 lines | 4 hours |
| 100–400 lines | 1 business day |
| > 400 lines | 2 business days |

Never leave a PR without a response for more than 2 business days. Even a "I'll review this tomorrow" comment unblocks the author.

### What to Check

#### 1. Correctness

- Does the code do what the PR description says?
- Are there edge cases that are not handled?
- Does error handling cover realistic failure modes?
- Are async operations properly awaited?
- Are race conditions possible?

#### 2. Security

- Are all inputs validated at the boundary?
- Is there any path to SQL injection, XSS, or CSRF?
- Are secrets passed through environment variables, not hardcoded?
- Are authorization checks in place for every sensitive operation?
- Does this change expose any new attack surface?

See `standards/security/README.md` for specifics.

#### 3. Architecture

- Does the change follow the repository's layering conventions?
- Is business logic in services, not in controllers or components?
- Is there unnecessary coupling between modules?
- Does this introduce circular dependencies?
- Is the change compatible with horizontal scaling?

#### 4. Performance

- Are there N+1 query risks?
- Is there unbounded data loading without pagination or limits?
- Are expensive operations cached when appropriate?
- Does this add work to the critical path that belongs off the critical path?

#### 5. Tests

- Are unit tests present for new business logic?
- Do tests assert behavior, not implementation?
- Are edge cases and error conditions covered?
- Do tests remain valid if the implementation is refactored?

---

## Comment Classification

Use prefixes to signal intent. This removes ambiguity and makes it clear what the author must act on.

| Prefix | Meaning | Must fix? |
|---|---|---|
| `[blocker]` | Must be resolved before merge | Yes |
| `[suggestion]` | Improvement, but not required | No |
| `[question]` | Seeking understanding | Author should respond |
| `[nit]` | Minor style or formatting point | Author's discretion |
| `[praise]` | Something done well | No action needed |

```
[blocker] This endpoint has no authorization check. Any authenticated user
can delete any other user's data. Add a permission check using
AuthorizationService.requirePermission(user, Permission.DELETE_USER).

[suggestion] Consider caching this result in Redis with a 5-minute TTL.
The database hit on every request will become a bottleneck at scale.

[question] Why is this using a raw query instead of the ORM? Is there a
performance reason, or is this worth a follow-up to align with the repository pattern?

[nit] Variable name `d` isn't descriptive. `deletedCount` would read better.

[praise] Clean use of the repository pattern here — easy to swap the
implementation for testing.
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
- [ ] CI is green
- [ ] PR description is complete (what, how, testing done)
- [ ] No debug logs, commented-out code, or TODOs left in
- [ ] No secrets in the diff
- [ ] Related documentation updated if applicable

### Responding to Reviews

- Respond to every comment, even with just "Done" or "Fixed in X"
- Do not silently apply changes without acknowledging the feedback
- If you disagree, explain why — do not just ignore the comment
- Do not merge until all `[blocker]` comments are resolved

---

## Review Anti-Patterns

### For Reviewers

| Anti-pattern | Why it's harmful |
|---|---|
| Nitpicking style that the linter handles | Wastes time on automatable checks |
| Approving without actually reading | Gives false confidence |
| Leaving vague comments like "This is bad" | Leaves the author without direction |
| Blocking on preference, not standards | Creates subjective gatekeeping |
| Reviewing architecture for the first time at PR stage | Architecture should be aligned before implementation |

### For Authors

| Anti-pattern | Why it's harmful |
|---|---|
| Giant PRs that are impossible to review | Reviewers rubber-stamp or miss bugs |
| Pushing new commits during review without flagging | Invalidates in-progress reviews |
| Merging without resolving blockers | Breaks review process |
| Not self-reviewing before requesting review | Wastes reviewer's time on obvious issues |

---

## Architecture Review (Pre-Implementation)

For changes that cross architectural boundaries, involve new dependencies, or affect multiple teams, do a lightweight **architecture review** before writing code.

A one-page doc or PR discussion covering:

1. **Problem**: What is being solved?
2. **Options considered**: At least 2 alternatives evaluated
3. **Chosen approach**: What and why
4. **Trade-offs**: What is given up
5. **Impact**: What breaks or changes for consumers

This prevents wasted implementation work and large-scale review conflicts.

---

## Review Checklist (Quick Reference)

```markdown
## Code Review Checklist

### Correctness
- [ ] Logic matches PR description
- [ ] Edge cases handled
- [ ] Error paths handled

### Security
- [ ] Inputs validated
- [ ] Authorization checks in place
- [ ] No secrets hardcoded
- [ ] No SQL injection or XSS risk

### Architecture
- [ ] Follows layering conventions
- [ ] Business logic in services, not UI or controllers
- [ ] No circular dependencies introduced

### Performance
- [ ] No N+1 queries
- [ ] Unbounded queries paginated
- [ ] Caching used where appropriate

### Tests
- [ ] New logic has tests
- [ ] Edge cases covered
- [ ] Tests are behavior-focused, not implementation-focused

### Housekeeping
- [ ] No debug logs
- [ ] No commented-out code
- [ ] Docs updated if needed
```
