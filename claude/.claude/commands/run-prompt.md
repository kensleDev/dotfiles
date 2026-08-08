<objective>
Execute one or more prompts from `.agent/prompts/` as delegated sub-tasks with fresh context. Supports single prompt execution, parallel execution of multiple independent prompts, and sequential execution of dependent prompts.
</objective>

<input>
The user will specify which prompt(s) to run via $ARGUMENTS, which can be:

**Single prompt:**

- Empty (no arguments): Run the most recently created prompt (default behavior)
- A prompt number (e.g., "001", "5", "42")
- A partial filename (e.g., "user-auth", "dashboard")

**Multiple prompts:**

- Multiple numbers (e.g., "005 006 007")
- With execution flag: "005 006 007 --parallel" or "005 006 007 --sequential"
- If no flag specified with multiple prompts, default to --sequential for safety
</input>

<process>
<step1_parse_arguments>
Parse $ARGUMENTS to extract:
- Prompt numbers/names (all arguments that are not flags)
- Execution strategy flag (--parallel or --sequential)

<examples>
- "005" → Single prompt: 005
- "005 006 007" → Multiple prompts: [005, 006, 007], strategy: sequential (default)
- "005 006 007 --parallel" → Multiple prompts: [005, 006, 007], strategy: parallel
- "005 006 007 --sequential" → Multiple prompts: [005, 006, 007], strategy: sequential
</examples>
</step1_parse_arguments>

<step2_resolve_files>
For each prompt number/name:

- Detect current git branch: `!git branch --show-current` (fallback to "main")
- If empty or "last": Find with `!ls -t .agent/prompts/[current-branch]/*.md | head -1`
- If a number: Find file matching that zero-padded number in current branch folder (e.g., "5" matches ".agent/prompts/[current-branch]/005-_.md", "42" matches ".agent/prompts/[current-branch]/042-_.md")
- If text: Find files containing that string in the filename within current branch folder
- If contains "/" (e.g., "feature-auth/005"): Treat as explicit branch path and search in that specific branch folder

<matching_rules>

- If exactly one match found: Use that file
- If multiple matches found: List them and ask user to choose
- If no matches found in current branch: Check root .agent/prompts/ for backward compatibility, then report error and list available prompts
</matching_rules>
</step2_resolve_files>

<step3_execute_with_agents>
<agent_resolution>
For each prompt file:

1. Read the prompt content
2. Extract <agent_allocation> to determine which agent to use
3. Identify agent type from agents directory
4. Prepare agent-specific execution context

<agent_resolution_rules>

- If <agent_allocation> specifies "researcher": Use researcher agent
- If <agent_allocation> specifies "fullstack-developer": Use fullstack-developer agent
- If no allocation: Default to fullstack-developer for implementation tasks
- If researcher workflow: Researcher creates implementation prompt, then fullstack-developer executes it
</agent_resolution_rules>

<agent_loading>
Load agent definition from agents directory:

1. Read agent file (e.g., `agents/fullstack-developer.md` or `agents/researcher.md`)
2. Extract agent capabilities, tools, and workflow patterns
3. Prepare context with agent's specific expertise and constraints
4. Configure tool access based on agent's defined toolset
</agent_loading>
</agent_resolution>

<execution_by_agent>
<researcher_agent>

1. Load researcher.md agent definition
2. Execute with researcher's toolset (including MCP tools)
3. Research phase creates implementation prompt at `.agent/prompts/[branch-name]/[number]-[name].md`
4. Archive research task prompt to `.agent/prompts/[branch-name]/completed/`
5. Return the path to the created implementation prompt

<researcher_workflow>
Researcher agent's job is to:
- Investigate the topic using MCP tools (Context7, web-search-prime, web-reader)
- Create a well-structured implementation prompt for fullstack-developer
- Save the implementation prompt with the next sequential number
- Include XML structure, requirements, success criteria
</researcher_workflow>
</researcher_agent>

<fullstack_developer_agent>

1. Load fullstack-developer.md agent definition
2. Execute with fullstack-developer's toolset and skills
3. Implement the specific task requirements
4. Archive prompt to `.agent/prompts/[branch-name]/completed/`
5. Return implementation results
</fullstack_developer_agent>

<research_first_workflow>
When researcher creates an implementation prompt:

1. Execute researcher agent on research task prompt
2. Researcher creates implementation prompt at `[number]-[name].md`
3. Prompt user: "Researcher created implementation prompt at .agent/prompts/[branch]/[number]-[name].md. Run fullstack-developer to execute it?"
4. If user confirms, execute fullstack-developer on the new implementation prompt
5. Return consolidated results from both phases
</research_first_workflow>

<parallel_workflow>
For multiple independent prompts (same agent type):

1. Verify prompts are truly independent (no shared file modifications)
2. **Spawn all Task tools in a SINGLE MESSAGE** (critical for parallel):
   - Use Task tool for each prompt with fullstack-developer context
   - All agents work simultaneously on different aspects
3. Wait for ALL agents to complete
4. Integrate outputs from all agents
5. Archive all prompts to completed folder
</parallel_workflow>

<sequential_workflow>
For dependent prompts:

1. Determine execution order from dependencies
2. Execute first prompt with appropriate agent
3. Wait for completion
4. Pass output as context to next prompt
5. Repeat until all prompts complete
6. Return consolidated results showing progression
</sequential_workflow>
</execution_by_agent>
</step3_execute_with_agents>
</process>

<context_strategy>
By delegating to a sub-task with the appropriate agent context, the actual implementation work happens in fresh context while the main conversation stays lean for orchestration and iteration.
</context_strategy>

<output>
<researcher_output>
✓ Research task executed: .agent/prompts/[branch]/[number]-research-[topic].md

Researcher created implementation prompt:
.agent/prompts/[branch]/[number]-[name].md

<research_summary>
[Summary of research findings]
</research_summary>

<next_action>
Run fullstack-developer to execute the implementation prompt?
</next_action>
</researcher_output>

<fullstack_developer_output>
✓ Executed: .agent/prompts/[branch]/[number]-[name].md with fullstack-developer
✓ Archived to: .agent/prompts/[branch]/completed/[number]-[name].md

<results>
[Summary of what fullstack-developer accomplished]
</results>
</fullstack_developer_output>

<research_first_output>
🔍 Research Phase Completed: .agent/prompts/[branch]/[number]-research-[topic].md
🛠️ Implementation Prompt Created: .agent/prompts/[branch]/[number]-[name].md
✓ Archived research task to: .agent/prompts/[branch]/completed/[number]-research-[topic].md

<research_summary>
[Summary of key research insights]
</research_summary>

<implementation_prompt_ready>
The implementation prompt is ready for fullstack-developer to execute.
</implementation_prompt_ready>
</research_first_output>

<parallel_output>
✓ Executed in PARALLEL:

- .agent/prompts/[branch]/005-implement-auth.md with fullstack-developer
- .agent/prompts/[branch]/006-implement-api.md with fullstack-developer
- .agent/prompts/[branch]/007-implement-ui.md with fullstack-developer

✓ All archived to .agent/prompts/[branch]/completed/

<results>
[Consolidated summary of all results]
</results>
</parallel_output>

<sequential_output>
✓ Executed SEQUENTIALLY:

1. .agent/prompts/[branch]/005-setup-database.md with fullstack-developer → Success
2. .agent/prompts/[branch]/006-create-migrations.md with fullstack-developer → Success
3. .agent/prompts/[branch]/007-seed-data.md with fullstack-developer → Success

✓ All archived to .agent/prompts/[branch]/completed/

<results>
[Consolidated summary showing progression through each step]
</results>
</sequential_output>
</output>

<critical_notes>

- For parallel execution: ALL Task tool calls MUST be in a single message
- For sequential execution: Wait for each Task to complete before starting next
- Archive prompts only after successful completion to `.agent/prompts/[branch-name]/completed/`
- Ensure completed folder exists before archiving: `!mkdir -p .agent/prompts/[branch-name]/completed/` (fail gracefully if mkdir fails)
- If any prompt fails, stop sequential execution and report error
- Provide clear, consolidated results for multiple prompt execution
- Agent-specific: Always load agent context from agents directory
- Researcher workflow: Researcher creates prompts, fullstack-developer executes them
- Researcher output: Creates implementation prompts at `.agent/prompts/[branch-name]/[number]-[name].md`
- Fullstack-developer: Handles all SvelteKit, Next.js, and general implementation tasks
- Branch context: Default to current git branch, support explicit branch paths for cross-branch execution
- Backward compatibility: Check root .agent/prompts/ if no files found in current branch folder
</critical_notes>
