# PRD Generator

Generate a new Product Requirements Document (PRD) from a user prompt.

## User Request

The user wants to create a PRD for: $ARGUMENTS

## Process

<thinking>
1. **Extract PRD name**: From user prompt, create a concise, hyphenated name
2. **Generate category**: Based on the prompt, categorize the PRD (e.g., "feature", "bugfix", "refactor", "docs", "test", "performance", "security")
3. **Create description**: Summarize the task in 1-2 sentences
4. **Generate steps**: Break down the task into clear, actionable steps
5. **Initialize passes**: Set to false (will be updated during implementation)
</thinking>

## Workflow

1. **Parse user prompt** to understand the task requirements
2. **Clairify** by asking any questions if needed
3. **Research** to understand code, get documentation, compare implementation apporaches. Use reserach-agent-lite, and if required, loop back to step 2 before proceding to step 4.
4. **Determine next PRD number** by checking existing files in `.agent/prd/`
5. **Extract PRD name** - create a concise, hyphenated name from the prompt
6. **Generate PRD content**:
   - category: Appropriate category based on task type
   - description: Clear summary of what needs to be done
   - steps: List of actionable steps to complete the task
   - passes: false (initial state)
7. **Create files**:
   - `./.agent/prd/{number}-prd-{name}.json` - PRD specification
   - `./.agent/prd/{number}-prd-{name}-progress.txt` - Progress tracking
8. **Confirm creation** with user

## PRD JSON Schema

```json
{
  "category": "string",
  "description": "string",
  "steps": ["string"],
  "passes": "boolean"
}
```

## Categories

Use these categories:
- **feature**: New functionality or capabilities
- **bugfix**: Fixing reported issues or bugs
- **refactor**: Code restructuring without changing behavior
- **docs**: Documentation improvements
- **test**: Adding or improving tests
- **performance**: Optimizations and performance improvements
- **security**: Security enhancements
- **ci/cd**: Build/deployment infrastructure
- **chore**: Maintenance tasks

## File Naming

PRD files use the format: `{number}-prd-{name}.json` and `{number}-prd-{name}-progress.txt`

PRD name should:
- Be lowercase
- Use hyphens instead of spaces
- Be concise but descriptive
- Avoid special characters
- Example: "user-authentication" from "add user authentication feature"

Number format:
- Zero-padded 3-digit numbers: 001, 002, 003, etc.
- Numbers are sequential based on creation order
- Next number determined by checking existing PRD files in `.agent/prd/`

## File Creation Steps

<step1_determine_next_number>
Determine the next PRD number:

1. List existing PRD files in `.agent/prd/`: `!ls .agent/prd/*.json 2>/dev/null || echo "none"`
2. Extract numbers from filenames using pattern: `{number}-prd-`
3. Find the highest number, or start at 0 if no files exist
4. Next number = highest number + 1
5. Format as zero-padded 3-digit number (001, 002, etc.)

<examples>
- No files: next number is 001
- Files: 001-prd-*.json, 002-prd-*.json → next number is 003
- Files: 001-prd-*.json only → next number is 002
</examples>
</step1_determine_next_number>

<step2_generate_prd_name>
From $ARGUMENTS, extract or generate a PRD name:

Rules:
- Convert to lowercase
- Replace spaces with hyphens
- Remove special characters
- Keep it concise (2-4 words typical)
- Example: "add user authentication" → "user-authentication"

If the prompt contains an explicit name in quotes, use that.
Otherwise, generate a descriptive name from the task description.
</step2_generate_prd_name>

<step3_generate_prd_content>
Generate the PRD JSON content:

1. **category**: Analyze the task and assign appropriate category
2. **description**: Write 1-2 sentence summary of what needs to be done
3. **steps**: Break down into 3-10 clear, actionable steps
   - Each step should be specific and measurable
   - Start with action verbs (Create, Implement, Fix, Update, etc.)
   - Order logically (dependencies first)
4. **passes**: Set to false (implementation not yet started)

<example_prd>
```json
{
  "category": "feature",
  "description": "Implement user authentication with JWT tokens and refresh mechanism",
  "steps": [
    "Set up authentication API endpoints",
    "Implement JWT token generation and validation",
    "Create user session management with refresh tokens",
    "Add authentication middleware for protected routes",
    "Implement login and logout functionality",
    "Write unit tests for authentication logic"
  ],
  "passes": false
}
```
</example_prd>
</step2_generate_prd_content>

