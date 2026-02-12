import { Hono } from 'hono'
import { logger } from 'hono/logger'
import { cors } from 'hono/cors'
import { requestId } from './middleware/requestId.js'
import { errorHandler } from './middleware/errorHandler.js'
import { usersRouter } from './routes/users.js'
import { authRouter } from './routes/auth.js'

const app = new Hono()

// Global middleware (order matters!)
app.use('*', errorHandler)
app.use('*', requestId)
app.use('*', logger())
app.use('*', cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true,
}))

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: new Date().toISOString() }))

// API routes
app.route('/api/users', usersRouter)
app.route('/api/auth', authRouter)

// 404 handler
app.notFound((c) => c.json({ error: 'Not Found' }, 404))

const port = parseInt(process.env.PORT || '3000')

console.log(`🚀 Server running on port ${port}`)

export default {
  port,
  fetch: app.fetch,
}

// Start server if running directly
if (import.meta.url === `file://${process.argv[1]}`) {
  Deno.serve({ port }, app.fetch)
}
