# Troubleshooting

Read this when the user reports an error, command not found, missing script, app startup failure, blank window, asset issue, port issue, or packaging problem.

## `deno desktop` command missing

Check Deno version:

```bash
deno --version
```

If older than Deno 2.9, update:

```bash
deno upgrade
```

## Turbo says task/script does not exist

Likely causes:

- The task is defined in `turbo.json` but not in the selected package.
- The command is using Bun to run a root script instead of asking Turbo to run a package task.
- The `--filter` package name does not match the package's `name` field.

Correct shape:

```bash
bunx turbo run desktop:dev --filter=desktop
```

Selected package must contain:

```jsonc
{
  "name": "desktop",
  "scripts": {
    "desktop:dev": "deno desktop --hmr ."
  }
}
```

`turbo.json` should declare the task too:

```jsonc
{
  "tasks": {
    "desktop:dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

## Framework app packages but opens blank

Check:

1. Was the framework built first?
2. Was `deno desktop .` run from the app directory?
3. Is the app expecting a hard-coded external port?
4. Are assets referenced with absolute file-system paths?
5. Does the app require env vars at runtime that are missing in the desktop app?
6. Does the backend support the browser APIs used by the UI?

Try:

```bash
npm run build
deno desktop --backend cef --inspect .
```

## Port confusion

Do not set a fixed port for production desktop serving. In desktop mode Deno manages the local port. Only read `DENO_SERVE_ADDRESS` to construct URLs for additional windows:

```ts
const addr = Deno.env.get("DENO_SERVE_ADDRESS")!;
const port = addr.split(":").pop();
```

## Permission denied after packaging

Permissions must be passed to `deno desktop` because they are baked into the app:

```bash
deno desktop --allow-read=./data --allow-write=./data main.ts
```

Do not debug a packaged permission issue only with `deno run -A`; reproduce with the actual `deno desktop` command.

## Assets work in dev but not packaged

Avoid `Deno.cwd()` and fragile relative paths. Prefer:

- Framework-managed static/public assets.
- Paths derived from `import.meta.url`.
- Explicit embedded/bundled assets.
- A tiny explicit server for static builds.

## WebView backend rendering differs by OS

Try CEF:

```bash
deno desktop --backend cef .
```

If CEF fixes it, explain the tradeoff: bigger app bundle in exchange for Chromium consistency and stronger renderer debugging.

## HMR stuck or inconsistent

Restart the app when changing imports, config files, top-level state, permissions, or backend. Then test production packaging separately:

```bash
npm run build
deno desktop .
```

## Installer/cross-compile issue

Check:

- Target triple is supported.
- Output extension matches the intended format.
- The host OS supports the packaging step required for that format.
- CI uses platform runners for release artifacts.
- Signing/notarization is configured for public macOS distribution.
