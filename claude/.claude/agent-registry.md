---
name: agent-registry
description: Registry of available distilled agents with their capabilities and use cases
---

# Agent Registry

## Available Agents

### Researcher
- **File**: `agents/researcher.md`
- **Role**: Expert research investigator
- **Specialties**: Technical documentation research, problem investigation, information gathering
- **Tools**: WebSearch, WebFetch, Context7 MCP, Svelte MCP, shadcn-ui MCP
- **Use When**: Need to investigate, research best practices, understand new technologies
- **Primary Workflows**:
  - Investigation → Implementation
  - Problem → Research → Fix
  - New Technology → Research → Integrate

### Fullstack Specialist
- **File**: `agents/fullstack-specialist.md`
- **Role**: End-to-end fullstack expert
- **Specialties**: Node.js backends, API design, database architecture, frontend integration
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Building complete features from database to UI
- **Integration Partners**: typescript-expert, database-specialist, security-specialist

### TypeScript Expert
- **File**: `agents/typescript-expert.md`
- **Role**: TypeScript language specialist
- **Specialties**: Advanced TypeScript patterns, type safety, generic programming
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Complex TypeScript implementations, type definitions, generic patterns
- **Integration Partners**: All agents for type safety

### React Next.js Specialist
- **File**: `agents/react-nextjs-specialist.md`
- **Role**: React and Next.js framework expert
- **Specialties**: Component development, Next.js features, React patterns
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: React/Next.js specific implementations, component architecture
- **Integration Partners**: ui-ux-designer, typescript-expert, fullstack-specialist

### Database Specialist
- **File**: `agents/database-specialist.md`
- **Role**: Database architecture and optimization expert
- **Specialties**: Schema design, query optimization, migrations
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Database schema changes, query optimization, data architecture
- **Integration Partners**: performance-specialist, fullstack-specialist

### Security Specialist
- **File**: `agents/security-specialist.md`
- **Role**: Security implementation and audit expert
- **Specialties**: Authentication, authorization, security best practices
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Security implementations, vulnerability assessments, authentication systems
- **Integration Partners**: fullstack-specialist, devops-specialist

### Performance Specialist
- **File**: `agents/performance-specialist.md`
- **Role**: Performance optimization expert
- **Specialties**: Application optimization, profiling, benchmarking
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Performance issues, optimization needs, bottleneck analysis
- **Integration Partners**: database-specialist, fullstack-specialist

### DevOps Specialist
- **File**: `agents/devops-specialist.md`
- **Role**: Infrastructure and deployment expert
- **Specialties**: CI/CD, containerization, cloud infrastructure
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Infrastructure setup, deployment pipelines, automation
- **Integration Partners**: security-specialist, fullstack-specialist

### UI/UX Designer
- **File**: `agents/ui-ux-designer.md`
- **Role**: User interface and experience design expert
- **Specialties**: Component design, user flows, design systems
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: UI component design, user experience improvements, design systems
- **Integration Partners**: react-nextjs-specialist, accessibility-specialist

### QA Test Specialist
- **File**: `agents/qa-test-specialist.md`
- **Role**: Quality assurance and testing expert
- **Specialties**: Test strategy, test implementation, quality assurance
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Test implementation, quality assurance, test strategies
- **Integration Partners**: All agents for comprehensive testing

### Accessibility Specialist
- **File**: `agents/accessibility-specialist.md`
- **Role**: Web accessibility expert
- **Specialties**: ARIA implementation, accessibility compliance, inclusive design
- **Tools**: Read, Write, Edit, Bash, Glob, Grep
- **Use When**: Accessibility implementation, compliance checks, inclusive design
- **Integration Partners**: ui-ux-designer, react-nextjs-specialist

## Agent Selection Guide

### Research-First Workflows
These patterns start with researcher for investigation, then delegate to specialists:

| Task Type | Research Focus | Primary Specialist | Secondary Agents |
|-----------|----------------|---------------------|------------------|
| New technology implementation | Technology evaluation, best practices | domain-specific specialist | typescript-expert |
| Bug investigation | Root cause analysis, solution research | domain-specific specialist | qa-test-specialist |
| Performance issues | Bottleneck analysis, optimization techniques | performance-specialist | domain-specific specialist |
| Security implementation | Security best practices, vulnerability research | security-specialist | fullstack-specialist |
| Complex feature development | Architecture patterns, integration approaches | fullstack-specialist | relevant domain specialists |

### Direct Specialist Workflows
These patterns can go directly to specialists without initial research:

| Task Type | Primary Specialist | When to Use |
|-----------|-------------------|-------------|
| TypeScript type definitions | typescript-expert | Clear typing requirements |
| Database schema implementation | database-specialist | Schema already designed |
| UI component from design | ui-ux-designer | Design specifications available |
| Test implementation | qa-test-specialist | Features already implemented |
| Deployment pipeline setup | devops-specialist | Infrastructure requirements known |
| Security audit | security-specialist | Existing system to review |

### Multi-Agent Collaboration Patterns

**Full Feature Development**:
```
researcher → fullstack-specialist → typescript-expert → qa-test-specialist
```

**Performance Optimization**:
```
performance-specialist → researcher → domain-specialist → qa-test-specialist
```

**Security Implementation**:
```
security-specialist → researcher → fullstack-specialist → qa-test-specialist
```

**UI Component Development**:
```
ui-ux-designer → react-nextjs-specialist → typescript-expert → accessibility-specialist
```

## Agent Capabilities Matrix

| Agent | Research | Implementation | Testing | Architecture | Optimization | Security |
|-------|----------|----------------|---------|--------------|--------------|----------|
| researcher | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐⭐ | ⭐ | ⭐⭐ |
| fullstack-specialist | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| typescript-expert | ⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐ | ⭐ | ⭐ |
| react-nextjs-specialist | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| database-specialist | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| security-specialist | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ |
| performance-specialist | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| devops-specialist | ⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ |
| ui-ux-designer | ⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ | ⭐ | ⭐ |
| qa-test-specialist | ⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐ |
| accessibility-specialist | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐ | ⭐ |

Legend: ⭐ = Limited, ⭐⭐ = Basic, ⭐⭐⭐ = Good, ⭐⭐⭐⭐ = Strong, ⭐⭐⭐⭐⭐ = Expert

## Common Task → Agent Mappings

| Task Description | Recommended Agent(s) | Workflow |
|------------------|----------------------|----------|
| "Add user authentication" | researcher → security-specialist → fullstack-specialist | Research → Security → Implementation |
| "Optimize slow queries" | researcher → database-specialist | Research → Database Optimization |
| "Create reusable component" | ui-ux-designer → react-nextjs-specialist | Design → Implementation |
| "Fix TypeScript errors" | typescript-expert | Direct Implementation |
| "Set up CI/CD pipeline" | devops-specialist | Direct Implementation |
| "Audit security vulnerabilities" | security-specialist → researcher | Security Review → Research |
| "Implement real-time features" | researcher → fullstack-specialist | Research → Implementation |
| "Add comprehensive testing" | qa-test-specialist → domain-specialist | Test Strategy → Domain Testing |
| "Improve page load speed" | performance-specialist → researcher | Performance Analysis → Research |
| "Ensure WCAG compliance" | accessibility-specialist → ui-ux-designer | Accessibility Audit → Design Updates |
