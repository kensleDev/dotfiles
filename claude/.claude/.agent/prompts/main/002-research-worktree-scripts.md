<agent_allocation>
Primary: researcher
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research and create a structured implementation prompt for: Creating bash scripts to automate the worktree-manager workflow for faster execution and reduced LLM computation overhead.

Your goal is to thoroughly investigate the existing worktree-manager skill and create a well-structured prompt that the fullstack-developer agent can execute to implement bash scripts that handle most of the computation, with a thin LLM layer for integration and decision-making.
</objective>

<research_objective>
Investigate:
1. **Existing worktree-manager skill analysis** - Review all scripts in `skills/worktree-manager/scripts/` to understand current implementation
2. **LLM vs Bash responsibility split** - Identify which operations should be automated in bash vs. controlled by LLM
3. **Script consolidation opportunities** - Can multiple scripts be consolidated? What new scripts are needed?
4. **Error handling patterns** - How to handle errors gracefully when LLM is thin layer
5. **Package manager detection** - How to robustly detect and handle different package managers
6. **Dev server detection** - How to detect and start dev servers across different project types
7. **Validation patterns** - How to perform health checks across different project types
8. **Configuration management** - How to handle project-specific config vs. defaults
9. **Parallel execution** - How to handle multiple worktree creation in parallel
10. **Integration with LLM** - How the bash scripts will report status and interact with Claude Code

Key questions to answer:
- What operations are slow when handled by LLM but fast in bash?
- What decision-making must remain with LLM (user intent, project-specific settings, error recovery)?
- How should the bash scripts structure their output for LLM consumption?
- What error handling should be in bash vs. LLM?
- How to make the scripts idempotent and safe?
</research_objective>

<research_scope>
Sources to prioritize:
- **Existing codebase**: `skills/worktree-manager/scripts/*` - all bash scripts
- **Existing codebase**: `skills/worktree-manager/SKILL.md` - full skill documentation
- **Existing codebase**: `skills/worktree-manager/config.json` - config structure
- **Context7**: Search for best practices in bash script design and error handling
- **web-search-prime**: Search for bash script patterns for git worktrees, port management, and process management

Focus on:
- Bash best practices for error handling (`set -euo pipefail`, trap handlers)
- Git worktree operations and edge cases
- Port management and conflict detection
- Package manager detection across multiple ecosystems
- Dev server detection and health check patterns
- Process management (starting/stopping servers)
- JSON manipulation with jq for registry management
- Terminal launching patterns (tmux, ghostty, iterm2)
- Script modularity and reusability
- Idempotency in bash scripts
</research_scope>

<prompt_requirements>
The structured prompt you create MUST include:

1. **XML tag structure** with clear semantic tags:
   - <agent_allocation> - Assign to fullstack-developer
   - <objective> - Clear statement of what needs to be done
   - <context> - Why this matters, who it's for, tech stack
   - <requirements> - Specific functional requirements
   - <responsibility_split> - Clear delineation between bash and LLM responsibilities
   - <output> - File paths and content descriptions
   - <success_criteria> - How to verify completion

2. **Explicit instructions** - Tell the fullstack-developer exactly what to do:
   - What scripts to create in `skills/worktree-scripts/`
   - How each script should work
   - What the LLM integration layer should do
   - Error handling requirements
   - Output format requirements

3. **File paths** - Use relative paths like:
   - `skills/worktree-scripts/create-worktree.sh`
   - `skills/worktree-scripts/SKILL.md`
   - `skills/worktree-scripts/config.json`

4. **Success criteria** - Clear, measurable criteria for completion:
   - Scripts must be executable and idempotent
   - Error handling must be comprehensive
   - Output must be machine-parseable for LLM consumption
   - Integration layer must be thin and focused on decision-making

5. **Verification steps** - How to confirm the solution works:
   - Test script execution with various scenarios
   - Test error handling paths
   - Test parallel worktree creation
   - Test across different package managers and project types

6. **Implementation guidance**:
   - Script consolidation strategy (merge existing scripts where sensible)
   - New script requirements
   - Output format standards (JSON for machine readability)
   - Error message formats
   - Exit codes and their meanings
   - Logging and debug modes
</prompt_requirements>

<output>
Save your structured implementation prompt to:
`.agent/prompts/main/002-worktree-scripts.md`

The prompt file should contain ONLY the structured prompt for fullstack-developer, no preamble or metadata.
</output>

<success_criteria>
Your research is complete when:
- All existing worktree-manager scripts have been analyzed
- Clear distinction between bash and LLM responsibilities is defined
- New script architecture is designed with consolidation opportunities identified
- Error handling patterns for bash scripts are researched
- Output format requirements for LLM consumption are defined
- A complete, executable prompt is written for fullstack-developer
- The prompt includes clear success criteria and verification steps
- The prompt specifies how scripts will handle parallel execution
- Integration patterns between bash and LLM are clearly defined
</success_criteria>
