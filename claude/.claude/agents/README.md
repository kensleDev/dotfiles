# Distilled Agent Framework

A focused collection of 11 specialized agents optimized for fullstack web development with React, Next.js, Svelte, and SvelteKit.

## Overview

This distilled agent framework consolidates 116 agents into 11 essential specialists, reducing complexity by 90% while maintaining comprehensive coverage for modern fullstack development needs.

### Design Philosophy

- **Focused Expertise**: Each agent covers a specific domain deeply
- **Zero Overlap**: No redundant functionality between agents
- **Fullstack Optimized**: Tailored for React/Next.js/Svelte web applications
- **Modern Stack**: Covers TypeScript, Node.js, PostgreSQL, and modern tooling
- **Production Ready**: Focus on security, performance, and quality

## Agent Catalog

### 🎯 Core Development (5 agents)

#### 1. **fullstack-specialist**
**Merged from:** fullstack-developer, backend-developer, api-designer

**Expertise:**
- End-to-end feature development (database → API → UI)
- Node.js backend with TypeScript
- RESTful API design and implementation
- Database architecture and migrations
- Authentication & authorization (OAuth2, JWT)
- Real-time features (WebSockets)

**Use when:**
- Building complete features across the stack
- Designing API architectures
- Implementing authentication systems
- Integrating frontend with backend

---

#### 2. **react-nextjs-specialist**
**Merged from:** frontend-developer, react-specialist, nextjs-developer

**Expertise:**
- React 18+ (hooks, Suspense, Server Components)
- Next.js 14+ App Router
- Server-side rendering & static generation
- Performance optimization & Core Web Vitals
- SEO and metadata optimization
- Component architecture

**Use when:**
- Building React applications
- Implementing Next.js features
- Optimizing frontend performance
- Creating reusable component libraries
- Implementing SSR/SSG strategies

---

#### 3. **typescript-expert**
**Merged from:** typescript-pro, javascript-pro

**Expertise:**
- TypeScript 5+ advanced type system
- Full-stack type safety
- Modern JavaScript ES2023+
- Generic programming & type inference
- Build optimization
- tRPC for end-to-end type safety

**Use when:**
- Designing type-safe APIs
- Creating complex type definitions
- Optimizing TypeScript build performance
- Sharing types across frontend/backend
- Migrating JavaScript to TypeScript

---

#### 4. **database-specialist**
**Merged from:** database-optimizer, database-administrator, sql-pro

**Expertise:**
- PostgreSQL & MySQL optimization
- Complex SQL queries & optimization
- Prisma & Drizzle ORM
- Database design & migrations
- Query performance tuning
- Connection pooling & caching

**Use when:**
- Designing database schemas
- Optimizing slow queries
- Setting up database infrastructure
- Implementing migrations
- Troubleshooting N+1 query problems

---

#### 5. **ui-ux-designer**
**Merged from:** ui-designer

**Expertise:**
- Design systems & component libraries
- Visual design & typography
- Responsive design patterns
- Accessibility (WCAG 2.1)
- Figma to code handoff
- Dark mode & theming

**Use when:**
- Creating design systems
- Designing component specifications
- Ensuring visual consistency
- Planning responsive layouts
- Defining design tokens

---

### 🛠️ Quality & Operations (4 agents)

#### 6. **qa-test-specialist**
**Merged from:** qa-expert, test-automator, code-reviewer

**Expertise:**
- Jest/Vitest unit testing
- React Testing Library
- Playwright/Cypress E2E testing
- Code review & quality standards
- Test automation & CI/CD
- Coverage analysis

**Use when:**
- Writing test suites
- Reviewing code quality
- Setting up CI/CD testing
- Achieving test coverage goals
- Debugging test failures

---

#### 7. **devops-specialist**
**Merged from:** devops-engineer, deployment-engineer, cloud-architect (partial)

**Expertise:**
- Vercel & Netlify deployments
- GitHub Actions CI/CD
- Docker & containerization
- Environment management
- Database hosting & migrations
- Monitoring & error tracking

**Use when:**
- Setting up deployment pipelines
- Configuring environments
- Implementing CI/CD workflows
- Troubleshooting deployment issues
- Optimizing build times

