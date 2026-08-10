/**
 * Test utility functions
 */

export function createTestToken(payload: any): string {
  // In production, this would use a real JWT library
  // For testing, we use a simple mock token
  return `test-token-${Buffer.from(JSON.stringify(payload)).toString('base64')}`
}

export async function authenticatedRequest(
  app: any,
  path: string,
  token: string,
  options?: RequestInit
) {
  return app.request(path, {
    ...options,
    headers: {
      ...options?.headers,
      'Authorization': `Bearer ${token}`,
    },
  })
}
