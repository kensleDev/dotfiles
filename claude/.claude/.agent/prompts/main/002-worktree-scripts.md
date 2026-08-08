<agent_allocation>
Primary: fullstack-developer
</agent_allocation>

<objective>
Create a new skill `worktree-scripts` that automates the worktree-manager workflow with bash scripts to reduce LLM computation overhead and improve execution speed. The scripts will handle all fast, deterministic operations while the LLM layer focuses on decision-making and error recovery.

You will implement a modular bash library, focused automation scripts, and JSON output format for LLM consumption.
</objective>

<context>
The existing `worktree-manager` skill requires the LLM to execute 10+ separate bash commands for each worktree creation, resulting in high computation overhead and slower execution. Research shows that most operations (git worktree creation, port allocation, package manager detection, dependency installation, health checks, process management, PR status checking) are deterministic and fast in bash.

The solution is to create a new skill `worktree-scripts` with:
1. A shared bash library (`lib/common.sh`) with reusable functions
2. Focused automation scripts that handle all fast operations
3. JSON output format for LLM consumption
4. Idempotent operations with comprehensive error handling
5. A thin LLM integration layer for decision-making

Tech stack: Bash, jq (JSON manipulation), standard Unix tools (git, curl, lsof, etc.)
</context>

<requirements>
1. **Create new skill directory structure:**
   ```
   skills/worktree-scripts/
   ├── lib/
   │   └── common.sh              # Shared library with reusable functions
   ├── scripts/
   │   ├── setup-worktree.sh       # Create worktree, install, validate, register, launch (NEW)
   │   ├── launch-agent.sh         # Launch Claude Code in terminal (ENHANCED)
   │   ├── cleanup-worktree.sh     # Remove worktree, kill ports, update registry (ENHANCED)
   │   ├── show-status.sh          # Show status in JSON format (NEW)
   │   ├── sync-registry.sh       # Sync registry with actual worktrees (ENHANCED)
   │   └── manage-ports.sh        # Allocate/release ports (ENHANCED)
   ├── config.json                # Configuration (copy from worktree-manager)
   └── SKILL.md                  # Documentation for new skill
   ```

2. **Implement library (`lib/common.sh`) with:**
   - **Configuration loading:** `wt_config_load()` to load config.json with defaults
   - **Logging functions:** `wt_log`, `wt_warn`, `wt_error`, `wt_debug` with JSON output
   - **Registry operations:** `wt_registry_get`, `wt_registry_update`, `wt_registry_add`, `wt_registry_remove`
   - **Package manager detection:** `wt_detect_package_manager()`, `wt_install_deps()`
   - **Port management:** `wt_allocate_ports()`, `wt_release_ports()`, `wt_check_port_available()`
   - **Dev server detection:** `wt_detect_dev_server()`, `wt_get_start_command()`
   - **Health checks:** `wt_health_check()` with retry logic
   - **Output helpers:** `wt_output_json()` for structured JSON output
   - **Error handling:** Trap handlers, cleanup functions
   - **Idempotency helpers:** Functions to check before create/remove

   **Naming convention:** Use `wt_` prefix for all public functions, `_wt_` prefix for private helpers

