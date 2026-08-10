using TodoApi.Features.Todos.Models;
using TodoApi.Features.Todos.Services;
using System.Linq;

namespace TodoApi.Features.Todos;

public static class TodoHandlers
{
    public static async Task<IResult> GetAllAsync(
        int? page,
        int? pageSize,
        string? sortBy,
        bool? desc,
        ITodoService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var pageValue = page ?? 1;
        var pageSizeValue = pageSize ?? 20;
        var descValue = desc ?? false;

        var todos = await service.GetAllAsync(pageValue, pageSizeValue, sortBy, descValue, cancellationToken);
        var total = await service.GetCountAsync(cancellationToken);

        var etag = GenerateListETag(todos, total, pageValue, pageSizeValue, sortBy, descValue);
        if (httpContext.Request.Headers.IfNoneMatch == etag)
        {
            return Results.StatusCode(StatusCodes.Status304NotModified);
        }

        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Ok(new TodoListResponse(pageValue, pageSizeValue, total, todos));
    }

    public static async Task<IResult> GetByIdAsync(
        Guid id,
        ITodoService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var todo = await service.GetByIdAsync(id, cancellationToken);
        if (todo is null)
        {
            return Results.NotFound();
        }

        var etag = GenerateEntityETag(todo);
        if (httpContext.Request.Headers.IfNoneMatch == etag)
        {
            return Results.StatusCode(StatusCodes.Status304NotModified);
        }

        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Ok(todo);
    }

    public static async Task<IResult> CreateAsync(
        CreateTodoRequest request,
        ITodoService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var todo = await service.CreateAsync(request, cancellationToken);
        var etag = GenerateEntityETag(todo);
        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Created($"/todos/{todo.Id}", todo);
    }

    public static async Task<IResult> UpdateAsync(
        Guid id,
        UpdateTodoRequest request,
        ITodoService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var todo = await service.UpdateAsync(id, request, cancellationToken);
        if (todo is null)
        {
            return Results.NotFound();
        }

        var etag = GenerateEntityETag(todo);
        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Ok(todo);
    }

    public static async Task<IResult> DeleteAsync(Guid id, ITodoService service, CancellationToken cancellationToken)
    {
        var removed = await service.DeleteAsync(id, cancellationToken);
        return removed ? Results.NoContent() : Results.NotFound();
    }

    private static string GenerateEntityETag(TodoDto todo)
    {
        return $"\"{todo.Id}:{todo.UpdatedAt?.ToUnixTimeSeconds() ?? todo.CreatedAt.ToUnixTimeSeconds()}\"";
    }

    private static string GenerateListETag(
        IReadOnlyList<TodoDto> todos,
        long total,
        int page,
        int pageSize,
        string? sortBy,
        bool desc)
    {
        var lastStamp = todos.Count == 0
            ? 0
            : todos.Max(t => (t.UpdatedAt ?? t.CreatedAt).ToUnixTimeSeconds());

        var key = $"{total}:{page}:{pageSize}:{sortBy}:{desc}:{lastStamp}";
        return $"\"{key}\"";
    }
}
