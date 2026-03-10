using TodoApi.Common.Validation;
using TodoApi.Features.Todos.Models;

namespace TodoApi.Features.TodoTryError;

public static class TodoTryErrorEndpoints
{
    public static IEndpointRouteBuilder MapTodoTryErrorEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/todos-try-error")
            .WithTags("Todos")
            .AddEndpointFilter<ValidationFilter>();

        group.MapGet("/", TodoTryErrorHandlers.GetAllAsync)
            .WithName("GetTodosTryError")
            .WithSummary("List todos (TryError)")
            .WithDescription("Returns a paged list of todos with optional sorting.")
            .Produces<TodoListResponse>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status304NotModified)
            .RequireRateLimiting("ReadHeavy");

        group.MapGet("/{id:guid}", TodoTryErrorHandlers.GetByIdAsync)
            .WithName("GetTodoTryError")
            .WithSummary("Get a todo (TryError)")
            .Produces<TodoDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .Produces(StatusCodes.Status304NotModified)
            .RequireRateLimiting("ReadHeavy");

        group.MapPost("/", TodoTryErrorHandlers.CreateAsync)
            .WithName("CreateTodoTryError")
            .WithSummary("Create a todo (TryError)")
            .Accepts<CreateTodoRequest>("application/json")
            .Produces<TodoDto>(StatusCodes.Status201Created)
            .ProducesValidationProblem()
            .RequireRateLimiting("WriteStrict");

        group.MapPut("/{id:guid}", TodoTryErrorHandlers.UpdateAsync)
            .WithName("UpdateTodoTryError")
            .WithSummary("Update a todo (TryError)")
            .Accepts<UpdateTodoRequest>("application/json")
            .Produces<TodoDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesValidationProblem()
            .RequireRateLimiting("WriteStrict");

        group.MapDelete("/{id:guid}", TodoTryErrorHandlers.DeleteAsync)
            .WithName("DeleteTodoTryError")
            .WithSummary("Delete a todo (TryError)")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .RequireRateLimiting("WriteStrict");

        return app;
    }
}
