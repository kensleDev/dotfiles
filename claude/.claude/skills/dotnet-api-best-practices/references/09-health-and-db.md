# Health checks and EF Core

EF Core uses SQLite with normalized connection string settings.

Conventions:

- DbContext: `references/TodoApi/Data/AppDbContext.cs`.
- Connection string normalization in `ServiceCollectionExtensions`.
- Health checks add a DbContext check (`db`).
- Database is created and seeded on startup in `Program.cs`.

See `references/TodoApi/Infrastructure/Health/HealthCheckExtensions.cs` and
`references/TodoApi/Data/Seed/DbSeeder.cs`.
