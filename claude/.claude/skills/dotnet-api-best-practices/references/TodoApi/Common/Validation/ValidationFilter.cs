using FluentValidation;
using FluentValidation.Results;
using System.Linq;

namespace TodoApi.Common.Validation;

public sealed class ValidationFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        List<ValidationFailure> failures = [];

        foreach (var argument in context.Arguments)
        {
            if (argument is null)
            {
                continue;
            }

            var validatorType = typeof(IValidator<>).MakeGenericType(argument.GetType());
            var validator = context.HttpContext.RequestServices.GetService(validatorType);
            if (validator is null)
            {
                continue;
            }

            var validationResult = await ((IValidator)validator).ValidateAsync(new ValidationContext<object>(argument));
            if (!validationResult.IsValid)
            {
                failures.AddRange(validationResult.Errors);
            }
        }

        if (failures.Count > 0)
        {
            var errors = new Dictionary<string, string[]>(StringComparer.Ordinal);
            foreach (var group in failures.GroupBy(failure => failure.PropertyName ?? string.Empty))
            {
                errors[group.Key] = group.Select(f => f.ErrorMessage).ToArray();
            }

            return Results.ValidationProblem(errors);
        }

        return await next(context);
    }
}
