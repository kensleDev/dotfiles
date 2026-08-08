# Research: Tmux Multi-Window Session Management for Worktree Manager

**Date:** 2026-01-18
**Confidence:** High
**Researcher:** researcher agent

---

## Executive Summary

Tmux automation for multi-window sessions is well-documented and straightforward. The recommended approach:
1. Use `tmux has-session` to check if session exists
2. Use `tmux new-session -d -A` to create or attach to session (detached)
3. Use `tmux new-window -t SESSION -n NAME -c DIR` to add windows
4. Slugify branch names for filesystem-safe window names
5. Check for tmux installation with `command -v` and provide clear error message

---

## Research Objectives

Investigate how to update the worktree-manager skill to use tmux sessions with multiple windows (one per worktree) instead of opening separate terminal windows for each worktree.

---

## Findings

### 1. Tmux Session/Window Management from Bash

#### Checking if Session Exists
```bash
# Returns exit code 0 if exists, 1 if not
tmux has-session -t SESSION_NAME 2>/dev/null
if [ $? -eq 0 ]; then
    # Session exists
else
    # Session does not exist
fi
```

**Best Practice:** Always use `2>/dev/null` to suppress error messages when checking.

#### Creating Session vs Adding Window to Existing Session

**Option A: Using new-session with -A flag (create or attach)**
```bash
# Creates session if not exists, attaches if exists
tmux new-session -A -d -s SESSION_NAME -n WINDOW_NAME -c DIR "command"
```

**Option B: Manual check and create/add**
```bash
SESSION="wt-myproject"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    # Create new session with first window
    tmux new-session -d -s "$SESSION" -n "$BRANCH" -c "$WORKTREE_PATH" "$COMMAND"
else
    # Add window to existing session
    tmux new-window -t "$SESSION" -n "$BRANCH" -c "$WORKTREE_PATH" "$COMMAND"
fi
```

**Recommendation:** Option B is clearer for the worktree use case, as it allows per-window customization and better error handling.

#### Window Naming Best Practices

**Window Name Conventions:**
- **Length:** No strict limit, but recommended to keep under 20-30 characters for readability
- **Special Characters:** Most characters are allowed, but avoid:
  - Colons (`:`) - used for session:window targeting
  - Spaces - need quoting
  - Backslashes - require escaping
- **Recommended:** Slugify branch names by replacing `/` with `-`
  - `feature/auth` → `feature-auth`
  - `fix/login-bug` → `fix-login-bug`

```bash
# Slugify branch name
WINDOW_NAME=$(echo "$BRANCH" | tr '/' '-')
```

**Window Names Don't Need to Be Unique** - tmux identifies windows by index, not name. However, descriptive names aid navigation.

#### Listing Sessions and Windows

```bash
# List all sessions
tmux list-sessions

# List windows in a session
tmux list-windows -t SESSION_NAME

# Format output
tmux list-windows -t SESSION_NAME -F "#{window_index}: #{window_name} #{pane_current_path}"
```

---

### 2. Best Practices for Tmux Automation

#### Session Naming Conventions

**Recommended Pattern:** `wt-<project-name>`
- Prefix `wt-` identifies as worktree session
- Project name helps distinguish between different projects
- Example: `wt-obsidian-ai-agent`, `wt-myproject`

```bash
SESSION_NAME="wt-$PROJECT"
```

#### Handling Detached vs Attached Sessions

**For Scripted Session Creation:**
- **Always create sessions detached** (`-d` flag) to prevent script blocking
- Detached sessions continue running in background
- Multiple clients can attach to the same session

```bash
# Create detached session
tmux new-session -d -s SESSION_NAME

# Add window to detached session
tmux new-window -t SESSION_NAME -n WINDOW_NAME -c DIR
```

**Attaching to Existing Session:**
```bash
# Attach to session (from terminal)
tmux attach -t SESSION_NAME

# Or list sessions and choose
tmux ls
tmux attach -t wt-myproject
```

#### Ensuring Sessions Persist

Sessions persist automatically after script exits when created with `-d`. No special handling needed.

---

### 3. Integration with Existing Workflow

#### Current Implementation Analysis

