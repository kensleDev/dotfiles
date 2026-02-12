# Hono Validation Patterns

This reference covers request/response validation using Zod with Hono, including patterns, error handling, and best practices.

## Installation

```bash
npm install zod @hono/zod-validator
```

## Request Validation

### Path Parameters

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

const userParamsSchema = z.object({
  id: z.string().uuid('Invalid user ID format'),
})

app.get('/users/:id', 
  zValidator('param', userParamsSchema),
  (c) => {
    const { id } = c.req.valid('param')
    return c.json({ userId: id })
  }
)
```

### Query Parameters

```typescript
const listUsersQuerySchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(1).max(100).default(20),
  search: z.string().optional(),
  sortBy: z.enum(['name', 'email', 'createdAt']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('asc'),
})

app.get('/users', 
  zValidator('query', listUsersQuerySchema),
  (c) => {
    const { page, limit, search, sortBy, sortOrder } = c.req.valid('query')
    // Fetch users with pagination
    return c.json({ users: [], page, limit })
  }
)
```

### Request Body (JSON)

```typescript
const createUserSchema = z.object({
  name: z.string()
    .min(2, 'Name must be at least 2 characters')
    .max(100, 'Name must not exceed 100 characters'),
  email: z.string()
    .email('Invalid email address')
    .transform(email => email.toLowerCase()),
  age: z.number()
    .int('Age must be a whole number')
    .min(18, 'Must be at least 18 years old')
    .optional(),
  role: z.enum(['user', 'admin', 'moderator']).default('user'),
  preferences: z.object({
    newsletter: z.boolean().default(false),
    notifications: z.boolean().default(true),
  }).optional(),
})

app.post('/users',
  zValidator('json', createUserSchema),
  async (c) => {
    const data = c.req.valid('json')
    // Create user with validated data
    return c.json({ id: '123', ...data }, 201)
  }
)
```

### Form Data

```typescript
const updateProfileSchema = z.object({
  displayName: z.string().min(1).max(50),
  bio: z.string().max(500).optional(),
  avatar: z.instanceof(File).optional(),
})

app.post('/profile',
  zValidator('form', updateProfileSchema),
  async (c) => {
    const { displayName, bio, avatar } = c.req.valid('form')
    // Update profile...
    return c.json({ success: true })
  }
)
```

### Multiple Validations

```typescript
app.put('/users/:id',
  zValidator('param', userParamsSchema),
  zValidator('json', updateUserSchema),
  (c) => {
    const { id } = c.req.valid('param')
    const updates = c.req.valid('json')
    return c.json({ userId: id, ...updates })
  }
)
```

## Advanced Validation Patterns

### Nested Objects

```typescript
const addressSchema = z.object({
  street: z.string().min(1),
  city: z.string().min(1),
  state: z.string().length(2),
  zipCode: z.string().regex(/^\d{5}(-\d{4})?$/),
  country: z.string().default('US'),
})

const orderSchema = z.object({
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().min(1),
    price: z.number().positive(),
  })).min(1, 'Order must have at least one item'),
  shippingAddress: addressSchema,
  billingAddress: addressSchema.optional(),
  notes: z.string().max(1000).optional(),
})
```

### Conditional Validation

```typescript
const registrationSchema = z.object({
  type: z.enum(['individual', 'business']),
  email: z.string().email(),
  companyName: z.string().optional(),
  taxId: z.string().optional(),
}).refine(
  (data) => {
    if (data.type === 'business') {
      return !!data.companyName && !!data.taxId
    }
    return true
  },
  {
    message: 'Business registration requires company name and tax ID',
    path: ['companyName']
  }
)
```

### Custom Validators

```typescript
const strongPasswordSchema = z.string()
  .min(8, 'Password must be at least 8 characters')
  .refine(
    (password) => /[A-Z]/.test(password),
    'Password must contain at least one uppercase letter'
  )
  .refine(
    (password) => /[a-z]/.test(password),
    'Password must contain at least one lowercase letter'
  )
  .refine(
    (password) => /\d/.test(password),
    'Password must contain at least one number'
  )
  .refine(
    (password) => /[!@#$%^&*(),.?":{}|<>]/.test(password),
    'Password must contain at least one special character'
  )

const changePasswordSchema = z.object({
  currentPassword: z.string(),
  newPassword: strongPasswordSchema,
  confirmPassword: z.string(),
}).refine(
  (data) => data.newPassword === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword']
  }
)
```

### File Upload Validation

```typescript
const avatarUploadSchema = z.object({
  avatar: z.instanceof(File)
    .refine(
      (file) => file.size <= 5 * 1024 * 1024,
      'File must be less than 5MB'
    )
    .refine(
      (file) => ['image/jpeg', 'image/png', 'image/webp'].includes(file.type),
      'File must be a JPEG, PNG, or WebP image'
    ),
})

app.post('/avatar',
  zValidator('form', avatarUploadSchema),
  async (c) => {
    const { avatar } = c.req.valid('form')
    // Process avatar...
    return c.json({ success: true, filename: avatar.name })
  }
)
```

## Response Validation

### Validate Before Sending

```typescript
const userResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
})

app.get('/users/:id',
  zValidator('param', userParamsSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    
    // Fetch user from database
    const user = await db.user.findUnique({ where: { id } })
    if (!user) {
      return c.json({ error: 'User not found' }, 404)
    }
    
    // Validate response before sending
    const validatedUser = userResponseSchema.parse(user)
    return c.json(validatedUser)
  }
)
```

### Response Schema Middleware

```typescript
import { z } from 'zod'

