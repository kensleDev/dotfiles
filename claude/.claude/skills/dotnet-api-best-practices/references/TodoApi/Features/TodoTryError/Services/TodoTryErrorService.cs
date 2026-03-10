using Microsoft.EntityFrameworkCore;
using TodoApi.Data;
using TodoApi.Features.Todos.Mapping;
using TodoApi.Features.Todos.Models;
using TryError;

namespace TodoApi.Features.TodoTryError.Services;

public sealed class TodoTryErrorService : ITodoTryErrorService
{
    private readonly AppDbContext _dbContext;

    public TodoTryErrorService(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<TryResult<TodoListResponse?>> GetListAsync(
        int page,
        int pageSize,
        string? sortBy,
        bool desc,
        CancellationToken cancellationToken = default)
    {
        return Try.TryPromise<TodoListResponse?>(async () =>
        {
            page = page < 1 ? 1 : page;
            pageSize = pageSize is < 1 or > 200 ? 20 : pageSize;

            IQueryable<Todo> query = _dbContext.Todos.AsNoTracking();

            query = sortBy?.ToLowerInvariant() switch
            {
                "title" => desc ? query.OrderByDescending(todo => todo.Title) : query.OrderBy(todo => todo.Title),
                "completed" => desc ? query.OrderByDescending(todo => todo.IsCompleted) : query.OrderBy(todo => todo.IsCompleted),
                "updated" => desc ? query.OrderByDescending(todo => todo.UpdatedAt) : query.OrderBy(todo => todo.UpdatedAt),
                _ => desc ? query.OrderByDescending(todo => todo.CreatedAt) : query.OrderBy(todo => todo.CreatedAt)
            };

            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(todo => TodoMapper.ToDto(todo))
                .ToListAsync(cancellationToken);

            var total = await _dbContext.Todos.LongCountAsync(cancellationToken);

            return new TodoListResponse(page, pageSize, total, items);
        });
    }

    public Task<TryResult<TodoDto?>> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return Try.TryPromise(async () =>
            await _dbContext.Todos
                .AsNoTracking()
                .Where(todo => todo.Id == id)
                .Select(todo => TodoMapper.ToDto(todo))
                .SingleOrDefaultAsync(cancellationToken));
    }

    public Task<TryResult<TodoDto?>> CreateAsync(
        CreateTodoRequest request,
        CancellationToken cancellationToken = default)
    {
        return Try.TryPromise<TodoDto?>(async () =>
        {
            var todo = new Todo
            {
                Id = Guid.NewGuid(),
                Title = request.Title,
                Description = request.Description,
                IsCompleted = false,
                CreatedAt = DateTimeOffset.UtcNow
            };

            _dbContext.Todos.Add(todo);
            await _dbContext.SaveChangesAsync(cancellationToken);

            return TodoMapper.ToDto(todo);
        });
    }

    public Task<TryResult<TodoDto?>> UpdateAsync(
        Guid id,
        UpdateTodoRequest request,
        CancellationToken cancellationToken = default)
    {
        return Try.TryPromise(async () =>
        {
            var todo = await _dbContext.Todos.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
            if (todo is null)
            {
                return null;
            }

            todo.Title = request.Title;
            todo.Description = request.Description;
            todo.IsCompleted = request.IsCompleted;
            todo.UpdatedAt = DateTimeOffset.UtcNow;

            await _dbContext.SaveChangesAsync(cancellationToken);

            return TodoMapper.ToDto(todo);
        });
    }

    public Task<TryResult<bool>> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return Try.TryPromise(async () =>
        {
            var todo = await _dbContext.Todos.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
            if (todo is null)
            {
                return false;
            }

            _dbContext.Todos.Remove(todo);
            await _dbContext.SaveChangesAsync(cancellationToken);
            return true;
        });
    }
}