**File:** `skills/worktree-manager/scripts/launch-agent.sh`
- **Current tmux case:** Lines 107-115
- **Issue:** Creates one session per worktree with name `wt-$PROJECT-$BRANCH`
- **Desired:** One session per project with multiple windows

#### Required Changes

**1. Update `config.json`:**
```json
{
  "terminal": "tmux",
  "shell": "zsh",
  ...
}
```

**2. Update `launch-agent.sh` tmux case:**
```bash
tmux)
    if ! command -v tmux &> /dev/null; then
        echo "Error: tmux not found. Please install tmux: brew install tmux"
        exit 1
    fi

    SESSION_NAME="wt-$PROJECT"
    WINDOW_NAME=$(echo "$BRANCH" | tr '/' '-')

    # Check if session exists
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        # Create new session with first window
        tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "$SHELL_CMD -c '$INNER_CMD'"
    else
        # Add window to existing session
        tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "$SHELL_CMD -c '$INNER_CMD'"
    fi

    # If first window in session, offer to attach
    WINDOW_COUNT=$(tmux list-windows -t "$SESSION_NAME" | wc -l | tr -d ' ')
    if [ "$WINDOW_COUNT" -eq 1 ]; then
        echo "   tmux session: $SESSION_NAME"
        echo "   Attach with: tmux attach -t $SESSION_NAME"
        echo "   Or open later: tmux ls"
    else
        echo "   tmux session: $SESSION_NAME (window $WINDOW_COUNT)"
        echo "   Navigate: Ctrl+b w (to choose window)"
    fi
    ;;
```

**3. Update `SKILL.md`:**

- Add tmux navigation section:
  ```markdown
  ### Tmux Navigation

  When using tmux terminal, all worktrees for a project are in a single session with multiple windows:

  - **List sessions:** `tmux ls`
  - **Attach to session:** `tmux attach -t wt-<project>`
  - **Switch windows:** `Ctrl+b w` (interactive window list)
  - **Next/Previous window:** `Ctrl+b n` / `Ctrl+b p`
  - **Select by number:** `Ctrl+b 0` through `Ctrl+b 9`
  - **Rename window:** `Ctrl+b ,`
  - **Detach from session:** `Ctrl+b d`

  **Example:**
  ```
  tmux ls
  wt-obsidian-ai-agent: 3 windows (created Tue Jan 18 10:00:00 2026)

  tmux attach -t wt-obsidian-ai-agent
  # Now use Ctrl+b w to switch between feature-auth, feature-payments, fix-login-bug
  ```

  - Update "Launch Agent Manually" section with tmux example
  - Update example sessions to show multi-window tmux sessions
  - Add note about window naming convention

#### Backwards Compatibility

**Maintain existing terminal types:** The switch statement already supports multiple terminal types (`ghostty`, `iterm2`, `wezterm`, `kitty`, `alacritty`). The tmux case will be added without removing others.

**Configuration-driven:** Users can switch between terminal types by changing `config.json`.

---

### 4. Edge Cases

#### What if tmux not installed?

**Detection:**
```bash
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux not found."
    echo "Install tmux:"
    echo "  macOS: brew install tmux"
    echo "  Ubuntu/Debian: sudo apt install tmux"
    echo "  Fedora: sudo dnf install tmux"
    exit 1
fi
```

**Fallback Behavior:**
- Exit with clear error message
- Provide installation instructions for common platforms
- Don't silently fall back to another terminal (user explicitly chose tmux)

#### What if session exists but detached?

**Behavior:** Add new window to the detached session. The session remains detached until user manually attaches.

**Command:** `tmux new-window -t SESSION_NAME` works whether session is attached or detached.

**User Experience:** Inform user they can attach later:
```bash
echo "   Session created (detached)"
echo "   Attach anytime: tmux attach -t $SESSION_NAME"
```

#### What if window name conflicts?

**Behavior:** Tmux allows duplicate window names. Windows are identified by index, not name.

**Resolution:** Accept duplicate names - they will be displayed as `feature-auth`, `feature-auth (1)`, etc. in the window list.

**Alternative (optional):** Append index to avoid duplicates:
```bash
# Count existing windows with this name
EXISTING=$(tmux list-windows -t "$SESSION_NAME" -F "#{window_name}" | grep -c "^${WINDOW_NAME}$" || echo "0")

