<agent_allocation>
Primary: fullstack-developer
Output: implementation
Workflow: implementation
</agent_allocation>

<objective>
Update worktree-manager skill to use tmux sessions with multiple windows (one per worktree) instead of opening separate terminal windows for each worktree.

The goal: When creating multiple worktrees (e.g., "spin up 3 worktrees for features A, B, C"), launch a single tmux session named `wt-<project>` containing multiple windows (one per worktree), each running a Claude Code agent.
</objective>

<context>
Current behavior:
- `launch-agent.sh` opens separate terminal windows (Ghostty, iTerm2, etc.) for each worktree
- Each worktree runs in its own isolated terminal process
- Current tmux implementation creates one session per worktree with name `wt-$PROJECT-$BRANCH`
- config.json has `"terminal": "iterm"` set (user wants to change to tmux)

Desired behavior:
- Single tmux session named `wt-$PROJECT` (one session per project)
- Each worktree is a separate window within the tmux session
- Windows labeled with branch name (slugified: `feature/auth` → `feature-auth`) for easy navigation (Ctrl+b w)
- Add windows to existing session if it already exists
- Even single worktree uses tmux with one window
- User can attach to session anytime with: `tmux attach -t wt-<project>`

Current code to modify:
- `skills/worktree-manager/config.json` - Change terminal to tmux
- `skills/worktree-manager/scripts/launch-agent.sh` - Update tmux case to use multi-window sessions
- `skills/worktree-manager/SKILL.md` - Update documentation with tmux navigation guide
</context>

<requirements>

### 1. Update config.json

**File:** `skills/worktree-manager/config.json`

Change the terminal setting from "iterm" to "tmux":

```json
{
  "terminal": "tmux",
  "shell": "zsh",
  "claudeCommand": "opencode",
  "portPool": {
    "start": 8100,
    "end": 8199
  },
  "portsPerWorktree": 2,
  "worktreeBase": "~/.tmp/worktrees",
  "registryPath": "~/.tmp/worktree-registry.json",
  "defaultCopyDirs": [".agents", ".env.example", ".env"],
  "healthCheckTimeout": 30,
  "healthCheckRetries": 6
}
```

### 2. Update launch-agent.sh Tmux Case

**File:** `skills/worktree-manager/scripts/launch-agent.sh`

Replace the existing tmux case (lines 107-115) with the following implementation:

```bash
tmux)
    if ! command -v tmux &> /dev/null; then
        echo "Error: tmux not found"
        echo "Install tmux:"
        echo "  macOS:   brew install tmux"
        echo "  Ubuntu:   sudo apt install tmux"
        echo "  Fedora:   sudo dnf install tmux"
        exit 1
    fi

    # Session naming: one session per project
    SESSION_NAME="wt-$PROJECT"

    # Window naming: slugified branch name (replace / with -)
    WINDOW_NAME=$(echo "$BRANCH" | tr '/' '-')

    # Check if session exists
    WINDOW_COUNT_BEFORE=0
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        # Session exists - count current windows
        WINDOW_COUNT_BEFORE=$(tmux list-windows -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')

        # Add new window to existing session
        tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "$SHELL_CMD -c '$INNER_CMD'"
    else
        # Create new session with first window (detached)
        tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "$SHELL_CMD -c '$INNER_CMD'"
    fi

    # Get window count after
    WINDOW_COUNT_AFTER=$(tmux list-windows -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')

    # Provide user feedback
    if [ "$WINDOW_COUNT_BEFORE" -eq 0 ]; then
        echo "   tmux session: $SESSION_NAME (1 window)"
        echo "   Attach with: tmux attach -t $SESSION_NAME"
    else
        echo "   tmux session: $SESSION_NAME (window $WINDOW_COUNT_AFTER of $WINDOW_COUNT_AFTER)"
        echo "   Navigate: Ctrl+b w"
    fi
    ;;
```

**Key Implementation Details:**

1. **Error Handling:** Check if tmux is installed with `command -v`, provide installation instructions for common platforms

