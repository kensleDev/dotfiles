import { Context, Next } from 'hono'

interface RateLimitEntry {
  count: number
  resetTime: number
}

const store = new Map<string, RateLimitEntry>()

/**
 * Rate limiting middleware (in-memory)
 * For production, consider using Redis or a similar cache
 */
export const rateLimit = (options: {
  maxRequests: number
  windowMs: number
}) => {
  return async (c: Context, next: Next) => {
    const ip = c.req.header('x-forwarded-for') || c.req.header('cf-connecting-ip') || 'unknown'
    const now = Date.now()
    const resetTime = now + options.windowMs

    // Clean up expired entries
    for (const [key, entry] of store.entries()) {
      if (entry.resetTime < now) {
        store.delete(key)
      }
    }

    const entry = store.get(ip) || { count: 0, resetTime }

    if (entry.resetTime < now) {
      entry.count = 1
      entry.resetTime = resetTime
    } else {
      entry.count++
    }

    store.set(ip, entry)

    if (entry.count > options.maxRequests) {
      return c.json(
        {
          error: 'Too many requests',
          retryAfter: Math.ceil((entry.resetTime - now) / 1000),
        },
        429
      )
    }

    c.header('X-RateLimit-Limit', options.maxRequests.toString())
    c.header('X-RateLimit-Remaining', (options.maxRequests - entry.count).toString())
    c.header('X-RateLimit-Reset', entry.resetTime.toString())

    await next()
  }
}
