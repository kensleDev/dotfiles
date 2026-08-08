# Research: Automate Worktree Manager with Bash Scripts

**Date:** 2025-01-18
**Confidence:** High
**Researcher:** researcher agent

---

## Executive Summary

Analysis of the existing worktree-manager skill reveals that most operations are currently handled by the LLM through manual execution of bash commands. This results in high LLM computation overhead and slower execution times. The solution is to consolidate operations into reusable bash scripts with structured JSON output, creating a thin LLM integration layer focused on decision-making and error recovery.

**Key findings:**
- 7 existing scripts can be consolidated into ~4 focused scripts plus a library
- Current scripts have good error handling but lack JSON output for LLM consumption
- Package manager detection, dev server detection, and validation can be fully automated
- Idempotent patterns and structured logging with JSON are well-established practices

**Recommendation:** Create a new skill `worktree-scripts` with modular bash library, focused automation scripts, and JSON output format for LLM consumption.

---

## Research Objectives

1. **Analyze existing worktree-manager implementation** - Review all 7 scripts to understand current operations
2. **Define bash vs LLM responsibility split** - Identify what should be automated vs controlled by LLM
3. **Identify consolidation opportunities** - Determine which scripts can be merged and what new scripts are needed
4. **Research error handling patterns** - Best practices for robust bash scripts
5. **Define output format requirements** - How scripts should report status for LLM consumption
6. **Design integration layer** - How bash scripts will interact with Claude Code

---

## Root Cause Analysis

### Current Issues

**Problem 1: High LLM Overhead**
- Every worktree creation requires LLM to execute 10+ separate bash commands
- LLM thinks through each step individually, leading to slower execution
- Operations like package manager detection, port allocation, git worktree creation are deterministic and don't need LLM

**Problem 2: Inconsistent Error Handling**
- Some scripts use `set -e`, others don't
- Error messages are human-readable but not machine-parseable
- Exit codes are inconsistent across scripts
- No structured logging for debugging

**Problem 3: Code Duplication**
- Package manager detection logic exists in SKILL.md but not in scripts
- Dev server detection patterns are documented but not automated
- Health check logic is manually described, not implemented in scripts
- Registry operations with jq are repeated across multiple scripts

**Problem 4: Poor Reusability**
- Scripts are monolithic and hard to test
- No shared library for common operations
- Functions cannot be sourced and reused
- No namespace conventions to avoid collisions

---

## Findings

### 1. Existing Script Analysis

**Current Scripts:**
1. `allocate-ports.sh` - Allocates N ports from pool, updates registry
2. `register.sh` - Registers worktree in global registry
3. `launch-agent.sh` - Launches Claude Code in terminal (ghostty/tmux/iterm2)
4. `status.sh` - Shows worktree status in table format
5. `cleanup.sh` - Removes worktree, kills ports, updates registry
6. `sync.sh` - Reconciles registry with actual worktrees and PR status
7. `release-ports.sh` - Releases ports back to pool

**Strengths:**
- All use `set -e` for error propagation
- Good use of `jq` for JSON manipulation
- Comprehensive error messages to stderr
- Support for multiple terminal types (ghostty, tmux, iterm2, wezterm, kitty, alacritty)

**Weaknesses:**
- No JSON output format (all human-readable tables)
- No shared library for common functions
- Inconsistent exit codes (mostly 1 for all errors)
- No structured logging for debugging
- No validation/health check automation
- No package manager detection in scripts
- No dev server detection in scripts

---

### 2. Bash vs LLM Responsibility Split

#### **Bash Responsibilities (Fast, Deterministic, Repetitive)**

| Operation | Reason for Automation |
|-----------|---------------------|
| Git worktree operations | Deterministic, well-defined |
| Port allocation from pool | Simple logic, deterministic |
| Registry JSON manipulation | jq operations, pure computation |
| Package manager detection | File-based detection, deterministic |
| Dependency installation | Command execution, deterministic |
| Dev server detection | File/config-based, deterministic |
| Health checks (curl with timeout) | Network operations, deterministic |
| Process management (kill on ports) | Simple system operations |
| Terminal launching | Command execution, deterministic |
| PR status checking | gh CLI, deterministic |

