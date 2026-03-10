using TodoApi.Data;

namespace TodoApi.Infrastructure.Health;

public static class HealthCheckExtensions
{
    public static IServiceCollection AddAppHealthChecks(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHealthChecks()
            .AddDbContextCheck<AppDbContext>("db");

        return services;
    }
}
