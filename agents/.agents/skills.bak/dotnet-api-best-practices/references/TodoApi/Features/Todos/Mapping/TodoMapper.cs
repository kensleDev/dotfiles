using TodoApi.Features.Todos.Models;

namespace TodoApi.Features.Todos.Mapping;

public static class TodoMapper
{
    public static TodoDto ToDto(Todo todo)
    {
        return new TodoDto(
            todo.Id,
            todo.Title,
            todo.Description,
            todo.IsCompleted,
            todo.CreatedAt,
            todo.UpdatedAt);
    }
}
