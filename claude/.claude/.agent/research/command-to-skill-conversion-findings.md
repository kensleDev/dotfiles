# Research: Converting Claude Code Commands to Skills

**Date:** 2026-01-17
**Confidence:** High
**Researcher:** researcher agent

---

## Executive Summary

Claude Code commands and skills have fundamentally different argument handling mechanisms. Commands use special variables (`$ARGUMENTS`, `$1`, `$2`) while skills use natural language interpretation. Converting the prompt workflow commands to skills requires replacing argument syntax with conversational input parsing and using direct file operations instead of MCP dependencies.

---

## Research Objectives

Investigate how to convert three Claude Code commands (`create-prompt`, `run-prompt`, `workflow`) into native skills while preserving 100% of workflow functionality without MCP server dependency.

---

## Key Findings

### 1. Structural Differences: Commands vs Skills

**Commands (`/Users/kd/.claude/commands/*.md`):**
- Use `$ARGUMENTS` to capture all user input as a single string
- Use positional arguments: `$1`, `$2`, `$3`, etc.
- Invoked via slash commands: `/command args`
- Frontmatter can include `argument-hint` for CLI-style help

**Skills (`/Users/kd/.claude/skills/*/SKILL.md`):**
- Receive input as natural language conversation context
- No special variable syntax for arguments
- Invoked via natural language matching to description
- Frontmatter focuses on `name`, `description`, `allowed-tools`

**Critical Discovery:** Skills cannot use `$ARGUMENTS` or positional variables. They must interpret user requests from conversational context.

### 2. Agent Invocation via Task Tool

**How to invoke agents from skills:**

```markdown
# Pattern from official Claude Code documentation

Use the Task tool to launch the [agent-name] agent.

The agent will:
1. Load agent definition from /path/to/agents/[agent-name].md
2. Execute with specialized capabilities and toolset
3. Return results to the calling skill
```

**Key points:**
- Task tool is the standard mechanism for agent invocation
- Agents are defined in `/Users/kd/.claude/agents/[agent-name].md`
- Invoked agents retain access to same resources as calling skill
- Agent spawning works from skills just like commands

### 3. Allowed Tools Configuration

**Skills must specify tools in frontmatter:**

```yaml
---
name: skill-name
description: Brief single-line description
allowed-tools: Bash, Read, Write, Task, Glob, Grep
---
```

**Tool patterns:**
- Single tool: `allowed-tools: Read`
- Multiple tools: `allowed-tools: Bash, Read, Write, Task`
- Bash with filters: `allowed-tools: Bash(git:*)`

**Required tools for prompt workflow:**
- `Bash` - Git operations, file operations, directory management
- `Read` - Reading prompt files, agent definitions
- `Write` - Creating new prompt files
- `Task` - Invoking researcher and fullstack-developer agents
- `Glob` - Finding existing prompt files
- `Grep` - Searching prompt content (optional)

### 4. Replacing MCP Dependency with Native Tools

**Current MCP tools to replace:**
- `create_research_task` → Use `Write` tool with Bash for file operations
- `create_implementation_task` → Use `Write` tool with Bash for file operations
- `list_prompts` → Use `Glob` tool to find prompt files
- `get_prompt` → Use `Read` tool to read prompt files
- `move_prompt_to_completed` → Use `Bash` tool with `mv` command

**File operations pattern:**
```bash
# Detect git branch
!git branch --show-current || echo "main"

# Create directory structure
!mkdir -p .agent/prompts/{branch}/completed/

# List existing prompts to determine next number
!ls .agent/prompts/{branch}/ 2>/dev/null | grep -E '^[0-9]{3}-'

# Archive completed prompts
!mv .agent/prompts/{branch}/{file}.md .agent/prompts/{branch}/completed/
```

### 5. Input Handling Strategy for Skills

**Problem:** Skills can't use `$ARGUMENTS` like commands.

**Solution:** Parse natural language requests from conversation context.

**Pattern to implement:**
```markdown
## Input Handling

When user invokes this skill:

1. Check the most recent user message for the task description
2. Look for flags like "--auto" in natural language
3. Extract parameters using pattern matching
4. If ambiguous, ask clarifying questions:

"Could you clarify what specific task you'd like me to create a prompt for?"
```

**Example transformations:**
- Command: `/create-prompt Add WebSocket authentication --auto`
- Skill: "Create a prompt for adding WebSocket authentication, auto mode"
- Skill interpretation: Detect "auto mode" from context, extract task description

### 6. Skill Structure Best Practices

**From official documentation:**

```yaml
---
name: skill-name
description: Single line under 200 characters
allowed-tools: [tool list]
---

# Skill Title

## Quick Start
[Brief usage instructions]

## Input Handling
[How to interpret user requests]

## Workflow
[Step-by-step process]

## Agent Invocation
[How to use Task tool]
```

**Progressive disclosure:**
- Keep SKILL.md concise (~50-150 lines)
- Put detailed docs in `references/` subdirectory
- Use code blocks sparingly (1-2 recommended)
- Description must be single line for Level 1 efficiency

---

## Implementation Strategy

### Optimal Skill Structure

**Three separate skills (not one combined):**

1. **create-prompt** - Prompt engineering and research task creation
2. **run-prompt** - Prompt execution with agent delegation
3. **workflow** - Full orchestration of all stages

