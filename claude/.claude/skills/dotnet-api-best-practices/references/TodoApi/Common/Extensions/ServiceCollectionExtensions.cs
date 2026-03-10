using FluentValidation;
using Microsoft.AspNetCore.HttpLogging;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using TodoApi.Auth;
using TodoApi.Common.Errors;
using TodoApi.Common.Validation;
using TodoApi.Data;
using TodoApi.Data.Seed;
using TodoApi.Infrastructure.Options;
using TodoApi.Features.TodoTryError.Services;
using TodoApi.Features.Todos.Services;
using TodoApi.Infrastructure.Health;
using TodoApi.Infrastructure.Swagger;

namespace TodoApi.Common.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddAppServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<ApiKeyOptions>()
            .Bind(configuration.GetSection(ApiKeyOptions.SectionName))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services.AddOptions<ConnectionStringsOptions>()
            .Bind(configuration.GetSection(ConnectionStringsOptions.SectionName))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services.AddOptions<CorsSettings>()
            .Bind(configuration.GetSection(CorsSettings.SectionName))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services.AddDbContext<AppDbContext>((serviceProvider, options) =>
        {
            var connectionStrings = serviceProvider.GetRequiredService<IOptions<ConnectionStringsOptions>>().Value;
            var sqliteConnectionString = BuildSqliteConnectionString(connectionStrings.Default!);
            options.UseSqlite(sqliteConnectionString);
        });

        services.AddValidatorsFromAssembly(typeof(ServiceCollectionExtensions).Assembly);
        services.AddScoped<ValidationFilter>();

        services.AddScoped<ITodoService, TodoService>();
        services.AddScoped<ITodoTryErrorService, TodoTryErrorService>();
        services.AddScoped<DbSeeder>();

        services.AddExceptionHandler<GlobalExceptionHandler>();
        services.AddProblemDetails();

        services.AddHttpLogging(options =>
        {
            options.LoggingFields = HttpLoggingFields.RequestMethod
                | HttpLoggingFields.RequestPath
                | HttpLoggingFields.ResponseStatusCode
                | HttpLoggingFields.Duration;
        });

        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
            {
                Title = "Todo API",
                Version = "v1"
            });

            options.SupportNonNullableReferenceTypes();

            options.AddSecurityDefinition("ApiKey", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
                In = Microsoft.OpenApi.Models.ParameterLocation.Header,
                Name = "X-Api-Key",
                Description = "API key required to access endpoints."
            });

            options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
            {
                {
                    new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                    {
                        Reference = new Microsoft.OpenApi.Models.OpenApiReference
                        {
                            Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                            Id = "ApiKey"
                        }
                    },
                    Array.Empty<string>()
                }
            });

            options.MapType<TodoApi.Features.Todos.Models.TodoListResponse>(() =>
                new Microsoft.OpenApi.Models.OpenApiSchema
                {
                    Type = "object",
                    Example = new Microsoft.OpenApi.Any.OpenApiObject
                    {
                        ["page"] = new Microsoft.OpenApi.Any.OpenApiInteger(1),
                        ["pageSize"] = new Microsoft.OpenApi.Any.OpenApiInteger(20),
                        ["total"] = new Microsoft.OpenApi.Any.OpenApiLong(2),
                        ["items"] = new Microsoft.OpenApi.Any.OpenApiArray
                        {
                            new Microsoft.OpenApi.Any.OpenApiObject
                            {
                                ["id"] = new Microsoft.OpenApi.Any.OpenApiString("11111111-1111-1111-1111-111111111111"),
                                ["title"] = new Microsoft.OpenApi.Any.OpenApiString("Read minimal API docs"),
                                ["description"] = new Microsoft.OpenApi.Any.OpenApiString("Explore routing and endpoint filters"),
                                ["isCompleted"] = new Microsoft.OpenApi.Any.OpenApiBoolean(false),
                                ["createdAt"] = new Microsoft.OpenApi.Any.OpenApiString("2026-01-01T12:00:00Z"),
                                ["updatedAt"] = new Microsoft.OpenApi.Any.OpenApiString("2026-01-01T12:00:00Z")
                            }
                        }
                    }
                });

            options.OperationFilter<TodoOperationFilter>();
        });

        services.AddAppHealthChecks(configuration);

        var corsSettings = configuration.GetSection(CorsSettings.SectionName).Get<CorsSettings>()
            ?? new CorsSettings();

        services.AddCors(options =>
        {
            options.AddPolicy("Default", policy =>
            {
                if (corsSettings.AllowedOrigins.Length == 0)
                {
                    return;
                }

                policy.WithOrigins(corsSettings.AllowedOrigins)
                    .AllowAnyHeader()
                    .AllowAnyMethod();

                if (corsSettings.AllowCredentials)
                {
                    policy.AllowCredentials();
                }
            });
        });

        return services;
    }

    private static string BuildSqliteConnectionString(string connectionString)
    {
        var builder = new SqliteConnectionStringBuilder(connectionString);
        if (string.IsNullOrWhiteSpace(builder.DataSource))
        {
            throw new InvalidOperationException("SQLite connection string must include a Data Source.");
        }

        builder.Mode = SqliteOpenMode.ReadWriteCreate;
        builder.Cache = SqliteCacheMode.Shared;
        builder.Pooling = true;
        builder.DefaultTimeout = 5;
        return builder.ToString();
    }
}
