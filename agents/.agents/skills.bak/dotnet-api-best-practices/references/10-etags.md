# ETags

List and detail endpoints emit ETags and honor `If-None-Match`.

Conventions:

- Set `Response.Headers.ETag` and `Cache-Control: no-cache`.
- If `If-None-Match` matches, return 304.

See `references/TodoApi/Features/Todos/TodoHandlers.cs` for list + entity ETag logic.
