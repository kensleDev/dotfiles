namespace TodoApi.Features.Todos.Models;

public sealed record TodoListResponse(
    int Page,
    int PageSize,
    long Total,
    IReadOnlyList<TodoDto> Items);
