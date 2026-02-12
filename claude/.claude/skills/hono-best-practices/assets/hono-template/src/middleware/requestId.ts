import { Context, Next } from 'hono'

declare module 'hono' {
  interface ContextVariableMap {
    requestId: string
  }
}

export const requestId = async (c: Context, next: Next) => {
  const id = c.req.header('x-request-id') || crypto.randomUUID()
  c.set('requestId', id)
  c.header('x-request-id', id)
  await next()
}
