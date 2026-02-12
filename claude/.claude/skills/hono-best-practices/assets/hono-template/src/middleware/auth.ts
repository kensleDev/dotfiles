import { Context, Next } from 'hono'

export interface JWTPayload {
  userId: string
  email: string
  role: string
}

declare module 'hono' {
  interface ContextVariableMap {
    user: JWTPayload
  }
}

/**
 * Authentication middleware that validates JWT tokens
 * Note: This is a simplified example. In production, use a proper JWT library
 * and implement proper token verification with your secret key.
 */
export const authMiddleware = async (c: Context, next: Next) => {
  const authHeader = c.req.header('Authorization')

  if (!authHeader?.startsWith('Bearer ')) {
    throw new Error('Missing or invalid Authorization header')
  }

  const token = authHeader.slice(7)

  // TODO: Implement proper JWT verification
  // Example: const payload = await verifyToken(token, process.env.JWT_SECRET!)
  try {
    // This is a mock implementation
    const payload: JWTPayload = {
      userId: 'mock-user-id',
      email: 'user@example.com',
      role: 'user',
    }
    
    c.set('user', payload)
    await next()
  } catch (err) {
    throw new Error('Invalid or expired token')
  }
}

/**
 * Authorization middleware for role-based access control
 */
export const requireRole = (...roles: string[]) => {
  return async (c: Context, next: Next) => {
    const user = c.get('user')

    if (!user || !roles.includes(user.role)) {
      throw new Error('Insufficient permissions')
    }

    await next()
  }
}
