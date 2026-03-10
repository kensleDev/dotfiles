#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# setup-turbo-dotnet.sh
# Scaffolds a Turborepo monorepo with a .NET
# Web API, OpenAPI export, and TS type generation
# ─────────────────────────────────────────────

# ── Colours ──────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

log() { echo -e "${CYAN}${BOLD}▶ $*${RESET}"; }
success() { echo -e "${GREEN}${BOLD}✔ $*${RESET}"; }
warn() { echo -e "${YELLOW}${BOLD}⚠ $*${RESET}"; }
error() {
  echo -e "${RED}${BOLD}✘ $*${RESET}"
  exit 1
}
spacer() { echo ""; }

# ── Preflight checks ─────────────────────────
check_deps() {
  log "Checking dependencies..."

  command -v bun >/dev/null 2>&1 || error "bun is not installed. Install it from https://bun.sh"
  command -v dotnet >/dev/null 2>&1 || error "dotnet SDK is not installed. Install it from https://dot.net"
  command -v git >/dev/null 2>&1 || error "git is not installed."

  DOTNET_VERSION=$(dotnet --version)
  BUN_VERSION=$(bun --version)

  success "bun v$BUN_VERSION"
  success "dotnet v$DOTNET_VERSION"
  spacer
}

# ── Paths ─────────────────────────────────────
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd -- "${SCRIPT_DIR}/.." && pwd)
SOURCE_DIR="${ROOT_DIR}/references/TodoApi"

# ── Args / config ─────────────────────────────
PROJECT_NAME="${1:-my-app}"
API_NAME="${2:-}"
TARGET_DIR="./$PROJECT_NAME"
FRONTEND_ENABLED="false"
FRONTEND_TEMPLATE=""

if [[ -d "$TARGET_DIR" ]]; then
  error "Directory '$TARGET_DIR' already exists. Choose a different name or remove it first."
fi

# Detect dotnet target framework (e.g. net9.0)
DOTNET_TFM="net$(dotnet --version | cut -d. -f1,2)"

# ── Scaffold Turborepo ────────────────────────
prompt_api_name() {
  if [[ -n "${API_NAME}" ]]; then
    return
  fi

  if [[ -t 0 ]]; then
    read -r -p "API name (default: ${PROJECT_NAME}): " API_NAME
  fi

  if [[ -z "${API_NAME}" ]]; then
    API_NAME="${PROJECT_NAME}"
  fi
}

prompt_frontend() {
  if [[ ! -t 0 ]]; then
    return
  fi

  read -r -p "Add a frontend app? (y/N): " add_frontend
  case "${add_frontend}" in
    y|Y|yes|YES)
      FRONTEND_ENABLED="true"
      ;;
    *)
      FRONTEND_ENABLED="false"
      return
      ;;
  esac

  local options
  options=$(cat <<'EOF'
vanilla	Vanilla
vanilla-ts	Vanilla (TS)
vue	Vue
vue-ts	Vue (TS)
react	React
react-ts	React (TS)
react-compiler	React Compiler
react-compiler-ts	React Compiler (TS)
react-swc	React SWC
react-swc-ts	React SWC (TS)
preact	Preact
preact-ts	Preact (TS)
lit	Lit
lit-ts	Lit (TS)
svelte	Svelte
svelte-ts	Svelte (TS)
solid	Solid
solid-ts	Solid (TS)
qwik	Qwik
qwik-ts	Qwik (TS)
EOF
  )

  if command -v fzf >/dev/null 2>&1; then
    local selection
    selection=$(printf "%s\n" "$options" | fzf --prompt="Select frontend template: " --with-nth=2 --delimiter=$'\t' --height=15 --reverse || true)
    if [[ -n "${selection}" ]]; then
      FRONTEND_TEMPLATE="${selection%%$'\t'*}"
      return
    fi
  fi

  echo "Choose a frontend template:"
  echo "  1) Vanilla"
  echo "  2) Vanilla (TS)"
  echo "  3) Vue"
  echo "  4) Vue (TS)"
  echo "  5) React"
  echo "  6) React (TS)"
  echo "  7) React Compiler"
  echo "  8) React Compiler (TS)"
  echo "  9) React SWC"
  echo " 10) React SWC (TS)"
  echo " 11) Preact"
  echo " 12) Preact (TS)"
  echo " 13) Lit"
  echo " 14) Lit (TS)"
  echo " 15) Svelte"
  echo " 16) Svelte (TS)"
  echo " 17) Solid"
  echo " 18) Solid (TS)"
  echo " 19) Qwik"
  echo " 20) Qwik (TS)"
  read -r -p "Selection [1-20] or template name: " framework_choice

  case "${framework_choice}" in
    1) FRONTEND_TEMPLATE="vanilla" ;;
    2) FRONTEND_TEMPLATE="vanilla-ts" ;;
    3) FRONTEND_TEMPLATE="vue" ;;
    4) FRONTEND_TEMPLATE="vue-ts" ;;
    5) FRONTEND_TEMPLATE="react" ;;
    6) FRONTEND_TEMPLATE="react-ts" ;;
    7) FRONTEND_TEMPLATE="react-compiler" ;;
    8) FRONTEND_TEMPLATE="react-compiler-ts" ;;
    9) FRONTEND_TEMPLATE="react-swc" ;;
    10) FRONTEND_TEMPLATE="react-swc-ts" ;;
    11) FRONTEND_TEMPLATE="preact" ;;
    12) FRONTEND_TEMPLATE="preact-ts" ;;
    13) FRONTEND_TEMPLATE="lit" ;;
    14) FRONTEND_TEMPLATE="lit-ts" ;;
    15) FRONTEND_TEMPLATE="svelte" ;;
    16) FRONTEND_TEMPLATE="svelte-ts" ;;
    17) FRONTEND_TEMPLATE="solid" ;;
    18) FRONTEND_TEMPLATE="solid-ts" ;;
    19) FRONTEND_TEMPLATE="qwik" ;;
    20) FRONTEND_TEMPLATE="qwik-ts" ;;
    vanilla|vanilla-ts|vue|vue-ts|react|react-ts|react-compiler|react-compiler-ts|react-swc|react-swc-ts|preact|preact-ts|lit|lit-ts|svelte|svelte-ts|solid|solid-ts|qwik|qwik-ts)
      FRONTEND_TEMPLATE="${framework_choice}" ;;
    *)
      warn "Unknown selection, skipping frontend"
      FRONTEND_ENABLED="false"
      ;;
  esac
}