if [ "$EXISTING" -gt 0 ]; then
    WINDOW_NAME="${WINDOW_NAME}-${EXISTING}"
fi
```

**Recommendation:** Don't implement - duplicate names are acceptable and simpler.

#### How to handle shell configuration (fish vs bash) in tmux?

**Current Implementation:** The script already handles shell configuration via `SHELL_CMD` from config.json (fish, bash, zsh).

**Tmux Behavior:** Tmux inherits the user's default shell when not specified, but can explicitly set with `-c` or default-shell option.

**For Worktree Manager:**
```bash
# Pass the configured shell to tmux
tmux new-session -d -s SESSION_NAME -n WINDOW_NAME -c "$WORKTREE_PATH" "$SHELL_CMD -c 'COMMAND'"

# Or rely on user's default shell (simpler)
tmux new-session -d -s SESSION_NAME -n WINDOW_NAME -c "$WORKTREE_PATH"
```

**Recommendation:** Use the configured `SHELL_CMD` to maintain consistency across terminal types.

---

### 5. User Experience

#### Informing User About Tmux Session

**After launching worktrees, provide clear information:**

```bash
# After first worktree
echo "✅ Created tmux session: wt-obsidian-ai-agent"
echo "   Window 1: feature-auth"
echo "   Attach: tmux attach -t wt-obsidian-ai-agent"

# After second worktree
echo "✅ Added window to session: wt-obsidian-ai-agent"
echo "   Window 2: feature-payments"
echo "   Navigate: Ctrl+b w"

# Summary after all worktrees
echo ""
echo "📊 Summary:"
echo "   Session: wt-obsidian-ai-agent"
echo "   Windows: 3"
echo "   Attach: tmux attach -t wt-obsidian-ai-agent"
echo ""
echo "📝 Tmux Navigation:"
echo "   Switch windows: Ctrl+b w"
echo "   Next/prev window: Ctrl+b n / Ctrl+b p"
echo "   Detach: Ctrl+b d"
```

#### Helping User Navigate Between Windows

**In SKILL.md, provide quick reference:**
```markdown
## Tmux Quick Reference

