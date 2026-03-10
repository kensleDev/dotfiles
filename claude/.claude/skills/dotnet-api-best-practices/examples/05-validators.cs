public sealed class CreateWidgetValidator : AbstractValidator<CreateWidgetRequest>
{
    public CreateWidgetValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Description)
            .MaximumLength(1000)
            .When(x => x.Description is not null);
    }
}

public sealed class UpdateWidgetValidator : AbstractValidator<UpdateWidgetRequest>
{
    public UpdateWidgetValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Description)
            .MaximumLength(1000)
            .When(x => x.Description is not null);
    }
}
