# Commands and Configuration

Read this when the user asks for CLI flags, `deno.json`, app metadata, output paths, permissions, or build tasks.

## Common commands

```bash
# Build/run a desktop app for the host platform
deno desktop main.ts

# Package a detected framework app from the app root
deno desktop .

# Development with HMR
deno desktop --hmr main.ts
deno desktop --hmr .

# Choose backend
deno desktop --backend webview main.ts
deno desktop --backend cef main.ts

# Cross-compile
deno desktop --target aarch64-apple-darwin main.ts
deno desktop --target x86_64-apple-darwin main.ts
deno desktop --target x86_64-pc-windows-msvc main.ts
deno desktop --target aarch64-unknown-linux-gnu main.ts
deno desktop --target x86_64-unknown-linux-gnu main.ts
deno desktop --all-targets main.ts

# Choose output format from extension
deno desktop --output ./dist/MyApp.app main.ts
deno desktop --output ./dist/MyApp.dmg main.ts
deno desktop --output ./dist/MyApp.msi main.ts
deno desktop --output ./dist/my-app.AppImage main.ts
deno desktop --output ./dist/my-app.deb main.ts
deno desktop --output ./dist/my-app.rpm main.ts

# Compress distributable payload
deno desktop --compress main.ts
deno desktop --compress=xz main.ts
deno desktop --compress=zstd main.ts
```

## Permissions

`deno desktop` accepts Deno runtime permission flags. Permissions granted at build time are baked into the compiled app.

Prefer scoped permissions:

```bash
deno desktop   --allow-read=./config,./data   --allow-write=./config,./data   --allow-net=api.example.com   main.ts
```

Avoid `--allow-all` in production unless the app genuinely needs it.

## Desktop config skeleton

Use a `desktop` block in `deno.json` for repeatable metadata and build defaults:

```jsonc
{
  "name": "my-app",
  "version": "1.0.0",
  "tasks": {
    "desktop:dev": "deno desktop --hmr .",
    "desktop:build": "deno task build && deno desktop ."
  },
  "desktop": {
    "app": {
      "name": "My App",
      "identifier": "com.example.myapp",
      "icons": {
        "macos": "./icons/app.icns",
        "windows": "./icons/app.ico",
        "linux": "./icons/app.png"
      }
    },
    "backend": "webview",
    "output": {
      "macos": "./dist/MyApp.app",
      "windows": "./dist/windows/MyApp",
      "linux": "./dist/linux/my-app.AppImage"
    }
  }
}
```

## Config guidance

- Set a stable reverse-DNS `desktop.app.identifier` for real apps, especially if using notifications or signing.
- Use platform-native icon formats: `.icns` for macOS, `.ico` for Windows, `.png` for Linux.
- Use `desktop.output` for repeatable local/CI builds.
- Use `--output` for one-off overrides.
- Keep package scripts thin; do not hide important build steps.

## Package manager examples

```jsonc
// package.json
{
  "scripts": {
    "build": "vite build",
    "desktop:dev": "deno desktop --hmr .",
    "desktop:build": "npm run build && deno desktop ."
  }
}
```

```jsonc
// deno.json
{
  "tasks": {
    "build": "vite build",
    "desktop:dev": "deno desktop --hmr .",
    "desktop:build": "deno task build && deno desktop ."
  }
}
```

## CLI vs config priority

When both CLI flags and `deno.json` fields are present, prefer explaining CLI flags as one-off overrides and config fields as persistent defaults. For output paths, the usual priority is:

1. `--output` CLI flag.
2. `desktop.output` in `deno.json`.
3. Platform default derived from the project/app name.
