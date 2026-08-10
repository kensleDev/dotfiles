import { describe, it, expect, beforeEach } from 'vitest'
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { authMiddleware } from '../src/middleware/auth'

// Mock context helper
function mockContext(overrides = {}) {
  return {
    req: {
      header: () => undefined,
      method: 'GET',
      url: new URL('http://localhost'),
      query: () => ({}),
      param: () => ({}),
      json: () => Promise.resolve({}),
    },
    json: () => null,
    set: () => {},
    get: () => undefined,
    header: () => {},
    status: 200,
    ...overrides,
  } as any
}

describe('authMiddleware', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('returns 401 if no token', async () => {
    const c = mockContext()
    c.req.header = vi.fn().mockReturnValue(undefined)
    const next = vi.fn()

    await authMiddleware(c, next)

    expect(c.json).toHaveBeenCalledWith(
      { error: 'Unauthorized', message: 'Missing authentication token' },
      401
    )
    expect(next).not.toHaveBeenCalled()
  })

  it('sets user if valid token', async () => {
    const c = mockContext()
    const mockUser = { id: '1', email: 'test@example.com', role: 'user' }
    c.req.header = vi.fn().mockReturnValue('Bearer valid-token')
    const next = vi.fn()

    await authMiddleware(c, next)

    expect(c.set).toHaveBeenCalledWith('user', mockUser)
    expect(next).toHaveBeenCalled()
  })
})
