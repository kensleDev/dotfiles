using Microsoft.EntityFrameworkCore;
using TodoApi.Features.Todos.Models;

namespace TodoApi.Data.Seed;

public sealed class DbSeeder
{
    public async Task SeedAsync(AppDbContext dbContext, CancellationToken cancellationToken = default)
    {
        if (await dbContext.Todos.AnyAsync(cancellationToken))
        {
            return;
        }

        var now = DateTimeOffset.UtcNow;

        dbContext.Todos.AddRange(
            new Todo
            {
                Id = Guid.NewGuid(),
                Title = "Read minimal API docs",
                Description = "Explore routing and endpoint filters",
                IsCompleted = false,
                CreatedAt = now
            },
            new Todo
            {
                Id = Guid.NewGuid(),
                Title = "Add health checks",
                Description = "Expose /health endpoint",
                IsCompleted = true,
                CreatedAt = now
            });

        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
