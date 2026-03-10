# Proxy headers

Forwarded headers are enabled so IP-based rate limiting works behind proxies.

Conventions:

- `X-Forwarded-For` and `X-Forwarded-Proto` are accepted.
- Known networks/proxies are cleared to allow containerized deployments.

See `references/TodoApi/Program.cs`.