#### **LLM Responsibilities (Decision-Making, User Intent, Error Recovery)**

| Operation | Reason for LLM |
|-----------|-----------------|
| Parse user requests for worktree creation | Natural language understanding |
| Decide which branches to create worktrees for | Context-aware decision making |
| Determine task descriptions for agents | User intent interpretation |
| Error recovery strategies | Context-dependent decisions |
| Conflict resolution (port, branch, path) | Context-aware conflict handling |
| Project-specific configuration decisions | Understanding project needs |
| Warn vs. proceed decisions | User experience judgment |
| Parallel execution coordination | Resource management decisions |

---

### 3. Script Consolidation Opportunities

**Proposed Architecture:**

```
skills/worktree-scripts/
├── lib/
│   └── common.sh              # Shared library with reusable functions
├── scripts/
│   ├── setup-worktree.sh       # Create worktree, install, validate, register (NEW)
│   ├── launch-agent.sh         # Launch Claude Code in terminal (ENHANCED)
│   ├── cleanup-worktree.sh     # Remove worktree, kill ports, update registry (ENHANCED)
│   ├── show-status.sh          # Show status in JSON format (NEW)
│   ├── sync-registry.sh       # Sync registry with actual worktrees (ENHANCED)
│   └── manage-ports.sh        # Allocate/release ports (ENHANCED)
├── config.json                # Configuration (reuse from worktree-manager)
└── SKILL.md                  # Documentation for new skill
```

**Consolidation Strategy:**

1. **`setup-worktree.sh` (NEW)** - Combines:
   - Git worktree creation
   - Copy uncommitted resources (`.agents`, `.env.example`)
   - Package manager detection
   - Dependency installation
   - Dev server detection
   - Health check (start server, curl, stop server)
   - Register in global registry
   - Launch agent (optional flag)
   - **Output:** JSON with all details + status

2. **`launch-agent.sh` (ENHANCED)** - Enhance existing:
   - Add JSON output option (`--json`)
   - Extract terminal detection logic to library
   - Support project-specific config override

3. **`cleanup-worktree.sh` (ENHANCED)** - Enhance existing `cleanup.sh`:
   - Add JSON output option (`--json`)
   - Port cleanup logic to library
   - Worktree removal logic to library

4. **`show-status.sh` (NEW)** - Replace `status.sh`:
   - Always output JSON (for LLM parsing)
   - Optional human-readable table (`--human`)
   - Filter by project, status, branch
   - Include PR status, port usage, health status

5. **`sync-registry.sh` (ENHANCED)** - Enhance existing `sync.sh`:
   - Add JSON output option (`--json`)
   - Move PR checking logic to library
   - Add auto-fix option (`--fix`)

6. **`manage-ports.sh` (ENHANCED)** - Combine `allocate-ports.sh` + `release-ports.sh`:
   - `allocate` subcommand
   - `release` subcommand
   - Add JSON output for both

---

### 4. Error Handling Patterns

**Research from jsdev.space and arslan.io:**

#### **Standard Script Header**

```bash
#!/bin/bash
# strict mode
set -euo pipefail

# Trap errors for cleanup
trap 'handle_error $? $LINENO' ERR

# Handle interrupt
trap 'handle_interrupt' INT TERM
```

#### **Error Handling Functions**

```bash
# Error handler for trap
handle_error() {
    local exit_code=$1
    local line_number=$2
    _log_error "Script failed at line $line_number with exit code $exit_code"
    cleanup  # Call cleanup function
    exit $exit_code
}

# Graceful interrupt handler
handle_interrupt() {
    _log_warn "Interrupted, cleaning up..."
    cleanup
    exit 130  # Standard exit code for SIGINT
}

# Exit with error message
error_exit() {
    _log_error "$1"
    exit "${2:-1}"
}

# Warning message
warn() {
    _log_warn "$1"
    return 0
}
```