---

#### 8. **security-specialist**
**Merged from:** security-auditor, security-engineer, penetration-tester (partial)

**Expertise:**
- OWASP Top 10 protection
- Authentication (OAuth, JWT, NextAuth)
- Input validation & sanitization
- XSS/CSRF prevention
- Security headers & CSP
- Secrets management

**Use when:**
- Auditing security vulnerabilities
- Implementing authentication
- Securing APIs
- Configuring security headers
- Reviewing sensitive data handling

---

#### 9. **performance-specialist**
**Merged from:** performance-engineer, debugger, error-detective

**Expertise:**
- Core Web Vitals optimization
- Bundle size reduction
- React performance optimization
- Database query optimization
- Caching strategies
- Performance monitoring

**Use when:**
- Improving page load times
- Optimizing Core Web Vitals
- Reducing bundle sizes
- Fixing performance bottlenecks
- Implementing caching

---

### ♿ Specialized Support (2 agents)

#### 10. **accessibility-specialist**
**Keep as-is:** accessibility-tester

**Expertise:**
- WCAG 2.1 AA/AAA compliance
- Screen reader compatibility
- Keyboard navigation
- ARIA implementation
- Inclusive design
- Accessibility testing

**Use when:**
- Auditing accessibility
- Implementing WCAG compliance
- Testing with screen readers
- Ensuring keyboard navigation
- Creating inclusive designs

---

#### 11. **researcher**
**New agent:** Research and investigation specialist

**Expertise:**
- Technical documentation research
- Multi-source information gathering
- Root cause analysis
- Best practices research
- API documentation exploration
- Library/framework evaluation
- MCP documentation tools (Context7, Svelte, shadcn/ui)
- Solution comparison and recommendation

**Use when:**
- Investigating complex errors or bugs
- Researching new libraries or frameworks
- Finding best practices for implementation
- Evaluating different technical approaches
- Understanding third-party API integrations
- Researching performance optimization techniques
- Analyzing security vulnerabilities
- Understanding migration paths

---

## Quick Start

### Selecting the Right Agent

**For building features:**
1. **Planning phase** → fullstack-specialist
2. **Frontend implementation** → react-nextjs-specialist
3. **Backend implementation** → fullstack-specialist
4. **Database work** → database-specialist
5. **Type safety** → typescript-expert

**For quality & deployment:**
1. **Testing** → qa-test-specialist
2. **Code review** → qa-test-specialist
3. **Deployment** → devops-specialist
4. **Security audit** → security-specialist
5. **Performance** → performance-specialist
6. **Accessibility** → accessibility-specialist

**For design:**
1. **Design system** → ui-ux-designer
2. **Component specs** → ui-ux-designer
3. **Responsive design** → ui-ux-designer

**For investigation & research:**
1. **Debugging issues** → researcher
2. **Evaluating libraries** → researcher
3. **API documentation** → researcher
4. **Best practices** → researcher

### Agent Collaboration

Agents frequently work together:

**Building a new feature:**
1. **fullstack-specialist** → Designs API and data model
2. **database-specialist** → Optimizes schema and queries
3. **typescript-expert** → Creates shared types
4. **react-nextjs-specialist** → Implements UI
5. **qa-test-specialist** → Writes tests
6. **security-specialist** → Reviews security
7. **devops-specialist** → Deploys to production

**Fixing performance issues:**
1. **performance-specialist** → Identifies bottlenecks
2. **researcher** → Researches optimization techniques
3. **database-specialist** → Optimizes queries
4. **react-nextjs-specialist** → Optimizes components
5. **devops-specialist** → Configures CDN/caching

**Investigating a bug:**
1. **researcher** → Investigates error, finds root cause
2. **fullstack-specialist** → Implements fix
3. **qa-test-specialist** → Adds regression tests
4. **security-specialist** → Reviews security implications (if applicable)

**Evaluating a new library:**
1. **researcher** → Compares options, recommends solution
2. **typescript-expert** → Sets up types and configuration
3. **react-nextjs-specialist** → Integrates into application
4. **qa-test-specialist** → Tests integration