scaffold_turbo() {
  log "Scaffolding Turborepo: $PROJECT_NAME"

  bunx --yes create-turbo@latest "$PROJECT_NAME" \
    --package-manager bun \
    --skip-install \
    2>/dev/null

  cd "$TARGET_DIR"

  # Remove example apps we don't need
  rm -rf apps/docs
  if [[ "${FRONTEND_ENABLED}" != "true" ]]; then
    rm -rf apps/web
  fi

  success "Turborepo created"
  spacer
}

# ── .NET Web API ──────────────────────────────
scaffold_dotnet() {
  log "Scaffolding .NET Web API in apps/api..."

  local repo_root
  repo_root="$(pwd)"

  "${SCRIPT_DIR}/08-init-api.sh" "${PROJECT_NAME}" "${PROJECT_NAME}" "${API_NAME}" "${repo_root}/apps/api" "${repo_root}"

  # package.json so Turbo can invoke dotnet scripts
  cat >apps/api/package.json <<EOF
{
  "name": "@repo/api",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev":             "dotnet watch run --project Api.csproj",
    "build":           "dotnet build Api.csproj -c Release",
    "test":            "dotnet test",
    "clean":           "dotnet clean",
    "generate:openapi": "dotnet tool restore && dotnet swagger tofile --output ../../packages/api-types/openapi.json ./bin/Release/${DOTNET_TFM}/Api.dll v1",
    "generate:client":  "dotnet tool restore && dotnet nswag run nswag.json"
  }
}
EOF

  success ".NET Web API ready"
  spacer
}

# ── api-client package ────────────────────────
scaffold_api_client() {
  if [[ "${FRONTEND_ENABLED}" != "true" ]]; then
    return
  fi

  log "Creating packages/api-client..."

  mkdir -p packages/api-client/src

  cat >packages/api-client/package.json <<'EOF'
{
  "name": "@repo/api-client",
  "version": "0.0.0",
  "private": true,
  "exports": {
    ".": "./src/index.ts"
  }
}
EOF

  cat >packages/api-client/src/index.ts <<'EOF'
export * from './client';
EOF

  cat >packages/api-client/src/client.ts <<'EOF'
// Auto-generated by NSwag — do not edit manually.
// Run `bun sync-client` from the repo root to regenerate.
export {};
EOF

  if [[ -f "apps/api/nswag.json" ]]; then
    python3 - <<'PY'
import json
import pathlib

path = pathlib.Path("apps/api/nswag.json")
data = json.loads(path.read_text(encoding="utf-8"))
data["codeGenerators"]["openApiToTypeScriptClient"]["output"] = "../../packages/api-client/src/client.ts"
path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
  fi

  success "api-client package created"
  spacer
}

# ── Frontend app ──────────────────────────────
scaffold_frontend() {
  if [[ "${FRONTEND_ENABLED}" != "true" ]]; then
    return
  fi

  log "Scaffolding frontend app in apps/web (${FRONTEND_TEMPLATE})..."

  rm -rf apps/web
  bunx --yes create-vite apps/web --template "${FRONTEND_TEMPLATE}" 2>/dev/null

  success "Frontend app ready"
  spacer
}

