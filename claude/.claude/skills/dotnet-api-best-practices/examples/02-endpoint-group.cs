public static class WidgetEndpoints
{
    public static IEndpointRouteBuilder MapWidgetEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/widgets")
            .WithTags("Widgets")
            .AddEndpointFilter<ValidationFilter>();

        group.MapGet("/", WidgetHandlers.GetAllAsync)
            .WithName("GetWidgets")
            .WithSummary("List widgets")
            .Produces<WidgetListResponse>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status304NotModified)
            .RequireRateLimiting("ReadHeavy");

        group.MapGet("/{id:guid}", WidgetHandlers.GetByIdAsync)
            .WithName("GetWidget")
            .WithSummary("Get a widget")
            .Produces<WidgetDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .Produces(StatusCodes.Status304NotModified)
            .RequireRateLimiting("ReadHeavy");

        group.MapPost("/", WidgetHandlers.CreateAsync)
            .WithName("CreateWidget")
            .WithSummary("Create a widget")
            .Accepts<CreateWidgetRequest>("application/json")
            .Produces<WidgetDto>(StatusCodes.Status201Created)
            .ProducesValidationProblem()
            .RequireRateLimiting("WriteStrict");

        group.MapPut("/{id:guid}", WidgetHandlers.UpdateAsync)
            .WithName("UpdateWidget")
            .WithSummary("Update a widget")
            .Accepts<UpdateWidgetRequest>("application/json")
            .Produces<WidgetDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound)
            .ProducesValidationProblem()
            .RequireRateLimiting("WriteStrict");

        group.MapDelete("/{id:guid}", WidgetHandlers.DeleteAsync)
            .WithName("DeleteWidget")
            .WithSummary("Delete a widget")
            .Produces(StatusCodes.Status204NoContent)
            .Produces(StatusCodes.Status404NotFound)
            .RequireRateLimiting("WriteStrict");

        return app;
    }
}
