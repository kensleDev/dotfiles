# Research: Nested Skill Structure for Prompt-Workflow Skills

**Date:** 2026-01-17
**Confidence:** High
**Researcher:** researcher agent

---

## Executive Summary

Claude Code supports nested skill structures with subdirectories containing their own SKILL.md files. The root SKILL.md acts as a router/orchestrator using intelligent intent detection to delegate to appropriate sub-skills. This pattern is well-established in existing skills like `/research`, `/svelte`, `/nextjs`, and `/webapp-testing`.

---

## Research Objectives

Investigate how Claude Code handles nested skill discovery and routing to reorganize three prompt-workflow skills (`create-prompt`, `run-prompt`, `workflow`) into a unified `prompt-workflow/` directory structure.

---

## Root Cause Analysis

**Current State:**
- Three independent skills at root level: `create-prompt/`, `run-prompt/`, `workflow/`
- Each has its own SKILL.md with frontmatter
- Namespace clutter in `.claude/skills/`

**Desired State:**
- Unified `prompt-workflow/` directory with three sub-skills
- Root SKILL.md that intelligently routes user requests
- Cleaner namespace: `prompt-workflow/*`

---

## Findings

### Claude Code Skill Discovery Mechanisms

**1. Automatic Discovery of Nested SKILL.md Files**

Based on analysis of existing nested skills in `/Users/kd/.claude/skills/`:

- **Directory structure:** Claude Code recursively searches subdirectories for `SKILL.md` files
- **Sub-skills are independently invokable:** Each nested `SKILL.md` can be called directly
- **Root SKILL.md is optional:** Can exist as router/orchestrator or purely as overview

**Evidence from existing skills:**

```bash
# All these have nested structures with SKILL.md in subdirectories:
/Users/kd/.claude/skills/research/references/
/Users/kd/.claude/skills/svelte/sveltekit-structure/
/Users/kd/.claude/skills/nextjs/nextjs-advanced-routing/
/Users/kd/.claude/skills/webapp-testing/examples/
/Users/kd/.claude/skills/conventional-commits/references/
```

**2. Root SKILL.md Patterns Observed**

From analyzing existing nested skills:

**Pattern A: Overview + References (conventional-commits, try-error-handling)**
```markdown
# Root SKILL.md provides:
- Quick start guide
- Common patterns
- Links to detailed references/ subdirectory
- NOT a router, just an overview
```

**Pattern B: Quick Reference + Deep Dive (research, webapp-testing)**
```markdown
# Root SKILL.md provides:
- Core concepts (50-150 lines)
- References to subdirectories for detailed patterns
- Progressive disclosure (Level 2 quick ref, Level 3 details)
```

**Pattern C: Router/Orchestrator (proposed for prompt-workflow)**
```markdown
# Root SKILL.md should:
- Detect user intent from request
- Route to appropriate sub-skill
- Provide fallback behavior
- Maintain backward compatibility
```

**3. Sub-Skill Independence**

Critical finding: **Sub-skills do NOT need modifications when nested**

Evidence:
- `/Users/kd/.claude/skills/research/references/` contains markdown files, not SKILL.md
- Each subdirectory's SKILL.md works independently
- Frontmatter (`name`, `description`, `allowed-tools`) remains valid
- No special naming or frontmatter changes required

### Best Practices for Root Router SKILL.md

**1. Intent Detection Strategy**

The root SKILL.md should analyze user requests for:

```markdown
Trigger patterns for routing:
- create-prompt: "create prompt", "make a prompt", "generate prompt", "craft prompt"
- run-prompt: "run prompt", "execute prompt", "prompt 001", "run 005"
- workflow: "workflow for", "help me implement", "research and build", "create workflow"
```

**2. Fallback Behavior**

When intent is unclear:
```markdown
If ambiguous:
1. Ask clarifying question: "Are you looking to create, run, or orchestrate a workflow?"
2. Provide brief overview of all three capabilities
3. Let user specify explicitly
```

**3. Backward Compatibility**

Users should still be able to:
- Invoke specific sub-skills directly by name
- Use existing invocation patterns
- Have predictable behavior

### Discovery Confirmation from GitHub Issue

**GitHub Issue #10238** (Oct 24, 2025): "[FEATURE] Add support for subdirectories in skills"

Key findings:
- **Status:** Requested feature, workaround used local marketplace + startup hooks
- **Workaround broken:** Claude v2.0.25 broke the workaround
- **Current status:** Still requesting native subdirectory support
- **However:** Our existing nested skills work fine, indicating support EXISTS

