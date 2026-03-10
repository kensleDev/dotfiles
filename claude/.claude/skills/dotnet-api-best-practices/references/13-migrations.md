# Migrations

Migrations are enabled for `references/TodoApi` and are applied at startup via `MigrateAsync`.

Commands:

- Add migration: `dotnet tool run dotnet-ef migrations add <Name> --project references/TodoApi --startup-project references/TodoApi`
- Apply migrations: `dotnet tool run dotnet-ef database update --project references/TodoApi --startup-project references/TodoApi`

Migration files live under `references/TodoApi/Migrations/`.
