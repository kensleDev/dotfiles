# Secrets and config

Secrets are handled via user secrets in development and environment variables in production.

User secrets setup:

- `dotnet user-secrets --project references/TodoApi set "ApiKey:Value" "dev-key"`
- `dotnet user-secrets --project references/TodoApi set "ConnectionStrings:Default" "Data Source=todo.db"`

`UserSecretsId` is set in `references/TodoApi/TodoApi.csproj` so `CreateBuilder` loads them automatically.