2. **Session Naming:** Use `wt-$PROJECT` format (e.g., `wt-obsidian-ai-agent`)

3. **Window Naming:** Slugify branch name by replacing `/` with `-` (e.g., `feature/auth` → `feature-auth`)

4. **Session Detection:** Use `tmux has-session -t "$SESSION_NAME" 2>/dev/null` to check if session exists (redirect stderr to suppress error messages)

5. **Create vs Add:**
   - If session doesn't exist: `tmux new-session -d -s SESSION_NAME -n WINDOW_NAME -c DIR "COMMAND"`
   - If session exists: `tmux new-window -t SESSION_NAME -n WINDOW_NAME -c DIR "COMMAND"`

6. **Detached Creation:** Always use `-d` flag to prevent script blocking

7. **User Feedback:**
   - First window: Show attach command
   - Subsequent windows: Show navigation hint (Ctrl+b w)

8. **Maintain Shell Compatibility:** Use configured `$SHELL_CMD` and `$INNER_CMD` from existing code

### 3. Update SKILL.md

**File:** `skills/worktree-manager/SKILL.md`

Add the following sections (insert after "Example Session" section, before "Common Issues"):

```markdown
## Tmux Navigation

When using tmux terminal, all worktrees for a project are in a single session with multiple windows (one per worktree).

### Session Management

- **List all sessions:** `tmux ls`
- **Attach to session:** `tmux attach -t wt-<project>`
- **Detach from session:** `Ctrl+b d`

### Window Navigation

| Action | Key Combination | Description |
|--------|-----------------|-------------|
| List windows interactively | `Ctrl+b w` | Shows all windows - select with arrow keys or numbers |
| Next window | `Ctrl+b n` | Move to next window |
| Previous window | `Ctrl+b p` | Move to previous window |
| Select by number | `Ctrl+b 0` ... `Ctrl+b 9` | Jump directly to window 0-9 |
| Rename current window | `Ctrl+b ,` | Prompt to rename the current window |
| Close current window | `Ctrl+b &` | Confirm to close the current window |

### Session and Window Naming

- **Session name:** `wt-<project>` (one session per project)
- **Window name:** Slugified branch name (`feature/auth` → `feature-auth`)
- **Example:**
  ```
  Session: wt-obsidian-ai-agent
  Windows:
    0: feature-auth
    1: feature-payments
    2: fix-login-bug
  ```

### Example Workflow

```bash
# Launch 3 worktrees for a project
User: "Spin up worktrees for feature/auth, feature/payments, fix/login-bug"

# Output from worktree-manager:
✅ Created tmux session: wt-obsidian-ai-agent (1 window)
   Attach with: tmux attach -t wt-obsidian-ai-agent

✅ Added window to session: wt-obsidian-ai-agent (window 2 of 2)
   Navigate: Ctrl+b w

✅ Added window to session: wt-obsidian-ai-agent (window 3 of 3)
   Navigate: Ctrl+b w

# User attaches to session
$ tmux attach -t wt-obsidian-ai-agent

# Now user can navigate between worktrees with Ctrl+b w
# Or use Ctrl+b 0/1/2 to jump to specific windows
```

### Manual Tmux Operations

**List all sessions:**
```bash
tmux ls
# wt-obsidian-ai-agent: 3 windows (created Tue Jan 18 10:00:00 2026)
# wt-another-project: 1 windows (created Tue Jan 18 11:30:00 2026)
```

**Attach to specific session:**
```bash
tmux attach -t wt-obsidian-ai-agent
```

**Kill a session:**
```bash
tmux kill-session -t wt-obsidian-ai-agent
```

**Kill a specific window (from inside tmux):**
```
Ctrl+b &  # Prompt to close current window
```

**List windows in session:**
```bash
tmux list-windows -t wt-obsidian-ai-agent
# 0: feature-auth* (2 panes) [160x50]
# 1: feature-payments (1 panes) [160x50]
# 2: fix-login-bug (1 panes) [160x50]
```
```

