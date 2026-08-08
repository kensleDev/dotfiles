<agent_allocation>
Primary: research-agent-lite
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research and create implementation prompt for: Update worktree-manager skill to use tmux sessions with multiple windows (one per worktree) instead of opening separate terminals for each worktree.

The goal: When creating multiple worktrees (e.g., "spin up 3 worktrees for features A, B, C"), launch a single terminal with a tmux session containing multiple windows (one per worktree), each running a Claude Code agent.
</objective>

<context>
Current behavior:
- `launch-agent.sh` opens separate terminal windows (Ghostty, iTerm2, etc.) for each worktree
- Each worktree runs in its own isolated terminal process
- Config.json has `"terminal": "iterm"` set (user wants to change to tmux)

Desired behavior:
- Single terminal opens with tmux session named after project (e.g., `wt-myproject`)
- Each worktree is a separate window within the tmux session
- Windows labeled with branch name for easy navigation (`Ctrl+b w`)
- Add windows to existing session if it already exists
- Even single worktree uses tmux with one window

Current code to modify:
- `skills/worktree-manager/config.json` - Change terminal to tmux
- `skills/worktree-manager/scripts/launch-agent.sh` - Update tmux handling
- `skills/worktree-manager/SKILL.md` - Update documentation
</context>

<research_objective>
Investigate:

1. **tmux session/window management from bash**:
   - How to check if a tmux session exists (`tmux has-session`)
   - How to create new session vs add window to existing session
   - How to name windows for easy navigation
   - How to list sessions and windows

2. **Best practices for tmux automation**:
   - Proper session naming conventions
   - Window naming best practices (max length, special chars)
   - Handling detached vs attached sessions
   - Ensuring sessions persist after script exits

3. **Integration with existing workflow**:
   - How to update SKILL.md to describe tmux usage
   - How to update example sessions in documentation
   - Backwards compatibility with other terminal types

4. **Edge cases**:
   - What if tmux not installed? Fallback behavior?
   - What if session exists but detached? Attach or add window?
   - What if window name conflicts?
   - How to handle shell configuration (fish vs bash) in tmux

5. **User experience**:
   - How to inform user about tmux session name and commands
   - How to help user navigate between windows
   - Session cleanup (when worktree deleted, should window be closed?)
</research_objective>

<research_scope>
Sources:
- tmux documentation (man pages, official docs)
- Context7 (if tmux docs available)
- web-search-prime (tmux session management examples, best practices)
- web-reader (tmux scripting guides)
- codebase (existing worktree-manager scripts for patterns)

Focus:
- tmux scripting from bash
- Session/window management APIs
- Best practices for automated session creation
</research_scope>

<prompt_requirements>
The implementation prompt MUST include:

1. **XML tags**: <agent_allocation>, <objective>, <context>, <requirements>, <implementation_steps>, <output>, <success_criteria>

2. **Explicit instructions**:
   - Exact changes to `launch-agent.sh` tmux case
   - How to check for existing sessions
   - How to add windows to existing sessions
   - Session naming: `wt-$PROJECT`
   - Window naming: branch name (slugified)
   - Fallback if tmux not found

3. **File paths** (relative from working dir):
   - `skills/worktree-manager/config.json`
   - `skills/worktree-manager/scripts/launch-agent.sh`
   - `skills/worktree-manager/SKILL.md`

4. **Requirements**:
   - Change config.json `"terminal"` to `"tmux"`
   - Update launch-agent.sh to handle multi-window sessions
   - Update SKILL.md examples and documentation
   - Maintain backwards compatibility with other terminal types
   - Include user instructions for tmux navigation

5. **Success criteria**:
   - Single tmux session per project
   - Each worktree = separate window
   - Windows named by branch
   - Adds windows to existing session
   - Documentation updated
   - Works for single and multiple worktrees
</prompt_requirements>

<output>
Save to: `.agent/prompts/main/001-worktree-manager-tmux.md`

Content: ONLY the structured implementation prompt (no preamble, no "Here is the prompt", just the XML)
</output>

<success_criteria>
Complete when:
- tmux session/window management API understood
- Best practices for automated sessions identified
- Edge cases addressed (existing sessions, missing tmux, etc.)
- Implementation approach defined
- Executable prompt created with:
  - Exact code changes needed
  - File paths specified
  - Success criteria measurable
  - User experience documented
</success_criteria>
