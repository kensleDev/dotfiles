import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import {
  createUserSchema,
  updateUserSchema,
  userIdParamsSchema,
  listUsersQuerySchema,
} from '../schemas/user.js'
import { authMiddleware } from '../middleware/auth.js'
import { requireRole } from '../middleware/auth.js'

const usersRouter = new Hono()

// Mock database - replace with real database in production
const users = new Map<string, any>()
users.set('550e8400-e29b-41d4-a716-446655440000', {
  id: '550e8400-e29b-41d4-a716-446655440000',
  name: 'Admin User',
  email: 'admin@example.com',
  role: 'admin',
  createdAt: '2024-01-01T00:00:00.000Z',
  updatedAt: '2024-01-01T00:00:00.000Z',
})

// GET /users - List users with pagination
usersRouter.get(
  '/',
  authMiddleware,
  zValidator('query', listUsersQuerySchema),
  (c) => {
    const { page, limit, search, sortBy, sortOrder } = c.req.valid('query')

    let filteredUsers = Array.from(users.values())

    // Apply search filter
    if (search) {
      const searchTerm = search.toLowerCase()
      filteredUsers = filteredUsers.filter(
        (user) =>
          user.name.toLowerCase().includes(searchTerm) ||
          user.email.toLowerCase().includes(searchTerm)
      )
    }

    // Apply sorting
    filteredUsers.sort((a, b) => {
      const aVal = a[sortBy]
      const bVal = b[sortBy]
      const comparison = aVal < bVal ? -1 : aVal > bVal ? 1 : 0
      return sortOrder === 'asc' ? comparison : -comparison
    })

    // Apply pagination
    const total = filteredUsers.length
    const totalPages = Math.ceil(total / limit)
    const startIndex = (page - 1) * limit
    const paginatedUsers = filteredUsers.slice(startIndex, startIndex + limit)

    return c.json({
      users: paginatedUsers,
      pagination: {
        page,
        limit,
        total,
        totalPages,
      },
    })
  }
)

// GET /users/:id - Get user by ID
usersRouter.get(
  '/:id',
  authMiddleware,
  zValidator('param', userIdParamsSchema),
  (c) => {
    const { id } = c.req.valid('param')
    const user = users.get(id)

    if (!user) {
      throw new Error('User not found')
    }

    return c.json(user)
  }
)

// POST /users - Create new user (admin only)
usersRouter.post(
  '/',
  authMiddleware,
  requireRole('admin'),
  zValidator('json', createUserSchema),
  (c) => {
    const data = c.req.valid('json')
    const id = crypto.randomUUID()

    const newUser = {
      id,
      ...data,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }

    users.set(id, newUser)

    return c.json(newUser, 201)
  }
)

// PATCH /users/:id - Update user
usersRouter.patch(
  '/:id',
  authMiddleware,
  zValidator('param', userIdParamsSchema),
  zValidator('json', updateUserSchema),
  (c) => {
    const { id } = c.req.valid('param')
    const updates = c.req.valid('json')
    const currentUser = c.get('user')

    const existingUser = users.get(id)
    if (!existingUser) {
      throw new Error('User not found')
    }

    // Users can only update themselves, admins can update anyone
    if (currentUser.role !== 'admin' && currentUser.userId !== id) {
      throw new Error('Forbidden')
    }

    const updatedUser = {
      ...existingUser,
      ...updates,
      updatedAt: new Date().toISOString(),
    }

    users.set(id, updatedUser)

    return c.json(updatedUser)
  }
)

// DELETE /users/:id - Delete user (admin only)
usersRouter.delete(
  '/:id',
  authMiddleware,
  requireRole('admin'),
  zValidator('param', userIdParamsSchema),
  (c) => {
    const { id } = c.req.valid('param')
    
    if (!users.has(id)) {
      throw new Error('User not found')
    }

    users.delete(id)

    return c.json({ message: 'User deleted successfully' })
  }
)

export { usersRouter }
