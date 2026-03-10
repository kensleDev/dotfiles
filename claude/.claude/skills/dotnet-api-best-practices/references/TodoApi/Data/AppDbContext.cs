using Microsoft.EntityFrameworkCore;
using TodoApi.Features.Todos.Models;

namespace TodoApi.Data;

public sealed class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<Todo> Todos { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Todo>(entity =>
        {
            entity.HasKey(todo => todo.Id);
            entity.Property(todo => todo.Title).HasMaxLength(200).IsRequired();
            entity.Property(todo => todo.Description).HasMaxLength(1000);
            entity.Property(todo => todo.CreatedAt)
                .HasConversion(
                    value => value.UtcDateTime,
                    value => new DateTimeOffset(DateTime.SpecifyKind(value, DateTimeKind.Utc)));
            entity.Property(todo => todo.UpdatedAt)
                .HasConversion(
                    value => value.HasValue ? value.Value.UtcDateTime : (DateTime?)null,
                    value => value.HasValue
                        ? new DateTimeOffset(DateTime.SpecifyKind(value.Value, DateTimeKind.Utc))
                        : null);
        });
    }
}