#### **Exit Code Conventions**

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Configuration error (missing config, invalid values) |
| 3 | Missing dependency (jq, git, gh, etc.) |
| 4 | Validation failure (health check failed) |
| 5 | Permission error (cannot write to directory) |
| 6 | Resource conflict (port in use, worktree exists) |
| 130 | Interrupted (SIGINT/SIGTERM) |

---

### 5. Idempotency Patterns

**Research from arslan.io:**

#### **File Operations**

```bash
# Create directory (idempotent)
mkdir -p "$WORKTREE_PATH"

# Create file only if not exists
[ ! -f "$config_file" ] && create_config "$config_file"

# Remove file/directory (no error if missing)
rm -rf "$directory"

# Copy directory only if destination doesn't exist
[ ! -d "$dest" ] && cp -r "$src" "$dest"
```

#### **Symbolic Links**

```bash
# Create symlink idempotently
ln -sfn "$source" "$target"
```

#### **Git Worktree Operations**

```bash
# Check if worktree already exists before creating
if ! git worktree list | grep -q "$WORKTREE_PATH"; then
    git worktree add "$WORKTREE_PATH" -b "$branch"
fi
```

#### **Registry Updates**

```bash
# Check if entry exists before adding
if ! jq -e ".worktrees[] | select(.project == \"$PROJECT\")" "$REGISTRY" > /dev/null; then
    # Add entry
fi
```

---

### 6. Structured Logging with JSON

**Research from Medium article on structured logging with jq:**

#### **Log Function**

```bash
_log() {
    local level=$1
    local message=$2
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo '{}' | jq \
        --arg timestamp "$timestamp" \
        --arg level "$level" \
        --arg message "$message" \
        '{timestamp: $timestamp, level: $level, message: $message}' >&2
}

_log_info() { _log "INFO" "$1"; }
_log_warn() { _log "WARN" "$1"; }
_log_error() { _log "ERROR" "$1"; }
_log_debug() { _log "DEBUG" "$1"; }
```

**Usage:**

```bash
_log_info "Starting worktree setup"
_log_warn "Validation failed, continuing anyway"
_log_error "Failed to install dependencies"
```

**Output:**

```json
{"timestamp":"2025-01-18T10:00:00Z","level":"INFO","message":"Starting worktree setup"}
```

---

### 7. Package Manager Detection

**Detection Logic (from SKILL.md):**

```bash
_detect_package_manager() {
    local project_dir=$1

    # Check in priority order
    if [ -f "$project_dir/bun.lockb" ]; then
        echo "bun"
    elif [ -f "$project_dir/pnpm-lock.yaml" ]; then
        echo "pnpm"
    elif [ -f "$project_dir/yarn.lock" ]; then
        echo "yarn"
    elif [ -f "$project_dir/package-lock.json" ]; then
        echo "npm"
    elif [ -f "$project_dir/uv.lock" ]; then
        echo "uv"
    elif [ -f "$project_dir/pyproject.toml" ]; then
        echo "uv"
    elif [ -f "$project_dir/requirements.txt" ]; then
        echo "pip"
    elif [ -f "$project_dir/go.mod" ]; then
        echo "go"
    elif [ -f "$project_dir/Cargo.toml" ]; then
        echo "cargo"
    else
        return 1
    fi
}

_get_install_command() {
    local pm=$1
    case $pm in
        bun) echo "bun install" ;;
        pnpm) echo "pnpm install" ;;
        yarn) echo "yarn install" ;;
        npm) echo "npm install" ;;
        uv) echo "uv sync" ;;
        pip) echo "pip install -r requirements.txt" ;;
        go) echo "go mod download" ;;
        cargo) echo "cargo build" ;;
        *) return 1 ;;
    esac
}
```

---

### 8. Dev Server Detection and Health Checks

**Dev Server Detection:**

