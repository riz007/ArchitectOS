#!/usr/bin/env node
/**
 * ArchitectOS automated PR review engine.
 * Runs on GitHub Actions, calls Claude to review the PR diff against
 * ArchitectOS standards, and posts the result as a PR comment.
 *
 * Required env vars:
 *   ANTHROPIC_API_KEY  — Claude API key
 *   GH_TOKEN           — GitHub token with pull-requests:write
 *   PR_NUMBER          — Pull request number
 *   REPO               — owner/repo
 *   BASE_SHA           — base commit SHA
 *   HEAD_SHA           — head commit SHA
 *   PR_TITLE           — pull request title (for context)
 */

'use strict'

const { execSync } = require('child_process')
const Anthropic = require('@anthropic-ai/sdk')

const MAX_DIFF_CHARS = 60_000
const REVIEW_BOT_MARKER = '<!-- aos-review-bot -->'

// ── Helpers ────────────────────────────────────────────────────────────────

function run(cmd, opts = {}) {
  return execSync(cmd, { encoding: 'utf8', ...opts }).trim()
}

function getDiff() {
  const base = process.env.BASE_SHA
  const head = process.env.HEAD_SHA
  const extensions = ['*.ts', '*.tsx', '*.js', '*.mjs', '*.vue', '*.py', '*.java']
  const pathFilter = extensions.map(e => `'${e}'`).join(' ')

  let diff
  try {
    diff = run(`git diff ${base}..${head} -- ${pathFilter}`)
  } catch {
    diff = run(`git diff HEAD~1..HEAD -- ${pathFilter}`)
  }

  if (!diff) return null

  if (diff.length > MAX_DIFF_CHARS) {
    diff = diff.slice(0, MAX_DIFF_CHARS)
    diff += '\n\n> ⚠️ Diff truncated to 60 000 chars. Review the full diff on GitHub.'
  }

  return diff
}

async function runReview(diff) {
  const client = new Anthropic()

  const systemPrompt = `You are an expert senior software engineer performing an automated code review on behalf of ArchitectOS.

Your job is to review the PR diff against the following standards. Be specific: reference the exact file and line where possible. Be direct and concise — no padding.

## Standards to check

### Architecture
- Business logic must live in services, not in controllers, components, or route handlers
- Controllers delegate in one line — no if/else, no DB calls
- DTOs used for all API inputs and outputs — no raw entity exposure
- Feature-based folder organisation (src/modules/ or src/features/)

### Type safety (TypeScript)
- No \`any\` — use \`unknown\` or proper types
- All function parameters and return types declared
- No type assertions (\`as X\`) unless unavoidable

### Security
- Parameterised queries — no SQL string concatenation
- All inputs validated at the API boundary (Zod / class-validator / Pydantic)
- Auth guard on every non-public state-changing endpoint
- No hardcoded secrets, API keys, or passwords
- Resource ownership verified before read or mutation (IDOR prevention)
- No sensitive data in log output

### Testing
- New behaviour has tests
- Test names describe the behaviour: "should throw when email is taken"
- Mocks only at system boundaries (HTTP, DB, external APIs)
- No floating promises in test assertions

### Performance
- No new N+1 query patterns
- New collections are paginated
- No synchronous I/O in async request handlers

### Code quality
- No duplicate logic — DRY
- Functions do one thing
- No dead code, commented-out code, or debug console.log statements
- Breaking changes have a migration path

## Output format

Use this exact structure:

\`\`\`
## ArchitectOS Review

### [FAIL] Category — brief title
**File:** \`path/to/file.ts:line\`
**Issue:** one sentence explaining the problem
**Fix:**
\`\`\`code example\`\`\`

### [WARN] Category — brief title
**File:** \`path/to/file.ts:line\`
**Issue:** one sentence
**Fix:** one sentence

---
**Summary:** N failures · N warnings · APPROVE or REQUEST CHANGES
\`\`\`

If the diff has no issues:
\`\`\`
## ArchitectOS Review
✅ All checks passed. This PR meets ArchitectOS standards.

**Summary:** 0 failures · 0 warnings · APPROVE
\`\`\`

Important:
- Only report real issues visible in the diff
- Do not invent problems that are not in the changed code
- Do not report style issues that a linter would catch
- Limit to the most important findings — do not pad with minor nits`

  const userMessage = `PR title: ${process.env.PR_TITLE || 'Unknown'}

Diff:
${diff}`

  const response = await client.messages.create({
    model: 'claude-sonnet-4-6',
    max_tokens: 2048,
    system: systemPrompt,
    messages: [{ role: 'user', content: userMessage }],
  })

  return response.content[0].text
}

async function deleteExistingBotComment(prNumber, repo) {
  try {
    const comments = JSON.parse(
      run(`gh api repos/${repo}/issues/${prNumber}/comments --jq '[.[] | {id: .id, body: .body}]'`)
    )
    for (const c of comments) {
      if (c.body.includes(REVIEW_BOT_MARKER)) {
        run(`gh api repos/${repo}/issues/comments/${c.id} -X DELETE`)
      }
    }
  } catch {
    // Non-fatal — continue even if we can't clean up old comments
  }
}

async function postComment(prNumber, repo, reviewBody) {
  await deleteExistingBotComment(prNumber, repo)

  const body = `${REVIEW_BOT_MARKER}\n${reviewBody}\n\n---\n*Posted by [ArchitectOS](https://github.com/riz007/architect-os) · [Disable](https://github.com/riz007/architect-os/blob/main/skills/aos-ci/SKILL.md#disabling-the-review)*`

  // Write body to a temp file to avoid shell escaping issues
  const fs = require('fs')
  const tmpFile = '/tmp/aos-review-body.md'
  fs.writeFileSync(tmpFile, body, 'utf8')

  run(`gh pr comment ${prNumber} --repo ${repo} --body-file ${tmpFile}`)
}

// ── Main ───────────────────────────────────────────────────────────────────

async function main() {
  const prNumber = process.env.PR_NUMBER
  const repo = process.env.REPO

  if (!process.env.ANTHROPIC_API_KEY) {
    console.error('ANTHROPIC_API_KEY is not set. Add it to your repository secrets.')
    process.exit(1)
  }

  console.log(`Reviewing PR #${prNumber} in ${repo}…`)

  const diff = getDiff()
  if (!diff) {
    console.log('No source file changes detected — skipping review.')
    process.exit(0)
  }

  console.log(`Diff size: ${diff.length} chars`)

  const review = await runReview(diff)
  console.log('\n── Review ──────────────────────────────────────────')
  console.log(review)
  console.log('────────────────────────────────────────────────────\n')

  await postComment(prNumber, repo, review)
  console.log(`Review posted to PR #${prNumber}`)

  if (review.includes('[FAIL]')) {
    console.error('Review found [FAIL] level issues. Marking check as failed.')
    process.exit(1)
  }
}

main().catch(err => {
  console.error('pr-review.js error:', err.message)
  process.exit(1)
})
