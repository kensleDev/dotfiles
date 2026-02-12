import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const authRouter = new Hono()

// Mock user database - replace with real database in production
const users = new Map<string, any>()
users.set('user@example.com', {
  id: '550e8400-e29b-41d4-a716-446655440000',
  name: 'Test User',
  email: 'user@example.com',
  passwordHash: 'hashed-password-here',
  role: 'user',
})

const registerSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/\d/, 'Password must contain at least one number'),
})

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
})

// POST /register - Register new user
authRouter.post(
  '/register',
  zValidator('json', registerSchema),
  async (c) => {
    const { name, email, password } = c.req.valid('json')

    // Check if user already exists
    if (users.has(email)) {
      throw new Error('User already exists')
    }

    // TODO: Hash password with bcrypt or similar
    const passwordHash = 'hashed-' + password

    const newUser = {
      id: crypto.randomUUID(),
      name,
      email,
      passwordHash,
      role: 'user',
      createdAt: new Date().toISOString(),
    }

    users.set(email, newUser)

    // TODO: Generate proper JWT token
    const token = 'mock-jwt-token'

    return c.json({
      token,
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role,
      },
    }, 201)
  }
)

// POST /login - Login user
authRouter.post(
  '/login',
  zValidator('json', loginSchema),
  async (c) => {
    const { email, password } = c.req.valid('json')

    const user = users.get(email)

    if (!user) {
      throw new Error('Invalid credentials')
    }

    // TODO: Verify password hash
    if (user.passwordHash !== 'hashed-' + password) {
      throw new Error('Invalid credentials')
    }

    // TODO: Generate proper JWT token
    const token = 'mock-jwt-token'

    return c.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    })
  }
)

// GET /me - Get current user
authRouter.get('/me', (c) => {
  // This route would typically use auth middleware
  // For demo purposes, we return a mock response
  return c.json({
    id: '550e8400-e29b-41d4-a716-446655440000',
    name: 'Test User',
    email: 'user@example.com',
    role: 'user',
  })
})

export { authRouter }