```bash
_detect_dev_server() {
    local project_dir=$1

    # Check docker-compose
    if [ -f "$project_dir/docker-compose.yml" ] || [ -f "$project_dir/compose.yml" ]; then
        echo "docker-compose"
        return 0
    fi

    # Check package.json scripts
    if [ -f "$project_dir/package.json" ]; then
        local scripts=$(jq -r '.scripts | keys[]' "$project_dir/package.json")
        if echo "$scripts" | grep -qE '^(dev|start:dev|serve)$'; then
            echo "npm-script"
            return 0
        fi
    fi

    # Check Python projects
    if [ -f "$project_dir/pyproject.toml" ] || [ -f "$project_dir/requirements.txt" ]; then
        # Check for uvicorn
        if grep -q "uvicorn" "$project_dir/requirements.txt" 2>/dev/null || \
           grep -q "uvicorn" "$project_dir/pyproject.toml" 2>/dev/null; then
            echo "uvicorn"
            return 0
        fi

        # Check for Flask
        if grep -q "Flask" "$project_dir/requirements.txt" 2>/dev/null || \
           grep -q "Flask" "$project_dir/pyproject.toml" 2>/dev/null; then
            echo "flask"
            return 0
        fi
    fi

    # Check Go
    if [ -f "$project_dir/go.mod" ]; then
        echo "go"
        return 0
    fi

    return 1
}

_get_start_command() {
    local server_type=$1
    local port=$2
    case $server_type in
        docker-compose) echo "docker-compose up -d" ;;
        npm-script) echo "PORT=$port npm run dev" ;;
        uvicorn) echo "uv run uvicorn app.main:app --port $port" ;;
        flask) echo "flask run --port $port" ;;
        go) echo "go run ." ;;
        *) return 1 ;;
    esac
}
```

**Health Check with Retry:**

```bash
_health_check() {
    local url=$1
    local max_retries=6
    local retry_delay=5
    local timeout=30

    _log_info "Health check: $url"

    for ((i=1; i<=max_retries; i++)); do
        if curl -sf --max-time "$timeout" "$url" > /dev/null 2>&1; then
            _log_info "Health check passed"
            return 0
        fi

        if [ $i -lt $max_retries ]; then
            _log_warn "Health check failed, retry $i/$max_retries in ${retry_delay}s..."
            sleep "$retry_delay"
        fi
    done

    _log_error "Health check failed after $max_retries attempts"
    return 1
}
```

---

### 9. Modular Bash Library Design

**Research from lost-in-it.com:**

#### **Namespace Convention**

Use `wt_` prefix for all worktree functions:
- Public: `wt_log`, `wt_error`, `wt_detect_package_manager`
- Private: `_wt_registry_add`, `_wt_port_find_available`

#### **Library Structure**

