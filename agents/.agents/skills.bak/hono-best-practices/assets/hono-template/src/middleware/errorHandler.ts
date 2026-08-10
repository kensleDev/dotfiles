import { Context, Next } from 'hono'
import { z } from 'zod'

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: unknown
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export const errorHandler = async (c: Context, next: Next) => {
  try {
    await next()
  } catch (err) {
    const requestId = c.get('requestId')
    console.error(`[${requestId}] Error:`, err)

    if (err instanceof AppError) {
      return c.json(
        {
          error: {
            code: err.code,
            message: err.message,
            details: err.details,
            requestId,
          },
        },
        err.statusCode
      )
    }

    if (err instanceof z.ZodError) {
      return c.json(
        {
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid request data',
            details: err.issues.map(issue => ({
              path: issue.path.join('.'),
              message: issue.message,
            })),
            requestId,
          },
        },
        400
      )
    }

    // Unknown errors
    const message = process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : (err as Error).message

    return c.json(
      {
        error: {
          code: 'INTERNAL_ERROR',
          message,
          requestId,
        },
      },
      500
    )
  }
}
