<agent_allocation>
Primary: fullstack-developer
Workflow: directory-reorganization
</agent_allocation>

<objective>
Reorganize three prompt-workflow skills from flat structure to nested directory structure with intelligent root router.

Transform the current flat structure:
```
/Users/kd/.claude/skills/create-prompt/SKILL.md
/Users/kd/.claude/skills/run-prompt/SKILL.md
/Users/kd/.claude/skills/workflow/SKILL.md
```

Into a nested structure:
```
/Users/kd/.claude/skills/prompt-workflow/
├── SKILL.md              # Root: Router/orchestrator
├── create-prompt/
│   └── SKILL.md         # Sub-skill: Prompt creation
├── run-prompt/
│   └── SKILL.md         # Sub-skill: Prompt execution
└── workflow/
    └── SKILL.md         # Sub-skill: End-to-end orchestration
```
</objective>

<context>
**Why we're reorganizing:**
- Better organization: Group related prompt-workflow functionality under single namespace
- Cleaner skills directory: Reduce clutter from three separate root-level skills
- Intelligent routing: Add root SKILL.md that routes user requests to appropriate sub-skill
- Maintainability: Easier to manage and extend prompt-workflow capabilities

**Current functionality to preserve:**
- create-prompt: Expert prompt engineer that creates optimized, XML-structured prompts
- run-prompt: Execute prompts from .agent/prompts/ as delegated sub-tasks
- workflow: Master orchestrator for end-to-end research and implementation workflows

**Key insight from research:**
Claude Code supports nested skill structures. Sub-skills are independently invocable and don't need modifications when nested. The root SKILL.md acts as an intelligent router based on user intent detection.

Research findings: `/Users/kd/dotfiles/claude/.claude/.agent/research/nested-skill-structure-research.md`
</context>

<requirements>
1. **Create directory structure**
   - Create `/Users/kd/.claude/skills/prompt-workflow/` directory
   - Create three subdirectories: `create-prompt/`, `run-prompt/`, `workflow/`

2. **Move existing SKILL.md files**
   - Move `/Users/kd/.claude/skills/create-prompt/SKILL.md` → `/Users/kd/.claude/skills/prompt-workflow/create-prompt/SKILL.md`
   - Move `/Users/kd/.claude/skills/run-prompt/SKILL.md` → `/Users/kd/.claude/skills/prompt-workflow/run-prompt/SKILL.md`
   - Move `/Users/kd/.claude/skills/workflow/SKILL.md` → `/Users/kd/.claude/skills/prompt-workflow/workflow/SKILL.md`
   - DO NOT modify the content of these files

3. **Create root router SKILL.md**
   - Create `/Users/kd/.claude/skills/prompt-workflow/SKILL.md`
   - Implement intelligent routing based on user intent detection
   - Include overview of the prompt-workflow system
   - Reference/link to all three sub-skills

4. **Root router requirements:**
   - **Intent detection:** Analyze user requests and route to appropriate sub-skill
   - **create-prompt triggers:** "create prompt", "make a prompt", "generate prompt", "craft prompt", "build a prompt for"
   - **run-prompt triggers:** "run prompt", "execute prompt", "launch prompt", specific prompt numbers (e.g., "prompt 001", "run 005")
   - **workflow triggers:** "workflow for", "create workflow", "help me implement", "research and build", complex tasks requiring research + implementation
   - **Fallback behavior:** If intent is unclear, ask clarifying question offering all three options
   - **Allowed tools:** Bash, Read, Write, Glob, Task

5. **Root router SKILL.md structure:**
   ```markdown
   ---
   name: prompt-workflow
   description: [clear description of the orchestrator]
   allowed-tools: Bash, Read, Write, Glob, Task
   ---

   # Prompt Workflow Orchestrator

   [Quick start overview]

   ## Routing Logic
   [Intent detection patterns]

   ## Sub-Skill Capabilities
   [Brief description of each sub-skill]

   ## Direct Sub-Skill Invocation
   [Explain users can still invoke sub-skills directly]

   [Error handling and fallback behavior]
   ```

6. **Preserve backward compatibility**
   - Sub-skills must remain independently invocable
   - All existing functionality must work unchanged
   - No modifications to sub-skill SKILL.md content

7. **Cleanup after migration**
   - Remove empty old directories: `/Users/kd/.claude/skills/create-prompt/`, `/Users/kd/.claude/skills/run-prompt/`, `/Users/kd/.claude/skills/workflow/`
   - Only after verifying nested structure works correctly
</requirements>

<constraints>
- DO NOT modify the content of existing SKILL.md files when moving them
- DO NOT break existing functionality - all three sub-skills must work as before
- DO NOT remove old directories until after successful testing
- The root router MUST provide intelligent routing, not just a static overview
- The root router MUST ask for clarification when intent is ambiguous
- Follow the pattern proven by existing nested skills: `/research`, `/svelte`, `/nextjs`, `/webapp-testing`
</constraints>

<output>
Create/modify files:
- `/Users/kd/.claude/skills/prompt-workflow/SKILL.md` - Root router with intelligent intent detection and routing
- `/Users/kd/.claude/skills/prompt-workflow/create-prompt/SKILL.md` - Moved from existing location (unchanged)
- `/Users/kd/.claude/skills/prompt-workflow/run-prompt/SKILL.md` - Moved from existing location (unchanged)
- `/Users/kd/.claude/skills/prompt-workflow/workflow/SKILL.md` - Moved from existing location (unchanged)

Remove after verification:
- `/Users/kd/.claude/skills/create-prompt/` - Remove empty directory after successful migration
- `/Users/kd/.claude/skills/run-prompt/` - Remove empty directory after successful migration
- `/Users/kd/.claude/skills/workflow/` - Remove empty directory after successful migration
</output>

<success_criteria>
Implementation is complete when:

1. **Directory structure created:**
   - `/Users/kd/.claude/skills/prompt-workflow/` exists
   - Contains root `SKILL.md` and three subdirectories

2. **Sub-skills moved:**
   - All three SKILL.md files moved to nested locations
   - File contents unchanged from originals

3. **Root router functional:**
   - Routes to create-prompt when detecting "create prompt", "make a prompt", etc.
   - Routes to run-prompt when detecting "run prompt", "execute", prompt numbers
   - Routes to workflow when detecting "workflow for", "help me implement", etc.
   - Asks for clarification when intent is ambiguous

4. **Sub-skills independently invocable:**
   - Each sub-skill can be invoked directly by name
   - All existing functionality preserved
   - No breaking changes

5. **Cleanup complete:**
   - Old empty directories removed
   - No orphaned files or directories

6. **Verification:**
   - Test invocation of each sub-skill independently
   - Test root router with various request patterns
   - Test ambiguous requests trigger clarification
   - Confirm backward compatibility maintained
</success_criteria>
