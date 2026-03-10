<agent_allocation>
Primary: research-agent-lite
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research and create a structured implementation prompt for: {{TASK}}

Your goal is to thoroughly investigate this topic and create a well-structured prompt
that the fullstack-agent agent can execute to implement this feature/fix/change.
</objective>

<research_objective>
Investate:
- {{RESEARCH_AREAS}}
- {{KEY_QUESTIONS}}
- {{TECHNICAL_AREAS}}
- {{BEST_PRACTICES}}
- {{POTENTIAL_APPROACHES}}
</research_objective>

<research_scope>
Sources to prioritize:
- Context7 for official documentation
- web-search-prime for community knowledge
- web-reader for specific documentation pages
- Existing codebase for patterns

Focus on:
- {{LIBRARIES}}
- {{FRAMEWORK_PATTERNS}}
- {{SECURITY_PERFORMANCE}}
</research_scope>

<prompt_requirements>
The structured prompt you create MUST include:

1. **XML tag structure** with clear semantic tags:
   - <agent_allocation> - Assign to fullstack-agent
   - <objective> - Clear statement of what needs to be done
   - <context> - Why this matters, who it's for, tech stack
   - <requirements> - Specific functional requirements
   - <constraints> - What to avoid and WHY
   - <output> - File paths and content descriptions
   - <success_criteria> - How to verify completion

2. **Explicit instructions** - Tell the fullstack-agent exactly what to do

3. **File paths** - Use relative paths like `./src/components/Button.svelte`

4. **Success criteria** - Clear, measurable criteria for completion

5. **Verification steps** - How to confirm the solution works
</prompt_requirements>

<output>
Save your structured implementation prompt to:
`.agent/prompts/{{BRANCH}}/{{NEXT_NUMBER}}-{{FILENAME}}.md`

Use the next available number after this research task file.

The prompt file should contain ONLY the structured prompt for fullstack-agent,
no preamble or metadata.
</output>

<success_criteria>
Your research is complete when:
- All key questions about implementation are answered
- Multiple approaches have been considered and evaluated
- Best practices for the tech stack are identified
- A complete, executable prompt is written for fullstack-agent
- The prompt includes clear success criteria and verification steps
</success_criteria>