# ── api-types package ─────────────────────────
scaffold_api_types() {
  log "Creating packages/api-types..."

  mkdir -p packages/api-types/src

  cat >packages/api-types/package.json <<'EOF'
{
  "name": "@repo/api-types",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "build": "openapi-typescript openapi.json -o src/index.ts"
  },
  "exports": {
    ".": "./src/index.ts"
  },
  "devDependencies": {
    "openapi-typescript": "^7.0.0"
  }
}
EOF

  # Placeholder so the package directory is valid before first openapi export
  cat >packages/api-types/src/index.ts <<'EOF'
// Auto-generated by openapi-typescript — do not edit manually.
// Run `bun sync-types` from the repo root to regenerate.
export {};
EOF

  cat >packages/api-types/README.md <<'EOF'
# @repo/api-types

TypeScript types auto-generated from the .NET Web API OpenAPI spec.

## Regenerating types

```bash
# From repo root
bun sync-types
```

## Usage

```ts
import type { paths, components } from '@repo/api-types'

type WeatherForecast = components['schemas']['WeatherForecast']
type GetForecastResponse = paths['/weatherforecast']['get']['responses']['200']['content']['application/json']
```
EOF

  success "api-types package created"
  spacer
}

# ── turbo.json ────────────────────────────────
write_turbo_config() {
  log "Writing turbo.json..."

  cat >turbo.json <<'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["bin/**", "obj/**", "dist/**", ".next/**", "src/index.ts"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["build"],
      "cache": false
    },
    "clean": {
      "cache": false
    },
    "generate:openapi": {
      "dependsOn": ["@repo/api#build"],
      "outputs": ["openapi.json"],
      "cache": false
    },
    "generate:client": {
      "dependsOn": ["@repo/api#build"],
      "outputs": ["packages/api-client/src/client.ts"],
      "cache": false
    },
    "@repo/api-types#build": {
      "dependsOn": ["@repo/api#generate:openapi"]
    }
  }
}
EOF

  success "turbo.json written"
  spacer
}

# ── Root package.json ─────────────────────────
write_root_package_json() {
  log "Updating root package.json..."

  # Merge our scripts into whatever create-turbo generated
  FRONTEND_ENABLED="${FRONTEND_ENABLED}" node - <<'JS'
const frontendEnabled = process.env.FRONTEND_ENABLED === 'true';
const fs   = require('fs');
const path = 'package.json';
const pkg  = JSON.parse(fs.readFileSync(path, 'utf8'));

pkg.scripts = {
  ...pkg.scripts,
  "dev":        "turbo dev",
  "build":      "turbo build",
  "test":       "turbo test",
  "clean":      "turbo clean",
  "sync-types": "turbo generate:openapi && turbo build --filter=@repo/api-types"
};

if (frontendEnabled) {
  pkg.scripts["sync-client"] = "turbo generate:client";
}

fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
JS

  success "Root package.json updated"
  spacer
}

# ── .gitignore ────────────────────────────────
update_gitignore() {
  log "Updating .gitignore..."

  cat >>.gitignore <<'EOF'

# .NET
**/bin/
**/obj/
*.user
*.suo
.vs/

# Generated OpenAPI / types
packages/api-types/openapi.json
packages/api-types/src/index.ts
EOF

  success ".gitignore updated"
  spacer
}

# ── Install deps ──────────────────────────────
install_deps() {
  log "Installing dependencies..."
  bun install
  success "Dependencies installed"
  spacer
}

# ── Done ──────────────────────────────────────
print_summary() {
  spacer
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${GREEN}${BOLD}  ✔ $PROJECT_NAME is ready!${RESET}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  spacer
  echo -e "  ${BOLD}Next steps:${RESET}"
  echo -e "  ${CYAN}cd $PROJECT_NAME${RESET}"
  spacer
  echo -e "  ${BOLD}Start dev servers:${RESET}"
  echo -e "  ${CYAN}bun dev${RESET}"
  spacer
  echo -e "  ${BOLD}Build everything:${RESET}"
  echo -e "  ${CYAN}bun build${RESET}"
  spacer
  echo -e "  ${BOLD}Generate + sync TS types from OpenAPI spec:${RESET}"
  echo -e "  ${CYAN}bun sync-types${RESET}"
  spacer
  echo -e "  ${BOLD}API will be available at:${RESET}"
  echo -e "  ${CYAN}https://localhost:7000/swagger${RESET}"
  spacer
  echo -e "  ${BOLD}Detected .NET target framework:${RESET} ${DOTNET_TFM}"
  echo -e "  ${YELLOW}If this doesn't match your api.csproj, update the${RESET}"
  echo -e "  ${YELLOW}generate:openapi path in apps/api/package.json${RESET}"
  spacer
}

# ── Main ──────────────────────────────────────
main() {
  spacer
  echo -e "${BOLD}Turborepo + .NET Web API Setup${RESET}"
  spacer

  check_deps
  prompt_api_name
  prompt_frontend
  scaffold_turbo
  scaffold_dotnet
  scaffold_frontend
  scaffold_api_client
  scaffold_api_types
  write_turbo_config
  write_root_package_json
  update_gitignore
  install_deps
  print_summary
}

main
