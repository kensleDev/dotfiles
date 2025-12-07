# Research-First Task Execution

## Overview

This command implements a research-first workflow where tasks are first analyzed by the researcher agent to gather necessary information, then handed off to the appropriate specialist agent for implementation.

## Usage

```bash
/research-task "Implement JWT authentication for Next.js app"
/research-task "Optimize database queries for user dashboard" --agent=database-specialist
/research-task "Add real-time notifications with WebSockets"
```

## Process Flow

### Step 1: Research Phase (Researcher Agent)

The researcher agent will:

- Analyze the task requirements
- Research best practices and patterns using context7 MCP and websearch
- Investigate any technical dependencies or constraints
- Document findings and recommendations
- Identify the appropriate specialist agent for implementation

### Step 2: Implementation Phase (Specialist Agent)

Based on research findings, the task is delegated to the appropriate specialist:

- `fullstack-specialist` for fullstack features
- `react-nextjs-specialist` for React/Next.js work
- `typescript-expert` for TypeScript-related tasks
- `database-specialist` for database work
- `security-specialist` for security implementations
- `performance-specialist` for performance optimization
- `devops-specialist` for infrastructure/deployment
- `ui-ux-designer` for design work
- `qa-test-specialist` for testing strategies
- `accessibility-specialist` for accessibility work

## Implementation

### Parse Arguments

Parse the `$ARGUMENTS` to extract:

- Task description (all text before any flags)
- Target agent (from `--agent=<name>` flag)
- Optional parameters (if any in the future)

### Research Phase Execution

1. Invoke the researcher agent with the task description
2. Provide context about available specialist agents
3. Request research on:
   - Best practices for the task
   - Technical requirements and dependencies
   - Potential implementation approaches
   - Recommended tools and patterns
   - Any security or performance considerations

### Specialist Selection

If no agent is specified via `--agent`, let the researcher determine the most appropriate specialist based on:

- Task complexity and requirements
- Technical domain
- Project context
- Implementation considerations

If an agent is specified, the researcher should validate that it's the appropriate choice and provide research findings tailored for that specialist.

### Implementation Phase Execution

1. Load the selected specialist agent definition
2. Provide the research findings as context
3. Execute the task with the specialist's toolset
4. Monitor implementation progress
5. Ensure successful task completion

## Output Format

### Research Phase Output

```
🔍 Research Phase Started
Task: [task description]
Agent: researcher

📚 Research Findings:
[Detailed research findings from researcher agent]

🎯 Recommended Specialist: [agent-name]
Reasoning: [why this specialist is recommended]

🔧 Implementation Requirements:
[Key requirements for implementation phase]

---
```

### Implementation Phase Output

```
🛠️ Implementation Phase Started
Task: [task description]
Agent: [specialist-agent-name]
Research Findings Applied: [summary of key research insights]

📋 Implementation Progress:
[Progress updates from specialist agent]

✅ Task Completed
[Summary of completed work]

📊 Quality Checks:
[Validation results, test results, etc.]

🔗 Related Files:
[List of files modified/created]

---
```

## Error Handling

If the researcher identifies issues that prevent task completion:

1. Clearly explain the blocking issues
2. Suggest alternative approaches
3. Recommend additional research if needed
4. Allow the user to adjust the task or constraints

If the specialist encounters implementation challenges:

1. Attempt to resolve using available tools and research findings
2. If additional research is needed, request it from the researcher
3. Provide clear feedback on what needs to be adjusted

## Integration Points

### With Task Files

If working within a task management system:

1. Check if the task corresponds to an existing task file
2. Update task file with research findings and progress
3. Mark task as complete upon successful implementation

### With Documentation

1. Save research findings to appropriate documentation location
2. Update project documentation with new patterns or approaches
3. Create or update API documentation if applicable

### With Testing

1. Ensure appropriate tests are created or updated
2. Run test suites to validate implementation
3. Document any testing considerations or requirements

## Example Execution

For the command: `/research-task "Implement JWT authentication for Next.js app"`

### Expected Research Phase Output

```
🔍 Research Phase Started
Task: Implement JWT authentication for Next.js app
Agent: researcher

📚 Research Findings:
- JWT best practices recommend short-lived access tokens (15-30 min) with refresh tokens
- Next.js API routes最适合处理JWT令牌验证
- 推荐使用NextAuth.js库简化实现
- 安全考虑包括：HTTPS only cookies、CSRF保护、安全的令牌存储

🎯 Recommended Specialist: fullstack-specialist
Reasoning: Authentication spans frontend, backend, and database layers requiring fullstack expertise

🔧 Implementation Requirements:
- Next.js API routes for token endpoints
- Database schema for user sessions and refresh tokens
- Frontend authentication context
- Secure cookie configuration
- TypeScript types for authentication state

---
```

### Expected Implementation Phase Output

```
🛠️ Implementation Phase Started
Task: Implement JWT authentication for Next.js app
Agent: fullstack-specialist
Research Findings Applied: Used NextAuth.js with refresh token pattern

📋 Implementation Progress:
- Created authentication API routes (/api/auth/*)
- Updated database schema with sessions table
- Implemented authentication context provider
- Added protected route middleware
- Configured secure HTTP-only cookies

✅ Task Completed
Successfully implemented JWT authentication system with NextAuth.js. Includes secure token handling, refresh token rotation, and comprehensive TypeScript types.

📊 Quality Checks:
- All authentication endpoints tested
- Token validation working correctly
- Security headers properly configured
- TypeScript types included throughout

🔗 Related Files:
- /pages/api/auth/[...nextauth].ts
- /lib/auth.ts
- /pages/api/auth/token.ts
- /components/providers/AuthProvider.tsx
- /middleware.ts
- /prisma/schema.prisma

---
```
