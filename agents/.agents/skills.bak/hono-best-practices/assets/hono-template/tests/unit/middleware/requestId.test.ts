import { describe, it, expect } from 'vitest'
import { requestId } from '../../../src/middleware/requestId.js'
import { Hono } from 'hono'

describe('requestId middleware', () => {
  it('should generate a new request ID if not provided', async () => {
    const app = new Hono()
    app.use('*', requestId)
    app.get('/test', (c) => c.json({ requestId: c.get('requestId') }))

    const res = await app.request('/test')
    const data = await res.json()

    expect(res.headers.get('x-request-id')).toBeDefined()
    expect(data.requestId).toBeDefined()
    expect(typeof data.requestId).toBe('string')
  })

  it('should use provided request ID from header', async () => {
    const app = new Hono()
    app.use('*', requestId)
    app.get('/test', (c) => c.json({ requestId: c.get('requestId') }))

    const customId = 'my-custom-request-id'
    const res = await app.request('/test', {
      headers: { 'x-request-id': customId },
    })
    const data = await res.json()

    expect(res.headers.get('x-request-id')).toBe(customId)
    expect(data.requestId).toBe(customId)
  })
})
