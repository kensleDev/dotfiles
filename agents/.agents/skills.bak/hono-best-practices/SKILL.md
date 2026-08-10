---
name: hono-best-practices
description: Production-ready patterns and best practices for Hono API development, including middleware architecture, Zod validation, and testing strategies
version: 1.0.0
---

# Hono Best Practices

This skill provides production-ready patterns for building Hono APIs with React frontends. Focuses on middleware architecture, validation with Zod, and comprehensive testing.

## When to Use This Skill

Use this skill when:

- Building a new Hono API (REST or GraphQL)
- Setting up authentication and authorization
- Implementing request/response validation
- Adding middleware (CORS, logging, rate limiting)
- Writing tests for Hono routes and middleware
- Structuring a production Hono project
- Optimizing for performance with Hono

## Core Workflow

### 1. Project Setup

Start with the template from `assets/hono-template/`:

```bash
# Copy the template structure
cp -r assets/hono-template/ your-project/
cd your-project
npm install
```

The template includes:
- Middleware directory for reusable middleware
- Routes directory for organized endpoints
- Test setup with Vitest and Playwright
- Example validation with Zod

### 2. Middleware Layer

Apply middleware patterns from `references/hono-middleware.md`:

1. **Global middleware** (applied to all routes):
   - Logger (development)
   - CORS (production)
   - Error handling
   - Request ID generation

2. **Route-specific middleware**:
   - Authentication (JWT, session)
   - Authorization (role-based)
   - Rate limiting
   - Input validation

3. **Custom middleware**:
   - Create reusable middleware in `src/middleware/`
   - Compose middleware for specific routes
   - Test middleware independently

### 3. Validation Layer

Use patterns from `references/hono-validation.md`:

1. **Request validation**:
   - Define schemas with Zod
   - Use `@hono/zod-validator` middleware
   - Validate query params, path params, body

2. **Response validation** (optional, for critical APIs):
   - Validate API responses before sending
   - Catch contract violations early

3. **Error handling**:
   - Provide clear validation errors
   - Format error responses consistently
   - Log validation failures

### 4. Testing Strategy

Follow patterns from `references/hono-testing.md`:

1. **Unit tests** (Vitest):
   - Test middleware independently
   - Test route handlers with mocked context
   - Test validation logic

2. **Integration tests**:
   - Test full request/response cycle
   - Test middleware composition
   - Test error handling

3. **E2E tests** (Playwright):
   - Test API from frontend perspective
   - Test authentication flows
   - Test real network conditions

## Quick Reference

### Route Structure

```typescript
// src/routes/users.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

const createUserSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
})

app.post('/', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  // Create user...
  return c.json({ id: '123', ...data }, 201)
})
```

### Middleware Pattern

```typescript
// src/middleware/auth.ts
export const authMiddleware = async (c: Context, next: Next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')
  
  if (!token) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  
  const user = await verifyToken(token)
  c.set('user', user)
  await next()
}
```

## Best Practices

### Performance

- Use Hono's built-in compression middleware
- Leverage edge-compatible patterns
- Cache frequently accessed data
- Use connection pooling for databases

### Security

- Always validate input (never trust client data)
- Use HTTPS in production
- Implement rate limiting
- Sanitize error messages (don't leak stack traces)

### Maintainability

- Keep routes small and focused
- Extract business logic to services
- Use TypeScript strictly
- Document complex middleware

## Reference Files

- **[Middleware Patterns](references/hono-middleware.md)** - Architecture, composition, and custom middleware
- **[Validation Patterns](references/hono-validation.md)** - Zod integration and error handling
- **[Testing Patterns](references/hono-testing.md)** - Unit, integration, and E2E testing

## Project Template

See `assets/hono-template/` for a complete, minimal project structure ready for production use.
