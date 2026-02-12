import type { Context, Next } from 'hono'

interface RateLimitConfig {
  requests: number
  window: string // '1m', '1h', '1d'
}

const rateLimits = new Map<string, { count: number; resetTime: number }>()

export const rateLimitMiddleware = (config: RateLimitConfig) => {
  return async (c: Context, next: Next) => {
    const key = c.req.header('x-forwarded-for') || c.req.header('cf-connecting-ip') || 'unknown'
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
      c.header('X-RateLimit-Limit', config.requests.toString())
      c.header('X-RateLimit-Remaining', '0')
      c.header('X-RateLimit-Reset', limit.resetTime.toString())
      
      return c.json(
        {
          error: 'Too Many Requests',
          message: `Rate limit exceeded. Try again in ${resetAfter}s`,
        },
        429
      )
    }

    limit.count++
    
    c.header('X-RateLimit-Limit', config.requests.toString())
    c.header('X-RateLimit-Remaining', (config.requests - limit.count).toString())
    c.header('X-RateLimit-Reset', limit.resetTime.toString())
    
    await next()
  }
}

function parseWindow(window: string): number {
  const match = window.match(/^(\d+)([mhd])$/)
  if (!match) return 60000
  const [, num, unit] = match
  const multipliers: Record<string, number> = { m: 60000, h: 3600000, d: 86400000 }
  return parseInt(num) * multipliers[unit]
}
