using TodoApi.Auth;
using TodoApi.Common.Extensions;
using TodoApi.Data;
using TodoApi.Data.Seed;
using TodoApi.Features.Todos;
using TodoApi.Infrastructure.Logging;
using TodoApi.Infrastructure.Observability;
using TodoApi.Features.TodoTryError;
using Microsoft.EntityFrameworkCore;
using TryError;
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.HttpOverrides;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.AddStructuredLogging(builder.Configuration);
builder.Services.AddAppServices(builder.Configuration);
builder.Services.AddObservability(builder.Environment);
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownIPNetworks.Clear();
    options.KnownProxies.Clear();
});
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
    {
        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetFixedWindowLimiter(key, _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = 100,
            Window = TimeSpan.FromMinutes(1),
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0
        });
    });

    options.AddPolicy("ReadHeavy", context =>
    {
        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetFixedWindowLimiter(key, _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = 300,
            Window = TimeSpan.FromMinutes(1),
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0
        });
    });

    options.AddPolicy("WriteStrict", context =>
    {
        var key = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetFixedWindowLimiter(key, _ => new FixedWindowRateLimiterOptions
        {
            PermitLimit = 30,
            Window = TimeSpan.FromMinutes(1),
            QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
            QueueLimit = 0
        });
    });
});

var app = builder.Build();

app.UseForwardedHeaders();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseExceptionHandler();
app.UseHttpsRedirection();
app.UseHttpLogging();
app.UseCors("Default");
app.UseRateLimiter();
app.UseMiddleware<ApiKeyMiddleware>();

app.MapGet("/", () => Results.Ok(new { status = "ok" }))
    .DisableRateLimiting();
app.MapGet("/try-error", async (HttpContext context) =>
{
    var shouldFail = context.Request.Query.ContainsKey("fail");
    var result = await Try.TryPromise(async () =>
    {
        if (shouldFail)
        {
            throw new InvalidOperationException("Simulated failure");
        }

        await Task.Delay(10);
        return "ok";
    });

    return result.ToApiResult(value => Results.Ok(new { value }));
});
app.MapHealthChecks("/health")
    .DisableRateLimiting();
app.MapTodoEndpoints();
app.MapTodoTryErrorEndpoints();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await dbContext.Database.MigrateAsync();
    var seeder = scope.ServiceProvider.GetRequiredService<DbSeeder>();
    await seeder.SeedAsync(dbContext);
}

app.Run();