3. **Implement focused scripts:**

   **`setup-worktree.sh` (NEW):**
   - Usage: `./setup-worktree.sh <branch> <task> <ports> [--no-agent] [--no-validate]`
   - Arguments:
     - `branch`: Git branch name (e.g., "feature/auth")
     - `task`: Task description for the agent
     - `ports`: Comma-separated ports (e.g., "8100,8101")
     - `--no-agent`: Don't launch agent
     - `--no-validate`: Skip health check validation
   - Operations:
     1. Detect project name from git remote or current directory
     2. Slugify branch name (replace / with -)
     3. Create worktree path: `~/tmp/worktrees/<project>/<branch-slug>/`
     4. Create git worktree
     5. Copy uncommitted resources (`.agents`, `.env.example`, `.env`)
     6. Detect package manager and install dependencies
     7. Detect dev server
     8. Start dev server
     9. Run health check with retry (unless --no-validate)
     10. Stop dev server
     11. Register in global registry
     12. Launch agent (unless --no-agent)
   - Output: JSON with all details + status + timing
   - Error handling: Continue on validation failure, exit on other errors

   **`launch-agent.sh` (ENHANCED from existing):**
   - Usage: `./launch-agent.sh <worktree-path> [task] [--json]`
   - Arguments:
     - `worktree-path`: Path to worktree directory
     - `task`: Optional task description
     - `--json`: Output JSON instead of human-readable text
   - Operations:
     1. Load configuration from config.json
     2. Detect terminal type (ghostty, tmux, iterm2, wezterm, kitty, alacritty)
     3. Launch Claude Code in new terminal
     4. For tmux: Create session per project, window per worktree
   - Output: JSON with terminal info and session details (if --json)
   - Reuse existing script, add JSON output option

   **`cleanup-worktree.sh` (ENHANCED from cleanup.sh):**
   - Usage: `./cleanup-worktree.sh <project> <branch> [--delete-branch] [--json]`
   - Or: `./cleanup-worktree.sh --merged [--delete-branch] [--json]`
   - Operations:
     1. Find worktree entry in registry
     2. Kill processes on allocated ports
     3. Remove worktree directory
     4. Prune git worktree references
     5. Remove from registry
     6. Release ports from pool
     7. Optionally delete local and remote git branches
   - Output: JSON with cleanup results (if --json)
   - Reuse existing script, add JSON output option

   **`show-status.sh` (NEW, replaces status.sh):**
   - Usage: `./show-status.sh [--json] [--project <name>] [--status <active|merged|orphaned>]`
   - Arguments:
     - `--json`: Always output JSON (default)
     - `--human`: Output human-readable table
     - `--project <name>`: Filter by project name
     - `--status <status>`: Filter by status
   - Operations:
     1. Read worktree registry
     2. For each worktree:
        - Check if directory exists
        - Check if repo exists
        - Check port usage (lsof)
        - Check PR status (via gh CLI if available)
     3. Filter by project and status if specified
     4. Output results
   - Output: JSON array of worktree objects with all details
   - Include port pool status in output

   **`sync-registry.sh` (ENHANCED from sync.sh):**
   - Usage: `./sync-registry.sh [--quiet] [--fix] [--json]`
   - Arguments:
     - `--quiet`: Only show issues, not OK entries
     - `--fix`: Automatically fix issues
     - `--json`: Output JSON instead of text
   - Operations:
     1. Compare registry entries with actual git worktrees
     2. Check PR status for each worktree branch
     3. Report discrepancies
     4. Optionally fix issues (with --fix)
   - Output: JSON with sync results (if --json)
   - Reuse existing script, add JSON output option

   **`manage-ports.sh` (NEW, combines allocate-ports.sh + release-ports.sh):**
   - Usage: `./manage-ports.sh allocate <count>` or `./manage-ports.sh release <port1,port2,...>`
   - Operations:
     - `allocate <count>`: Find N available ports, mark as allocated in registry
     - `release <ports>`: Release comma-separated ports back to pool
   - Output: JSON with port numbers (allocate) or release confirmation (release)
   - Reuse existing logic from allocate-ports.sh and release-ports.sh

4. **All scripts must:**
   - Use `set -euo pipefail` for strict error handling
   - Source `lib/common.sh` for shared functions
   - Output JSON by default (with --human flag for tables)
   - Use structured logging with `wt_log`, `wt_warn`, `wt_error`
   - Implement trap handlers for cleanup on errors/interrupts
   - Be idempotent (safe to run multiple times)
   - Use consistent exit codes:
     - 0: Success
     - 1: General error
     - 2: Configuration error
     - 3: Missing dependency
     - 4: Validation failure
     - 5: Permission error
     - 6: Resource conflict
     - 130: Interrupted (SIGINT/SIGTERM)
   - Include timing information for performance monitoring

5. **Configuration (config.json):**
   - Copy existing config from `worktree-manager/config.json`
   - Include all settings: terminal, shell, claudeCommand, portPool, portsPerWorktree, worktreeBase, etc.

6. **Documentation (SKILL.md):**
   - Complete documentation for new skill
   - Script reference with usage examples
   - Output format examples (JSON)
   - Comparison table with old worktree-manager skill
   - Migration guide for users
   - Error code reference
   - Best practices and troubleshooting
</requirements>

<responsibility_split>
**Bash Scripts (This Implementation):**
- Git worktree creation/removal
- Port allocation from pool
- Registry JSON manipulation
- Package manager detection and dependency installation
- Dev server detection and health checks
- Process management (kill processes on ports)
- Terminal launching
- PR status checking
- All file system operations
- JSON output formatting

**LLM Layer (In worktree-manager skill, future update):**
- Parse user requests for worktree creation
- Decide which branches to create worktrees for
- Allocate ports upfront (call manage-ports.sh allocate)
- Coordinate parallel execution with subagents
- Parse JSON output from scripts
- Make error recovery decisions
- Warn users about risks before proceeding
- Report aggregated results to users
</responsibility_split>

<output>
Create the following files:

**Library:**
- `skills/worktree-scripts/lib/common.sh` - Shared bash library with all reusable functions

