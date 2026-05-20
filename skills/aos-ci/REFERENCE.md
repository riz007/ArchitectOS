# CI Integration — Reference

## Complete workflow file

```yaml
# .github/workflows/aos-pr-review.yml
name: ArchitectOS PR Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  review:
    name: AI Code Review
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0          # full history needed for accurate diffs

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install review dependencies
        run: |
          cd tools/cli
          npm install

      - name: Run ArchitectOS Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
          REPO: ${{ github.repository }}
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          HEAD_SHA: ${{ github.event.pull_request.head.sha }}
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: node tools/cli/pr-review.js
```

---

## Restricting which files are reviewed

Edit the `getDiff()` function in `tools/cli/pr-review.js` to change the file extensions:

```javascript
// Default — TypeScript, JavaScript, Vue, Python, Java
const extensions = ['*.ts', '*.tsx', '*.js', '*.mjs', '*.vue', '*.py', '*.java']

// Backend only
const extensions = ['*.ts', '*.js', '*.py', '*.java']

// Frontend only
const extensions = ['*.vue', '*.tsx', '*.jsx']
```

---

## Soft mode — warnings only, never fail

To make the review informational (never fail the CI check), change the exit condition in `pr-review.js`:

```javascript
// Remove or comment this out:
if (review.includes('[FAIL]')) {
  console.error('Review found [FAIL] level issues. Marking check as failed.')
  process.exit(1)
}
```

---

## Excluding files or paths

Add a path filter to the diff command in `pr-review.js`:

```javascript
diff = run(`git diff ${base}..${head} -- ${pathFilter} ':!*.generated.ts' ':!src/migrations/**'`)
```

---

## Adding project-specific standards

Append custom rules to the `systemPrompt` in `pr-review.js`:

```javascript
const systemPrompt = `...existing prompt...

## Project-specific rules
- All API endpoints must be versioned under /api/v1/
- Redis cache keys must follow the pattern: resource:id:field
- No direct imports from other bounded contexts — use the public module index
`
```

---

## Branch protection integration

To require the ArchitectOS review to pass before merging:

1. Go to **Settings → Branches → Branch protection rules**
2. Add a rule for `main` (or your default branch)
3. Enable **Require status checks to pass before merging**
4. Search for and select `AI Code Review`

This blocks merges when `[FAIL]` findings are present.

---

## Running locally

You can run the same review locally against any branch:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
export GH_TOKEN=$(gh auth token)
export PR_NUMBER=123
export REPO=your-org/your-repo
export BASE_SHA=main
export HEAD_SHA=HEAD
export PR_TITLE="My feature branch"

node tools/cli/pr-review.js
```

---

## Troubleshooting

**"ANTHROPIC_API_KEY is not set"**
The secret is missing from repository settings. Add it at Settings → Secrets → Actions.

**"No source file changes detected"**
The PR only changes non-source files (docs, configs, etc.). The review is skipped intentionally.

**Review posts but check passes despite `[FAIL]`**
Ensure `fetch-depth: 0` is set on the checkout step. Shallow clones can produce empty diffs.

**Review is too long / times out**
Reduce `MAX_DIFF_CHARS` in `pr-review.js` (default 60 000). Very large PRs should be split.
