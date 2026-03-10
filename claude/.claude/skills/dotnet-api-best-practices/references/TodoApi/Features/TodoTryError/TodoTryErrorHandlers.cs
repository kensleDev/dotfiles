using System.Linq;
using TodoApi.Features.TodoTryError.Services;
using TodoApi.Features.Todos.Models;
using TryError;

namespace TodoApi.Features.TodoTryError;

public static class TodoTryErrorHandlers
{
    public static async Task<IResult> GetAllAsync(
        int? page,
        int? pageSize,
        string? sortBy,
        bool? desc,
        ITodoTryErrorService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var pageValue = page ?? 1;
        var pageSizeValue = pageSize ?? 20;
        var descValue = desc ?? false;

        var result = await service.GetListAsync(
            pageValue,
            pageSizeValue,
            sortBy,
            descValue,
            cancellationToken);

        return result.ToApiResult(response =>
        {
            if (response is null)
            {
                return Results.Problem(
                    detail: "Todo list not available.",
                    statusCode: StatusCodes.Status500InternalServerError);
            }

            var etag = GenerateListETag(response.Items, response.Total, response.Page, response.PageSize, sortBy, descValue);
            if (httpContext.Request.Headers.IfNoneMatch == etag)
            {
                return Results.StatusCode(StatusCodes.Status304NotModified);
            }

            httpContext.Response.Headers.ETag = etag;
            httpContext.Response.Headers.CacheControl = "no-cache";
            return Results.Ok(response);
        });
    }

    public static async Task<IResult> GetByIdAsync(
        Guid id,
        ITodoTryErrorService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var result = await service.GetByIdAsync(id, cancellationToken);

        return result.ToApiResult(response =>
        {
            if (response is null)
            {
                return Results.NotFound();
            }

            var etag = GenerateEntityETag(response);
            if (httpContext.Request.Headers.IfNoneMatch == etag)
            {
                return Results.StatusCode(StatusCodes.Status304NotModified);
            }

            httpContext.Response.Headers.ETag = etag;
            httpContext.Response.Headers.CacheControl = "no-cache";
            return Results.Ok(response);
        });
    }

    public static async Task<IResult> CreateAsync(
        CreateTodoRequest request,
        ITodoTryErrorService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var result = await service.CreateAsync(request, cancellationToken);

        return result.ToApiResult(response =>
        {
            if (response is null)
            {
                return Results.Problem(
                    detail: "Todo could not be created.",
                    statusCode: StatusCodes.Status500InternalServerError);
            }

            var etag = GenerateEntityETag(response);
            httpContext.Response.Headers.ETag = etag;
            httpContext.Response.Headers.CacheControl = "no-cache";
            return Results.Created($"/todos-try-error/{response.Id}", response);
        });
    }

    public static async Task<IResult> UpdateAsync(
        Guid id,
        UpdateTodoRequest request,
        ITodoTryErrorService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var result = await service.UpdateAsync(id, request, cancellationToken);

        return result.ToApiResult(response =>
        {
            if (response is null)
            {
                return Results.NotFound();
            }

            var etag = GenerateEntityETag(response);
            httpContext.Response.Headers.ETag = etag;
            httpContext.Response.Headers.CacheControl = "no-cache";
            return Results.Ok(response);
        });
    }

    public static async Task<IResult> DeleteAsync(
        Guid id,
        ITodoTryErrorService service,
        CancellationToken cancellationToken)
    {
        var result = await service.DeleteAsync(id, cancellationToken);

        return result.ToApiResult(response =>
            response ? Results.NoContent() : Results.NotFound());
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