**Scripts:**
- `skills/worktree-scripts/scripts/setup-worktree.sh` - Complete worktree setup automation
- `skills/worktree-scripts/scripts/launch-agent.sh` - Launch Claude Code in terminal (enhanced from existing)
- `skills/worktree-scripts/scripts/cleanup-worktree.sh` - Remove worktree (enhanced from existing cleanup.sh)
- `skills/worktree-scripts/scripts/show-status.sh` - Show worktree status in JSON format
- `skills/worktree-scripts/scripts/sync-registry.sh` - Sync registry (enhanced from existing sync.sh)
- `skills/worktree-scripts/scripts/manage-ports.sh` - Port allocation/release (consolidated)

**Configuration:**
- `skills/worktree-scripts/config.json` - Copy from worktree-manager/config.json

**Documentation:**
- `skills/worktree-scripts/SKILL.md` - Complete documentation for new skill

All scripts must be executable: `chmod +x scripts/*.sh`
</output>

<success_criteria>
1. **Library exists and is complete:**
   - `lib/common.sh` exists with all required functions
   - Functions use `wt_` namespace prefix
   - Sourceable by all scripts
   - Well-documented with comments

2. **Scripts are functional:**
   - All 6 scripts exist and are executable
   - Each script sources `lib/common.sh`
   - All scripts output JSON by default
   - Scripts handle errors gracefully

3. **Output format is consistent:**
   - All scripts output JSON with consistent structure
   - JSON includes `status` field ("success" or "error")
   - Success JSON includes `data` object with results
   - Error JSON includes `error` object with code and message

4. **Error handling is comprehensive:**
   - All scripts use `set -euo pipefail`
   - Trap handlers for cleanup on errors/interrupts
   - Consistent exit codes (0-6, 130)
   - Clear error messages in JSON format

5. **Idempotency is achieved:**
   - Scripts can be run multiple times safely
   - Check before create operations
   - Graceful handling of existing resources
   - No side effects from re-runs

6. **Performance is improved:**
   - Single `setup-worktree.sh` command replaces 10+ LLM operations
   - Execution time should be measured and included in output
   - JSON parsing overhead is negligible

7. **Documentation is complete:**
   - SKILL.md documents all scripts with usage examples
   - JSON output format is documented with examples
   - Error codes are documented
   - Migration guide from old skill is included

8. **Compatibility is maintained:**
   - Scripts work with existing worktree-manager registry
   - Terminal launching works with all supported terminals
   - Package manager detection covers all ecosystems
</success_criteria>

<verification>
1. **Test library functions:**
   ```bash
   # Source library
   source skills/worktree-scripts/lib/common.sh

   # Test configuration loading
   wt_config_load
   echo "Terminal: $WT_TERMINAL"
   echo "Registry: $WT_REGISTRY"

   # Test logging
   wt_log "Test info message"
   wt_error "Test error message"

   # Test package manager detection (in a real project directory)
   cd /path/to/some/project
   pm=$(wt_detect_package_manager .)
   echo "Package manager: $pm"
   ```

2. **Test port management:**
   ```bash
   # Allocate ports
   ports=$(skills/worktree-scripts/scripts/manage-ports.sh allocate 2)
   echo "Allocated ports: $ports"

   # Verify in registry
   cat ~/.claude/worktree-registry.json | jq '.portPool.allocated'

   # Release ports
   skills/worktree-scripts/scripts/manage-ports.sh release $ports

   # Verify released
   cat ~/.claude/worktree-registry.json | jq '.portPool.allocated'
   ```

3. **Test worktree setup:**
   ```bash
   # Setup worktree (in a git repo)
   cd /path/to/your/git/repo

   # Allocate ports first
   ports=$(skills/worktree-scripts/scripts/manage-ports.sh allocate 2)

   # Setup worktree
   result=$(skills/worktree-scripts/scripts/setup-worktree.sh \
     "feature/test-branch" "Test task" "$ports" --no-validate --no-agent)

   # Parse JSON result
   echo "$result" | jq '.'
   echo "$result" | jq '.status'
   echo "$result" | jq '.data.worktree.worktreePath'

   # Verify worktree exists
   ls -la ~/tmp/worktrees/$(basename $(git remote get-url origin))/feature-test-branch/

   # Verify in registry
   cat ~/.claude/worktree-registry.json | jq '.worktrees[] | select(.branch == "feature/test-branch")'

   # Cleanup
   skills/worktree-scripts/scripts/cleanup-worktree.sh \
     $(basename $(git remote get-url origin)) feature/test-branch --json | jq '.'
   ```

