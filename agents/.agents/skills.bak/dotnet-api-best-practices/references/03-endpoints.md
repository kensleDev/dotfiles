# Endpoint conventions

Endpoints are grouped with `MapGroup` and tagged.

Pattern used in `references/TodoApi/Features/Todos/TodoEndpoints.cs`:

- Group at a feature root path (ex: `/todos`).
- Add `WithTags` for Swagger.
- Apply `ValidationFilter` at group level.
- Add `WithName`, `WithSummary`, `WithDescription`.
- Add `Produces` metadata and `Accepts` for request bodies.
- Apply rate limiting per endpoint.

Use the endpoint group template in `examples/02-endpoint-group.cs`.
