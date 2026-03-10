# Prompt Engineer

Create effective prompts using XML tag structuring for Claude Code.

## User Request
The user wants: $ARGUMENTS

## Core Process

<thinking>
1. Clarity: Colleague understand this? Missing context/requirements?
2. Complexity: Simple/trivial or complex (research needed)?
3. Research needed: New tech, patterns, best practices?
4. Direct implementation: Well-defined, no research?
5. Prompt depth: Concise or comprehensive?
6. Verification: Error checking needed?
7. Project context: Codebase patterns needed?
8. Prompt quality: "Go beyond basics"? Explain WHY? Examples?
</thinking>

## Workflow

User Request → create-prompt → research-agent-lite → fullstack-agent

Flow: Clarify? → Research? → Direct?

## Interaction

**Step 1: Clarify** (if needed)

"I'll create a prompt. Let me clarify:

1. [ambiguity]
2. [constraints]
3. What for? Who uses it?
4. Example of [aspect]?

Answer or say 'continue'."

**Step 2: Confirm**

"I'll create research task: [summary]

Creates prompt at: .agent/prompts/[branch]/[number]-[name].md

Proceed?"

**Step 3: Generate Task**

Save to: `.agent/prompts/[branch]/[number]-research-[topic].md`

Get branch: `!git branch --show-current` (fallback: main)
Next number: check existing files

## Research Task Template

```xml
<agent_allocation>
Primary: research-agent-lite
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>

<objective>
Research and create implementation prompt for: [task]

Create well-structured prompt for fullstack-agent execution.
</objective>

<research_objective>
Investigate:
- Required information
- Key questions
- Technical areas
- Best practices
- Approaches and trade-offs
</research_objective>

<research_scope>
Sources: Context7 (docs), web-search-prime (community), web-reader (pages), codebase (patterns)

Focus: libraries, frameworks, security, performance
</research_scope>

<prompt_requirements>
Structured prompt MUST include:

1. **XML tags**: <agent_allocation>, <objective>, <context>, <requirements>, <constraints>, <output>, <success_criteria>

2. **Explicit instructions**: Exact actions for fullstack-agent

3. **File paths**: Relative like `./src/components/Button.svelte`

4. **Success criteria**: Measurable completion criteria

5. **Verification**: How to confirm solution works
</prompt_requirements>

<output>
Save to: `.agent/prompts/[branch]/[number]-[name].md`

Next number after research task file.

Content: ONLY structured prompt (no preamble)
</output>

<success_criteria>
Complete when:
- Key questions answered
- Approaches evaluated
- Best practices identified
- Executable prompt created
- Success criteria included
</success_criteria>
```

## Direct Implementation (Rare)

For trivial tasks: typos, single-line changes, obvious implementations.

Skip research-agent-lite when:
- Unambiguous, straightforward
- No research needed
- Approach obvious
- Minimal change

**Direct template:**

```xml
<agent_allocation>
Primary: fullstack-agent
Workflow: direct-implementation
</agent_allocation>

<objective>
[What to do]
</objective>

<context>
[Why, tech stack]
</context>

<requirements>
[Specific requirements]
</requirements>

<output>
Files:
- `./path/to/file.ext` - [action]
</output>

<success_criteria>
[Verify completion]
</success_criteria>
```

## Agent-Aware Prompt Construction

### Always Include

- XML tags with semantic structure
- **Agent allocation**: Which agent handles this
- **Context**: Why matters, what for, who uses
- **Explicit instructions**: Exact actions
- **File output**: Relative paths from working dir
- **Success criteria**: Measurable completion

### Research Tasks

```xml
<agent_allocation>
Primary: research-agent-lite
Output: structured implementation prompt
Workflow: research-to-prompt
</agent_allocation>
```

### Direct Implementation

```xml
<agent_allocation>
Primary: fullstack-agent
Workflow: direct-implementation
</agent_allocation>
```

### Conditionally Include

- Extended thinking (complex reasoning)
- "Go beyond basics" (creative/ambitious)
- WHY explanations (constraints)
- Parallel tool calling (agentic)
- MCP server refs (beneficial)
- Examples (ambiguous requirements)

## File Naming

**Research tasks:** `[number]-research-[topic].md` → `.agent/prompts/[branch]/`

**Implementation prompts:** `[number]-[name].md` → `.agent/prompts/[branch]/`

**Numbering:** Sequential (001, 002, 003...) - check existing files

## Meta Instructions

- Clarify before generating
- Detect branch: `!git branch --show-current` (fallback: main)
- Create folder: `!mkdir -p .agent/prompts/[branch]/completed/`
- Next number: check existing files
- Descriptive but concise names
- Adapt XML structure
- Relative paths from working dir

## Clarification Examples

- "Build dashboard" → What kind? What data? Who?
- "Fix bug" → Describe it? Expected vs actual?
- "Add auth" → What type? Which providers? Context?
- "Optimize performance" → What issues? Metrics?
- "Create report" → Who for? What will they do?

## Decision Tree

After creating research task:

---

**Research task created!**

<presentation>
✓ Saved to .agent/prompts/[branch]/[number]-research-[topic].md

research-agent-lite will:
1. Investigate topic
2. Create structured prompt
3. Save to .agent/prompts/[branch]/[number+1]-[name].md

Next?

1. Run research-agent-lite now
2. Review/edit first
3. Other

Choose (1-3): _
</presentation>

<action>
If #1: research-agent-lite executes, creates implementation prompt.
Then: "research-agent-lite created prompt at .agent/prompts/[branch]/[number+1]-[name].md

Run fullstack-agent to execute?"
</action>

---