```bash
#!/bin/bash
# skills/worktree-scripts/lib/common.sh

# Guard against double-sourcing
if [[ -n "${_WORKTREE_SCRIPTS_LOADED:-}" ]]; then
    return 0
fi
_WORKTREE_SCRIPTS_LOADED=1

# ===== CONFIGURATION =====
wt_config_load() {
    local config_file="${1:-~/.claude/skills/worktree-scripts/config.json}"

    if [ -f "$config_file" ]; then
        WT_TERMINAL=$(jq -r '.terminal // "ghostty"' "$config_file")
        WT_SHELL=$(jq -r '.shell // "fish"' "$config_file")
        WT_CLAUDE_CMD=$(jq -r '.claudeCommand // "claude"' "$config_file")
        WT_PORT_POOL_START=$(jq -r '.portPool.start // 8100' "$config_file")
        WT_PORT_POOL_END=$(jq -r '.portPool.end // 8199' "$config_file")
        WT_PORTS_PER_WORKTREE=$(jq -r '.portsPerWorktree // 2' "$config_file")
        WT_REGISTRY="${HOME}/.claude/worktree-registry.json"
    else
        # Defaults
        WT_TERMINAL="ghostty"
        WT_SHELL="fish"
        WT_CLAUDE_CMD="claude"
        WT_PORT_POOL_START=8100
        WT_PORT_POOL_END=8199
        WT_PORTS_PER_WORKTREE=2
        WT_REGISTRY="${HOME}/.claude/worktree-registry.json"
    fi
}

# ===== LOGGING =====
wt_log_json() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo '{}' | jq \
        --arg timestamp "$timestamp" \
        --arg level "$level" \
        --arg message "$message" \
        '{timestamp: $timestamp, level: $level, message: $message}'
}

wt_log() { wt_log_json "INFO" "$@" >&2; }
wt_warn() { wt_log_json "WARN" "$@" >&2; }
wt_error() { wt_log_json "ERROR" "$@" >&2; }
wt_debug() { wt_log_json "DEBUG" "$@" >&2; }

# ===== REGISTRY OPERATIONS =====
wt_registry_get() {
    jq -r '.' "$WT_REGISTRY" 2>/dev/null || echo '{}'
}

wt_registry_update() {
    local new_json=$1
    local tmp=$(mktemp)
    echo "$new_json" > "$tmp" && mv "$tmp" "$WT_REGISTRY"
}

# ===== PACKAGE MANAGER DETECTION =====
wt_detect_package_manager() {
    # Implementation as shown above
}

wt_install_deps() {
    local project_dir=$1
    local pm=$(wt_detect_package_manager "$project_dir")
    local cmd=$(_wt_get_install_command "$pm")
    (cd "$project_dir" && $cmd)
}

# ===== PORT MANAGEMENT =====
wt_allocate_ports() {
    local count=$1
    # Implementation with jq to find available ports
}

wt_release_ports() {
    local ports=$1  # Comma-separated
    # Implementation with jq to remove from allocated list
}

# ===== OUTPUT HELPERS =====
wt_output_json() {
    local status=$1
    shift
    local data="$*"
    echo '{}' | jq \
        --arg status "$status" \
        --argjson data "$data" \
        '{status: $status, data: $data}'
}
```

**Usage in scripts:**

```bash
#!/bin/bash
# scripts/setup-worktree.sh

set -euo pipefail

# Source library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Load configuration
wt_config_load

# Use library functions
wt_log "Setting up worktree..."
local pm=$(wt_detect_package_manager "$WORKTREE_PATH")
wt_install_deps "$WORKTREE_PATH"

# Output JSON result
wt_output_json "success" '{"worktreePath":"'$WORKTREE_PATH'", "ports":[8100,8101]}'
```

---

### 10. JSON Output Format for LLM Consumption

#### **Success Output**

```json
{
  "status": "success",
  "worktree": {
    "id": "uuid",
    "project": "my-project",
    "branch": "feature/auth",
    "branchSlug": "feature-auth",
    "worktreePath": "/Users/me/tmp/worktrees/my-project/feature-auth",
    "ports": [8100, 8101],
    "createdAt": "2025-01-18T10:00:00Z",
    "status": "active",
    "agentLaunched": true,
    "terminal": "tmux",
    "tmuxSession": "wt-myproject"
  },
  "validation": {
    "passed": true,
    "attempts": 2,
    "duration": 15
  },
  "timing": {
    "total": 45,
    "gitWorktree": 2,
    "installDeps": 25,
    "validation": 15,
    "register": 1
  }
}
```

#### **Error Output**

```json
{
  "status": "error",
  "error": {
    "code": 4,
    "type": "validation_failed",
    "message": "Health check failed after 6 attempts",
    "context": {
      "url": "http://localhost:8100/health",
      "attempts": 6,
      "timeout": 30,
      "retryDelay": 5
    }
  },
  "worktree": {
    "id": "uuid",
    "project": "my-project",
    "branch": "feature/auth",
    "worktreePath": "/Users/me/tmp/worktrees/my-project/feature-auth",
    "ports": [8100, 8101]
  },
  "partialSuccess": {
    "gitWorktree": true,
    "depsInstalled": true,
    "registered": true,
    "validation": false
  }
}
```

---

### 11. Parallel Execution Considerations

**When creating multiple worktrees:**

1. **Port Allocation Must Be Serialized**
   - Race condition if parallel scripts allocate ports simultaneously
   - Use `flock` to serialize port allocation
   - Or allocate all ports upfront from LLM, pass to each script

