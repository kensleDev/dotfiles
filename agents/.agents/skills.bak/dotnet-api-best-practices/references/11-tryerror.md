# TryError pattern

TryError provides explicit error tuple results to avoid exception flow in handlers.

Conventions:

- Services return `TryResult<T>` and wrap work in `Try.TryPromise`.
- Handlers map to `IResult` via `ToApiResult` in `TryError/TryApiExtensions.cs`.

Reference implementation:

- Feature: `references/TodoApi/Features/TodoTryError/`
- Library: `TryError/`

Local feed install (preferred while private):

- `dotnet nuget add source "/Users/kd/nuget-local" -n Local`
- `dotnet add package TryError --version 0.1.0`

Public fallback (once published):

- `dotnet add package TryError`
