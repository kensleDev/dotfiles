# Structure

Feature-based layout mirrors `references/TodoApi/Features/Todos` and `references/TodoApi/Features/TodoTryError`.

Recommended folder shape per feature:

- `Endpoints.cs` for `MapGroup` + route metadata
- `Handlers.cs` for request/response logic
- `Services/` for data access and domain operations
- `Models/` for request/response types and entities
- `Validation/` for FluentValidation validators
- `Mapping/` for DTO mappers when needed

See concrete structure in `references/TodoApi/Features/Todos/`.
