# Hono Testing Patterns

This reference covers unit, integration, and E2E testing strategies for Hono applications using Vitest and Playwright.

## Setup

### Installation

```bash
npm install -D vitest @vitest/coverage-v8
npm install -D playwright @playwright/test
```

### Vitest Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['node_modules/', 'tests/e2e/'],
    },
  },
})
```

### Test File Structure

```
tests/
├── unit/
│   ├── middleware/
│   │   ├── auth.test.ts
│   │   └── rateLimit.test.ts
│   ├── validators/
│   │   └── userSchema.test.ts
│   └── services/
│       └── userService.test.ts
├── integration/
│   ├── routes/
│   │   ├── users.test.ts
│   │   └── auth.test.ts
│   └── api.test.ts
└── e2e/
    ├── auth-flow.spec.ts
    └── api-spec.ts
```

## Unit Testing

### Testing Middleware

```typescript
// tests/unit/middleware/auth.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { authMiddleware } from '@/middleware/auth'
import { Hono } from 'hono'
import { Context } from 'hono'

describe('authMiddleware', () => {
  let app: Hono
  
  beforeEach(() => {
    app = new Hono()
    app.use('*', authMiddleware)
    app.get('/protected', (c) => c.json({ message: 'Success', user: c.get('user') }))
  })
  
  it('should reject requests without Authorization header', async () => {
    const res = await app.request('/protected')
    expect(res.status).toBe(401)
    const data = await res.json()
    expect(data.error).toBe('Missing or invalid Authorization header')
  })
  
  it('should reject invalid tokens', async () => {
    const res = await app.request('/protected', {
      headers: { 'Authorization': 'Bearer invalid-token' }
    })
    expect(res.status).toBe(401)
  })
  
  it('should set user context with valid token', async () => {
    const validToken = generateTestToken({ userId: '123', role: 'user' })
    const res = await app.request('/protected', {
      headers: { 'Authorization': `Bearer ${validToken}` }
    })
    expect(res.status).toBe(200)
    const data = await res.json()
    expect(data.user).toEqual({ userId: '123', role: 'user' })
  })
})
```

### Testing Zod Schemas

```typescript
// tests/unit/validators/userSchema.test.ts
import { describe, it, expect } from 'vitest'
import { z } from 'zod'
import { createUserSchema } from '@/schemas/user'

describe('createUserSchema', () => {
  const validData = {
    name: 'John Doe',
    email: 'john@example.com',
    age: 25,
    role: 'user',
  }
  
  it('should accept valid user data', () => {
    const result = createUserSchema.safeParse(validData)
    expect(result.success).toBe(true)
  })
  
  it('should reject name shorter than 2 characters', () => {
    const result = createUserSchema.safeParse({ ...validData, name: 'A' })
    expect(result.success).toBe(false)
    if (!result.success) {
      expect(result.error.issues[0].message).toBe('Name must be at least 2 characters')
    }
  })
  
  it('should reject invalid email format', () => {
    const result = createUserSchema.safeParse({ ...validData, email: 'not-an-email' })
    expect(result.success).toBe(false)
  })
  
  it('should reject age under 18', () => {
    const result = createUserSchema.safeParse({ ...validData, age: 17 })
    expect(result.success).toBe(false)
  })
  
  it('should apply default role', () => {
    const { role } = createUserSchema.parse({
      name: 'Jane',
      email: 'jane@example.com',
    })
    expect(role).toBe('user')
  })
})
```

### Testing Route Handlers in Isolation

```typescript
// tests/unit/routes/users.test.ts
import { describe, it, expect, vi } from 'vitest'
import { getUsersHandler } from '@/routes/users'
import { Hono } from 'hono'

describe('getUsersHandler', () => {
  it('should return users list', async () => {
    const mockUsers = [
      { id: '1', name: 'User 1', email: 'user1@example.com' },
      { id: '2', name: 'User 2', email: 'user2@example.com' },
    ]
    
    vi.mock('@/services/userService', () => ({
      fetchUsers: vi.fn().mockResolvedValue(mockUsers),
    }))
    
    const app = new Hono()
    app.get('/users', getUsersHandler)
    
    const res = await app.request('/users')
    expect(res.status).toBe(200)
    const data = await res.json()
    expect(data.users).toEqual(mockUsers)
  })
})
```

## Integration Testing

### Testing Complete Routes

```typescript
// tests/integration/routes/users.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { app } from '@/index'
import { setupTestDB, teardownTestDB, seedUsers } from '@/test/utils'

