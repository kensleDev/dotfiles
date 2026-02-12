# Hono Middleware Patterns

Complete guide to middleware architecture, composition, and best practices for Hono APIs.

## Middleware Architecture

### Global Middleware

Applied to all routes in your application. Use for cross-cutting concerns:

```typescript
// src/index.ts
import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { requestId } from './middleware/request-id'

const app = new Hono()

// Development only
if (process.env.NODE_ENV === 'development') {
  app.use('*', logger())
}

// Production
app.use('*', cors({
  origin: ['https://yourdomain.com'],
  credentials: true,
}))

// Always
app.use('*', requestId())
```

**Global middleware checklist:**
- ✅ Logger (development)
- ✅ CORS (production)
- ✅ Error handling (always)
- ✅ Request ID (always)
- ✅ Compression (production)

### Route-Specific Middleware

Applied to specific routes or route groups:

```typescript
// src/routes/users.ts
import { authMiddleware } from '../middleware/auth'
import { rateLimitMiddleware } from '../middleware/rate-limit'

const users = new Hono()

// Auth required for all user routes
users.use('*', authMiddleware)

// Rate limit registration endpoint
users.post('/register', rateLimitMiddleware({ requests: 5, window: '1m' }), async (c) => {
  // Registration logic
})
```

**Route-specific middleware uses:**
- Authentication/authorization
- Rate limiting
- Role-based access control
- Input validation
- Request/response transformation

## Builtin Middleware

Hono provides several built-in middleware:

### Logger

```bash
npm install @hono/logger
```

```typescript
import { logger } from 'hono/logger'

app.use('*', logger())
```

Options:
- `pretty`: Pretty print logs (default: true)
- `logParams`: Include request params (default: false)

### CORS

```bash
npm install @hono/cors
```

```typescript
import { cors } from 'hono/cors'

app.use('*', cors({
  origin: ['https://yourdomain.com'],
  credentials: true,
  maxAge: 86400,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
}))
```

### ETag

```bash
npm install @hono/etag
```

```typescript
import { etag } from 'hono/etag'

app.use('*', etag())
```

Enables 304 Not Modified responses for caching.

## Custom Middleware

### Authentication Middleware

```typescript
// src/middleware/auth.ts
import type { Context, Next } from 'hono'

export interface AuthUser {
  id: string
  email: string
  role: 'admin' | 'user'
}

export const authMiddleware = async (c: Context, next: Next) => {
  const token = c.req.header('Authorization')?.replace('Bearer ', '')

  if (!token) {
    return c.json({ error: 'Unauthorized', message: 'Missing authentication token' }, 401)
  }

  try {
    const user = await verifyToken(token) // Implement verifyToken
    c.set('user', user)
    await next()
  } catch (error) {
    return c.json({ error: 'Unauthorized', message: 'Invalid or expired token' }, 401)
  }
}

// Helper to get authenticated user
export const getUser = (c: Context): AuthUser | undefined => {
  return c.get('user')
}
```

### Rate Limiting Middleware

```typescript
// src/middleware/rate-limit.ts
import type { Context, Next } from 'hono'

interface RateLimitConfig {
  requests: number
  window: string // '1m', '1h', '1d'
}

const rateLimits = new Map<string, { count: number; resetTime: number }>()

export const rateLimitMiddleware = (config: RateLimitConfig) => {
  return async (c: Context, next: Next) => {
    const key = c.req.header('x-forwarded-for') || 'unknown'
    const now = Date.now()
    const windowMs = parseWindow(config.window)

    let limit = rateLimits.get(key)

    if (!limit || now > limit.resetTime) {
      limit = { count: 0, resetTime: now + windowMs }
      rateLimits.set(key, limit)
    }

    if (limit.count >= config.requests) {
      const resetAfter = Math.ceil((limit.resetTime - now) / 1000)
      c.header('Retry-After', resetAfter.toString())
      return c.json(
        { error: 'Too Many Requests', message: `Try again in ${resetAfter}s` },
        429
      )
    }

    limit.count++
    await next()
  }
}

function parseWindow(window: string): number {
  const match = window.match(/^(\d+)([mhd])$/)
  if (!match) return 60000
  const [, num, unit] = match
  const multipliers = { m: 60000, h: 3600000, d: 86400000 }
  return parseInt(num) * multipliers[unit as keyof typeof multipliers]
}
```

### Error Handling Middleware