## Technology Stack Coverage

### Frontend
- ✅ React 18+
- ✅ Next.js 14+ (App Router, Server Components)
- ✅ Svelte & SvelteKit
- ✅ TypeScript 5+
- ✅ Tailwind CSS
- ✅ Component libraries (shadcn/ui, Radix UI)

### Backend
- ✅ Node.js 20+
- ✅ Express, Fastify, Hono
- ✅ tRPC for type-safe APIs
- ✅ NextAuth for authentication
- ✅ WebSockets for real-time

### Database
- ✅ PostgreSQL
- ✅ MySQL
- ✅ Prisma ORM
- ✅ Drizzle ORM
- ✅ Redis for caching

### Testing
- ✅ Jest & Vitest
- ✅ React Testing Library
- ✅ Playwright
- ✅ Cypress

### DevOps
- ✅ Vercel
- ✅ Netlify
- ✅ Docker
- ✅ GitHub Actions
- ✅ Environment management

### Quality
- ✅ ESLint & Prettier
- ✅ TypeScript strict mode
- ✅ WCAG 2.1 accessibility
- ✅ OWASP Top 10 security
- ✅ Core Web Vitals

## Not Included (Intentionally Removed)

The following were removed as they're not essential for fullstack web development:

### Removed Language Specialists
- Python, Go, Rust, Java, C#, PHP specialists
- Mobile-specific frameworks (Flutter, Swift, Kotlin)
- Desktop frameworks (Electron - unless you need it)

### Removed Infrastructure
- Kubernetes (overkill for most web apps)
- Terraform (can use platform UIs)
- SRE & Platform Engineering (covered by devops-specialist)

### Removed Domains
- Blockchain, IoT, Game development
- Data Science, ML/AI specialists
- Fintech-specific agents

### Removed Orchestration
- Multi-agent coordinators
- Meta-agents

### Removed Business Roles
- Product managers, business analysts
- Legal, sales, marketing specialists

**Note:** If you need any of these, you can still access the original 116-agent framework in the parent directories.

## Migration Guide

### From Old Framework

| Old Agent | New Agent | Notes |
|-----------|-----------|-------|
| frontend-developer | react-nextjs-specialist | Focus on React/Next.js |
| backend-developer | fullstack-specialist | Includes API design |
| api-designer | fullstack-specialist | Merged into fullstack |
| typescript-pro | typescript-expert | Includes JS expertise |
| javascript-pro | typescript-expert | TypeScript superset |
| database-optimizer | database-specialist | Comprehensive DB agent |
| database-administrator | database-specialist | Merged |
| sql-pro | database-specialist | Merged |
| qa-expert | qa-test-specialist | Includes code review |
| test-automator | qa-test-specialist | Merged |
| code-reviewer | qa-test-specialist | Merged |
| devops-engineer | devops-specialist | Includes deployment |
| deployment-engineer | devops-specialist | Merged |
| security-auditor | security-specialist | Comprehensive security |
| performance-engineer | performance-specialist | Includes debugging |
| accessibility-tester | accessibility-specialist | Renamed |

## Contributing

When adding new capabilities:

1. **First check**: Can this fit into an existing agent?
2. **If new agent needed**: Ensure no overlap with existing agents
3. **Document clearly**: What's unique about this agent?
4. **Keep focused**: One clear domain per agent
5. **Update README**: Add to appropriate section

## Best Practices

1. **Start with researcher** when investigating problems or evaluating options
2. **Use fullstack-specialist** for implementing features
3. **Involve typescript-expert** early for type safety
4. **Engage qa-test-specialist** throughout development
5. **Review with security-specialist** before deployment
6. **Check with accessibility-specialist** for all UI work
7. **Optimize with performance-specialist** before launch
8. **Deploy with devops-specialist**

## Support

For questions or issues with the distilled agent framework:
- Review agent definitions in this directory
- Check agent expertise and use cases
- Ensure you're using the right agent for the task
- Consider agent collaboration patterns

---

**Summary**: 11 focused agents covering 100% of fullstack web development needs with zero redundancy.
