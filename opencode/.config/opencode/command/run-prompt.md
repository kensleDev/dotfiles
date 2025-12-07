<objective>
Execute one or more prompts from `./prompts/` as delegated sub-tasks with fresh context. Supports single prompt execution, parallel execution of multiple independent prompts, and sequential execution of dependent prompts.
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

- If empty or "last": Find with `!ls -t ./prompts/*.md | head -1`
- If a number: Find file matching that zero-padded number (e.g., "5" matches "005-_.md", "42" matches "042-_.md")
- If text: Find files containing that string in the filename

<matching_rules>

- If exactly one match found: Use that file
- If multiple matches found: List them and ask user to choose
- If no matches found: Report error and list available prompts
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

- If <agent_allocation> exists: Use specified agents
- If no allocation: Default to general-purpose for simple tasks
- If researcher is primary: Check for secondary agent in workflow
- If multiple agents: Determine execution order (sequential/parallel)
  </agent_resolution_rules>

<agent_loading>
Load agent definition from agents directory:

1. Read agent file (e.g., `agents/agents/[agent-name].md`)
2. Extract agent capabilities, tools, and workflow patterns
3. Prepare context with agent's specific expertise and constraints
4. Configure tool access based on agent's defined toolset
   </agent_loading>
   </agent_resolution>

<execution_by_agent>
<researcher_agent>

1. Load researcher.md agent definition
2. Execute with researcher's toolset (including MCP tools)
3. Research phase outputs saved to `./research/` directory
4. If prompt includes implementation phase:
   - Pass research findings as context to next agent
   - Follow specified workflow (sequential/parallel)
5. Archive prompt with research phase metadata
   </researcher_agent>

<specialist_agents>

1. Load appropriate specialist agent definition
2. Execute with specialist's toolset
3. Apply any research findings if available
4. Implement the specific task requirements
5. Archive prompt with implementation metadata
   </specialist_agents>

<multi_agent_workflows>
<research_first_workflow>

1. Execute researcher agent first
2. Capture research findings and recommendations
3. Pass findings to secondary specialist agent
4. Specialist agent implements based on research
5. Return consolidated results from both phases
   </research_first_workflow>

<parallel_specialist_workflow>

1. Identify independent specialist agents
2. **Spawn all Task tools in a SINGLE MESSAGE** (critical for parallel):
   - Use Task tool for each specialist with their agent context
   - All agents work simultaneously on different aspects
3. Wait for ALL specialists to complete
4. Integrate outputs from all specialists
5. Archive all prompts with consolidated metadata
   </parallel_specialist_workflow>

<sequential_specialist_workflow>

1. Determine agent execution order from dependencies
2. Execute first specialist agent
3. Wait for completion
4. Pass output as context to next agent
5. Repeat until all agents complete
6. Return consolidated results showing progression
   </sequential_specialist_workflow>
   </multi_agent_workflows>
   </execution_by_agent>
   </step3_execute_with_agents>
   </process>

<context_strategy>
By delegating to a sub-task with the appropriate agent context, the actual implementation work happens in fresh context while the main conversation stays lean for orchestration and iteration. Agent specialization ensures tasks are handled by experts in their respective domains.
</context_strategy>

<output>
<research_first_output>
🔍 Research Phase Completed: ./prompts/005-implement-auth.md
🛠️ Implementation Phase Completed with fullstack-specialist
✓ Archived to: ./prompts/completed/005-implement-auth.md

<research_findings>
[Summary of key research insights from researcher agent]
</research_findings>

<implementation_results>
[Summary of what the specialist accomplished based on research]
</implementation_results>

<consolidated_outcome>
[End-to-end results showing research-informed implementation]
</consolidated_outcome>
</research_first_output>

<single_prompt_output>
✓ Executed: ./prompts/005-implement-feature.md with [agent-name]
✓ Archived to: ./prompts/completed/005-implement-feature.md

<results>
[Summary of what the specialist agent accomplished]
</results>
</single_prompt_output>

<parallel_output>
✓ Executed in PARALLEL:

- ./prompts/005-implement-auth.md with security-specialist
- ./prompts/006-implement-api.md with fullstack-specialist
- ./prompts/007-implement-ui.md with react-nextjs-specialist

✓ All archived to ./prompts/completed/

<results>
[Consolidated summary of all specialist agent results]
[Agent collaboration summary]
</results>
</parallel_output>

<sequential_output>
✓ Executed SEQUENTIALLY:

1. ./prompts/005-setup-database.md with database-specialist → Success
2. ./prompts/006-create-migrations.md with database-specialist → Success
3. ./prompts/007-seed-data.md with database-specialist → Success

✓ All archived to ./prompts/completed/

<results>
[Consolidated summary showing progression through each step]
[Agent handoffs and context passing]
</results>
</sequential_output>
</output>

<critical_notes>

- For parallel execution: ALL Task tool calls MUST be in a single message
- For sequential execution: Wait for each Task to complete before starting next
- Archive prompts only after successful completion
- If any prompt fails, stop sequential execution and report error
- Provide clear, consolidated results for multiple prompt execution
- Agent-specific: Always load agent context from agents directory
- Agent workflows: Respect agent allocation tags and workflow patterns
- Agent tools: Restrict tool access to agent's defined toolset
- Agent handoffs: Include relevant outputs as context for next agent
- Research-first: Always complete research phase before implementation
  </critical_notes>