**Update the "Launch Agent Manually" section** (around line 356) to include tmux example:

```markdown
### 3. Launch Agent Manually

If `launch-agent.sh` fails:

**For Ghostty:**
```bash
open -na "Ghostty.app" --args -e fish -c "cd '$WORKTREE_PATH' && claude"
```

**For iTerm2:**
```bash
osascript -e 'tell application "iTerm2" to create window with default profile' \
  -e 'tell application "iTerm2" to tell current session of current window to write text "cd '"$WORKTREE_PATH"' && claude"'
```

**For tmux:**
```bash
# Add window to existing session
SESSION_NAME="wt-myproject"
WINDOW_NAME=$(echo "feature/auth" | tr '/' '-')
tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "fish -c 'claude'"

# Or create new session
tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "fish -c 'claude'"
```
```

**Update the "Example Session" section** (around line 682) to reflect tmux usage:

```markdown
## Example Session

**User:** "Spin up 2 worktrees for feature/dark-mode and fix/login-bug"

**You:**
1. Detect project: `obsidian-ai-agent` (from git remote)
2. Detect package manager: `uv` (found uv.lock)
3. Allocate 4 ports: `~/.claude/skills/worktree-manager/scripts/allocate-ports.sh 4` → `8100 8101 8102 8103`
4. Create worktrees:
   ```bash
   mkdir -p ~/tmp/worktrees/obsidian-ai-agent
   git worktree add ~/tmp/worktrees/obsidian-ai-agent/feature-dark-mode -b feature/dark-mode
   git worktree add ~/tmp/worktrees/obsidian-ai-agent/fix-login-bug -b fix/login-bug
   ```
5. Copy .agents/:
   ```bash
   cp -r .agents ~/tmp/worktrees/obsidian-ai-agent/feature-dark-mode/
   cp -r .agents ~/tmp/worktrees/obsidian-ai-agent/fix-login-bug/
   ```
6. Install deps in each worktree:
   ```bash
   (cd ~/tmp/worktrees/obsidian-ai-agent/feature-dark-mode && uv sync)
   (cd ~/tmp/worktrees/obsidian-ai-agent/fix-login-bug && uv sync)
   ```
7. Validate each (start server, health check, stop)
8. Register both worktrees in `~/.claude/worktree-registry.json`
9. Launch agents:
   ```bash
   ~/.claude/skills/worktree-manager/scripts/launch-agent.sh \
     ~/tmp/worktrees/obsidian-ai-agent/feature-dark-mode "Implement dark mode toggle"
   ~/.claude/skills/worktree-manager/scripts/launch-agent.sh \
     ~/tmp/worktrees/obsidian-ai-agent/fix-login-bug "Fix login redirect bug"
   ```
10. Report:
    ```
    Created 2 worktrees with agents:

    | Branch | Ports | Path | Task |
    |--------|-------|------|------|
    | feature/dark-mode | 8100, 8101 | ~/tmp/worktrees/.../feature-dark-mode | Implement dark mode |
    | fix/login-bug | 8102, 8103 | ~/tmp/worktrees/.../fix-login-bug | Fix login redirect |

    ✅ Created tmux session: wt-obsidian-ai-agent (1 window)
       Attach with: tmux attach -t wt-obsidian-ai-agent

    ✅ Added window to session: wt-obsidian-ai-agent (window 2 of 2)
       Navigate: Ctrl+b w

    Navigate between worktrees with Ctrl+b w after attaching.
    ```
```

### 4. Maintain Backwards Compatibility

**DO NOT REMOVE** support for other terminal types. The switch statement should continue to support:
- `ghostty`
- `iterm2` / `iterm`
- `tmux` (updated implementation)
- `wezterm`
- `kitty`
- `alacritty`

**DO NOT MODIFY** the case statement structure, only update the `tmux)` case.

### 5. User Instructions

When implementation is complete, update user with:

1. How to attach to tmux sessions
2. How to navigate between windows (Ctrl+b w)
3. List of key tmux shortcuts

Include this in the success criteria output.

</requirements>

<implementation_steps>

1. **Read existing files** to understand current implementation:
   - Read `skills/worktree-manager/config.json`
   - Read `skills/worktree-manager/scripts/launch-agent.sh`
   - Read `skills/worktree-manager/SKILL.md`

2. **Update config.json**:
   - Change `"terminal"` from `"iterm"` to `"tmux"`
   - Keep all other settings unchanged

3. **Update launch-agent.sh**:
   - Locate the `tmux)` case statement (lines 107-115)
   - Replace with new multi-window implementation
   - Ensure proper error handling for tmux not installed
   - Implement session existence check with `tmux has-session`
   - Implement window naming with slugification (`tr '/' '-'`)
   - Implement user feedback showing session name and navigation hints

4. **Update SKILL.md**:
   - Add new "Tmux Navigation" section before "Common Issues"
   - Include quick reference table for key combinations
   - Update "Launch Agent Manually" section with tmux example
   - Update "Example Session" to show tmux usage and output
   - Include session and window naming conventions

5. **Verify changes**:
   - Check that config.json is valid JSON
   - Check that launch-agent.sh is valid bash script
   - Check that SKILL.md markdown is valid
   - Ensure no other terminal types were modified

6. **Test mentally** (not execute):
   - Single worktree: Creates new session with 1 window
   - Multiple worktrees: Adds windows to existing session
   - Tmux not installed: Shows clear error with install instructions
   - Session naming follows `wt-$PROJECT` pattern
   - Window naming follows slugified branch name pattern

7. **Report completion** with summary of changes made

</implementation_steps>

<output>

After completing the implementation, provide:

1. **Summary of changes:**
   - List each file modified
   - Describe what changed in each file
   - Highlight key implementation details

2. **Verification:**
   - Confirm all files updated successfully
   - Confirm backwards compatibility maintained
   - Confirm JSON and syntax validity

3. **User guidance:**
   - How to test the new tmux functionality
   - How to attach to tmux sessions
   - Key tmux navigation shortcuts

4. **Example usage:**
   - Show example output when launching single worktree
   - Show example output when launching multiple worktrees
   - Demonstrate session and window naming

</output>

<success_criteria>

Implementation is successful when:

1. **Configuration updated:**
   - [ ] `skills/worktree-manager/config.json` has `"terminal": "tmux"`

2. **Launch script updated:**
   - [ ] `skills/worktree-manager/scripts/launch-agent.sh` tmux case implements multi-window sessions
   - [ ] Session naming uses `wt-$PROJECT` pattern
   - [ ] Window naming uses slugified branch names (`feature/auth` → `feature-auth`)
   - [ ] Session existence checked with `tmux has-session`
   - [ ] Detached sessions created with `-d` flag
   - [ ] Error handling for tmux not installed with install instructions
   - [ ] User feedback shows session name and navigation hints

3. **Documentation updated:**
   - [ ] `skills/worktree-manager/SKILL.md` includes "Tmux Navigation" section
   - [ ] Quick reference table with key combinations
   - [ ] "Launch Agent Manually" includes tmux example
   - [ ] "Example Session" shows tmux usage and output

4. **Backwards compatibility:**
   - [ ] Other terminal types (ghostty, iterm2, wezterm, kitty, alacritty) still work
   - [ ] No modifications to other terminal cases

5. **Functionality verified:**
   - [ ] Single worktree: Creates new session with 1 window
   - [ ] Multiple worktrees: Adds windows to existing session
   - [ ] Tmux not installed: Shows clear error message
   - [ ] Session naming consistent (wt-<project>)
   - [ ] Window naming consistent (slugified branch)

6. **User experience:**
   - [ ] Clear instructions for attaching to sessions
   - [ ] Clear instructions for navigating between windows
   - [ ] Examples provided for common workflows

</success_criteria>
