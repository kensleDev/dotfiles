public static class WidgetHandlers
{
    public static async Task<IResult> GetAllAsync(
        int? page,
        int? pageSize,
        string? sortBy,
        bool? desc,
        IWidgetService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var pageValue = page ?? 1;
        var pageSizeValue = pageSize ?? 20;
        var descValue = desc ?? false;

        var list = await service.GetAllAsync(pageValue, pageSizeValue, sortBy, descValue, cancellationToken);
        var total = await service.GetCountAsync(cancellationToken);

        var etag = GenerateListETag(list.Items, total, pageValue, pageSizeValue, sortBy, descValue);
        if (httpContext.Request.Headers.IfNoneMatch == etag)
        {
            return Results.StatusCode(StatusCodes.Status304NotModified);
        }

        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Ok(list);
    }

    public static async Task<IResult> GetByIdAsync(
        Guid id,
        IWidgetService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var widget = await service.GetByIdAsync(id, cancellationToken);
        if (widget is null)
        {
            return Results.NotFound();
        }

        var etag = GenerateEntityETag(widget);
        if (httpContext.Request.Headers.IfNoneMatch == etag)
        {
            return Results.StatusCode(StatusCodes.Status304NotModified);
        }

        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Ok(widget);
    }

    public static async Task<IResult> CreateAsync(
        CreateWidgetRequest request,
        IWidgetService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var widget = await service.CreateAsync(request, cancellationToken);
        var etag = GenerateEntityETag(widget);
        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Created($"/widgets/{widget.Id}", widget);
    }

    public static async Task<IResult> UpdateAsync(
        Guid id,
        UpdateWidgetRequest request,
        IWidgetService service,
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var widget = await service.UpdateAsync(id, request, cancellationToken);
        if (widget is null)
        {
            return Results.NotFound();
        }

        var etag = GenerateEntityETag(widget);
        httpContext.Response.Headers.ETag = etag;
        httpContext.Response.Headers.CacheControl = "no-cache";
        return Results.Ok(widget);
    }

    public static async Task<IResult> DeleteAsync(
        Guid id,
        IWidgetService service,
        CancellationToken cancellationToken)
    {
        var removed = await service.DeleteAsync(id, cancellationToken);
        return removed ? Results.NoContent() : Results.NotFound();
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
