public static class WidgetTryErrorHandlers
{
    public static async Task<IResult> GetAllAsync(
        int? page,
        int? pageSize,
        string? sortBy,
        bool? desc,
        IWidgetTryErrorService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var pageValue = page ?? 1;
        var pageSizeValue = pageSize ?? 20;
        var descValue = desc ?? false;

        var result = await service.GetListAsync(pageValue, pageSizeValue, sortBy, descValue, cancellationToken);

        return result.ToApiResult(response =>
        {
            if (response is null)
            {
                return Results.Problem(detail: "Widget list not available.", statusCode: StatusCodes.Status500InternalServerError);
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
        IWidgetTryErrorService service,
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
        CreateWidgetRequest request,
        IWidgetTryErrorService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var result = await service.CreateAsync(request, cancellationToken);

        return result.ToApiResult(response =>
        {
            if (response is null)
            {
                return Results.Problem(detail: "Widget could not be created.", statusCode: StatusCodes.Status500InternalServerError);
            }

            var etag = GenerateEntityETag(response);
            httpContext.Response.Headers.ETag = etag;
            httpContext.Response.Headers.CacheControl = "no-cache";
            return Results.Created($"/widgets-try-error/{response.Id}", response);
        });
    }

    public static async Task<IResult> UpdateAsync(
        Guid id,
        UpdateWidgetRequest request,
        IWidgetTryErrorService service,
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
        IWidgetTryErrorService service,
        CancellationToken cancellationToken)
    {
        var result = await service.DeleteAsync(id, cancellationToken);
        return result.ToApiResult(response => response ? Results.NoContent() : Results.NotFound());
    }

    private static string GenerateEntityETag(WidgetDto widget)
    {
        return $"\"{widget.Id}:{widget.UpdatedAt?.ToUnixTimeSeconds() ?? widget.CreatedAt.ToUnixTimeSeconds()}\"";
    }

    private static string GenerateListETag(
        IReadOnlyList<WidgetDto> items,
        long total,
        int page,
        int pageSize,
        string? sortBy,
        bool desc)
    {
        var lastStamp = items.Count == 0
            ? 0
            : items.Max(item => (item.UpdatedAt ?? item.CreatedAt).ToUnixTimeSeconds());

        var key = $"{total}:{page}:{pageSize}:{sortBy}:{desc}:{lastStamp}";
        return $"\"{key}\"";
    }
}