**Rationale:**
- Each skill has distinct purpose and usage pattern
- Users may want to run prompts without creating them
- Workflow skill combines both but adds orchestration
- Modularity allows flexible usage patterns

### Preserved Functionality

**All workflow stages maintained:**
1. Stage 1: Request Analysis & Clarification ✓
2. Stage 2: Research Task Creation ✓
3. Stage 3: Pre-implementation Review (CRITICAL - always shown) ✓
4. Stage 4: Implementation Execution ✓
5. Stage 5: Completion & Cleanup ✓

**Auto mode behavior:**
- Skips Stage 2 choice (automatic research task creation)
- ALWAYS shows Stage 3 (pre-implementation review)
- This is the critical human-in-the-loop checkpoint

**Agent workflow:**
- Researcher agent creates implementation prompts
- Fullstack-developer agent executes implementations
- Skills orchestrate via Task tool
- Agents loaded from `/Users/kd/.claude/agents/`

### Breaking Changes to Document

**Invocation changes:**
- Old: `/create-prompt Add auth --auto`
- New: "Create a prompt for adding authentication in auto mode"

**Argument passing:**
- Old: `$ARGUMENTS` contains all user input
- New: Parse from natural language conversation

**Parameter extraction:**
- Old: `$1` for first argument, `--auto` detection in string
- New: Pattern matching from conversation context

---

## Recommendations

### Primary Recommendation

Convert all three commands to skills using natural language input handling. Preserve all workflow stages and agent orchestration patterns. Replace MCP tools with direct Bash/Read/Write operations.

**Key implementation points:**
1. Use Task tool for all agent invocations
2. Parse user input from conversation context (no $ARGUMENTS)
3. Implement all 5 workflow stages in workflow skill
4. Always show pre-implementation choice (Stage 3)
5. Use absolute file paths throughout
6. Create sequential prompt numbers (001, 002, 003)
7. Archive prompts to completed/ folder after execution

### Alternative Approaches

**Approach 1: Single combined skill**
- Pros: Simpler deployment, unified interface
- Cons: Loses modularity, harder to use individual features
- **Not recommended** - Reduces flexibility

**Approach 2: Keep commands, add skills as wrappers**
- Pros: Gradual migration, backward compatibility
- Cons: Maintenance burden, confusing to users
- **Not recommended** - Adds complexity without benefit

**Approach 3: Hybrid (commands for slash invocation, skills for natural language)**
- Pros: Best of both worlds
- Cons: Duplicate code, sync issues
- **Maybe** - Only if slash commands are critical

### Risks and Considerations

**Risk 1: Natural language parsing may be less precise**
- **Mitigation:** Ask clarifying questions when ambiguous
- **Impact:** Low - users can provide clarification

**Risk 2: Auto mode detection less reliable**
- **Mitigation:** Look for keywords like "auto", "automatically", "skip"
- **Impact:** Low - can confirm with user if uncertain

**Risk 3: Breaking existing user workflows**
- **Mitigation:** Document changes clearly, provide migration guide
- **Impact:** Medium - users need to learn new invocation pattern

**Risk 4: Prompt numbering conflicts**
- **Mitigation:** Use atomic file operations, check existing files
- **Impact:** Low - filesystem locking prevents conflicts

---

## Implementation

### File Structure

```
/Users/kd/.claude/skills/
├── create-prompt/
│   └── SKILL.md
├── run-prompt/
│   └── SKILL.md
└── workflow/
    └── SKILL.md
```

### SKILL.md Template

```yaml
---
name: skill-name
description: Single-line description under 200 chars
allowed-tools: Bash, Read, Write, Task, Glob
---

# Skill Title

## Overview
[Brief description]

## Input Handling
[How to interpret natural language requests]

## Workflow
[Step-by-step instructions]

## Agent Invocation
[Task tool usage patterns]

## Error Handling
[Recovery strategies]
```

---

## Next Steps

1. [ ] Fullstack-developer reviews implementation prompt at `.agent/prompts/main/002-implement-prompt-workflow-skills.md`
2. [ ] Fullstack-developer creates three SKILL.md files with proper structure
3. [ ] Test each skill with sample inputs
4. [ ] Verify agent invocation via Task tool works correctly
5. [ ] Test all 5 workflow stages in workflow skill
6. [ ] Verify auto mode behavior (skip Stage 2, show Stage 3)
7. [ ] Confirm pre-implementation choice always shown
8. [ ] Test prompt archiving to completed/ folder
9. [ ] Document breaking changes and new usage patterns
10. [ ] Remove or deprecate old command files

---

## Sources Consulted

- [Claude Code Documentation - Skill Structure](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/plugin-structure/SKILL.md)
- [Claude Code Documentation - Command Arguments](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/command-development/SKILL.md)
- [Claude Code Documentation - Task Tool](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/command-development/references/plugin-features-reference.md)
- [Claude Skills 深度实测:能力包与软编排的完整指南](https://www.axtonliu.ai/newsletters/ai-2/posts/claude-skills-capability-package-soft-orchestration-guide)
- [Claude Code Skills 进阶 - Vibe Coding](https://jiangren.com.au/learn/vibe-coding/claude-code-skills)
- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Skill authoring best practices - Claude Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Inside Claude Code Skills: Structure, prompts, invocation](https://mikhail.io/2025/10/claude-code-skills/)
