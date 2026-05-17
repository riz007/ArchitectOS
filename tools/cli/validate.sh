#!/usr/bin/env bash
# ArchitectOS project validator
# Checks that a project conforms to ArchitectOS standards.
# Usage: ./tools/cli/validate.sh [project-path]

set -euo pipefail

PROJECT="${1:-.}"
PROJECT="$(cd "$PROJECT" && pwd)"

PASS=0
WARN=0
FAIL=0

# ── Helpers ────────────────────────────────────────────────────────────────

green="\033[0;32m"
yellow="\033[0;33m"
red="\033[0;31m"
reset="\033[0m"

pass() { echo -e "${green}  ✔${reset} $*"; ((PASS++)); }
warn() { echo -e "${yellow}  ⚠${reset} $*"; ((WARN++)); }
fail() { echo -e "${red}  ✗${reset} $*"; ((FAIL++)); }

section() { echo ""; echo "── $* ──────────────────────────────────────────"; }

file_exists()    { [[ -f "$PROJECT/$1" ]]; }
dir_exists()     { [[ -d "$PROJECT/$1" ]]; }
file_contains()  { grep -q "$2" "$PROJECT/$1" 2>/dev/null; }
has_package()    { file_exists "package.json" && grep -q "\"$1\"" "$PROJECT/package.json"; }

# ── Checks ─────────────────────────────────────────────────────────────────

check_repo_basics() {
  section "Repository"

  if dir_exists ".git"; then
    pass ".git directory exists"
  else
    fail "Not a git repository — run: git init"
  fi

  if file_exists ".gitignore"; then
    pass ".gitignore present"
  else
    fail ".gitignore missing"
  fi

  if file_exists "README.md"; then
    pass "README.md present"
  else
    warn "README.md missing — add setup and usage instructions"
  fi

  if file_exists ".env.example" || file_exists ".env.template"; then
    pass ".env.example / .env.template present"
  else
    warn ".env.example missing — document required environment variables"
  fi

  # Ensure .env files are gitignored
  if file_exists ".gitignore"; then
    if file_contains ".gitignore" "\.env"; then
      pass ".env files are gitignored"
    else
      fail ".env not in .gitignore — risk of secret exposure"
    fi
  fi
}

