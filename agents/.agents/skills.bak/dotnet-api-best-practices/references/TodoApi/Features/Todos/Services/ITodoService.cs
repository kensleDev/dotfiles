using TodoApi.Features.Todos.Models;

namespace TodoApi.Features.Todos.Services;

public interface ITodoService
{
    Task<IReadOnlyList<TodoDto>> GetAllAsync(
        int page,
        int pageSize,
        string? sortBy,
        bool desc,
        CancellationToken cancellationToken = default);
    Task<TodoDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TodoDto> CreateAsync(CreateTodoRequest request, CancellationToken cancellationToken = default);
    Task<TodoDto?> UpdateAsync(Guid id, UpdateTodoRequest request, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task<long> GetCountAsync(CancellationToken cancellationToken = default);
}