```typescript
// src/middleware/error-handler.ts
import type { Context, Next } from 'hono'

export const errorHandlerMiddleware = async (c: Context, next: Next) => {
  try {
    await next()
  } catch (error) {
    console.error('[Error]', error)

    if (error instanceof ValidationError) {
      return c.json(
        { error: 'Validation Error', message: error.message, fields: error.fields },
        400
      )
    }

    if (error instanceof AuthError) {
      return c.json({ error: 'Auth Error', message: error.message }, error.status)
    }

    // Default error response
    const status = (error as any).status || 500
    const isDev = process.env.NODE_ENV === 'development'

    return c.json(
      {
        error: isDev ? 'Internal Server Error' : 'An error occurred',
        message: isDev ? (error as Error).message : 'Please try again later',
        ...(isDev && { stack: (error as Error).stack }),
      },
      status
    )
  }
}

export class ValidationError extends Error {
  fields: Record<string, string>
  constructor(message: string, fields: Record<string, string>) {
    super(message)
    this.name = 'ValidationError'
    this.fields = fields
  }
}

export class AuthError extends Error {
  status: number
  constructor(message: string, status: number = 401) {
    super(message)
    this.name = 'AuthError'
    this.status = status
  }
}
```

### Request ID Middleware

```typescript
// src/middleware/request-id.ts
import type { Context, Next } from 'hono'

export const requestIdMiddleware = async (c: Context, next: Next) => {
  const requestId = c.req.header('x-request-id') || crypto.randomUUID()
  c.set('requestId', requestId)
  c.header('x-request-id', requestId)
  await next()
}
```

## Middleware Composition

### Stacking Middleware

```typescript
// src/middleware/api.ts
import { authMiddleware } from './auth'
import { rateLimitMiddleware } from './rate-limit'
import { validationMiddleware } from './validation'

export const apiMiddleware = [
  errorHandlerMiddleware,
  requestIdMiddleware,
  authMiddleware,
  rateLimitMiddleware({ requests: 100, window: '1m' }),
  validationMiddleware,
]

// Apply to routes
app.use('*', ...apiMiddleware)
```

### Conditional Middleware

```typescript
// src/middleware/conditional.ts
export const conditionalAuth = (condition: boolean) => {
  return condition ? authMiddleware : async (_: Context, next: Next) => await next()
}

// Usage
app.use('/public/*', conditionalAuth(false)) // No auth required
app.use('/api/*', conditionalAuth(true))  // Auth required
```

## Middleware Testing

Test middleware independently:

```typescript
// tests/middleware/auth.test.ts
import { describe, it, expect } from 'vitest'
import { authMiddleware, getUser } from '../src/middleware/auth'

describe('authMiddleware', () => {
  it('returns 401 if no token', async () => {
    const c = mockContext()
    c.req.header = jest.fn().mockReturnValue(undefined)

    await authMiddleware(c, mockNext)

    expect(c.json).toHaveBeenCalledWith(
      { error: 'Unauthorized', message: 'Missing authentication token' },
      401
    )
  })

  it('sets user if valid token', async () => {
    const c = mockContext()
    const mockUser = { id: '1', email: 'test@example.com', role: 'user' }
    c.req.header = jest.fn().mockReturnValue('Bearer valid-token')
    jest.mock('../src/lib/auth', () => ({
      verifyToken: () => Promise.resolve(mockUser),
    }))

    await authMiddleware(c, mockNext)

    expect(c.get).toHaveBeenCalledWith('user')
    expect(c.get('user')).toEqual(mockUser)
  })
})

function mockContext() {
  return {
    req: { header: jest.fn() },
    json: jest.fn(),
    set: jest.fn(),
  } as any
}

const mockNext = jest.fn()
```

## Best Practices

### Order Matters

Middleware runs in the order defined:

```typescript
// Wrong order
app.use('*', authMiddleware)     // Runs first
app.use('*', requestIdMiddleware)  // Runs second (too late!)

// Correct order
app.use('*', requestIdMiddleware)  // Runs first (assigns ID)
app.use('*', authMiddleware)       // Runs second (uses ID in logs)
```

### Keep Middleware Small

Each middleware should do one thing well:

```typescript
// Bad - does too much
export const bigMiddleware = async (c: Context, next: Next) => {
  const token = c.req.header('Authorization')
  if (!token) return c.json({ error: 'Unauthorized' }, 401)
  const user = await verifyToken(token)
  c.set('user', user)

  const now = Date.now()
  const limit = rateLimits.get(c.req.header('x-forwarded-for'))
  if (limit && limit.count > 100) {
    return c.json({ error: 'Too Many Requests' }, 429)
  }

  await next()
}

// Good - single responsibility
export const authMiddleware = async (c: Context, next: Next) => {
  const token = c.req.header('Authorization')
  if (!token) return c.json({ error: 'Unauthorized' }, 401)
  const user = await verifyToken(token)
  c.set('user', user)
  await next()
}

export const rateLimitMiddleware = () => {
  // Separate implementation...
}
```

### Type Safety

Always type middleware correctly:

```typescript
import type { MiddlewareHandler } from 'hono'

export const typedMiddleware: MiddlewareHandler = async (c, next) => {
  // TypeScript will infer Context and Next types
  await next()
}
```

## Resources

- [Hono Middleware Docs](https://hono.dev/docs/middleware)
- [Hono Builtin Middleware](https://hono.dev/docs/middleware/builtin)
- [@hono/logger](https://github.com/honojs/middleware/tree/main/packages/logger)
- [@hono/cors](https://github.com/honojs/middleware/tree/main/packages/cors)
