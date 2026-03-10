# DI and options

All services and options are registered in `references/TodoApi/Common/Extensions/ServiceCollectionExtensions.cs` via `AddAppServices`.

Conventions:

- Options are bound + validated with data annotations.
- `ValidateOnStart` is used for startup validation.
- DbContext configured via options (SQLite in this repo).

Examples:

- `ApiKeyOptions` in `references/TodoApi/Auth/ApiKeyOptions.cs`.
- `ConnectionStringsOptions` in `references/TodoApi/Infrastructure/Options/ConnectionStringsOptions.cs`.

When adding a new feature service:

- Add interface + implementation under `Features/<FeatureName>/Services/`.
- Register in `AddAppServices` with scoped lifetime.
