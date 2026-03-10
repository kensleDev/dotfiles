# Rate limiting

Rate limiting is configured globally and per endpoint.

Policies from `references/TodoApi/Program.cs`:

- Global: 100 requests/min per IP
- `ReadHeavy`: 300 requests/min per IP
- `WriteStrict`: 30 requests/min per IP

Conventions:

- Apply `.RequireRateLimiting("ReadHeavy")` on GET list/detail.
- Apply `.RequireRateLimiting("WriteStrict")` on POST/PUT/DELETE.
- Use `.DisableRateLimiting()` for `/` and `/health`.
