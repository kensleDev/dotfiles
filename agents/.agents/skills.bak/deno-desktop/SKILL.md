---
name: deno-desktop
description: Use when building, packaging, debugging, or distributing desktop apps with `deno desktop`. Covers Deno 2.9+, local HTTP serving, framework detection, BrowserWindow, bindings, backends, HMR, installers, cross-compilation, permissions, and desktop-specific `deno.json` config.
license: MIT
metadata:
  author: denoland
  version: "1.0"
---

# Deno Desktop

Deno Desktop turns a Deno entry point or supported web framework project into a native desktop bundle. Keep this file as the lightweight routing layer. Load only the reference files needed for the user's task.

## Use this skill when

The user is working with `deno desktop`, including:

- Packaging a Deno app or web framework app as a desktop app.
- Converting an existing SvelteKit, Next.js, Astro, Fresh, Remix, Nuxt, SolidStart, TanStack Start, or Vite app into a desktop bundle.
- Choosing `webview`, `cef`, or `raw` backends.
- Adding `Deno.BrowserWindow`, multi-window behaviour, bindings, menus, tray/dock, dialogs, or notifications.
- Setting up HMR, DevTools, framework build tasks, or monorepo scripts.
- Producing `.app`, `.dmg`, `.msi`, `.AppImage`, `.deb`, `.rpm`, or cross-compiled artifacts.
- Debugging desktop-specific behaviour around ports, build output, permissions, assets, or app startup.

## Do not use this skill when

- The user is only building a normal Deno CLI, API server, library, Fresh site, Deno Deploy app, or browser-only frontend.
- The user is asking about Electron, Tauri, Wails, Flutter, Swift, C#, or native platform tooling and has not asked to use Deno Desktop.
- The task is generic Deno guidance better covered by another Deno skill.

## Minimum mental model

Deno Desktop apps are local web apps packaged as desktop apps:

1. `deno desktop` builds a platform-specific bundle.
2. The desktop process starts a local HTTP server.
3. A native window opens with an embedded webview.
4. The webview navigates to the local server.
5. Browser UI code uses `fetch()` for HTTP routes and `bindings.<name>()` for privileged Deno-side calls.

Do not hard-code ports. In desktop mode, Deno selects a local port, sets `DENO_SERVE_ADDRESS`, and `Deno.serve()` binds to it.

## Fast answers

Use these defaults unless the user's context says otherwise:

```bash
# Plain Deno app
deno desktop main.ts

# Existing framework app, from the app directory
deno desktop --hmr .      # development
npm run build             # or deno task build / bun run build / pnpm build
deno desktop .            # production packaging

# Pick a backend only when needed
deno desktop --backend webview .
deno desktop --backend cef .
```

Default to `webview` for smaller apps. Recommend `cef` when the user needs consistent Chromium rendering, Chromium-only APIs, or renderer DevTools.

## Progressive disclosure routing

Read only the files needed for the current task:

| User need | Read |
| --- | --- |
| First explanation, architecture, ports, simple `Deno.serve()` app | `references/mental-model.md` |
| CLI flags, permissions, `deno.json`, app metadata, output paths | `references/commands-and-config.md` |
| SvelteKit, Next, Astro, Fresh, Vite, monorepos, Turborepo, package scripts | `references/frameworks-and-monorepos.md` |
| Backend selection: `webview`, `cef`, `raw`, cross-platform rendering | `references/backends.md` |
| `Deno.BrowserWindow`, multi-window apps, window lifecycle, native APIs | `references/windows-and-native-apis.md` |
| Webview-to-Deno calls, `win.bind()`, serialization, type declarations | `references/bindings.md` |
| HMR, DevTools, inspect flags, debugging across renderer/runtime | `references/development-debugging.md` |
| Installers, cross-compilation, CI, compression, code signing, security | `references/distribution-and-security.md` |
| Common failures and fixes | `references/troubleshooting.md` |

## Answering style

- Preserve the user's existing framework and package manager where possible.
- Prefer exact commands and minimal diffs over broad rewrites.
- For production framework packaging, include the framework build step before `deno desktop .`.
- For monorepos, run commands from the app package or use the workspace tool correctly, such as `turbo run desktop:dev --filter=<package>`.
- Mention that desktop permissions are baked into the compiled app when recommending permission flags.
- For newly released or fast-moving features, verify against the official Deno Desktop docs.