describe('GET /api/users', () => {
  let db
  
  beforeEach(async () => {
    db = await setupTestDB()
    await seedUsers(db, [
      { id: '1', name: 'Alice', email: 'alice@example.com' },
      { id: '2', name: 'Bob', email: 'bob@example.com' },
    ])
  })
  
  afterEach(async () => {
    await teardownTestDB(db)
  })
  
  it('should return all users with pagination', async () => {
    const res = await app.request('/api/users?page=1&limit=10')
    expect(res.status).toBe(200)
    
    const data = await res.json()
    expect(data.users).toHaveLength(2)
    expect(data.users[0].name).toBe('Alice')
    expect(data.pagination).toEqual({
      page: 1,
      limit: 10,
      total: 2,
      totalPages: 1,
    })
  })
  
  it('should filter users by search term', async () => {
    const res = await app.request('/api/users?search=Alice')
    expect(res.status).toBe(200)
    
    const data = await res.json()
    expect(data.users).toHaveLength(1)
    expect(data.users[0].name).toBe('Alice')
  })
})

describe('POST /api/users', () => {
  it('should create a new user', async () => {
    const userData = {
      name: 'Charlie',
      email: 'charlie@example.com',
      age: 30,
    }
    
    const res = await app.request('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    })
    
    expect(res.status).toBe(201)
    const data = await res.json()
    expect(data.id).toBeDefined()
    expect(data.name).toBe('Charlie')
    expect(data.email).toBe('charlie@example.com')
  })
  
  it('should return 400 for invalid data', async () => {
    const res = await app.request('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'X', email: 'invalid' }),
    })
    
    expect(res.status).toBe(400)
    const data = await res.json()
    expect(data.error).toBe('Validation failed')
  })
})
```

### Testing Middleware Composition

```typescript
// tests/integration/middleware/api.test.ts
import { describe, it, expect } from 'vitest'
import { Hono } from 'hono'
import { authMiddleware } from '@/middleware/auth'
import { rateLimit } from '@/middleware/rateLimit'

describe('API middleware composition', () => {
  const app = new Hono()
  
  app.use('/api/*', rateLimit({ maxRequests: 5, windowMs: 60000 }))
  app.use('/api/protected/*', authMiddleware)
  
  app.get('/api/public', (c) => c.json({ message: 'Public' }))
  app.get('/api/protected/data', (c) => c.json({ message: 'Protected', user: c.get('user') }))
  
  it('should allow access to public route', async () => {
    const res = await app.request('/api/public')
    expect(res.status).toBe(200)
  })
  
  it('should require auth for protected route', async () => {
    const res = await app.request('/api/protected/data')
    expect(res.status).toBe(401)
  })
  
  it('should allow access to protected route with valid token', async () => {
    const token = generateTestToken({ userId: '123', role: 'user' })
    const res = await app.request('/api/protected/data', {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    expect(res.status).toBe(200)
  })
})
```

### Testing Error Handling

```typescript
// tests/integration/errorHandling.test.ts
import { describe, it, expect } from 'vitest'
import { app } from '@/index'

describe('Error handling', () => {
  it('should handle 404 errors', async () => {
    const res = await app.request('/nonexistent-route')
    expect(res.status).toBe(404)
    const data = await res.json()
    expect(data.error).toBeDefined()
  })
  
  it('should handle validation errors consistently', async () => {
    const res = await app.request('/api/users', {
      method: 'POST',
      body: JSON.stringify({ invalid: 'data' }),
    })
    expect(res.status).toBe(400)
    const data = await res.json()
    expect(data.error).toBe('Validation failed')
    expect(data.fields).toBeDefined()
  })
  
  it('should handle server errors', async () => {
    // Simulate a database error
    vi.spyOn(db, 'user', 'create').mockRejectedValueOnce(new Error('DB Error'))
    
    const res = await app.request('/api/users', {
      method: 'POST',
      body: JSON.stringify({ name: 'Test', email: 'test@example.com' }),
    })
    expect(res.status).toBe(500)
  })
})
```

## E2E Testing with Playwright

### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium' },
    { name: 'firefox' },
    { name: 'webkit' },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

### API E2E Tests

```typescript
// tests/e2e/api.spec.ts
import { test, expect } from '@playwright/test'

test.describe('User API E2E', () => {
  let authToken: string
  
  test('should register a new user', async ({ request }) => {
    const response = await request.post('/api/auth/register', {
      data: {
        name: 'Test User',
        email: 'test@example.com',
        password: 'SecurePass123!',
      },
    })
    
    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    expect(data.token).toBeDefined()
    authToken = data.token
  })
  
  test('should login with valid credentials', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: {
        email: 'test@example.com',
        password: 'SecurePass123!',
      },
    })
    
    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    authToken = data.token
  })
  
  test('should access protected endpoint with token', async ({ request }) => {
    const response = await request.get('/api/users/me', {
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
    })
    
    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    expect(data.email).toBe('test@example.com')
  })
  
  test('should rate limit requests', async ({ request }) => {
    const requests = Array.from({ length: 11 }, () => 
      request.get('/api/public', { headers: { 'x-forwarded-for': '127.0.0.1' } })
    )
    
    const responses = await Promise.all(requests)
    
    // First 10 should succeed
    responses.slice(0, 10).forEach(r => expect(r.ok()).toBeTruthy())
    
    // 11th should be rate limited
    const lastResponse = responses[10]
    expect(lastResponse.status()).toBe(429)
  })
})
```

### Frontend + API E2E Tests

```typescript
// tests/e2e/auth-flow.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication Flow', () => {
  test('complete login flow', async ({ page }) => {
    await page.goto('/')
    
    // Click login button
    await page.click('button:text("Login")')
    
    // Fill login form
    await page.fill('input[name="email"]', 'test@example.com')
    await page.fill('input[name="password"]', 'SecurePass123!')
    await page.click('button:text("Sign In")')
    
    // Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('text=Welcome, Test User')).toBeVisible()
    
    // Verify API call was made
    const [apiResponse] = await Promise.all([
      page.waitForResponse(r => r.url().includes('/api/users/me')),
      page.reload(),
    ])
    
    expect(apiResponse.ok()).toBeTruthy()
    const userData = await apiResponse.json()
    expect(userData.email).toBe('test@example.com')
  })
  
  test('should show validation errors on register form', async ({ page }) => {
    await page.goto('/register')
    
    // Submit empty form
    await page.click('button:text("Create Account")')
    
    // Check validation errors
    await expect(page.locator('text=Name is required')).toBeVisible()
    await expect(page.locator('text=Email is required')).toBeVisible()
    await expect(page.locator('text=Password is required')).toBeVisible()
  })
})
```

## Test Utilities

### Database Test Setup

```typescript
// tests/utils/db.ts
import { Client } from 'pg'

