# Observability

OpenTelemetry is wired for traces and metrics.

Conventions:

- ASP.NET Core + HttpClient instrumentation enabled.
- Runtime metrics enabled.
- Console exporter in development.
- OTLP exporter is enabled when `OTEL_EXPORTER_OTLP_ENDPOINT` is set.

See `references/TodoApi/Infrastructure/Observability/ObservabilityExtensions.cs`.
