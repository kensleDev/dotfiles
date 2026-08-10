# Swagger

Swagger is enabled in development only.

Conventions:

- Add `AddEndpointsApiExplorer()`.
- Configure `AddSwaggerGen()` in `AddAppServices`.
- Use an operation filter for request/response examples.

See `references/TodoApi/Infrastructure/Swagger/TodoOperationFilter.cs`.
