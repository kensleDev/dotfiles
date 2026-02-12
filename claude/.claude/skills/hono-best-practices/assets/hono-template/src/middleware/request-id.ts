import type { Context, Next } from 'hono'

export const requestIdMiddleware = async (c: Context, next: Next) => {
  const requestId = c.req.header('x-request-id') || crypto.randomUUID()
  c.set('requestId', requestId)
  c.header('x-request-id', requestId)
  await next()
}
