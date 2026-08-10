--- SYSTEM PROMPT ---

Let's create a new prd:

**NOTE** the .agent folder lives in the current projects root

- Get the current count from .agent/prd/control/count.txt and increment it by 1 to get the new prd number, create it if it doesn't exist and set to 001
- Create the new files:
  .agent/prd/{count}-prd.json
  .agent/prd/{count}-prd-progress.txt (blank file)
- Update the count in .agent/prd/control/session-loop.md to reflect the new prd number. It session-loop doesn't exist create it with the following content:

`
@.agent/prd/001-prd.json @.agent/prd/001-prd-progress.txt

1. Decide which task to work on next. \
   This should be the one YOU decide has the highest priority,

- not necessarily the first in the list.

1. Check any feedback loops, such as types and tests. \
2. Append your progress to the progress.txt file. \
3. Make a git commit of that feature. \
   ONLY WORK ON A SINGLE FEATURE AT A TIME. \
4. Use the fullstack agent to execute tasks. ALL TASKS to be delegated preserve as much context in the main thread as possible.
5. If work is parallelizable, \
   delegate to other sub-agents as needed. \
6. When finished the feature, look for the next highest priority task and repeat without stopping \
   If, while implementing the feature, you notice that all work \
   is complete, output <promise >COMPLETE </promise >.
`

- Once the prd has been create output the above session-loop in the output for the user to copy

## Research

If the users hasn't specified, ask if they want to run the research agent before we create the tasks for extra context

If needed ask clarification questions before and after research. Keep asking questions until you feel you have a good grasp of the users intent but if you have enough information to confidently execute the prd then stop asking / don't ask.

## Task Extraction Process

**CRITICAL**: When the user's plan contains phases/sections, you must:

1. **Ignore phase headers** - These are organizational labels, NOT tasks
2. **Extract checklist items** - Each `[ ]` checkbox becomes a separate PRD item
3. **Break down each item** - EVERY PRD item must have sub-tasks in its `tasks` array
4. **Use nested items if provided** - If the user has indented/nested checkboxes, use those
5. **Create logical sub-tasks if not** - If there are no nested items, break the description into 2-4 logical steps

Example transformation:

```
## Phase 1: Setup
- [ ] Install shadcn/ui CLI
- [ ] Extract Porsche color palette from website
  - [ ] Primary colors (reds, blacks, grays)
  - [ ] Secondary/accent colors
```

Should become TWO PRD items (BOTH with populated tasks arrays):

```json
[
  {
    "category": "Setup",
    "description": "Install shadcn/ui CLI",
    "tasks": [
      {
        "task": "Run npm install command for shadcn/ui",
        "context": "Install the CLI tool globally or as dev dependency"
      },
      {
        "task": "Verify installation successful",
        "context": "Check that shadcn-ui command is available"
      }
    ],
    "passes": false
  },
  {
    "category": "Setup",
    "description": "Extract Porsche color palette from website",
    "tasks": [
      {
        "task": "Extract primary colors (reds, blacks, grays)",
        "context": "These are the main brand colors from the Porsche website"
      },
      {
        "task": "Extract secondary/accent colors",
        "context": "Supporting colors used for highlights and accents"
      }
    ],
    "passes": false
  }
]
```

**NEVER do this:**

```json
[
  {
    "category": "Setup",
    "description": "Install shadcn/ui CLI",
    "tasks": [], // ❌ WRONG - tasks array must never be empty
    "passes": false
  }
]
```

## PRD Format

```json
[
  {
    "category": "", // Use the phase/section name
    "description": "", // Use the specific checklist item text
    "tasks": [
      // REQUIRED - must have at least 1 task, preferably 2-4
      {
        "task": "", // Specific sub-action
        "context": "" // Additional details, reasoning, or clarification
      }
    ],
    "passes": false
  }
]
```

## Task Breakdown Rules

- ✅ **EVERY PRD item MUST have tasks in its array** - no exceptions
- ✅ If the user provides nested items, use those as tasks
- ✅ If no nested items exist, break the description into logical implementation steps
- ✅ Aim for 2-4 tasks per PRD item
- ✅ Each task should be a concrete, actionable step
- ❌ **NEVER leave tasks array empty**
- ❌ NOT a phase summary or grouping

---

## USER PROMPT

{
