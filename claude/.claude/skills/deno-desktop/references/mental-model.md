# Mental Model

Read this when the user needs an explanation of how Deno Desktop works, a minimal app, or guidance about local HTTP serving and ports.

## Core idea

A Deno Desktop app is still a web app at the UI layer. The app serves HTML, CSS, JavaScript, routes, APIs, and assets over local HTTP, then Deno opens a native webview pointed at that local server.

The simplest app is a normal `Deno.serve()` handler:

```ts
Deno.serve(() =>
  new Response("<h1>Hello, desktop</h1>", {
    headers: { "content-type": "text/html" },
  })
);
```

```bash
deno desktop main.ts
```

## Startup sequence

In desktop mode:

1. Deno chooses an unused local port.
2. Deno sets `DENO_SERVE_ADDRESS`, usually like `tcp:127.0.0.1:<port>`.
3. Your code calls `Deno.serve()`.
4. `Deno.serve()` uses the desktop-provided address and ignores any manually supplied port.
5. The webview navigates to `http://127.0.0.1:<port>` once the listener is ready.

Do not tell users to hard-code ports such as `3000`, `5173`, or `8000` for production desktop apps.

## Local HTTP vs bindings

Use normal HTTP routes for normal app/server concerns:

- Page rendering.
- Static assets.
- Form actions.
- Local API routes.
- WebSockets.
- Cookie/session-style flows.

Use bindings for privileged native operations:

- File system access.
- Reading/writing app settings.
- Opening native dialogs.
- Calling OS-specific or Deno-only code.
- Operations that should not be exposed as HTTP endpoints.

## Avoid Electron assumptions

Deno Desktop bindings are not Electron IPC. Prefer:

- `fetch()` for app routes.
- `win.bind()` for privileged Deno-side functions.
- `Deno.BrowserWindow` for native window lifecycle.

## Asset paths

Do not rely on `Deno.cwd()` to locate bundled assets. The app may launch with a user-controlled working directory. Prefer framework asset conventions, `import.meta.url`, embedded assets, or paths controlled by the desktop build configuration.

## Version guidance

`deno desktop` is a Deno 2.9+ feature. If the command is missing, tell the user to check `deno --version` and run:

```bash
deno upgrade
```
