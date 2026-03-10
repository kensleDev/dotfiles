using TodoApi.Common.Validation;
using TodoApi.Features.Todos.Models;

namespace TodoApi.Features.Todos;

public static class TodoEndpoints
{
    public static IEndpointRouteBuilder MapTodoEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/todos")
            .WithTags("Todos")
            .AddEndpointFilter<ValidationFilter>();

        group.MapGet("/", TodoHandlers.GetAllAsync)
            .WithName("GetTodos")
            .WithSummary("List todos")
            .WithDescription("Returns a paged list of todos with optional sorting.")
            .Produces<TodoListResponse>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status304NotModified)
            .RequireRateLimiting("ReadHeavy");

        group.MapGet("/{id:guid}", TodoHandlers.GetByIdAsync)
            .WithName("GetTodo")
            .WithSummary("Get a todo")
            .Produces<TodoDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .Produces(StatusCodes.Status304NotModified)
            .RequireRateLimiting("ReadHeavy");

        group.MapPost("/", TodoHandlers.CreateAsync)
            .WithName("CreateTodo")
            .WithSummary("Create a todo")
            .Accepts<CreateTodoRequest>("application/json")
            .Produces<TodoDto>(StatusCodes.Status201Created)
            .ProducesValidationProblem()
            .RequireRateLimiting("WriteStrict");

        group.MapPut("/{id:guid}", TodoHandlers.UpdateAsync)
            .WithName("UpdateTodo")
            .WithSummary("Update a todo")
            .Accepts<UpdateTodoRequest>("application/json")
            .Produces<TodoDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesValidationProblem()
            .RequireRateLimiting("WriteStrict");

        group.MapDelete("/{id:guid}", TodoHandlers.DeleteAsync)
            .WithName("DeleteTodo")
            .WithSummary("Delete a todo")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .RequireRateLimiting("WriteStrict");

        return app;
    }
}