<step4_create_files>
Create both files:

1. **PRD JSON file**: `./.agent/prd/{number}-prd-{name}.json`
   - Contains the PRD specification with category, description, steps, and passes
   - Use proper JSON formatting with 2-space indentation

2. **Progress file**: `./.agent/prd/{number}-prd-{name}-progress.txt`
   - Initially contains: "Progress tracking for PRD: {name}\n\nStatus: Not started"
   - Will be updated during implementation
</step4_create_files>

<step5_confirm_creation>
Display confirmation message:

---

**PRD created successfully!**

✓ PRD file: `./.agent/prd/{number}-prd-{name}.json`
✓ Progress file: `./.agent/prd/{number}-prd-{name}-progress.txt`

**PRD Summary:**
- Number: {number}
- Category: {category}
- Description: {description}
- Steps: {number} steps

**Next steps:**
1. Review the PRD content and edit if needed
2. Run `@command/prd-run {number}` to start implementation
3. Track progress in the progress file

---

</step5_confirm_creation>

## Meta Instructions

- Extract PRD name from $ARGUMENTS
- Determine next PRD number by checking existing files in `.agent/prd/`
- Use AI reasoning to generate appropriate category, description, and steps
- Create directories if they don't exist: `!mkdir -p .agent/prd`
- Create passes directory for completed PRDs: `!mkdir -p .agent/prd/passes`
- Files must be created in `./.agent/prd` directory
- Progress file should be plain text, not JSON
- All file paths use relative paths from working directory
- JSON files should be properly formatted with 2-space indentation
- Number format is zero-padded 3 digits (001, 002, 003...)

## Error Handling

- If PRD file already exists, prompt user to confirm overwrite
- If directory creation fails, report error to user
- If prompt is empty or too vague, ask for clarification

## Examples

**Example 1: Feature request**

Input: "Add user authentication with JWT"

PRD number: 001 (first PRD)
PRD name: "user-authentication-jwt"
Files created:
- `.agent/prd/001-prd-user-authentication-jwt.json`
- `.agent/prd/001-prd-user-authentication-jwt-progress.txt`

```json
{
  "category": "feature",
  "description": "Implement user authentication using JSON Web Tokens for secure API access",
  "steps": [
    "Set up authentication API endpoints (login, logout, refresh)",
    "Implement JWT token generation and validation middleware",
    "Create user session management with token refresh mechanism",
    "Add authentication guards for protected routes",
    "Implement password hashing and validation",
    "Write tests for authentication flows"
  ],
  "passes": false
}
```

**Example 2: Bug fix**

Input: "Fix memory leak in data processing"

PRD number: 002 (second PRD)
PRD name: "memory-leak-fix"
Files created:
- `.agent/prd/002-prd-memory-leak-fix.json`
- `.agent/prd/002-prd-memory-leak-fix-progress.txt`

```json
{
  "category": "bugfix",
  "description": "Resolve memory leak occurring during data processing operations",
  "steps": [
    "Identify source of memory leak in data processing code",
    "Add proper cleanup for resources and event listeners",
    "Implement connection pooling for database operations",
    "Add memory monitoring and logging",
    "Test with large datasets to verify fix",
    "Add regression tests for memory usage"
  ],
  "passes": false
}
```

**Example 3: Documentation**

Input: "Create API documentation for user module"

PRD number: 003 (third PRD)
PRD name: "api-documentation-user"
Files created:
- `.agent/prd/003-prd-api-documentation-user.json`
- `.agent/prd/003-prd-api-documentation-user-progress.txt`

```json
{
  "category": "docs",
  "description": "Create comprehensive API documentation for user module endpoints",
  "steps": [
    "Document all user module endpoints",
    "Add request/response examples for each endpoint",
    "Include authentication requirements",
    "Document error codes and responses",
    "Add usage examples in multiple languages",
    "Review and validate documentation"
  ],
  "passes": false
}
```

## Implementation Notes

- Use clear, action-oriented language in steps
- Steps should be atomic - each step should be independently completable
- Order steps to reflect dependencies
- Include testing steps as appropriate
- Keep descriptions concise but informative
- Category selection should be accurate based on the primary intent of the task