let testClient: Client

export async function setupTestDB() {
  const connectionString = process.env.TEST_DATABASE_URL
  testClient = new Client({ connectionString })
  await testClient.connect()
  
  // Start transaction
  await testClient.query('BEGIN')
  return testClient
}

export async function teardownTestDB(client: Client) {
  await client.query('ROLLBACK')
  await client.end()
}

export async function seedUsers(client: Client, users: any[]) {
  for (const user of users) {
    await client.query(
      'INSERT INTO users (id, name, email) VALUES ($1, $2, $3)',
      [user.id, user.name, user.email]
    )
  }
}
```

### Test Request Helper

```typescript
// tests/utils/request.ts
import { Hono } from 'hono'

export async function authenticatedRequest(
  app: Hono,
  path: string,
  token: string,
  options?: RequestInit
) {
  return app.request(path, {
    ...options,
    headers: {
      ...options?.headers,
      'Authorization': `Bearer ${token}`,
    },
  })
}

export async function createTestUser(app: Hono, userData: any) {
  const res = await app.request('/api/users', {
    method: 'POST',
    body: JSON.stringify(userData),
  })
  return res.json()
}
```

### Mock Services

```typescript
// tests/mocks/userService.ts
import { vi } from 'vitest'

export const mockUserService = {
  fetchUser: vi.fn(),
  fetchUsers: vi.fn(),
  createUser: vi.fn(),
  updateUser: vi.fn(),
  deleteUser: vi.fn(),
}

export function setupUserMocks() {
  vi.mock('@/services/userService', () => mockUserService)
  return mockUserService
}
```

## Best Practices

### Unit Testing

1. **Test in isolation**: Mock all external dependencies
2. **One assertion per test**: Keep tests focused
3. **Use descriptive names**: Test names should describe what they test
4. **Arrange-Act-Assert**: Clear test structure
5. **Test edge cases**: Null, undefined, empty strings, boundary values

### Integration Testing

1. **Use test database**: Isolated from production data
2. **Clean up after each test**: Reset state between tests
3. **Test happy and sad paths**: Success and failure cases
4. **Test middleware composition**: Verify middleware order and behavior
5. **Test validation**: Verify error messages and status codes

### E2E Testing

1. **Test critical user flows**: Login, checkout, registration
2. **Avoid testing implementation**: Test user behavior, not internal logic
3. **Use realistic data**: Test with production-like data
4. **Run in CI**: Catch regressions before deployment
5. **Keep tests stable**: Avoid flaky tests with proper waits and retries

### General

1. **Fast feedback**: Unit tests should be fast (<100ms each)
2. **Coverage goals**: Aim for 80%+ coverage on critical paths
3. **Parallel execution**: Run tests in parallel when possible
4. **Keep tests simple**: Avoid complex test logic
5. **Document complex setups**: Use helper functions for repetitive setup
6. **Test at appropriate levels**: Unit for logic, integration for API, E2E for flows