2. **Worktree Creation Can Be Parallel**
   - Git worktree operations are independent
   - Dependency installation can run in parallel
   - Each worktree uses different ports, no conflicts

3. **Script Design for Parallelism**

```bash
# In LLM layer (thin):
# Allocate ports upfront
PORTS=$(~/.claude/skills/worktree-scripts/scripts/manage-ports.sh allocate 6)

# Split ports and run in parallel
PORTS_ARRAY=($PORTS)
for i in {0..2}; do
    PORT_PAIR="${PORTS_ARRAY[$((i*2))]},${PORTS_ARRAY[$((i*2+1))]}"
    ~/.claude/skills/worktree-scripts/scripts/setup-worktree.sh \
        "$branch" "$task" "$PORT_PAIR" &
done

# Wait for all
wait
```

**Alternative - Single Script with Parallel Flag:**

```bash
# scripts/setup-worktree.sh
# Accept multiple branches at once
./setup-worktree.sh \
    --parallel \
    feature/auth,feature/payments,fix/login-bug \
    "Implement auth,Implement payments,Fix login bug"
```

**Recommendation:** Use LLM to coordinate parallelism with subagent pattern. Scripts remain single-worktree focused for simplicity.

---

### 12. Integration with LLM

#### **LLM Integration Layer (New in worktree-manager skill)**

The existing `worktree-manager` skill will be updated to:

1. **Parse user request** - Extract branches, tasks, project
2. **Allocate ports upfront** - Call `manage-ports.sh allocate N`
3. **Spawn subagents for parallel execution** - One per worktree
4. **Each subagent calls** `setup-worktree.sh` with pre-allocated ports
5. **Collect results** - Parse JSON output from each script
6. **Report summary** - Aggregate results, show failures, next steps

#### **Error Recovery**

When a script returns error JSON:

```json
{
  "status": "error",
  "error": {
    "code": 4,
    "type": "validation_failed"
  }
}
```

**LLM Decision Matrix:**

| Error Code | Error Type | LLM Action |
|------------|------------|-------------|
| 2 | Configuration error | Show error, abort all worktrees |
| 3 | Missing dependency | Show error, ask user to install, abort |
| 4 | Validation failure | Warn user, continue with other worktrees |
| 5 | Permission error | Show error, abort current worktree only |
| 6 | Resource conflict | Pick different ports/branch, retry |
| 130 | Interrupted | Cleanup partial worktrees, abort |

---

## Sources Consulted

