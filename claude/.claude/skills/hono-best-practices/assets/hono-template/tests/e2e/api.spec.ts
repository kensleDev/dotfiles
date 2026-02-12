import { test, expect } from '@playwright/test'

test.describe('API E2E Tests', () => {
  let authToken: string

  test('should register a new user', async ({ request }) => {
    const response = await request.post('/api/auth/register', {
      data: {
        name: 'E2E Test User',
        email: 'e2e-test@example.com',
        password: 'SecurePass123!',
      },
    })

    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    expect(data.token).toBeDefined()
    expect(data.user.email).toBe('e2e-test@example.com')
    
    authToken = data.token
  })

  test('should login with valid credentials', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: {
        email: 'e2e-test@example.com',
        password: 'SecurePass123!',
      },
    })

    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    expect(data.token).toBeDefined()
    authToken = data.token
  })

  test('should get health check', async ({ request }) => {
    const response = await request.get('/health')

    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    expect(data.status).toBe('ok')
    expect(data.timestamp).toBeDefined()
  })

  test('should access protected endpoint with auth token', async ({ request }) => {
    const response = await request.get('/api/users/me', {
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
    })

    expect(response.ok()).toBeTruthy()
    const data = await response.json()
    expect(data.email).toBeDefined()
  })

  test('should reject unauthorized requests', async ({ request }) => {
    const response = await request.get('/api/users/550e8400-e29b-41d4-a716-446655440000')

    // Should return 401 without auth token
    expect(response.status()).toBe(401)
  })

  test('should return validation errors for invalid data', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: {
        email: 'not-an-email',
        password: 'short',
      },
    })

    expect(response.status()).toBe(400)
    const data = await response.json()
    expect(data.error).toBeDefined()
  })

  test('should handle rate limiting', async ({ request }) => {
    // Make multiple requests quickly
    const requests = Array.from({ length: 11 }, (_, i) =>
      request.get('/health', {
        headers: { 'x-forwarded-for': '127.0.0.1' },
      })
    )

    const responses = await Promise.all(requests)

    // First 10 should succeed
    responses.slice(0, 10).forEach(res => expect(res.ok()).toBeTruthy())

    // 11th should be rate limited (if rate limiting is configured)
    const lastResponse = responses[10]
    expect(lastResponse.status()).toBeGreaterThanOrEqual(400)
  })
})
