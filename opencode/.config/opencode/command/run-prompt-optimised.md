# Run Prompt (Optimized)

Execute one or more prompts from `.agent/prompts/` as delegated sub-tasks with fresh context.
Supports single prompt execution, parallel execution of multiple independent prompts,
and sequential execution of dependent prompts.

## Input

The user will specify which prompt(s) to run via $ARGUMENTS, which can be:

**Single prompt:**

- Empty (no arguments): Run the most recently created prompt (default behavior)
- A prompt number (e.g., "001", "5", "42")
- A partial filename (e.g., "user-auth", "dashboard")

**Multiple prompts:**

- Multiple numbers (e.g., "005 006 007")
- With execution flag: "005 006 007 --parallel" or "005 006 007 --sequential"
- If no flag specified with multiple prompts, default to --sequential for safety

## Process

### Step 1: Parse Arguments

Parse $ARGUMENTS to extract:
- Prompt numbers/names (all arguments that are not flags)
- Execution strategy flag (--parallel or --sequential)

<examples>
- "005" → Single prompt: 005
- "005 006 007" → Multiple prompts: [005, 006, 007], strategy: sequential (default)
- "005 006 007 --parallel" → Multiple prompts: [005, 006, 007], strategy: parallel
- "005 006 007 --sequential" → Multiple prompts: [005, 006, 007], strategy: sequential
</examples>

### Step 2: Resolve Prompt Files

**Initialize helpers:** `!source scripts/prompt-helpers.sh`

**Get branch:** `BRANCH=\$(get_branch)`

For each prompt number/name:

- **If empty or "last":** Use `find_recent_prompt("\$BRANCH")`
- **If a number:** Use `resolve_prompt("$identifier", "\$BRANCH")` (handles zero-padding)
- **If text:** Use `resolve_prompt("$identifier", "\$BRANCH")` (partial filename match)
- **If contains "/" (e.g., "feature-auth/005"):** Use `resolve_prompt("$identifier", "\$BRANCH")` (explicit branch path)

**Matching rules:**

- If exactly one match found: Use that file
- If multiple matches found: List them and ask user to choose
- If no matches found in current branch: Check root .agent/prompts/ for backward compatibility, then report error and list available prompts

### Step 3: Execute with Agents

#### Agent Resolution

For each prompt file:

1. Read the prompt content
2. Extract <agent_allocation> to determine which agent to use
3. Identify agent type from agents directory
4. Prepare agent-specific execution context

**Agent resolution rules:**

- If <agent_allocation> specifies "research-agent-lite": Use research-agent-lite agent
- If <agent_allocation> specifies "fullstack-agent": Use fullstack-agent agent
- If no allocation: Default to fullstack-agent for implementation tasks
- If research-agent-lite workflow: Researcher creates implementation prompt, then fullstack-agent executes it

**Agent loading:**

Load agent definition from agents directory:

1. Read agent file (e.g., `agents/fullstack-agent.md` or `agents/research-agent-lite.md`)
2. Extract agent capabilities, tools, and workflow patterns
3. Prepare context with agent's specific expertise and constraints
4. Configure tool access based on agent's defined toolset

#### Execution by Agent

**research-agent-lite:**

1. Load research-agent-lite.md agent definition
2. Execute with research-agent-lite's toolset (including MCP tools)
3. Research phase creates implementation prompt at `.agent/prompts/[branch-name]/[number]-[name].md`
4. Archive research task prompt to `.agent/prompts/[branch-name]/completed/` using `archive_prompt()`
5. Return the path to the created implementation prompt

**research-agent-lite workflow:**

Researcher agent's job is to:
- Investigate the topic using MCP tools (Context7, web-search-prime, web-reader)
- Create a well-structured implementation prompt for fullstack-agent
- Save the implementation prompt with the next sequential number
- Include XML structure, requirements, success criteria

**fullstack-developer agent:**

1. Load fullstack-agent.md agent definition
2. Execute with fullstack-agent's toolset and skills
3. Implement the specific task requirements
4. Archive prompt to `.agent/prompts/[branch-name]/completed/` using `archive_prompt()`
5. Return implementation results

**Research first workflow:**

When research-agent-lite creates an implementation prompt:

