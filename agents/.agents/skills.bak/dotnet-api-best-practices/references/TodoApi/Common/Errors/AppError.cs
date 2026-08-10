using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Common.Errors;

public abstract record AppError(string Code, string Message)
{
    public virtual ProblemDetails ToProblemDetails(int statusCode)
    {
        return new ProblemDetails
        {
            Status = statusCode,
            Title = Code,
            Detail = Message
        };
    }
}

public sealed record NotFoundError(string Message) : AppError("NotFound", Message);

public sealed record ValidationError(string Message) : AppError("Validation", Message);

public sealed record ConflictError(string Message) : AppError("Conflict", Message);

public sealed record UnauthorizedError(string Message) : AppError("Unauthorized", Message);