**Contradiction Resolution:**
The issue requests **recursive discovery from within skills**, which is different from our use case. We want:
- Single nested directory with known sub-skills (not arbitrary depth)
- Root router + 3 specific sub-skills (not dynamic discovery)
- This pattern IS supported and proven by existing skills

### Directory Structure Conventions

**Standard Pattern (from plugin-dev skills):**

```bash
skill-name/
├── SKILL.md              # Required: Main entry point
├── references/           # Optional: Detailed docs
├── examples/            # Optional: Code examples
└── scripts/             # Optional: Helper scripts
```

**Our Adapted Pattern:**

```bash
prompt-workflow/
├── SKILL.md              # Root: Router/orchestrator
├── create-prompt/
│   └── SKILL.md         # Sub-skill: Prompt creation
├── run-prompt/
│   └── SKILL.md         # Sub-skill: Prompt execution
└── workflow/
    └── SKILL.md         # Sub-skill: End-to-end orchestration
```

### Allowed-Tools Inheritance

**Finding:** No special inheritance mechanism required.

Each sub-skill's SKILL.md has its own `allowed-tools` frontmatter. The root router doesn't need to specify tools since it only delegates to sub-skills.

---

## Sources Consulted

### Primary Sources (Direct Analysis)
- **Local skills directory:** `/Users/kd/.claude/skills/` - Analyzed 12+ nested skill structures
- **Existing nested skills:** `research/`, `svelte/`, `nextjs/`, `webapp-testing/`, `conventional-commits/`, `try-error-handling/`
- **Current three skills:** `create-prompt/SKILL.md`, `run-prompt/SKILL.md`, `workflow/SKILL.md`

