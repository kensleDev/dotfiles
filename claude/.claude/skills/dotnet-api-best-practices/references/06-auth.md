# API key auth

API key auth is enforced via middleware.

Conventions:

- Middleware: `references/TodoApi/Auth/ApiKeyMiddleware.cs`.
- Options: `ApiKeyOptions` in `references/TodoApi/Auth/ApiKeyOptions.cs`.
- Public endpoints are explicitly allowed (`/`, `/health`).
- API key header default: `X-Api-Key`.

Config:

- `ApiKey:Value` must be set.
