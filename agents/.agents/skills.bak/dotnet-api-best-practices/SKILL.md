---
name: dotnet-api-best-practices
description: Minimal API conventions and templates for fast, production-ready ASP.NET Core services, including TryError patterns, migrations, observability, auth, rate limiting, CORS, and proxy headers.
---

# dotnet-api-best-practices

Index for the minimal API conventions and templates used in this repo.
This is a progressive-disclosure index; details live in /references and /examples.

## Scope

- Minimal API conventions from `references/TodoApi`
- TryError handling pattern (`TryError` + `ToApiResult`)
- Templates for spinning up new features fast

## Quick-start checklist

- Create a feature folder under `references/TodoApi/Features/<FeatureName>/`
- Add models, handlers, services, validation, mapping
- Register services in `AddAppServices`
- Map endpoints with `MapGroup`, tags, metadata, filters
- Add rate limits per endpoint
- Wire validation via `ValidationFilter`
- Use ProblemDetails and global exception handler
- Use TryError pattern if explicit error tuples are desired
- Use local NuGet feed for TryError when available (see `references/11-tryerror.md`)
- Update Swagger examples if needed

## Adding to an existing monorepo

To add the API into an existing Turborepo:

```bash
# From your monorepo root
./path/to/dotnet-api-best-practices/scripts/08-init-api.sh <ProjectName> <SolutionName> [ApiName] apps/api .
```

Notes:
- This scaffolds into `apps/api` under the current repo.
- Use `ApiName` to control the singular/plural rename (defaults to `ProjectName`).

## References

- Structure and feature layout: `references/01-structure.md`
- DI and options binding: `references/02-di-and-options.md`
- Endpoint conventions: `references/03-endpoints.md`
- Validation conventions: `references/04-validation.md`
- Error handling and ProblemDetails: `references/05-errors.md`
- API key auth: `references/06-auth.md`
- Rate limiting policies: `references/07-rate-limiting.md`
- Swagger metadata and examples: `references/08-swagger.md`
- Health checks and EF Core setup: `references/09-health-and-db.md`
- ETag caching patterns: `references/10-etags.md`
- TryError pattern: `references/11-tryerror.md`
- Tests and benchmarks: `references/12-tests-and-benchmarks.md`
- EF Core migrations: `references/13-migrations.md`
- Secrets and config: `references/14-secrets.md`
- Observability: `references/15-observability.md`
- CORS policy: `references/16-cors.md`
- Proxy headers: `references/17-proxy-headers.md`
- Remaining gaps and recommendations: `references/18-gaps-and-recommendations.md`

## Examples

- Feature skeleton layout: `examples/01-feature-skeleton.md`
- Endpoint group template: `examples/02-endpoint-group.cs`
- CRUD handlers with ETags: `examples/03-handlers-crud.cs`
- TryError handlers pattern: `examples/04-tryerror-handlers.cs`
- FluentValidation templates: `examples/05-validators.cs`
- DI registration snippet: `examples/06-di-registration.cs`
- Swagger example snippets: `examples/07-swagger-examples.cs`
- Init scripts: `scripts/08-init-api.sh` (single repo) or `scripts/init-monorepo.sh` (monorepo)