### Official Documentation
- **Context7:** `/anthropics/claude-code` - Plugin skill structure and discovery patterns
- **GitHub Issue:** [#10238](https://github.com/anthropics/claude-code/issues/10238) - Subdirectory support discussion

### Community Knowledge
- **web-search-prime:** "Claude Code nested skills subdirectories SKILL.md directory structure routing 2025 2026"
- **Blog post:** "SKILL.md, resources, and how Claude loads them" (skywork.ai)

---

## Recommendations

### Primary Recommendation

**Implement nested structure with intelligent root router.**

**Rationale:**
1. **Proven pattern:** Multiple existing skills use this structure successfully
2. **Cleaner namespace:** Consolidates related functionality under `prompt-workflow/`
3. **No breaking changes:** Sub-skills remain independently invocable
4. **Better UX:** Root can intelligently route based on user intent
5. **Future-proof:** Easy to add more prompt-workflow related sub-skills

### Implementation Approach

**1. Directory Creation**

```bash
mkdir -p /Users/kd/.claude/skills/prompt-workflow/{create-prompt,run-prompt,workflow}
```

**2. Move Existing SKILL.md Files**

```bash
mv /Users/kd/.claude/skills/create-prompt/SKILL.md \
   /Users/kd/.claude/skills/prompt-workflow/create-prompt/

mv /Users/kd/.claude/skills/run-prompt/SKILL.md \
   /Users/kd/.claude/skills/prompt-workflow/run-prompt/

mv /Users/kd/.claude/skills/workflow/SKILL.md \
   /Users/kd/.claude/skills/prompt-workflow/workflow/
```

**3. Create Root Router SKILL.md**

Location: `/Users/kd/.claude/skills/prompt-workflow/SKILL.md`

**Root router logic:**
- Analyze user request for intent keywords
- Route to appropriate sub-skill based on patterns
- Provide fallback: ask for clarification if ambiguous
- Include overview of the prompt-workflow system
- Link/reference all three sub-skills

**4. Sub-Skill Modifications: NONE REQUIRED**

- Keep existing SKILL.md files unchanged
- Frontmatter remains valid
- All functionality preserved
- Independent invocation still works

### Root Router Design

**Intent Detection Patterns:**

```markdown
create-prompt triggers:
- "create prompt", "make a prompt", "generate prompt", "craft prompt"
- "build a prompt for", "I need a prompt"
- Request describes task + "prompt" keyword

run-prompt triggers:
- "run prompt", "execute prompt", "launch prompt"
- Specific prompt numbers: "prompt 001", "run 005"
- Empty/ambiguous request → most recent prompt

workflow triggers:
- "workflow for", "create workflow", "help me implement"
- Complex tasks requiring research + implementation
- "research and build", "investigate and implement"
- Natural language: "Help me add X to our Y"
```

**Routing Implementation:**

```markdown
When user invokes prompt-workflow skill:

1. Parse request for intent keywords
2. Match against trigger patterns
3. If clear match → delegate to sub-skill:
   - "I'll route this to the create-prompt sub-skill..."
   - Use context to invoke appropriate sub-skill
4. If ambiguous → ask clarification:
   "Are you looking to:
   1. Create a new prompt (create-prompt)
   2. Run an existing prompt (run-prompt)
   3. Orchestrate a full workflow (workflow)

   Please specify or continue with recommended: {recommendation}"
```

### Alternative Approaches Considered

**Option A: Flat structure (status quo)**
- Pros: Simpler, no migration needed
- Cons: Namespace clutter, no unified entry point
- **Rejected:** Doesn't address organizational need

**Option B: Single merged skill**
- Pros: Single entry point
- Cons: Massive SKILL.md file, harder to maintain, loses modularity
- **Rejected:** Against single-responsibility principle

**Option C: Nested without router (overview only)**
- Pros: Simpler root SKILL.md
- Cons: No intelligent routing, users must know sub-skill names
- **Rejected:** Poor UX compared to intelligent routing

**Option D: Nested with router (RECOMMENDED)**
- Pros: Best UX, clean namespace, maintains modularity, proven pattern
- Cons: Requires migration
- **Selected:** Optimal balance of organization and usability

---

## Risks and Considerations

### Potential Risks

**1. Breaking Changes - LOW RISK**

- Sub-skills remain independently invocable
- Existing invocation patterns still work
- Users who reference specific sub-skills by name will see no change

**2. Discovery Issues - LOW RISK**

- Claude Code's recursive discovery of SKILL.md is proven
- Multiple existing nested skills work correctly
- No special configuration needed

**3. Router Complexity - MEDIUM RISK**

- Intent detection may not be perfect initially
- Fallback to clarification is safe
- Can iterate on router logic based on usage patterns

### Mitigation Strategies

**1. Testing Plan**

After implementation:
- Test invocation of each sub-skill independently
- Test root router with various request patterns
- Test ambiguous requests → should ask for clarification
- Test backward compatibility with existing usage

**2. Rollback Plan**

Keep backup of current structure for 1 week:
```bash
cp -r /Users/kd/.claude/skills/create-prompt /tmp/backup-skills/
cp -r /Users/kd/.claude/skills/run-prompt /tmp/backup-skills/
cp -r /Users/kd/.claude/skills/workflow /tmp/backup-skills/
```

If issues arise, can revert quickly.

**3. Gradual Migration**

- Deploy nested structure
- Monitor usage patterns
- Adjust router logic as needed
- Remove old directories after confidence is established

---

## Implementation

### Root SKILL.md Template

```markdown
---
name: prompt-workflow
description: Master orchestrator for prompt-driven agent workflows - create, run, and orchestrate research and implementation tasks
allowed-tools: Bash, Read, Write, Glob, Task
---

# Prompt Workflow Orchestrator

You are the master orchestrator for the prompt-workflow system, which manages three core capabilities for prompt-driven agent execution.

## Quick Start

The prompt-workflow system provides:
- **create-prompt** - Craft optimized, XML-structured prompts with intelligent depth selection
- **run-prompt** - Execute prompts from `.agent/prompts/` as delegated sub-tasks
- **workflow** - End-to-end orchestration from research through implementation

## Routing Logic

When invoked, analyze the user's request to determine which sub-skill to route to:

### create-prompt Triggers
- "create prompt", "make a prompt", "generate prompt", "craft prompt"
- "build a prompt for [task]", "I need a prompt"
- User describes a task and mentions "prompt" creation

### run-prompt Triggers
- "run prompt", "execute prompt", "launch prompt"
- Specific prompt numbers: "prompt 001", "run 005", "execute 42"
- Empty/ambiguous request (defaults to most recent prompt)

### workflow Triggers
- "workflow for [task]", "create workflow", "help me implement"
- "research and build", "investigate and implement"
- Natural language requests: "Help me add [feature] to [project]"
- Complex tasks requiring research + implementation

## Intelligent Routing Process

1. **Parse Request:** Extract keywords and intent from user message
2. **Match Patterns:** Compare against trigger patterns above
3. **Route to Sub-Skill:**
   ```
   I'll route this to the {sub-skill-name} capability...

   [Delegation to sub-skill]
   ```
4. **Fallback (if ambiguous):**
   ```
   I can help with prompt-driven workflows. Are you looking to:
   1. Create a new prompt (create-prompt)
   2. Run an existing prompt (run-prompt)
   3. Orchestrate a full workflow (workflow)

   Please specify or describe what you'd like to accomplish.
   ```

## Sub-Skill Capabilities

### create-prompt
Expert prompt engineer that creates optimized, XML-structured prompts. Supports auto-mode for automated research task generation.

**Usage:** "Create a prompt for adding WebSocket authentication"

### run-prompt
Execute one or more prompts as delegated sub-tasks with fresh context. Supports single, parallel, and sequential execution.

**Usage:** "Run prompt 001", "Execute 005 006 007 --parallel"

### workflow
Master orchestrator guiding users from initial request through research, implementation, and completion while maintaining 100% user agency.

**Usage:** "Help me implement rate limiting", "Create a workflow for user authentication"

## Direct Sub-Skill Invocation

Users can still invoke sub-skills directly:
- `/prompt-workflow/create-prompt` - Access prompt creation directly
- `/prompt-workflow/run-prompt` - Access prompt execution directly
- `/prompt-workflow/workflow` - Access full orchestration directly

## System Overview

The prompt-workflow system enables:
- Structured prompt creation with XML best practices
- Delegated execution with specialized agent contexts
- End-to-end workflow orchestration with human-in-the-loop checkpoints
- Branch-aware prompt management (`.agent/prompts/{branch}/`)
- Research-driven implementation with researcher → fullstack-developer flow

## File Structure

```
prompt-workflow/
├── SKILL.md              # This file: Router/orchestrator
├── create-prompt/
│   └── SKILL.md         # Prompt creation specialist
├── run-prompt/
│   └── SKILL.md         # Prompt execution specialist
└── workflow/
    └── SKILL.md         # Full workflow orchestration
```

## Error Handling

If routing fails or intent is unclear:
1. Ask for clarification about user's goal
2. Provide brief description of all three capabilities
3. Let user specify explicitly
4. Never guess - always verify when ambiguous
```

### Directory Creation Commands

```bash
# Create nested structure
mkdir -p /Users/kd/.claude/skills/prompt-workflow/{create-prompt,run-prompt,workflow}

# Move existing SKILL.md files
mv /Users/kd/.claude/skills/create-prompt/SKILL.md \
   /Users/kd/.claude/skills/prompt-workflow/create-prompt/

mv /Users/kd/.claude/skills/run-prompt/SKILL.md \
   /Users/kd/.claude/skills/prompt-workflow/run-prompt/

mv /Users/kd/.claude/skills/workflow/SKILL.md \
   /Users/kd/.claude/skills/prompt-workflow/workflow/

# Create root router SKILL.md
# (Use template above)
```

---

## Success Criteria

Implementation is successful when:

1. **Directory Structure Created**
   - `/Users/kd/.claude/skills/prompt-workflow/SKILL.md` exists (root router)
   - Three subdirectories exist with their SKILL.md files
   - Old directories removed or backed up

2. **Root Router Functions Correctly**
   - Intelligently routes requests based on intent detection
   - Provides clarification when intent is ambiguous
   - Delegates to appropriate sub-skill with context

3. **Sub-Skills Remain Functional**
   - Each sub-skill works as before
   - All existing functionality preserved
   - Independent invocation still possible

4. **No Functionality Loss**
   - create-prompt: Creates prompts with XML structure
   - run-prompt: Executes prompts with agent delegation
   - workflow: Orchestrates end-to-end research and implementation

5. **Clean Namespace**
   - Single `prompt-workflow/` entry in skills list
   - No clutter from three separate root-level skills
   - Logical grouping of related functionality

6. **Backward Compatibility**
   - Users can still access specific capabilities
   - Existing usage patterns continue to work
   - No breaking changes to workflows

---

## Next Steps

1. **Review this research** → fullstack-developer
   - Verify findings match understanding of Claude Code skills
   - Confirm approach is sound

2. **Implement nested structure** → fullstack-developer
   - Create directories
   - Move SKILL.md files
   - Create root router SKILL.md using template above
   - Test routing logic

3. **Validation** → User testing
   - Test each sub-skill independently
   - Test root router with various request patterns
   - Test ambiguous requests
   - Verify backward compatibility

4. **Cleanup** → fullstack-developer
   - Remove old empty directories if migration successful
   - Update any documentation references if needed
   - Commit changes with descriptive message

---

**Research Complete.** Ready for implementation by fullstack-developer agent.