check_secrets() {
  section "Secrets"

  local found_secrets=0

  # Check for common secret patterns in source files
  while IFS= read -r -d '' file; do
    if grep -qiE '(password|secret|apikey|api_key|token)\s*=\s*["\x27][^"]+["\x27]' "$file" 2>/dev/null; then
      fail "Possible hardcoded secret in: ${file#$PROJECT/}"
      ((found_secrets++))
    fi
  done < <(find "$PROJECT" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/dist/*" \
    -not -name "*.test.*" \
    -not -name "*.spec.*" \
    -type f \
    \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" \) \
    -print0)

  [[ $found_secrets -eq 0 ]] && pass "No hardcoded secrets detected in source files"
}

check_typescript() {
  section "TypeScript"

  if ! file_exists "package.json"; then
    return
  fi

  if file_exists "tsconfig.json"; then
    pass "tsconfig.json present"

    if file_contains "tsconfig.json" '"strict": true'; then
      pass "strict mode enabled"
    else
      fail "strict mode not enabled in tsconfig.json — add: \"strict\": true"
    fi

    if file_contains "tsconfig.json" '"noUncheckedIndexedAccess"'; then
      pass "noUncheckedIndexedAccess enabled"
    else
      warn "noUncheckedIndexedAccess not set — consider enabling for safer array/object access"
    fi
  else
    warn "tsconfig.json missing in TypeScript project"
  fi
}

check_linting() {
  section "Linting & Formatting"

  if ! file_exists "package.json"; then
    return
  fi

  if file_exists ".eslintrc.js" || file_exists ".eslintrc.cjs" || \
     file_exists ".eslintrc.json" || file_exists "eslint.config.js" || \
     file_exists "eslint.config.mjs"; then
    pass "ESLint configuration present"
  else
    fail "ESLint not configured — add .eslintrc.js or eslint.config.js"
  fi

  if file_exists ".prettierrc" || file_exists ".prettierrc.json" || \
     file_exists "prettier.config.js" || file_contains "package.json" '"prettier"'; then
    pass "Prettier configuration present"
  else
    warn "Prettier not configured — add .prettierrc for consistent formatting"
  fi

  if dir_exists ".husky" || file_contains "package.json" '"husky"'; then
    pass "Husky git hooks configured"
  else
    warn "Husky not configured — consider pre-commit hooks for quality enforcement"
  fi
}

check_testing() {
  section "Testing"

  if ! file_exists "package.json"; then
    return
  fi

  local has_test_framework=0

  for framework in vitest jest playwright cypress; do
    if has_package "$framework"; then
      pass "Test framework: $framework"
      has_test_framework=1
      break
    fi
  done

  [[ $has_test_framework -eq 0 ]] && fail "No test framework installed (vitest, jest, playwright)"

  # Look for test files
  local test_count
  test_count=$(find "$PROJECT/src" \
    -type f \
    \( -name "*.test.ts" -o -name "*.spec.ts" -o -name "*.test.js" -o -name "*.spec.js" \) \
    2>/dev/null | wc -l | tr -d ' ')

  if [[ "$test_count" -gt 0 ]]; then
    pass "$test_count test file(s) found"
  else
    fail "No test files found in src/ — add unit tests for business logic"
  fi
}

check_docker() {
  section "Docker"

  if file_exists "Dockerfile" || file_exists "Dockerfile.backend" || file_exists "Dockerfile.frontend"; then
    pass "Dockerfile present"

    # Check for multi-stage builds (good practice)
    if grep -q "AS build" "$PROJECT/Dockerfile" 2>/dev/null || \
       grep -q "AS production" "$PROJECT/Dockerfile" 2>/dev/null; then
      pass "Multi-stage Dockerfile"
    else
      warn "Consider multi-stage Dockerfile for smaller production images"
    fi
  else
    warn "Dockerfile missing — containerization recommended for production"
  fi

  if file_exists "docker-compose.yml" || file_exists "docker-compose.yaml"; then
    pass "docker-compose.yml present"
  fi

  if file_exists ".dockerignore"; then
    pass ".dockerignore present"
  else
    warn ".dockerignore missing — add to exclude node_modules, .env, dist from image"
  fi
}

check_ci() {
  section "CI/CD"

  if dir_exists ".github/workflows"; then
    local workflow_count
    workflow_count=$(find "$PROJECT/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
    pass ".github/workflows present ($workflow_count workflow(s))"
  else
    warn "No GitHub Actions workflows — add CI for lint, test, security scan"
  fi
}

check_architecture() {
  section "Architecture"

  if ! dir_exists "src"; then
    warn "No src/ directory found — verify project structure"
    return
  fi

  # Check for feature-based organization signals
  if dir_exists "src/modules" || dir_exists "src/features" || dir_exists "src/domain"; then
    pass "Feature-based organization detected"
  else
    warn "Consider feature-based folder organization (src/modules/ or src/features/)"
  fi

  # Check for service layer
  if find "$PROJECT/src" -name "*.service.ts" -o -name "*_service.py" -o -name "*Service.java" 2>/dev/null | grep -q .; then
    pass "Service layer files detected"
  else
    warn "No service layer files detected — ensure business logic is isolated from controllers"
  fi
}

# ── Summary ────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo "════════════════════════════════════════════════"
  echo "  ArchitectOS Validation Report"
  echo "  Project: $PROJECT"
  echo "════════════════════════════════════════════════"
  echo -e "  ${green}Passed:${reset}   $PASS"
  echo -e "  ${yellow}Warnings:${reset} $WARN"
  echo -e "  ${red}Failed:${reset}   $FAIL"
  echo "────────────────────────────────────────────────"

  if [[ $FAIL -gt 0 ]]; then
    echo -e "  ${red}Result: FAIL${reset} — fix the failures above before shipping."
    echo ""
    exit 1
  elif [[ $WARN -gt 0 ]]; then
    echo -e "  ${yellow}Result: PASS with warnings${reset} — review warnings before shipping."
    echo ""
    exit 0
  else
    echo -e "  ${green}Result: PASS${reset} — project meets ArchitectOS standards."
    echo ""
    exit 0
  fi
}

# ── Main ───────────────────────────────────────────────────────────────────

echo "ArchitectOS Project Validator"
echo "Checking: $PROJECT"

check_repo_basics
check_secrets
check_typescript
check_linting
check_testing
check_docker
check_ci
check_architecture
print_summary
