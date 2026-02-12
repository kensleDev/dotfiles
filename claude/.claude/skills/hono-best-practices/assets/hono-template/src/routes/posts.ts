import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { authMiddleware, requireAuth } from '../middleware/auth'

const app = new Hono()

app.use('*', authMiddleware)

// Schemas
const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(10000),
})

const updatePostSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  content: z.string().min(1).max(10000).optional(),
})

// Routes
app.get('/', async (c) => {
  // TODO: Fetch posts from database
  return c.json({
    posts: [
      { id: '1', title: 'First Post', content: 'Content here...', authorId: '1' },
      { id: '2', title: 'Second Post', content: 'More content...', authorId: '2' },
    ],
  })
})

app.post(
  '/',
  rateLimitMiddleware({ requests: 5, window: '1h' }),
  zValidator('json', createPostSchema),
  async (c) => {
    const data = c.req.valid('json')
    const currentUser = requireAuth(c)

    // TODO: Create post in database
    const post = {
      id: crypto.randomUUID(),
      authorId: currentUser.id,
      ...data,
    }

    return c.json(post, 201)
  }
)

app.get('/:id', async (c) => {
  const id = c.req.param('id')

  // TODO: Fetch post from database
  if (id === '1') {
    return c.json({
      id: '1',
      title: 'First Post',
      content: 'Content here...',
      authorId: '1',
    })
  }

  return c.json({ error: 'Not Found', message: 'Post not found' }, 404)
})

export default app
