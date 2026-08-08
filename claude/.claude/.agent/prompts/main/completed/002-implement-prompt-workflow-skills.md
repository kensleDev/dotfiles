<agent_allocation>
Primary: fullstack-developer
Output: Three native Claude Code skills with full functionality
Workflow: command-to-skill-conversion
</agent_allocation>

<objective>
Convert three Claude Code commands into native skills while preserving 100% of the workflow functionality.

The three commands to convert are:
1. `/Users/kd/.claude/commands/create-prompt.md` - Creates research/implementation prompts
2. `/Users/kd/.claude/commands/run-prompt.md` - Executes prompts with agents
3. `/Users/kd/.claude/commands/workflow.md` - Orchestrates the full workflow

Your goal is to convert these into native Claude Code skills that:
- Invoke agents via the Task tool (no MCP server dependency)
- Handle user input through natural language (skills don't use $ARGUMENTS like commands)
- Preserve all workflow stages and decision points
- Maintain prompt file management (.agent/prompts/[branch]/)
- Support auto mode and interactive modes
</objective>

<context>
**Why this matters:**
The current commands rely on $ARGUMENTS which is command-specific syntax. Skills use natural language invocation and need different argument handling patterns. Additionally, the current workflow depends on an MCP server (prompt-workflow MCP) for prompt management, but we want to make this native to avoid the MCP dependency.

**What we're converting from/to:**
- **Commands** → **Skills**: Commands use $ARGUMENTS, $1, $2 for parameter capture. Skills use natural language matching and don't have special variable syntax.
- **MCP-dependent** → **Native**: Current workflow uses MCP tools like create_research_task, create_implementation_task. We'll use direct file operations (Bash tool) instead.
- **Parameter passing**: Commands get explicit arguments. Skills must parse natural language requests and extract parameters from context.

**Key difference discovered:**
- Commands use `$ARGUMENTS` to capture all user input as a string
- Skills receive user input as natural language that must be interpreted from the conversation context
- Skills can still use Bash, Read, Write, Edit, and Task tools just like commands

**Agent definitions available:**
- `/Users/kd/.claude/agents/research-agent.md` - Research investigator
- `/Users/kd/.claude/agents/fullstack-agent.md` - Fullstack developer
</context>

<requirements>

## 1. Skill Structure Requirements

Each skill MUST follow this structure:

```yaml
---
name: skill-name
description: Single-line description under 200 chars
allowed-tools: [tool list]
---

# Skill Title

Instructions and workflow...
```

**Skill locations:**
- `/Users/kd/.claude/skills/create-prompt/SKILL.md`
- `/Users/kd/.claude/skills/run-prompt/SKILL.md`
- `/Users/kd/.claude/skills/workflow/SKILL.md`

**Directory structure to create:**
```
/Users/kd/.claude/skills/
├── create-prompt/
│   └── SKILL.md
├── run-prompt/
│   └── SKILL.md
└── workflow/
    └── SKILL.md
```

## 2. Argument Handling Strategy

**Critical difference:** Skills cannot use `$ARGUMENTS` like commands. Instead, skills must:

1. **Interpret user's natural language request** from the conversation
2. **Extract parameters programmatically** using Bash/Read tools
3. **Ask clarifying questions** when parameters are ambiguous

**Pattern to use:**
```markdown
## Input Handling

When the user invokes this skill, extract the task description from their most recent message.

Use Bash to get recent conversation context if needed:
```bash
# Get current conversation context
# Parse user's request from the last message
```

If the request is ambiguous, ask clarifying questions:
- "What specific task should I create a prompt for?"
- "Should I enable auto mode?"
```

## 3. create-prompt Skill Requirements

**File:** `/Users/kd/.claude/skills/create-prompt/SKILL.md`

**Functionality to preserve:**
- Analyze task complexity (Golden Rule: clarity check)
- Determine if research is needed or direct implementation
- Create research task prompts with XML structure
- Detect git branch for prompt storage
- Generate sequential prompt numbers (001, 002, etc.)
- Support auto mode (--auto flag detection from natural language)
- Handle pre-implementation clarification stage
- Invoke researcher agent via Task tool

**Key workflow stages to implement:**
1. **Clarification stage** - Ask questions if task is ambiguous
2. **Confirmation stage** - Confirm understanding before creating prompt
3. **Research task creation** - Generate XML-structured research prompt
4. **File management** - Save to `.agent/prompts/[branch]/[number]-research-[topic].md`
5. **Agent invocation** - Use Task tool to launch researcher agent
6. **Pre-implementation review** - ALWAYS offer chance to review implementation prompt

**Agent invocation pattern:**
```markdown
Use the Task tool to launch the researcher agent:

Load the researcher agent definition from `/Users/kd/.claude/agents/research-agent.md`
Execute with the research task at: `.agent/prompts/[branch]/[number]-research-[topic].md`
```

**Tools needed:**
- `Bash` - For git branch detection, file operations, directory creation
- `Read` - For reading existing prompts to determine next number
- `Write` - For creating new prompt files
- `Task` - For invoking researcher agent
- `Glob` - For finding existing prompt files

## 4. run-prompt Skill Requirements

**File:** `/Users/kd/.claude/skills/run-prompt/SKILL.md`

**Functionality to preserve:**
- Parse prompt identifiers from user input (numbers, names, patterns)
- Resolve prompt files from `.agent/prompts/[branch]/`
- Support single prompt execution
- Support multiple prompts with --parallel or --sequential flags
- Detect agent allocation from prompt's <agent_allocation> tag
- Load agent definitions from `/Users/kd/.claude/agents/`
- Execute prompts with appropriate agent context
- Archive completed prompts to `.agent/prompts/[branch]/completed/`
- Handle researcher → fullstack-developer workflow

**Key workflow stages to implement:**
1. **Parse input** - Extract prompt numbers/names and execution strategy
2. **Resolve files** - Find matching prompt files in current branch
3. **Agent resolution** - Determine which agent to use from <agent_allocation>
4. **Load agent context** - Read agent definition from agents directory
5. **Execute** - Use Task tool to launch agent with prompt
6. **Archive** - Move completed prompts to completed/ folder

**Agent invocation pattern:**
```markdown
For each prompt file:
1. Read the prompt content
2. Extract <agent_allocation> to determine agent type
3. Load agent definition from `/Users/kd/.claude/agents/[agent-name].md`
4. Use Task tool to launch agent with the prompt

Example for researcher:
- Load: /Users/kd/.claude/agents/research-agent.md
- Execute with prompt at: .agent/prompts/[branch]/[number]-research-[topic].md

Example for fullstack-developer:
- Load: /Users/kd/.claude/agents/fullstack-agent.md
- Execute with prompt at: .agent/prompts/[branch]/[number]-[name].md
```

**Parallel execution:**
```markdown
For multiple independent prompts:
- Spawn ALL Task tool calls in a SINGLE message
- Wait for all agents to complete
- Integrate outputs from all agents
```

**Tools needed:**
- `Bash` - For git operations, file operations, directory management
- `Read` - For reading prompt files and agent definitions
- `Glob` - For finding prompt files by pattern
- `Task` - For invoking agents with prompts
- `Grep` - For searching prompt content if needed

## 5. workflow Skill Requirements

**File:** `/Users/kd/.claude/skills/workflow/SKILL.md`

**Functionality to preserve:**
- Full 5-stage workflow orchestration
- State management tracking (clarification → research → pre-implementation → implementation → completion)
- Auto mode detection (skip Stage 2 choice, but ALWAYS show Stage 3)
- Natural language triggering (detect workflow requests)
- Research task creation
- Researcher agent invocation
- Pre-implementation clarification (CRITICAL human-in-the-loop)
- Fullstack-developer agent invocation
- Prompt archiving to completed/
- Error recovery with options

**5 workflow stages to implement:**

**Stage 1: Request Analysis & Clarification**
- Detect auto mode from natural language ("--auto", "automatically")
- Analyze task clarity using Golden Rule
- Ask clarifying questions if needed
- Determine: research needed or direct implementation?

**Stage 2: Research Task Creation (if needed)**
- Detect git branch: `!git branch --show-current || echo "main"`
- Create directory: `!mkdir -p .agent/prompts/{branch}/completed/`
- Get next prompt number by listing existing files
- Create research prompt with XML structure
- Save to: `.agent/prompts/{branch}/{number}-research-{topic}.md`
- Skip choice if auto mode, otherwise present options

**Stage 3: Research Completion & Pre-Implementation (CRITICAL)**
- ALWAYS present this choice even in auto mode:
  ```
  Researcher created implementation prompt at:
  `.agent/prompts/{branch}/{number}-{name}.md`

  Before proceeding to implementation, you can:
  1. Review/edit the implementation prompt
  2. Add clarifications or adjustments
  3. Continue directly to implementation

  Choose (1-3) or just say 'continue': _
  ```
- This is the critical human-in-the-loop checkpoint

**Stage 4: Implementation Execution**
- Confirm implementation with user
- Ask about Ralph Wiggum loop if relevant
- Use Task tool to launch fullstack-developer agent
- Load agent from: `/Users/kd/.claude/agents/fullstack-agent.md`
- Execute with implementation prompt

**Stage 5: Completion & Cleanup**
- Archive research task: `!mv .agent/prompts/{branch}/{research-file} .agent/prompts/{branch}/completed/`
- Archive implementation prompt: `!mv .agent/prompts/{branch}/{implementation-file} .agent/prompts/{branch}/completed/`
- Provide summary of what was accomplished
- Update workflow state to completion

**State management:**
```markdown
Maintain workflow state in your responses:

<!-- WORKFLOW_STATE -->
<workflow_state>
  <stage>clarification|research|pre_implementation|implementation|completion</stage>
  <auto_mode>true|false</auto_mode>
  <branch>{current_git_branch}</branch>
  <research_prompt_path>{path_or_null}</research_prompt_path>
  <implementation_prompt_path>{path_or_null}</implementation_prompt_path>
</workflow_state>
<!-- END_WORKFLOW_STATE -->
```

**Tools needed:**
- `Bash` - For all git operations, file operations, directory management
- `Read` - For reading prompt files, agent definitions, existing prompts
- `Write` - For creating new prompt files
- `Task` - For invoking researcher and fullstack-developer agents
- `Glob` - For finding existing prompt files

## 6. Allowed Tools Configuration

Each skill frontmatter must specify allowed-tools:

**create-prompt:**
```yaml
---
name: create-prompt
description: Expert prompt engineer that creates optimized, XML-structured prompts with intelligent depth selection
allowed-tools: Bash, Read, Write, Glob, Task
---
```

**run-prompt:**
```yaml
---
name: run-prompt
description: Execute one or more prompts from .agent/prompts/ as delegated sub-tasks with fresh context
allowed-tools: Bash, Read, Glob, Grep, Task
---
```

**workflow:**
```yaml
---
name: workflow
description: Master orchestrator for prompt-driven agent workflow - guides users from initial request through research, implementation, and completion
allowed-tools: Bash, Read, Write, Glob, Task
---
```

## 7. Agent Loading Pattern

All skills must use this pattern for loading agents:

```markdown
## Agent Loading

To load an agent for execution:

1. Read the agent definition file:
   - Researcher: `/Users/kd/.claude/agents/research-agent.md`
   - Fullstack-developer: `/Users/kd/.claude/agents/fullstack-agent.md`

2. Use the Task tool to launch the agent:
   ```
   Use the Task tool to launch the {agent_type} agent with the task at:
   {prompt_file_path}

   The agent will:
   - Load their specialized capabilities
   - Execute with their specific toolset
   - Return results to this workflow
   ```

3. Wait for agent completion before proceeding to next stage
```

## 8. File Path Conventions

**Always use absolute paths:**
- Agent definitions: `/Users/kd/.claude/agents/{agent-name}.md`
- Skills: `/Users/kd/.claude/skills/{skill-name}/SKILL.md`
- Prompt directory: `.agent/prompts/{branch}/`
- Completed directory: `.agent/prompts/{branch}/completed/`

**Prompt naming:**
- Research tasks: `{number}-research-{topic}.md`
- Implementation prompts: `{number}-{name}.md`
- Number format: 001, 002, 003 (zero-padded, 3 digits)

**Branch detection:**
```bash
git branch --show-current 2>/dev/null || echo "main"
```

</requirements>

<constraints>

**What MUST be preserved:**
1. All 5 workflow stages in workflow skill
2. Auto mode functionality (skip Stage 2, always show Stage 3)
3. Pre-implementation clarification (critical human-in-the-loop)
4. Sequential prompt numbering
5. Branch-aware prompt storage
6. Agent invocation via Task tool
7. Prompt archiving to completed/
8. Error recovery with user choices

**What MUST change:**
1. Remove all $ARGUMENTS references (skills don't support this)
2. Remove MCP tool dependencies (use direct file operations)
3. Change argument handling to natural language interpretation
4. Use absolute file paths instead of relative

**What CAN be simplified:**
1. Choice presentation can be more conversational
2. State tracking can be less formal (keep in context, not XML tags)
3. Some command-specific patterns can be skill-specific

**Breaking changes to note:**
- Invocation changes from `/command args` to natural language requests
- No more $1, $2, $ARGUMENTS - must parse from conversation
- Users interact differently (no slash command syntax)

</constraints>

<output>

**Files to create:**

1. `/Users/kd/.claude/skills/create-prompt/SKILL.md`
   - Frontmatter with name, description, allowed-tools
   - Prompt engineering workflow with agent invocation
   - Natural language input handling
   - Research task creation with XML structure
   - Task tool usage for researcher agent

2. `/Users/kd/.claude/skills/run-prompt/SKILL.md`
   - Frontmatter with name, description, allowed-tools
   - Prompt resolution and parsing logic
   - Single and multi-prompt execution
   - Parallel and sequential execution modes
   - Agent loading and Task tool invocation

3. `/Users/kd/.claude/skills/workflow/SKILL.md`
   - Frontmatter with name, description, allowed-tools
   - Complete 5-stage workflow orchestration
   - State management across stages
   - Auto mode detection and handling
   - Pre-implementation clarification (always shown)
   - Agent choreography with Task tool

**Directory structure to create:**
```bash
mkdir -p /Users/kd/.claude/skills/create-prompt
mkdir -p /Users/kd/.claude/skills/run-prompt
mkdir -p /Users/kd/.claude/skills/workflow
```

**File structure for each skill:**
```markdown
---
name: skill-name
description: Single line description
allowed-tools: [tools]
---

# Skill Title

## Overview
[Brief description of what this skill does]

## Input Handling
[How to interpret user's natural language request]

## Workflow/Process
[Step-by-step instructions]

## Agent Invocation
[How to use Task tool to launch agents]

## Error Handling
[How to handle failures and offer recovery]
```

</output>

<success_criteria>

**Implementation is complete when:**

1. **All three skills exist** at specified paths with proper frontmatter
2. **Skills invoke correctly** via natural language (no slash commands)
3. **Agent spawning works** - Task tool successfully launches researcher and fullstack-developer
4. **Prompt files created** properly in .agent/prompts/[branch]/ with correct numbering
5. **Workflow stages work** - All 5 stages execute in order with proper state transitions
6. **Auto mode works** - Skips Stage 2 choice but ALWAYS shows Stage 3
7. **Pre-implementation review shown** - Every time, no exceptions
8. **Prompts archived** - Moved to completed/ folder after successful execution
9. **No MCP dependency** - All functionality uses native tools (Bash, Read, Write, Task)
10. **Error recovery works** - Failed operations offer user choices

**Testing checklist:**

- [ ] Test create-prompt: "Create a prompt for adding WebSocket authentication"
  - Should ask clarifying questions if ambiguous
  - Should create research task file
  - Should invoke researcher agent
  - Should show pre-implementation choice after research

- [ ] Test run-prompt: "Run prompt 001" or "Execute the last prompt"
  - Should find and read the prompt file
  - Should determine correct agent from <agent_allocation>
  - Should launch agent with Task tool
  - Should archive prompt after completion

- [ ] Test workflow: "Help me add rate limiting to my API"
  - Should go through all 5 stages
  - Should create research task
  - Should launch researcher
  - Should show pre-implementation choice
  - Should launch fullstack-developer after confirmation
  - Should archive both prompts

- [ ] Test auto mode: "Create a prompt for user auth --auto"
  - Should skip Stage 2 choice
  - Should auto-launch researcher
  - Should STILL show Stage 3 choice (pre-implementation)

- [ ] Test error handling
  - Invalid prompt number should list available prompts
  - Missing agent should report error clearly
  - Failed operations should offer recovery options

**Verification steps:**

1. Check all three SKILL.md files exist with valid YAML frontmatter
2. Verify allowed-tools includes Task for agent invocation
3. Test each skill with sample requests
4. Confirm agent definitions are loaded correctly
5. Verify prompt files created in correct locations
6. Check prompt numbering is sequential
7. Confirm archiving moves files to completed/
8. Test auto mode bypasses correct stage
9. Verify pre-implementation choice always shown
10. Confirm no MCP tools are referenced

</success_criteria>
