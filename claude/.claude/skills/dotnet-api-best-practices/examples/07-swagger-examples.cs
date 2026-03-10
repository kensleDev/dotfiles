public sealed class WidgetOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        if (!operation.Responses.TryGetValue("200", out var response))
        {
            return;
        }

        response.Content["application/json"].Example = new OpenApiObject
        {
            ["id"] = new OpenApiString("11111111-1111-1111-1111-111111111111"),
            ["name"] = new OpenApiString("Sample widget"),
            ["description"] = new OpenApiString("Example payload"),
            ["createdAt"] = new OpenApiString("2026-01-01T12:00:00Z")
        };
    }
}
