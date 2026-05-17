#!/usr/bin/env bash
# ArchitectOS scaffold generator
# Usage: ./tools/cli/scaffold.sh <template> <project-name> [destination]
#
# Templates:
#   vue-enterprise        Vue 3 + TypeScript + Pinia + Vitest
#   react-enterprise      React 18 + TypeScript + React Query + Zustand
#   nestjs-clean-arch     NestJS + TypeScript + TypeORM + clean architecture
#   fastapi-ddd           FastAPI + Pydantic + SQLAlchemy + domain-driven design
#   microservice-template Minimal NestJS microservice with messaging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCAFFOLDS_DIR="$REPO_ROOT/scaffolds"

SUPPORTED_TEMPLATES=(
  "vue-enterprise"
  "react-enterprise"
  "nestjs-clean-arch"
  "fastapi-ddd"
  "microservice-template"
)

# ── Helpers ────────────────────────────────────────────────────────────────

print_usage() {
  echo "Usage: $0 <template> <project-name> [destination]"
  echo ""
  echo "Templates:"
  for t in "${SUPPORTED_TEMPLATES[@]}"; do
    echo "  $t"
  done
  echo ""
  echo "Examples:"
  echo "  $0 vue-enterprise my-frontend"
  echo "  $0 nestjs-clean-arch user-service ./services/user-service"
  echo "  $0 fastapi-ddd analytics-api /workspace/analytics-api"
}

log()  { echo "[scaffold] $*"; }
info() { echo "[scaffold] ✔ $*"; }
warn() { echo "[scaffold] ⚠ $*" >&2; }
fail() { echo "[scaffold] ✗ $*" >&2; exit 1; }

check_dependencies() {
  local missing=()
  command -v git &>/dev/null || missing+=("git")
  command -v node &>/dev/null || missing+=("node")
  command -v npm &>/dev/null  || missing+=("npm")

  if [[ ${#missing[@]} -gt 0 ]]; then
    fail "Missing required tools: ${missing[*]}"
  fi
}

validate_template() {
  local template="$1"
  for t in "${SUPPORTED_TEMPLATES[@]}"; do
    [[ "$t" == "$template" ]] && return 0
  done
  fail "Unknown template: '$template'. Supported: ${SUPPORTED_TEMPLATES[*]}"
}

validate_project_name() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
    fail "Invalid project name: '$name'. Use only letters, numbers, hyphens, and underscores. Must start with a letter."
  fi
}

copy_scaffold() {
  local template="$1"
  local dest="$2"
  local scaffold_src="$SCAFFOLDS_DIR/$template"

  if [[ ! -d "$scaffold_src" ]]; then
    fail "Scaffold source not found: $scaffold_src"
  fi

  if [[ -d "$dest" ]]; then
    fail "Destination already exists: $dest"
  fi

  log "Copying '$template' scaffold to '$dest'..."
  cp -r "$scaffold_src" "$dest"
  info "Files copied."
}

replace_project_name() {
  local dest="$1"
  local project_name="$2"

  log "Replacing placeholders with project name '$project_name'..."

  # Escape the project name for safe use as a sed replacement string
  local escaped_name
  escaped_name=$(printf '%s' "$project_name" | sed 's/[&/\]/\\&/g')

  find "$dest" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/__pycache__/*" \
    -type f \
    \( -name "*.json" -o -name "*.ts" -o -name "*.js" -o -name "*.md" \
       -o -name "*.yml" -o -name "*.yaml" -o -name "*.py" -o -name "*.toml" \
       -o -name "*.env*" -o -name "Dockerfile*" -o -name "*.conf" \) \
    -exec sed -i.bak \
      -e "s/{{PROJECT_NAME}}/$escaped_name/g" \
      -e "s/architect-os-scaffold/$escaped_name/g" \
      {} \;

  find "$dest" -name "*.bak" -delete

  info "Placeholder replacement complete."
}

init_git() {
  local dest="$1"
  log "Initializing git repository..."
  git -C "$dest" init -q
  git -C "$dest" add .
  git -C "$dest" commit -q -m "chore: initialize from ArchitectOS $TEMPLATE scaffold"
  info "Git repository initialized."
}

install_dependencies() {
  local dest="$1"
  local template="$2"

  if [[ -f "$dest/package.json" ]]; then
    log "Installing Node.js dependencies..."
    npm --prefix "$dest" install --silent
    info "npm install complete."
  fi

  if [[ -f "$dest/requirements.txt" ]]; then
    log "Installing Python dependencies..."
    if command -v uv &>/dev/null; then
      uv pip install -r "$dest/requirements.txt" --quiet
    elif command -v pip &>/dev/null; then
      pip install -r "$dest/requirements.txt" --quiet
    else
      warn "pip not found — skipping Python dependency installation. Run 'pip install -r requirements.txt' manually."
    fi
    info "Python dependencies installed."
  fi

  if [[ -f "$dest/pyproject.toml" ]]; then
    log "Installing Python project (pyproject.toml)..."
    if command -v uv &>/dev/null; then
      uv pip install -e "$dest" --quiet
    else
      warn "uv not found — run 'pip install -e .' manually in $dest."
    fi
  fi
}

print_next_steps() {
  local dest="$1"
  local template="$2"
  local project_name="$3"

  echo ""
  echo "────────────────────────────────────────────────────────────"
  echo "  ArchitectOS scaffold ready: $project_name"
  echo "────────────────────────────────────────────────────────────"
  echo ""
  echo "  cd $dest"

  case "$template" in
    vue-enterprise|react-enterprise)
      echo "  cp .env.example .env.local"
      echo "  npm run dev"
      ;;
    nestjs-clean-arch|microservice-template)
      echo "  cp .env.example .env"
      echo "  docker-compose up -d"
      echo "  npm run start:dev"
      ;;
    fastapi-ddd)
      echo "  cp .env.example .env"
      echo "  docker-compose up -d"
      echo "  uvicorn src.main:app --reload"
      ;;
  esac

  echo ""
  echo "  Read the playbook:  $REPO_ROOT/playbooks/$template/README.md"
  echo "  View standards:     $REPO_ROOT/standards/"
  echo ""
}

# ── Main ───────────────────────────────────────────────────────────────────

main() {
  if [[ $# -lt 2 ]]; then
    print_usage
    exit 1
  fi

  local TEMPLATE="$1"
  local PROJECT_NAME="$2"
  local DESTINATION="${3:-$(pwd)/$PROJECT_NAME}"

  check_dependencies
  validate_template "$TEMPLATE"
  validate_project_name "$PROJECT_NAME"

  copy_scaffold "$TEMPLATE" "$DESTINATION"
  replace_project_name "$DESTINATION" "$PROJECT_NAME"
  init_git "$DESTINATION"
  install_dependencies "$DESTINATION" "$TEMPLATE"
  print_next_steps "$DESTINATION" "$TEMPLATE" "$PROJECT_NAME"
}

main "$@"
