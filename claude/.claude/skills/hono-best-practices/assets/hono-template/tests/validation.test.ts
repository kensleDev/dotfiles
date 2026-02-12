import { describe, it, expect, beforeEach } from 'vitest'
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

describe('Validation', () => {
  let app: Hono

  const schema = z.object({
    name: z.string().min(2).max(100),
    email: z.string().email(),
  })

  beforeEach(() => {
    app = new Hono()
    vi.clearAllMocks()
  })

  it('accepts valid data', async () => {
    app.post('/test', zValidator('json', schema), (c) => {
      const data = c.req.valid('json')
      return c.json({ success: true, data })
    })

    const res = await app.request('/test', {
      method: 'POST',
      body: JSON.stringify({
        name: 'John Doe',
        email: 'john@example.com',
      }),
      headers: { 'Content-Type': 'application/json' },
    })

    expect(res.status).toBe(200)
    const body = await res.json()
    expect(body.success).toBe(true)
  })

  it('rejects invalid email', async () => {
    app.post('/test', zValidator('json', schema), (c) => {
      const data = c.req.valid('json')
      return c.json({ success: true, data })
    })

    const res = await app.request('/test', {
      method: 'POST',
      body: JSON.stringify({
        name: 'John Doe',
        email: 'invalid-email',
      }),
      headers: { 'Content-Type': 'application/json' },
    })

    expect(res.status).toBe(400)
    const body = await res.json()
    expect(body).toHaveProperty('error')
  })

  it('rejects short name', async () => {
    app.post('/test', zValidator('json', schema), (c) => {
      const data = c.req.valid('json')
      return c.json({ success: true, data })
    })

    const res = await app.request('/test', {
      method: 'POST',
      body: JSON.stringify({
        name: 'J', // Too short
        email: 'john@example.com',
      }),
      headers: { 'Content-Type': 'application/json' },
    })

    expect(res.status).toBe(400)
    const body = await res.json()
    expect(body).toHaveProperty('error')
  })
})
