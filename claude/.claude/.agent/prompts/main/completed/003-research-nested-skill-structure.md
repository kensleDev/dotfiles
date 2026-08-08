<agent_allocation>
Primary: researcher
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research and create a structured implementation prompt for reorganizing three prompt-workflow skills into a nested folder structure with a root SKILL.md router.

Current structure:
```
/Users/kd/.claude/skills/create-prompt/SKILL.md
/Users/kd/.claude/skills/run-prompt/SKILL.md
/Users/kd/.claude/skills/workflow/SKILL.md
```

Target structure:
```
/Users/kd/.claude/skills/prompt-workflow/
├── SKILL.md (root - orchestrator/router)
├── create-prompt/
│   └── SKILL.md
├── run-prompt/
│   └── SKILL.md
└── workflow/
│   └── SKILL.md
```

Your goal is to design a root SKILL.md that intelligently routes user requests to the appropriate sub-skill while maintaining all existing functionality.
</objective>

<research_objective>
Investigate:
- How Claude Code discovers and loads nested skills
- Best practices for root SKILL.md patterns in multi-skill directories
- How to implement intelligent routing based on user intent detection
- Whether sub-skills need different frontmatter or naming when nested
- How to preserve backward compatibility with existing skill invocations
- Examples of nested skill structures in `/Users/kd/.claude/skills/` or plugins
</research_objective>

<research_scope>
Sources to prioritize:
- Existing nested skill examples in `/Users/kd/.claude/skills/`
- Plugin examples in `/Users/kd/.claude/plugins/` with nested structures
- Current three skill files to understand functionality to preserve
- Context7 for Claude Code skill discovery patterns

Focus on:
- Root SKILL.md routing patterns
- Sub-skill invocation from parent skill
- Allowed-tools inheritance or specification
- Directory structure conventions
</research_scope>

<prompt_requirements>
The structured prompt you create MUST include:

1. **XML tag structure** with clear semantic tags:
   - <agent_allocation> - Assign to fullstack-developer
   - <objective> - Clear statement of what needs to be done
   - <context> - Why we're reorganizing (better organization, cleaner namespace)
   - <requirements> - Specific functional requirements
   - <constraints> - What must be preserved
   - <output> - File paths and directory structure
   - <success_criteria> - How to verify it works

2. **Root SKILL.md requirements**:
   - Intelligent routing: detect user intent and route to appropriate sub-skill
   - Fallback behavior: what to do if intent is unclear
   - Overview of the prompt-workflow system
   - Links/references to sub-skills
   - Should it call sub-skills directly or provide guidance?

3. **Preserved functionality**:
   - All three sub-skills must work as before
   - Users should be able to invoke specific sub-skills
   - Root should intelligently route based on request type

4. **File paths**:
   - `/Users/kd/.claude/skills/prompt-workflow/SKILL.md` (root)
   - `/Users/kd/.claude/skills/prompt-workflow/create-prompt/SKILL.md`
   - `/Users/kd/.claude/skills/prompt-workflow/run-prompt/SKILL.md`
   - `/Users/kd/.claude/skills/prompt-workflow/workflow/SKILL.md`

5. **Success criteria**:
   - Root skill intelligently routes requests
   - Sub-skills remain functional
   - Clean namespace (prompt-workflow/*)
   - No functionality loss
</prompt_requirements>

<output>
Save your structured implementation prompt to:
`.agent/prompts/main/004-implement-nested-prompt-workflow-skills.md`

Use the next available number after this research task file.

The prompt file should contain ONLY the structured prompt for fullstack-developer,
no preamble or metadata.
</output>

<success_criteria>
Your research is complete when:
- You understand how Claude Code handles nested skill structures
- You've identified the best pattern for root SKILL.md routing
- You know whether sub-skills need modifications when nested
- You've documented the routing logic for the root skill
- A complete, executable prompt is written for fullstack-developer
- The prompt includes clear file paths and success criteria
</success_criteria>
