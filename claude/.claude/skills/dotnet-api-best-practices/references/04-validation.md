# Validation

Validation uses FluentValidation + a global endpoint filter.

Conventions:

- Validators live under `Features/<FeatureName>/Validation/`.
- `ValidationFilter` is registered as a scoped service in DI.
- Endpoint groups call `.AddEndpointFilter<ValidationFilter>()`.

See `references/TodoApi/Common/Validation/ValidationFilter.cs` and
validators in `references/TodoApi/Features/Todos/Validation/`.
