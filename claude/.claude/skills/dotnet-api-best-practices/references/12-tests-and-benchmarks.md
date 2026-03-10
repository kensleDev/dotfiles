# Tests and benchmarks

Existing tests and perf tooling live in `TryError.Tests` and `TryError.Benchmarks`.

Commands:

- Unit tests: `dotnet test TryError.Tests/TryError.Tests.csproj`
- Benchmarks: `dotnet run -c Release --project TryError.Benchmarks/TryError.Benchmarks.csproj`

When adding API tests, use `WebApplicationFactory` for integration tests and keep
minimal API handler logic unit-testable via services.
