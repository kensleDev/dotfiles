# TypeScript Error Handling Patterns

Framework-agnostic patterns for using `@julian-i/try-error` in TypeScript applications.

## Table of Contents

1. [Basic Patterns](#basic-patterns)
2. [Type Narrowing](#type-narrowing)
3. [Custom Error Classes](#custom-error-classes)
4. [Service Layer Patterns](#service-layer-patterns)
5. [Utility Functions](#utility-functions)
6. [Testing Patterns](#testing-patterns)

---

## Basic Patterns

### Async Operations

```typescript
import { tryPromise } from '@julian-i/try-error';

// Simple async
const [data, error] = await tryPromise(fetchUser(id));

// With timeout
const [response, error] = await tryPromise(
  fetch(url, { signal: AbortSignal.timeout(5000) })
);

// Chained promises
const [result, error] = await tryPromise(
  fetch(url)
    .then(r => r.json())
    .then(data => processData(data))
);
```

### Sync Operations

```typescript
import { tryThrow } from '@julian-i/try-error';

// JSON parsing
const [parsed, error] = tryThrow(() => JSON.parse(rawString));

// Validation
const [validated, error] = tryThrow(() => schema.parse(input));

// Computation that may throw
const [result, error] = tryThrow(() => riskyCalculation(values));
```

### Early Return Pattern

```typescript
async function processOrder(orderId: string) {
  const [order, orderError] = await tryPromise(db.order.findUnique({ 
    where: { id: orderId } 
  }));
  if (orderError) return { error: 'Failed to fetch order' };
  if (!order) return { error: 'Order not found' };

  const [payment, paymentError] = await tryPromise(
    stripe.paymentIntents.create({ amount: order.total })
  );
  if (paymentError) return { error: 'Payment failed' };

  const [updated, updateError] = await tryPromise(
    db.order.update({ where: { id: orderId }, data: { status: 'paid' } })
  );
  if (updateError) return { error: 'Failed to update order' };

  return { success: true, order: updated };
}
```

---

## Type Narrowing

### Basic Narrowing

```typescript
const [user, error] = await tryPromise(fetchUser(id));

if (error) {
  // error is Error
  console.error(error.message);
  return;
}

// user is User (null eliminated by error check)
console.log(user.name);
```

### With Type Guards

```typescript
// Define specific error types
class NotFoundError extends Error {
  constructor(public resource: string, public id: string) {
    super(`${resource} not found: ${id}`);
    this.name = 'NotFoundError';
  }
}

class ValidationError extends Error {
  constructor(public field: string, public reason: string) {
    super(`Validation failed: ${field} - ${reason}`);
    this.name = 'ValidationError';
  }
}

// Type guard
function isNotFoundError(error: Error): error is NotFoundError {
  return error.name === 'NotFoundError';
}

function isValidationError(error: Error): error is ValidationError {
  return error.name === 'ValidationError';
}

// Usage
const [user, error] = await tryPromise(userService.getById(id));

if (error) {
  if (isNotFoundError(error)) {
    return { status: 404, message: `User ${error.id} not found` };
  }
  if (isValidationError(error)) {
    return { status: 400, field: error.field, message: error.reason };
  }
  // Unknown error
  console.error('[getUser]', error);
  return { status: 500, message: 'Internal error' };
}
```

### Discriminated Unions

```typescript
type Result<T, E = Error> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

// Wrapper to convert TryResult to discriminated union
function toResult<T>([value, error]: [T | null, Error | null]): Result<T> {
  if (error) return { ok: false, error };
  return { ok: true, value: value as T };
}

// Usage
const result = toResult(await tryPromise(fetchUser(id)));

if (!result.ok) {
  // result.error is Error
  return handleError(result.error);
}

// result.value is User
return result.value;
```

---

## Custom Error Classes

### Base Application Error

```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = 'AppError';
    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id?: string) {
    super(
      id ? `${resource} not found: ${id}` : `${resource} not found`,
      'NOT_FOUND',
      404
    );
    this.name = 'NotFoundError';
  }
}

export class ValidationError extends AppError {
  constructor(
    message: string,
    public fields?: Record<string, string>
  ) {
    super(message, 'VALIDATION_ERROR', 400);
    this.name = 'ValidationError';
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 'FORBIDDEN', 403);
    this.name = 'ForbiddenError';
  }
}
```

### Error Handler Utility

```typescript
export function handleAppError(error: Error): {
  statusCode: number;
  body: { error: string; code?: string; fields?: Record<string, string> };
} {
  if (error instanceof AppError) {
    return {
      statusCode: error.statusCode,
      body: {
        error: error.message,
        code: error.code,
        ...(error instanceof ValidationError && error.fields 
          ? { fields: error.fields } 
          : {})
      }
    };
  }

  // Unknown error - log and return generic
  console.error('[handleAppError] Unexpected error:', error);
  return {
    statusCode: 500,
    body: { error: 'Internal server error' }
  };
}
```

---

## Service Layer Patterns

### Repository Pattern

```typescript
export class UserRepository {
  async findById(id: string): Promise<User> {
    const [user, error] = await tryPromise(
      db.user.findUnique({ where: { id } })
    );

    if (error) {
      console.error('[UserRepository.findById]', error);
      throw new AppError('Database error', 'DB_ERROR');
    }

    if (!user) {
      throw new NotFoundError('User', id);
    }

    return user;
  }

  async create(data: CreateUserInput): Promise<User> {
    const [user, error] = await tryPromise(
      db.user.create({ data })
    );

    if (error) {
      if (error.code === 'P2002') {
        throw new ValidationError('Email already exists', { email: 'taken' });
      }
      console.error('[UserRepository.create]', error);
      throw new AppError('Database error', 'DB_ERROR');
    }

    return user;
  }
}
```

### Service Pattern

```typescript
export class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService
  ) {}

  async register(input: RegisterInput): Promise<User> {
    // Validate
    const [validated, validationError] = tryThrow(() =>
      registerSchema.parse(input)
    );
    if (validationError) {
      throw new ValidationError('Invalid input', 
        validationError.flatten().fieldErrors
      );
    }

    // Create user (repo throws on duplicate)
    const user = await this.userRepo.create({
      email: validated.email,
      passwordHash: await hash(validated.password)
    });

    // Send welcome email (non-critical, log failure)
    const [_, emailError] = await tryPromise(
      this.emailService.sendWelcome(user.email)
    );
    if (emailError) {
      console.warn('[UserService.register] Welcome email failed', emailError);
    }

    return user;
  }
}
```

### Controller/Handler Pattern

```typescript
export async function handleRegister(request: Request): Promise<Response> {
  const [body, parseError] = await tryPromise(request.json());
  if (parseError) {
    return json({ error: 'Invalid JSON' }, 400);
  }

  const [user, error] = await tryPromise(
    userService.register(body)
  );

  if (error) {
    const { statusCode, body } = handleAppError(error);
    return json(body, statusCode);
  }

  return json({ id: user.id, email: user.email }, 201);
}
```

---

## Utility Functions

### Retry with Backoff

```typescript
import { tryPromise } from '@julian-i/try-error';

interface RetryOptions {
  maxAttempts?: number;
  baseDelay?: number;
  maxDelay?: number;
  shouldRetry?: (error: Error, attempt: number) => boolean;
}

async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const {
    maxAttempts = 3,
    baseDelay = 1000,
    maxDelay = 10000,
    shouldRetry = () => true
  } = options;

  let lastError: Error;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const [result, error] = await tryPromise(fn());

    if (!error) return result;

    lastError = error;

    if (attempt === maxAttempts || !shouldRetry(error, attempt)) {
      break;
    }

    const delay = Math.min(baseDelay * 2 ** (attempt - 1), maxDelay);
    await new Promise(resolve => setTimeout(resolve, delay));
  }

  throw lastError!;
}

// Usage
const user = await withRetry(
  () => fetchUser(id),
  {
    maxAttempts: 3,
    shouldRetry: (error) => error.message.includes('timeout')
  }
);
```

### Batch Processing

```typescript
import { tryPromise } from '@julian-i/try-error';

interface BatchResult<T> {
  successes: T[];
  failures: { index: number; error: Error }[];
}

async function processBatch<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>
): Promise<BatchResult<R>> {
  const results = await Promise.all(
    items.map(async (item, index) => {
      const [result, error] = await tryPromise(processor(item));
      return { index, result, error };
    })
  );

  return {
    successes: results
      .filter(r => !r.error)
      .map(r => r.result as R),
    failures: results
      .filter(r => r.error)
      .map(r => ({ index: r.index, error: r.error as Error }))
  };
}

// Usage
const { successes, failures } = await processBatch(
  userIds,
  (id) => userService.sendNotification(id)
);

console.log(`Sent ${successes.length}, failed ${failures.length}`);
failures.forEach(f => console.error(`Failed index ${f.index}:`, f.error));
```

### Fallback Chain

```typescript
import { tryPromise } from '@julian-i/try-error';

async function withFallback<T>(
  primary: () => Promise<T>,
  ...fallbacks: (() => Promise<T>)[]
): Promise<T> {
  const [result, error] = await tryPromise(primary());
  
  if (!error) return result;

  for (const fallback of fallbacks) {
    const [fallbackResult, fallbackError] = await tryPromise(fallback());
    if (!fallbackError) return fallbackResult;
  }

  throw error; // Throw original error if all fallbacks fail
}

// Usage
const config = await withFallback(
  () => fetchRemoteConfig(),
  () => readLocalConfig(),
  () => Promise.resolve(defaultConfig)
);
```

---

## Testing Patterns

### Mocking tryPromise Results

```typescript
import { describe, it, expect, vi } from 'vitest';
import { tryPromise } from '@julian-i/try-error';

// Mock the module
vi.mock('@julian-i/try-error', () => ({
  tryPromise: vi.fn(),
  tryThrow: vi.fn()
}));

describe('UserService', () => {
  it('handles database errors', async () => {
    const mockTryPromise = vi.mocked(tryPromise);
    mockTryPromise.mockResolvedValueOnce([null, new Error('DB connection failed')]);

    const result = await userService.getUser('123');

    expect(result).toEqual({ error: 'Failed to fetch user' });
  });

  it('returns user on success', async () => {
    const mockUser = { id: '123', name: 'Test' };
    const mockTryPromise = vi.mocked(tryPromise);
    mockTryPromise.mockResolvedValueOnce([mockUser, null]);

    const result = await userService.getUser('123');

    expect(result).toEqual({ user: mockUser });
  });
});
```

### Testing Error Paths

```typescript
describe('OrderService.processOrder', () => {
  it('returns error when order not found', async () => {
    vi.mocked(tryPromise)
      .mockResolvedValueOnce([null, null]); // findUnique returns null

    const result = await orderService.processOrder('invalid-id');

    expect(result).toEqual({ error: 'Order not found' });
  });

  it('returns error when payment fails', async () => {
    const mockOrder = { id: '1', total: 100 };
    vi.mocked(tryPromise)
      .mockResolvedValueOnce([mockOrder, null]) // Order found
      .mockResolvedValueOnce([null, new Error('Card declined')]); // Payment fails

    const result = await orderService.processOrder('1');

    expect(result).toEqual({ error: 'Payment failed' });
  });

  it('processes order successfully', async () => {
    const mockOrder = { id: '1', total: 100 };
    const mockPayment = { id: 'pi_123' };
    const mockUpdated = { ...mockOrder, status: 'paid' };

    vi.mocked(tryPromise)
      .mockResolvedValueOnce([mockOrder, null])
      .mockResolvedValueOnce([mockPayment, null])
      .mockResolvedValueOnce([mockUpdated, null]);

    const result = await orderService.processOrder('1');

    expect(result).toEqual({ success: true, order: mockUpdated });
  });
});
```

### Integration Test Pattern

```typescript
describe('API Integration', () => {
  it('handles the full error flow', async () => {
    // Setup: create a user that will conflict
    await db.user.create({ data: { email: 'existing@test.com' } });

    // Test: try to create duplicate
    const response = await fetch('/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'existing@test.com' })
    });

    expect(response.status).toBe(400);
    const body = await response.json();
    expect(body.error).toBe('Email already exists');
  });
});
```
