using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace TodoApi.Infrastructure.Swagger;

public sealed class TodoOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        var path = context.ApiDescription.RelativePath;
        var method = context.ApiDescription.HttpMethod;

        if (string.IsNullOrWhiteSpace(path) || string.IsNullOrWhiteSpace(method))
        {
            return;
        }

        if (IsTodosList(path, method))
        {
            ApplyListMetadata(operation);
            ApplyListResponseExample(operation);
            return;
        }

        if (IsTodoById(path, method))
        {
            ApplyGetByIdResponseExample(operation);
            return;
        }

        if (IsCreateTodo(path, method))
        {
            ApplyCreateRequestExample(operation);
            ApplyCreateResponseExample(operation);
            return;
        }

        if (IsUpdateTodo(path, method))
        {
            ApplyUpdateRequestExample(operation);
            ApplyUpdateResponseExample(operation);
        }
    }

    private static bool IsTodosList(string path, string method)
        => method.Equals("GET", StringComparison.OrdinalIgnoreCase)
            && IsTodosPath(path);

    private static bool IsTodoById(string path, string method)
        => method.Equals("GET", StringComparison.OrdinalIgnoreCase)
            && IsTodoByIdPath(path);

    private static bool IsCreateTodo(string path, string method)
        => method.Equals("POST", StringComparison.OrdinalIgnoreCase)
            && IsTodosPath(path);

    private static bool IsUpdateTodo(string path, string method)
        => method.Equals("PUT", StringComparison.OrdinalIgnoreCase)
            && IsTodoByIdPath(path);

    private static bool IsTodosPath(string path)
        => path.Equals("todos", StringComparison.OrdinalIgnoreCase)
            || path.Equals("todos-try-error", StringComparison.OrdinalIgnoreCase);

    private static bool IsTodoByIdPath(string path)
        => path.Equals("todos/{id}", StringComparison.OrdinalIgnoreCase)
            || path.Equals("todos-try-error/{id}", StringComparison.OrdinalIgnoreCase);

    private static void ApplyListMetadata(OpenApiOperation operation)
    {
        operation.Parameters ??= new List<OpenApiParameter>();
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "page",
            In = ParameterLocation.Query,
            Required = false,
            Description = "1-based page index.",
            Schema = new OpenApiSchema { Type = "integer", Default = new OpenApiInteger(1) }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "pageSize",
            In = ParameterLocation.Query,
            Required = false,
            Description = "Items per page (1-200).",
            Schema = new OpenApiSchema { Type = "integer", Default = new OpenApiInteger(20) }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "sortBy",
            In = ParameterLocation.Query,
            Required = false,
            Description = "Sort field.",
            Schema = new OpenApiSchema
            {
                Type = "string",
                Enum = new List<IOpenApiAny>
                {
                    new OpenApiString("created"),
                    new OpenApiString("title"),
                    new OpenApiString("completed"),
                    new OpenApiString("updated")
                }
            }
        });
        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "desc",
            In = ParameterLocation.Query,
            Required = false,
            Description = "Sort descending when true.",
            Schema = new OpenApiSchema { Type = "boolean", Default = new OpenApiBoolean(false) }
        });
    }

    private static void ApplyListResponseExample(OpenApiOperation operation)
    {
        if (!operation.Responses.TryGetValue("200", out var response))
        {
            return;
        }

        response.Content["application/json"].Example = new OpenApiObject
        {
            ["page"] = new OpenApiInteger(1),
            ["pageSize"] = new OpenApiInteger(20),
            ["total"] = new OpenApiLong(2),
            ["items"] = new OpenApiArray
            {
                new OpenApiObject
                {
                    ["id"] = new OpenApiString("11111111-1111-1111-1111-111111111111"),
                    ["title"] = new OpenApiString("Read minimal API docs"),
                    ["description"] = new OpenApiString("Explore routing and endpoint filters"),
                    ["isCompleted"] = new OpenApiBoolean(false),
                    ["createdAt"] = new OpenApiString("2026-01-01T12:00:00Z"),
                    ["updatedAt"] = new OpenApiString("2026-01-01T12:00:00Z")
                }
            }
        };
    }

    private static void ApplyGetByIdResponseExample(OpenApiOperation operation)
    {
        if (!operation.Responses.TryGetValue("200", out var response))
        {
            return;
        }

        response.Content["application/json"].Example = new OpenApiObject
        {
            ["id"] = new OpenApiString("11111111-1111-1111-1111-111111111111"),
            ["title"] = new OpenApiString("Read minimal API docs"),
            ["description"] = new OpenApiString("Explore routing and endpoint filters"),
            ["isCompleted"] = new OpenApiBoolean(false),
            ["createdAt"] = new OpenApiString("2026-01-01T12:00:00Z"),
            ["updatedAt"] = new OpenApiString("2026-01-01T12:00:00Z")
        };
    }

    private static void ApplyCreateRequestExample(OpenApiOperation operation)
    {
        operation.RequestBody ??= new OpenApiRequestBody();
        operation.RequestBody.Required = true;
        operation.RequestBody.Content["application/json"] = new OpenApiMediaType
        {
            Example = new OpenApiObject
            {
                ["title"] = new OpenApiString("Write documentation"),
                ["description"] = new OpenApiString("Add README and usage notes")
            }
        };
    }

    private static void ApplyCreateResponseExample(OpenApiOperation operation)
    {
        if (!operation.Responses.TryGetValue("201", out var response))
        {
            return;
        }

        response.Content["application/json"].Example = new OpenApiObject
        {
            ["id"] = new OpenApiString("22222222-2222-2222-2222-222222222222"),
            ["title"] = new OpenApiString("Write documentation"),
            ["description"] = new OpenApiString("Add README and usage notes"),
            ["isCompleted"] = new OpenApiBoolean(false),
            ["createdAt"] = new OpenApiString("2026-01-02T09:30:00Z"),
            ["updatedAt"] = new OpenApiNull()
        };
    }

    private static void ApplyUpdateRequestExample(OpenApiOperation operation)
    {
        operation.RequestBody ??= new OpenApiRequestBody();
        operation.RequestBody.Required = true;
        operation.RequestBody.Content["application/json"] = new OpenApiMediaType
        {
            Example = new OpenApiObject
            {
                ["title"] = new OpenApiString("Write documentation"),
                ["description"] = new OpenApiString("Add README and usage notes"),
                ["isCompleted"] = new OpenApiBoolean(true)
            }
        };
    }

    private static void ApplyUpdateResponseExample(OpenApiOperation operation)
    {
        if (!operation.Responses.TryGetValue("200", out var response))
        {
            return;
        }

        response.Content["application/json"].Example = new OpenApiObject
        {
            ["id"] = new OpenApiString("22222222-2222-2222-2222-222222222222"),
            ["title"] = new OpenApiString("Write documentation"),
            ["description"] = new OpenApiString("Add README and usage notes"),
            ["isCompleted"] = new OpenApiBoolean(true),
            ["createdAt"] = new OpenApiString("2026-01-02T09:30:00Z"),
            ["updatedAt"] = new OpenApiString("2026-01-02T10:00:00Z")
        };
    }
}