4. **Test status display:**
   ```bash
   # Show status as JSON
   skills/worktree-scripts/scripts/show-status.sh --json | jq '.'

   # Show status as human table
   skills/worktree-scripts/scripts/show-status.sh --human

   # Filter by project
   skills/worktree-scripts/scripts/show-status.sh --project my-project --json | jq '.'
   ```

5. **Test error handling:**
   ```bash
   # Test with invalid ports (should fail gracefully)
   skills/worktree-scripts/scripts/setup-worktree.sh \
     "test" "task" "99999,99998" --no-validate --no-agent

   # Test with duplicate worktree (should be idempotent)
   skills/worktree-scripts/scripts/setup-worktree.sh \
     "feature/test-branch" "task" "$ports" --no-validate --no-agent
   skills/worktree-scripts/scripts/setup-worktree.sh \
     "feature/test-branch" "task" "$ports" --no-validate --no-agent

   # Test cleanup with --delete-branch
   skills/worktree-scripts/scripts/cleanup-worktree.sh \
     $(basename $(git remote get-url origin)) feature/test-branch --delete-branch --json | jq '.'
   ```

6. **Test with different project types:**
   ```bash
   # Test with Node.js project (npm, yarn, pnpm, bun)
   cd /path/to/nodejs/project
   pm=$(source skills/worktree-scripts/lib/common.sh && wt_detect_package_manager .)
   echo "Node.js project: $pm"

   # Test with Python project (uv, pip)
   cd /path/to/python/project
   pm=$(source skills/worktree-scripts/lib/common.sh && wt_detect_package_manager .)
   echo "Python project: $pm"

   # Test with Go project
   cd /path/to/go/project
   pm=$(source skills/worktree-scripts/lib/common.sh && wt_detect_package_manager .)
   echo "Go project: $pm"
   ```

7. **Performance comparison:**
   ```bash
   # Time the new script
   time skills/worktree-scripts/scripts/setup-worktree.sh \
     "feature/perf-test" "Performance test" "8100,8101" --no-validate

   # Compare with manual LLM approach (should be much faster)
   ```

8. **Documentation review:**
   - Read SKILL.md and verify all scripts are documented
   - Check that JSON output examples are accurate
   - Verify migration guide is clear
   - Check error code reference
</verification>

<implementation_guidance>
1. **Library Architecture (`lib/common.sh`):**
   - Start with configuration loading functions
   - Add logging functions next (used everywhere)
   - Add registry operations
   - Add package manager detection
   - Add port management
   - Add dev server detection
   - Add health checks
   - Add output helpers last
   - Use `local` variables in all functions to avoid polluting global namespace
   - Add guard to prevent double-sourcing: `if [[ -n "${_WORKTREE_SCRIPTS_LOADED:-}" ]]; then return 0; fi`

2. **Script Implementation Order:**
   - Start with `manage-ports.sh` (simplest, tests library functions)
   - Then `show-status.sh` (tests registry operations)
   - Then `setup-worktree.sh` (most complex, tests all functions)
   - Then `cleanup-worktree.sh` (tests cleanup)
   - Then `launch-agent.sh` (enhance existing)
   - Finally `sync-registry.sh` (enhance existing)

3. **JSON Output Format:**
   - Always use `jq` to construct JSON (don't manually format strings)
   - Include `status` field at top level
   - Include `data` object for success results
   - Include `error` object for errors with `code`, `type`, `message`
   - Include `timing` object with duration information for major operations
   - Use `--compact-output` and `--monochrome-output` flags in jq

4. **Error Handling:**
   - Use `set -euo pipefail` at top of every script
   - Define trap handler: `trap 'handle_error $? $LINENO' ERR`
   - Define cleanup function that releases ports, removes partial worktree
   - Use `local` variables in functions to avoid state pollution
   - Always check command exit codes: `if ! command; then error_exit "..."; fi`
   - Use `|| true` for commands that are allowed to fail

5. **Idempotency:**
   - Always check before creating: `if [ ! -d "$path" ]; then create; fi`
   - Use `mkdir -p` for directories
   - Use `rm -rf` for removal (no error if missing)
   - Check registry entries before adding/updating
   - Handle "already exists" cases gracefully

6. **Configuration Loading:**
   - Check for config.json first, use sensible defaults if missing
   - Validate jq is installed: `command -v jq || error_exit "jq required"`
   - Allow environment variable overrides for each config value
   - Cache config values in global variables with `WT_` prefix

7. **Testing:**
   - Test each script incrementally
   - Use `--no-validate` flag during development to skip slow health checks
   - Use `--json` flag to parse output with jq during testing
   - Clean up test worktrees after testing
   - Test error paths intentionally (invalid ports, missing directories, etc.)
</implementation_guidance>
