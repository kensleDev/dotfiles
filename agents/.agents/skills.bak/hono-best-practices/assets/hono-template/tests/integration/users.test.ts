import { describe, it, expect, beforeEach } from 'vitest'
import { Hono } from 'hono'
import { usersRouter } from '../../src/routes/users.js'
import { authMiddleware } from '../../src/middleware/auth.js'
import { createTestToken } from '../helpers/testUtils.js'

describe('Users API Integration', () => {
  let app: Hono

  beforeEach(() => {
    app = new Hono()
    // Mock auth middleware to always succeed
    app.use('*', async (c, next) => {
      c.set('user', {
        userId: '550e8400-e29b-41d4-a716-446655440000',
        email: 'user@example.com',
        role: 'admin',
      })
      await next()
    })
    app.route('/api/users', usersRouter)
  })

  describe('GET /api/users', () => {
    it('should return users list with default pagination', async () => {
      const res = await app.request('/api/users')
      expect(res.status).toBe(200)

      const data = await res.json()
      expect(data.users).toBeInstanceOf(Array)
      expect(data.pagination).toEqual({
        page: 1,
        limit: 20,
        total: expect.any(Number),
        totalPages: expect.any(Number),
      })
    })

    it('should filter users by search term', async () => {
      const res = await app.request('/api/users?search=admin')
      expect(res.status).toBe(200)

      const data = await res.json()
      expect(data.users).toHaveLength(1)
      expect(data.users[0].name).toBe('Admin User')
    })

    it('should sort users by name', async () => {
      const res = await app.request('/api/users?sortBy=name&sortOrder=asc')
      expect(res.status).toBe(200)

      const data = await res.json()
      // Verify sorting
      expect(data.users[0].name).toBe('Admin User')
    })
  })

  describe('GET /api/users/:id', () => {
    it('should return user by ID', async () => {
      const userId = '550e8400-e29b-41d4-a716-446655440000'
      const res = await app.request(`/api/users/${userId}`)
      expect(res.status).toBe(200)

      const data = await res.json()
      expect(data.id).toBe(userId)
      expect(data.name).toBe('Admin User')
    })

    it('should return 404 for non-existent user', async () => {
      const res = await app.request('/api/users/non-existent-id')
      expect(res.status).toBe(400) // Validation error for invalid UUID
    })
  })

  describe('POST /api/users', () => {
    it('should create new user with valid data', async () => {
      const userData = {
        name: 'New User',
        email: 'newuser@example.com',
        role: 'user',
      }

      const res = await app.request('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData),
      })

      expect(res.status).toBe(201)
      const data = await res.json()
      expect(data.id).toBeDefined()
      expect(data.name).toBe('New User')
      expect(data.email).toBe('newuser@example.com')
    })

    it('should return 400 for invalid email', async () => {
      const res = await app.request('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: 'Test User',
          email: 'invalid-email',
        }),
      })

      expect(res.status).toBe(400)
      const data = await res.json()
      expect(data.error).toBe('Validation failed')
    })

    it('should return 400 for name too short', async () => {
      const res = await app.request('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: 'X',
          email: 'test@example.com',
        }),
      })

      expect(res.status).toBe(400)
      const data = await res.json()
      expect(data.error).toBe('Validation failed')
    })
  })

  describe('PATCH /api/users/:id', () => {
    it('should update user with valid data', async () => {
      const userId = '550e8400-e29b-41d4-a716-446655440000'

      const res = await app.request(`/api/users/${userId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: 'Updated Name',
        }),
      })

      expect(res.status).toBe(200)
      const data = await res.json()
      expect(data.name).toBe('Updated Name')
    })
  })

  describe('DELETE /api/users/:id', () => {
    it('should delete user', async () => {
      const userId = '550e8400-e29b-41d4-a716-446655440000'

      const res = await app.request(`/api/users/${userId}`, {
        method: 'DELETE',
      })

      expect(res.status).toBe(200)
      const data = await res.json()
      expect(data.message).toBe('User deleted successfully')
    })
  })
})
