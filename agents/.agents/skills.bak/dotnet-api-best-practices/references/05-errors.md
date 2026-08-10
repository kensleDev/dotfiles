# Errors and ProblemDetails

Global exception handling uses `IExceptionHandler` + ProblemDetails.

Conventions:

- Register `AddExceptionHandler<GlobalExceptionHandler>()`.
- Call `app.UseExceptionHandler()` before other middleware.
- Use ProblemDetails for consistent 500 responses.

Optional domain error records exist in `references/TodoApi/Common/Errors/AppError.cs`.
Handlers in this repo mostly return `Results.NotFound()` or `Results.ValidationProblem()`.
