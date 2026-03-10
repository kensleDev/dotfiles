using TodoApi.Features.Todos.Models;
using TryError;

namespace TodoApi.Features.TodoTryError.Services;

public interface ITodoTryErrorService
{
    Task<TryResult<TodoListResponse?>> GetListAsync(
        int page,
        int pageSize,
        string? sortBy,
        bool desc,
        CancellationToken cancellationToken = default);
    Task<TryResult<TodoDto?>> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TryResult<TodoDto?>> CreateAsync(CreateTodoRequest request, CancellationToken cancellationToken = default);
    Task<TryResult<TodoDto?>> UpdateAsync(Guid id, UpdateTodoRequest request, CancellationToken cancellationToken = default);
    Task<TryResult<bool>> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}
