import type { Context, Next } from 'hono'

export class ValidationError extends Error {
  fields: Record<string, string>
  constructor(message: string, fields: Record<string, string>) {
    super(message)
    this.name = 'ValidationError'
    this.fields = fields
  }
}

export const errorHandlerMiddleware = async (c: Context, next: Next) => {
  try {
    await next()
  } catch (error) {
    console.error('[Error]', error)

    // Validation errors
    if (error instanceof ValidationError) {
      return c.json(
        {
          error: 'Validation Failed',
          message: 'The request contains invalid data',
          fields: error.fields,
        },
        400
      )
    }

    // Hono HTTP errors
    if (error && typeof error === 'object' && 'status' in error) {
      return c.json(
        {
          error: (error as any).message || 'Request failed',
          message: (error as any).message,
        },
        (error as any).status || 500
      )
    }

    // Default error response
    const isDev = process.env.NODE_ENV === 'development'
    const status = (error as any).status || 500

    return c.json(
      {
        error: isDev ? 'Internal Server Error' : 'An error occurred',
        message: isDev ? (error as Error).message : 'Please try again later',
        ...(isDev && { stack: (error as Error).stack }),
      },
      status
    )
  }
}
