using Microsoft.Extensions.Options;
using Microsoft.Extensions.Primitives;

namespace TodoApi.Auth;

public sealed class ApiKeyMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ApiKeyOptions _options;

    public ApiKeyMiddleware(RequestDelegate next, IOptions<ApiKeyOptions> options)
    {
        _next = next;
        _options = options.Value;
    }

    public Task InvokeAsync(HttpContext context)
    {
        if (IsPublicEndpoint(context.Request.Path))
        {
            return _next(context);
        }

        if (string.IsNullOrWhiteSpace(_options.Value))
        {
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            return context.Response.WriteAsJsonAsync(new { error = "API key is not configured." });
        }

        var headerName = string.IsNullOrWhiteSpace(_options.HeaderName)
            ? "X-Api-Key"
            : _options.HeaderName;

        if (!context.Request.Headers.TryGetValue(headerName, out var providedKey))
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return context.Response.WriteAsJsonAsync(new { error = "Missing API key." });
        }

        if (!StringValues.Equals(providedKey, _options.Value))
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return context.Response.WriteAsJsonAsync(new { error = "Invalid API key." });
        }

        return _next(context);
    }

    private static bool IsPublicEndpoint(PathString path)
    {
        return path.Equals("/", StringComparison.OrdinalIgnoreCase)
            || path.Equals("/health", StringComparison.OrdinalIgnoreCase);
    }
}
