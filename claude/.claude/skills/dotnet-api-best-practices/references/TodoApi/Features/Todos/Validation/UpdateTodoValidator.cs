using FluentValidation;
using TodoApi.Features.Todos.Models;

namespace TodoApi.Features.Todos.Validation;

public sealed class UpdateTodoValidator : AbstractValidator<UpdateTodoRequest>
{
    public UpdateTodoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Description)
            .MaximumLength(1000)
            .When(x => x.Description is not null);
    }
}