export const validateResponse = <T extends z.ZodType>(schema: T) => {
  return async (c: Context, next: Next) => {
    await next()
    
    const response = c.res.clone()
    const data = await response.json()
    
    try {
      schema.parse(data)
    } catch (err) {
      console.error('Response validation error:', err)
      // Log but don't break in production
    }
  }
}

// Usage
app.get('/users/:id',
  zValidator('param', userParamsSchema),
  validateResponse(userResponseSchema),
  async (c) => {
    const user = await fetchUser(c.req.valid('param').id)
    return c.json(user)
  }
)
```

## Error Handling

### Custom Error Messages

```typescript
const createUserSchema = z.object({
  email: z.string().email('Please provide a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters long'),
  age: z.number({
    required_error: 'Age is required',
    invalid_type_error: 'Age must be a number',
  }),
})
```

### Formatted Validation Errors

```typescript
import { z } from 'zod'

export const formatZodError = (error: z.ZodError) => {
  const formattedErrors = error.issues.reduce((acc, issue) => {
    const path = issue.path.join('.')
    acc[path] = issue.message
    return acc
  }, {} as Record<string, string>)
  
  return {
    error: 'Validation failed',
    fields: formattedErrors,
  }
}

// In your error handler
export const errorHandler = async (c: Context, next: Next) => {
  try {
    await next()
  } catch (err) {
    if (err instanceof z.ZodError) {
      return c.json(formatZodError(err), 400)
    }
    // Handle other errors...
  }
}
```

### Validation Error Response Example

```json
{
  "error": "Validation failed",
  "fields": {
    "email": "Please provide a valid email address",
    "password": "Password must be at least 8 characters long",
    "address.zipCode": "Invalid ZIP code format"
  }
}
```

## Schema Reusability

### Partial Schemas (Updates)

```typescript
const userSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  age: z.number().int().positive().optional(),
  role: z.enum(['user', 'admin']).default('user'),
})

// For partial updates (PATCH)
const updateUserSchema = userSchema.partial()

app.patch('/users/:id',
  zValidator('param', userParamsSchema),
  zValidator('json', updateUserSchema),
  (c) => {
    const updates = c.req.valid('json')
    // Apply partial updates...
    return c.json({ success: true })
  }
)
```

### Schema Composition

```typescript
const baseSchema = z.object({
  id: z.string().uuid(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
})

const userSchema = baseSchema.extend({
  name: z.string(),
  email: z.string().email(),
})

const postSchema = baseSchema.extend({
  title: z.string(),
  content: z.string(),
  authorId: z.string().uuid(),
})
```

## Testing Validation

### Unit Testing Schemas

```typescript
import { describe, it, expect } from 'vitest'
import { z } from 'zod'

describe('createUserSchema', () => {
  const validData = {
    name: 'John Doe',
    email: 'john@example.com',
    age: 25,
    role: 'user',
  }
  
  it('should accept valid data', () => {
    expect(() => createUserSchema.parse(validData)).not.toThrow()
  })
  
  it('should reject invalid email', () => {
    const data = { ...validData, email: 'invalid-email' }
    expect(() => createUserSchema.parse(data)).toThrow()
  })
  
  it('should apply default values', () => {
    const data = { name: 'Jane', email: 'jane@example.com' }
    const result = createUserSchema.parse(data)
    expect(result.role).toBe('user')
  })
})
```

### Testing Validation in Routes

```typescript
import { describe, it, expect } from 'vitest'
import { testClient } from 'hono/testing'

describe('POST /users', () => {
  it('should create user with valid data', async () => {
    const res = await app.request('/users', {
      method: 'POST',
      body: JSON.stringify({
        name: 'John Doe',
        email: 'john@example.com',
      }),
    })
    
    expect(res.status).toBe(201)
    const data = await res.json()
    expect(data.email).toBe('john@example.com')
  })
  
  it('should return 400 for invalid data', async () => {
    const res = await app.request('/users', {
      method: 'POST',
      body: JSON.stringify({
        name: 'A',
        email: 'not-an-email',
      }),
    })
    
    expect(res.status).toBe(400)
    const data = await res.json()
    expect(data.error).toBe('Validation failed')
  })
})
```

## Best Practices

1. **Schema organization**: Keep schemas in dedicated files (`src/schemas/`)
2. **Reuse schemas**: Extend and compose schemas rather than duplicating
3. **Type inference**: Use `z.infer<>` to get TypeScript types from schemas
4. **Error messages**: Provide clear, actionable error messages
5. **Coercion**: Use `z.coerce.*` for type conversion from strings
6. **Defaults**: Set sensible defaults to reduce required fields
7. **Validation depth**: Balance validation thoroughness with performance
8. **Test schemas**: Write tests for both happy path and error cases
9. **Documentation**: Document complex validation rules with comments
10. **Partial updates**: Use `.partial()` for PATCH endpoints

## Type Inference

```typescript
import { z } from 'zod'

const userSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
})

// Infer TypeScript type from schema
type User = z.infer<typeof userSchema>
// { id: string; name: string; email: string; }

// For input validation only
type UserInput = z.input<typeof userSchema>
// { id: string | number; name: string | number; email: string | number; }

// For output validation only
type UserOutput = z.output<typeof userSchema>
// { id: string; name: string; email: string; }
```