| Action | Key Combination |
|--------|-----------------|
| List windows interactively | `Ctrl+b w` |
| Next window | `Ctrl+b n` |
| Previous window | `Ctrl+b p` |
| Window 0-9 | `Ctrl+b 0` ... `Ctrl+b 9` |
| Rename window | `Ctrl+b ,` |
| Close window | `Ctrl+b &` |
| Detach from session | `Ctrl+b d` |
| List all sessions | `tmux ls` |
| Attach to session | `tmux attach -t <name>` |
```

#### Session Cleanup

**Current Behavior:** When worktree is deleted via `cleanup.sh`, remove the tmux window.

**Implementation:**
```bash
# In cleanup.sh, after removing worktree
if [ "$TERMINAL" = "tmux" ]; then
    SESSION_NAME="wt-$PROJECT"
    WINDOW_NAME=$(echo "$BRANCH" | tr '/' '-')

    # Check if session exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        # Get window index by name
        WINDOW_INDEX=$(tmux list-windows -t "$SESSION_NAME" -F "#{window_name}:#{window_index}" | \
                      grep "^${WINDOW_NAME}:" | cut -d: -f2)

        if [ -n "$WINDOW_INDEX" ]; then
            # Kill the window
            tmux kill-window -t "${SESSION_NAME}:${WINDOW_INDEX}"
            echo "   Removed tmux window: $WINDOW_NAME"

            # Check if session is now empty
            WINDOW_COUNT=$(tmux list-windows -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')
            if [ -z "$WINDOW_COUNT" ] || [ "$WINDOW_COUNT" -eq 0 ]; then
                tmux kill-session -t "$SESSION_NAME"
                echo "   Killed empty tmux session: $SESSION_NAME"
            fi
        fi
    fi
fi
```

**Note:** Window cleanup is optional. Tmux sessions can have orphaned windows without issues. User can manually clean up with `Ctrl+b &` to close windows.

**Recommendation:** Implement window cleanup for better UX, but don't auto-kill empty sessions (user might want to keep them).

---

## Implementation

### Tmux Commands Reference

```bash
# Check if session exists (exit code: 0=exists, 1=not exists)
tmux has-session -t SESSION_NAME 2>/dev/null

# Create detached session with first window
tmux new-session -d -s SESSION_NAME -n WINDOW_NAME -c WORKING_DIR "COMMAND"

# Add window to existing session
tmux new-window -t SESSION_NAME -n WINDOW_NAME -c WORKING_DIR "COMMAND"

# Kill window
tmux kill-window -t SESSION_NAME:WINDOW_INDEX

# Kill session
tmux kill-session -t SESSION_NAME

# List sessions
tmux list-sessions

# List windows in session
tmux list-windows -t SESSION_NAME

# Attach to session
tmux attach -t SESSION_NAME

# Rename window
tmux rename-window -t SESSION_NAME:WINDOW_INDEX "NEW_NAME"
```

### Branch Slugification

```bash
# Replace slashes with dashes
BRANCH="feature/auth"
WINDOW_NAME=$(echo "$BRANCH" | tr '/' '-')  # → feature-auth

# Alternative: more aggressive slugification (for special characters)
WINDOW_NAME=$(echo "$BRANCH" | tr -cs 'a-zA-Z0-9' '-')
```

### Example Implementation (launch-agent.sh)

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

    SESSION_NAME="wt-$PROJECT"
    WINDOW_NAME=$(echo "$BRANCH" | tr '/' '-')
    WINDOW_COUNT_BEFORE=0

    # Check if session exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        WINDOW_COUNT_BEFORE=$(tmux list-windows -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')
        # Add window to existing session
        tmux new-window -t "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "$SHELL_CMD -c '$INNER_CMD'"
    else
        # Create new session with first window
        tmux new-session -d -s "$SESSION_NAME" -n "$WINDOW_NAME" -c "$WORKTREE_PATH" "$SHELL_CMD -c '$INNER_CMD'"
    fi

    # Window count after
    WINDOW_COUNT_AFTER=$(tmux list-windows -t "$SESSION_NAME" 2>/dev/null | wc -l | tr -d ' ')

    # User feedback
    if [ "$WINDOW_COUNT_BEFORE" -eq 0 ]; then
        echo "   tmux session: $SESSION_NAME (1 window)"
        echo "   Attach with: tmux attach -t $SESSION_NAME"
    else
        echo "   tmux session: $SESSION_NAME (window $WINDOW_COUNT_AFTER of $WINDOW_COUNT_AFTER)"
        echo "   Navigate: Ctrl+b w"
    fi
    ;;
```

---

## Recommendations

### Primary Recommendation

Implement tmux multi-window sessions in `launch-agent.sh` with these changes:

1. **Session naming:** `wt-$PROJECT` (one session per project)
2. **Window naming:** Slugified branch name (`feature/auth` → `feature-auth`)
3. **Session detection:** Use `tmux has-session` before creating
4. **Detached creation:** Always use `-d` flag to prevent blocking
5. **Error handling:** Check for tmux installation, provide install instructions
6. **User feedback:** Inform user about session name, window count, and navigation

### File Changes Required

1. **`skills/worktree-manager/config.json`:**
   - Change `"terminal": "iterm"` to `"terminal": "tmux"`

2. **`skills/worktree-manager/scripts/launch-agent.sh`:**
   - Update tmux case (lines 107-115) to implement multi-window logic
   - Add session existence check
   - Add window naming with slugification
   - Improve user feedback

3. **`skills/worktree-manager/SKILL.md`:**
   - Add "Tmux Navigation" section with quick reference table
   - Update "Launch Agent Manually" section
   - Update example sessions
   - Add notes about session/window naming

4. **`skills/worktree-manager/scripts/cleanup.sh`** (optional):
   - Add tmux window cleanup when deleting worktree
   - Handle session cleanup when last window removed

### Alternative Approaches

**Option A: Single Session for All Projects**
- Session: `wt-all`
- Windows: `project-name:branch-name`
- **Pros:** One session to rule them all
- **Cons:** Gets cluttered with many projects
- **Recommendation:** Not recommended - defeats purpose of per-project isolation

**Option B: Auto-attach on First Window**
- Automatically attach to session when first window is created
- **Pros:** User sees the session immediately
- **Cons:** Blocks script execution, confusing for multiple parallel worktrees
- **Recommendation:** Not recommended - keep sessions detached

**Option C: Use Pane Splits Instead of Windows**
- Each worktree is a pane in a split window
- **Pros:** See all worktrees at once
- **Cons:** Limited screen space, gets cramped with >2 worktrees
- **Recommendation:** Windows are better for >2 worktrees

### Risks and Considerations

1. **User unfamiliarity with tmux:**
   - **Mitigation:** Provide clear instructions in output and SKILL.md
   - Add quick reference table for common commands

2. **Session naming collisions:**
   - **Risk:** If project has same name as existing session
   - **Mitigation:** `wt-` prefix reduces collision risk
   - Tmux allows same-named sessions (different instances)

3. **Persistent sessions:**
   - **Risk:** Old sessions accumulate over time
   - **Mitigation:** Document `tmux kill-session` command
   - Consider adding `cleanup --tmux-sessions` to cleanup.sh

4. **Window name conflicts:**
   - **Risk:** Branch names result in same window name
   - **Mitigation:** Duplicate names are acceptable in tmux
   - Optional: Append index to disambiguate

5. **Fish shell in tmux:**
   - **Risk:** Fish syntax differs from bash
   - **Mitigation:** Use `SHELL_CMD` from config to match user's shell
   - Commands are run as strings, syntax handled by the shell itself

6. **Testing with other terminal types:**
   - **Risk:** Changes might affect other terminals
   - **Mitigation:** Only modify `tmux)` case statement
   - Test with existing terminals to ensure no regression

---

## Next Steps

1. [ ] **Review research file** - Verify findings and approach
2. [ ] **Create implementation prompt** - Generate structured prompt for fullstack-developer
3. [ ] **Update config.json** - Change terminal to "tmux"
4. [ ] **Update launch-agent.sh** - Implement multi-window session logic
5. [ ] **Update SKILL.md** - Add tmux documentation and examples
6. [ ] **Optional: Update cleanup.sh** - Add window cleanup logic
7. [ ] **Test with single worktree** - Verify session creation and attachment
8. [ ] **Test with multiple worktrees** - Verify multi-window behavior
9. [ ] **Test with other terminals** - Ensure no regression
10. [ ] **Document for users** - Add migration guide in SKILL.md

---

## Sources Consulted

- [Tmux Manual Page](https://man.openbsd.org/tmux) - Complete command reference
- [Checking If tmux Session Exists in Script](https://davidltran.com/blog/check-tmux-session-exists-script/) - Session detection pattern
- [Bash Scripts for tmux](https://medium.com/@jakemanger/bash-scripts-for-tmux-d77a0764833c) - Automation best practices
- [StackOverflow: tmux new-window to existing session](https://unix.stackexchange.com/questions/515935/tmux-how-to-specify-session-in-new-window) - Window targeting syntax
- [StackOverflow: Create session with multiple windows](https://stackoverflow.com/questions/48997929/how-do-i-create-a-tmux-session-with-multiple-windows-already-opened) - Detached session pattern
- [tmux Wiki: Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started) - Window naming basics
- [tmux Wiki: Advanced Use](https://github.com/tmux/tmux/wiki/Advanced-Use) - Scripting patterns
- [How to create tmux session with a script](https://how-to.dev/how-to-create-tmux-session-with-a-script) - Script examples
- [Baeldung: Bash check if command exists](https://www.baeldung.com/linux/bash-script-check-program-exists) - Command detection pattern

---

## Confidence Level

**Confidence: High**

**Rationale:**
- Extensive official documentation available (tmux man page, wiki)
- Multiple confirmed examples from StackOverflow, GitHub, blogs
- Current implementation is well-understood
- Approach is standard tmux automation pattern
- Edge cases have clear solutions
- No conflicting information found