1. Execute research-agent-lite agent on research task prompt
2. Researcher creates implementation prompt at `[number]-[name].md`
3. Prompt user: "research-agent-lite created implementation prompt at .agent/prompts/[branch]/[number]-[name].md. Run fullstack-agent to execute it?"
4. If user confirms, execute fullstack-agent on the new implementation prompt
5. Return consolidated results from both phases

**Parallel workflow:**

For multiple independent prompts (same agent type):

1. Verify prompts are truly independent (no shared file modifications)
2. **Spawn all Task tools in a SINGLE MESSAGE** (critical for parallel):
   - Use Task tool for each prompt with fullstack-agent context
   - All agents work simultaneously on different aspects
3. Wait for ALL agents to complete
4. Integrate outputs from all agents
5. Archive all prompts to completed folder using `archive_prompt()` for each

**Sequential workflow:**

For dependent prompts:

1. Determine execution order from dependencies
2. Execute first prompt with appropriate agent
3. Wait for completion
4. Pass output as context to next prompt
5. Repeat until all prompts complete
6. Return consolidated results showing progression

## Context Strategy

By delegating to a sub-task with the appropriate agent context, the actual implementation work happens in fresh context while the main conversation stays lean for orchestration and iteration.

## Output

**research-agent-lite output:**

```
✓ Research task executed: .agent/prompts/[branch]/[number]-research-[topic].md

Researcher created implementation prompt:
.agent/prompts/[branch]/[number]-[name].md

[Research summary]

Run fullstack-agent to execute the implementation prompt?
```

**fullstack-developer output:**

```
✓ Executed: .agent/prompts/[branch]/[number]-[name].md with fullstack-agent
✓ Archived to: .agent/prompts/[branch]/completed/[number]-[name].md

[Results summary]
```

**Research first output:**

```
🔍 Research Phase Completed: .agent/prompts/[branch]/[number]-research-[topic].md
🛠️ Implementation Prompt Created: .agent/prompts/[branch]/[number]-[name].md
✓ Archived research task to: .agent/prompts/[branch]/completed/[number]-research-[topic].md

[Research summary]

Implementation prompt is ready for fullstack-agent to execute.
```

**Parallel output:**

```
✓ Executed in PARALLEL:

- .agent/prompts/[branch]/005-implement-auth.md with fullstack-agent
- .agent/prompts/[branch]/006-implement-api.md with fullstack-agent
- .agent/prompts/[branch]/007-implement-ui.md with fullstack-agent

✓ All archived to .agent/prompts/[branch]/completed/

[Consolidated results]
```

**Sequential output:**

```
✓ Executed SEQUENTIALLY:

1. .agent/prompts/[branch]/005-setup-database.md with fullstack-agent → Success
2. .agent/prompts/[branch]/006-create-migrations.md with fullstack-agent → Success
3. .agent/prompts/[branch]/007-seed-data.md with fullstack-agent → Success

✓ All archived to .agent/prompts/[branch]/completed/

[Consolidated summary]
```

## Critical Notes

- For parallel execution: ALL Task tool calls MUST be in a single message
- For sequential execution: Wait for each Task to complete before starting next
- Archive prompts only after successful completion using `archive_prompt()` helper
- If any prompt fails, stop sequential execution and report error
- Provide clear, consolidated results for multiple prompt execution
- Agent-specific: Always load agent context from agents directory
- Researcher workflow: Researcher creates prompts, fullstack-agent executes them
- Researcher output: Creates implementation prompts at `.agent/prompts/[branch-name]/[number]-[name].md`
- Fullstack-developer: Handles all SvelteKit, Next.js, and general implementation tasks
- Branch context: Default to current git branch, support explicit branch paths for cross-branch execution
- Backward compatibility: Check root .agent/prompts/ if no files found in current branch folder

## Optimization Notes

This optimized version:
- Uses helper scripts for prompt resolution and file operations (~50% fewer bash calls)
- Centralizes file naming and path resolution logic
- Uses `archive_prompt()` helper for consistent archiving
- Maintains 100% feature parity with original

Compare with `run-prompt.md` to measure improvements in:
- Token usage
- Execution speed
- Code maintainability
