# Hono API Template

Production-ready Hono API boilerplate with middleware, validation, and testing setup.

## Quick Start

```bash
# Copy template
cp -r . your-project/
cd your-project

# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test
```

## Project Structure

```
src/
├── index.ts              # Main app entry point
├── middleware/          # Reusable middleware
│   ├── auth.ts          # Authentication/authorization
│   ├── error-handler.ts # Error handling
│   ├── rate-limit.ts   # Rate limiting
│   └── request-id.ts   # Request ID generation
└── routes/              # Route handlers
    ├── auth.ts          # Authentication endpoints
    ├── users.ts         # User management
    └── posts.ts         # Post management
```

## Features

- ✅ TypeScript with strict mode
- ✅ Zod validation middleware
- ✅ Built-in middleware (logger, CORS)
- ✅ Custom middleware (auth, rate limiting, error handling)
- ✅ Request ID tracking
- ✅ Vitest test setup
- ✅ Example routes with validation
- ✅ Error handling patterns

## Development

```bash
npm run dev         # Start development server
npm run build       # Build TypeScript
npm run test        # Run tests
npm run test:ui     # Run tests with UI
npm run lint        # Run ESLint
npm run lint:fix    # Fix ESLint issues
npm run typecheck   # Type check without emit
```

## Testing

```bash
npm test            # Run all tests
npm run test:ui     # Run tests with Vitest UI
npm run test:coverage # Run with coverage report
```

## Configuration

- `NODE_ENV`: Set to `development` or `production`
- `CORS_ORIGIN`: Comma-separated list of allowed origins (default: http://localhost:3000)

## TODO Items

The template includes TODO comments where you need to implement:

1. Token verification in `src/middleware/auth.ts`
2. Database operations in `src/routes/*.ts`
3. Adjust middleware for your authentication system
4. Add environment variables as needed

## Next Steps

1. Set up your database (Drizzle, Prisma, etc.)
2. Implement actual business logic in routes
3. Configure authentication (JWT, OAuth, session)
4. Add API documentation (OpenAPI/Swagger)
5. Set up CI/CD pipeline