### Official Documentation
- **worktree-manager SKILL.md** - Complete skill documentation (946 lines)
- **worktree-manager scripts/** - All 7 existing bash scripts
- **worktree-manager config.json** - Configuration structure

### Bash Best Practices
- **[Error Handling in Bash: 5 Essential Methods](https://jsdev.space/error-handling-bash/)** - Comprehensive error handling guide
- **[How to write idempotent Bash scripts](https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/)** - Idempotency patterns
- **[Designing Modular Bash: Functions, Namespaces, and Library Patterns](https://www.lost-in-it.com/posts/designing-modular-bash-functions-namespaces-library-patterns/)** - Modular design patterns
- **[Structured Logging in a Shell Script with jq](https://medium.com/@jesse.riddle/structured-logging-in-a-shell-script-with-jq-f7542a94a1f6)** - JSON logging patterns

### Community Resources
- **Stack Overflow: Multiple search results on bash error handling, idempotency, JSON parsing**
- **Reddit r/bash: Best practices for bash script development**
- **GitHub repositories: Various bash utility libraries (ammlib, bash-lib)**

### Research Date
- January 18, 2026

---

## Recommendations

### Primary Recommendation

Create a new skill `worktree-scripts` with the following structure:

1. **Library** (`lib/common.sh`):
   - Namespace: `wt_`
   - Functions: Logging, config loading, registry ops, package manager detection, port management, health checks
   - Source-able by all scripts

2. **Scripts**:
   - `setup-worktree.sh` - Single command to create, install, validate, register, launch
   - `launch-agent.sh` - Launch Claude Code in terminal (enhanced)
   - `cleanup-worktree.sh` - Remove worktree, kill ports, update registry (enhanced)
   - `show-status.sh` - Show status in JSON format (new)
   - `sync-registry.sh` - Sync registry with actual worktrees (enhanced)
   - `manage-ports.sh` - Allocate/release ports (consolidated)

3. **Output Format**:
   - All scripts output JSON by default (`--human` flag for tables)
   - Consistent structure: `{status: "...", data: {...}}`
   - Include timing information for performance monitoring

4. **Error Handling**:
   - Standard exit codes (0-6, 130)
   - Trap handlers for cleanup
   - Structured error messages in JSON
   - Idempotent operations

5. **Integration Layer** (in worktree-manager skill):
   - Thin LLM wrapper for decision-making
   - Coordinate parallel execution
   - Parse JSON output
   - Handle error recovery

### Alternative Approaches

**Option A: Modify existing scripts in place**
- **Pros:** No new skill, simpler migration
- **Cons:** Breaks existing skill, risk of regression
- **Verdict:** Not recommended

**Option B: Create separate skill as recommended**
- **Pros:** Clean migration, can test independently, existing skill continues to work
- **Cons:** Two skills to maintain
- **Verdict:** **RECOMMENDED**

**Option C: Replace worktree-manager entirely**
- **Pros:** Single source of truth
- **Cons:** High risk, all users affected
- **Verdict:** Too risky, not recommended

### Risks and Considerations

**Risk 1: Breaking changes to existing skill**
- **Mitigation:** Keep existing worktree-manager skill unchanged, create new skill
- **Migration Path:** Document how to switch, offer automated migration

**Risk 2: JSON parsing overhead**
- **Mitigation:** jq is fast, overhead is negligible compared to LLM computation
- **Performance Impact:** Net positive - much faster than LLM doing each step

**Risk 3: Learning curve for new skill**
- **Mitigation:** Comprehensive documentation, examples, clear naming
- **Documentation:** Include comparison table with old skill

**Risk 4: Terminal launching complexity**
- **Mitigation:** Extract to library, test thoroughly, use existing patterns
- **Testing:** Manual testing on each terminal type

**Risk 5: Parallel execution race conditions**
- **Mitigation:** Allocate ports upfront from LLM layer, pass to scripts
- **Alternative:** Use `flock` in manage-ports.sh for serialization

---

## Implementation

See `.agent/prompts/main/002-worktree-scripts.md` for complete implementation prompt for fullstack-developer agent.

---

## Next Steps

1. [ ] **Create new skill structure** → fullstack-developer
   - Create `skills/worktree-scripts/` directory
   - Create `lib/` and `scripts/` subdirectories
   - Create `config.json` (copy from worktree-manager)

2. [ ] **Implement library functions** → fullstack-developer
   - `lib/common.sh` with all shared functions
   - Namespace prefix `wt_`
   - Comprehensive error handling and logging

3. [ ] **Implement focused scripts** → fullstack-developer
   - Each script sources library
   - JSON output format
   - Idempotent operations
   - Comprehensive error handling

4. [ ] **Update worktree-manager skill** → fullstack-developer
   - Add integration layer for new scripts
   - Keep existing documentation for reference
   - Add migration guide

5. [ ] **Test with real worktree scenarios** → testing (if available) or manual testing
   - Single worktree creation
   - Multiple worktrees in parallel
   - Error scenarios (port conflict, validation failure, etc.)
   - Different project types (Node.js, Python, Go, etc.)

6. [ ] **Update documentation** → fullstack-developer
   - SKILL.md for new skill
   - Migration guide from old skill
   - Examples and best practices

---

## Success Criteria

- [ ] All scripts are idempotent (can run multiple times safely)
- [ ] All scripts output JSON by default
- [ ] Error handling is comprehensive with clear exit codes
- [ ] Library is sourceable and well-documented
- [ ] Integration layer in worktree-manager is thin and focused
- [ ] Parallel worktree creation works correctly
- [ ] Scripts handle all error scenarios gracefully
- [ ] Performance is significantly faster than LLM-based approach
- [ ] Documentation is clear and complete
