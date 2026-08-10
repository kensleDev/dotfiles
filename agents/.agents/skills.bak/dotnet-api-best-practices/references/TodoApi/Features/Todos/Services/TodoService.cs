using TodoApi.Data;
using TodoApi.Features.Todos.Models;
using TodoApi.Features.Todos.Mapping;
using Microsoft.EntityFrameworkCore;

namespace TodoApi.Features.Todos.Services;

public sealed class TodoService : ITodoService
{
    private readonly AppDbContext _dbContext;

    public TodoService(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<TodoDto>> GetAllAsync(
        int page,
        int pageSize,
        string? sortBy,
        bool desc,
        CancellationToken cancellationToken = default)
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

        var todos = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(todo => TodoMapper.ToDto(todo))
            .ToListAsync(cancellationToken);

        return todos;
    }

    public Task<long> GetCountAsync(CancellationToken cancellationToken = default)
    {
        return _dbContext.Todos.LongCountAsync(cancellationToken);
    }

    public Task<TodoDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return _dbContext.Todos
            .AsNoTracking()
            .Where(todo => todo.Id == id)
            .Select(todo => TodoMapper.ToDto(todo))
            .SingleOrDefaultAsync(cancellationToken);
    }

    public async Task<TodoDto> CreateAsync(CreateTodoRequest request, CancellationToken cancellationToken = default)
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
    }

    public async Task<TodoDto?> UpdateAsync(Guid id, UpdateTodoRequest request, CancellationToken cancellationToken = default)
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
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var todo = await _dbContext.Todos.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (todo is null)
        {
            return false;
        }

        _dbContext.Todos.Remove(todo);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }
}
