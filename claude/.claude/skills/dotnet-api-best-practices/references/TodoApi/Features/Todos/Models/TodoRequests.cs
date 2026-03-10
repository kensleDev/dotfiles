namespace TodoApi.Features.Todos.Models;

public sealed record CreateTodoRequest(
    string Title,
    string? Description);

public sealed record UpdateTodoRequest(
    string Title,
    string? Description,
    bool IsCompleted);
