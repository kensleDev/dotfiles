<agent_allocation>
Primary: researcher
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research and create a structured implementation prompt for converting three Claude Code commands into native skills.

The three commands to convert are:
1. `/Users/kd/.claude/commands/create-prompt.md` - Creates research/implementation prompts
2. `/Users/kd/.claude/commands/run-prompt.md` - Executes prompts with agents
3. `/Users/kd/.claude/commands/workflow.md` - Orchestrates the full workflow

Your goal is to thoroughly investigate how to convert these command files into native Claude Code skills while preserving 100% of the workflow functionality.
</objective>

<research_objective>
Investigate:
- Claude Code skill structure and best practices (frontmatter, directory layout)
- Differences between commands and skills (invocation patterns, argument handling)
- How to invoke agents from skills using the Task tool
- How to replace MCP server dependency with native skill functionality
- Best practices for skill organization (single skill vs multiple skills)
- How to handle file operations and prompt management within skills
- Tool availability and permissions in skills vs commands
</research_objective>

<research_scope>
Sources to prioritize:
- Context7 for Claude Code documentation on skills
- Existing skills in `/Users/kd/.claude/skills/` for patterns
- Example plugins in `/Users/kd/.claude/plugins/` for reference
- Current command files in `/Users/kd/.claude/commands/`
- Current agent definitions in `/Users/kd/.claude/agents/`

Focus on:
- Skill frontmatter structure (name, description, allowed-tools)
- Skill directory structure (SKILL.md, references/, scripts/, assets/)
- Agent invocation patterns using Task tool
- File path resolution in skill context
- State management across skill invocations
</research_scope>

<prompt_requirements>
The structured prompt you create MUST include:

1. **XML tag structure** with clear semantic tags:
   - <agent_allocation> - Assign to fullstack-developer
   - <objective> - Clear statement of what needs to be done
   - <context> - Why this matters, what we're converting from/to
   - <requirements> - Specific functional requirements for each skill
   - <constraints> - What to preserve, what can change
   - <output> - File paths and directory structure
   - <success_criteria> - How to verify the skills work

2. **Explicit instructions** - Tell the fullstack-developer exactly what to do

3. **File paths** - Use absolute paths since these are user-level configs:
   - `/Users/kd/.claude/skills/prompt-workflow/SKILL.md`
   - `/Users/kd/.claude/skills/create-prompt/SKILL.md`
   - `/Users/kd/.claude/skills/run-prompt/SKILL.md`
   - Reference directories as needed

4. **Preserved functionality**:
   - Prompt creation with auto mode
   - Agent invocation (researcher, fullstack-developer)
   - Prompt file management (.agent/prompts/[branch]/)
   - Sequential and parallel prompt execution
   - Pre-implementation confirmation flow
   - Workflow state management

5. **Success criteria**:
   - Skills invoke correctly via /skill-name
   - Agent spawning via Task tool works
   - Prompt files created/read/deleted properly
   - Workflow orchestration maintained
   - No MCP server dependency required
</prompt_requirements>

<output>
Save your structured implementation prompt to:
`.agent/prompts/main/002-implement-prompt-workflow-skills.md`

Use the next available number after this research task file.

The prompt file should contain ONLY the structured prompt for fullstack-developer,
no preamble or metadata.
</output>

<success_criteria>
Your research is complete when:
- You understand the structural differences between commands and skills
- You've identified how to handle $ARGUMENTS in skill context
- You know how to invoke agents via Task tool from skills
- You've determined the optimal skill structure (single vs multiple skills)
- You've documented any breaking changes or behavioral differences
- A complete, executable prompt is written for fullstack-developer
- The prompt includes clear file paths and success criteria
</success_criteria>
