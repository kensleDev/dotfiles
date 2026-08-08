# Development and Debugging

Read this when the user asks about HMR, dev workflow, DevTools, inspect flags, renderer/runtime debugging, or live reload issues.

## HMR

Use `--hmr` for development:

```bash
deno desktop --hmr main.ts
deno desktop --hmr .
```

For detected frameworks, Deno Desktop can run the framework dev workflow and point the webview at it. The goal is to preserve the same fast refresh and overlays the user sees in a browser.

For plain `Deno.serve()` apps, source changes can be hot-swapped where possible.

## Changes that may require restart

Tell users to restart when changes involve:

- Adding or removing imports.
- Changing class shapes used by existing instances.
- Changing top-level setup that only runs on first module load.
- Resetting module-level state that HMR preserved.
- Changing build/config files that the framework does not reload.
- Switching backend or permissions.

## DevTools commands

```bash
deno desktop --inspect main.ts
deno desktop --inspect-wait main.ts
deno desktop --inspect-brk main.ts
deno desktop --inspect=127.0.0.1:9230 main.ts
```

Then open `chrome://inspect` or `edge://inspect` and attach to the app target.

Flag meanings:

| Flag | Behaviour |
| --- | --- |
| `--inspect` | Starts immediately and listens for debugger attach |
| `--inspect-wait` | Waits before running user code |
| `--inspect-brk` | Waits and breaks on the first line |

## Backend note

For renderer debugging, prefer CEF:

```bash
deno desktop --backend cef --inspect .
```

Unified DevTools are strongest with CEF. With system webviews, renderer DevTools support may be limited or unavailable, though Deno-side inspection can still be useful.

## Debugging bindings

Binding calls cross from renderer JS into Deno-side handlers. Cross-boundary step-through may not feel like a single stack trace. Use matching log tags on both sides:

```ts
win.bind("readSettings", async () => {
  console.log("[bindings:readSettings] enter");
  const settings = await readSettings();
  console.log("[bindings:readSettings] exit");
  return settings;
});
```

Renderer:

```ts
console.log("[bindings:readSettings] call");
const settings = await bindings.readSettings();
console.log("[bindings:readSettings] result", settings);
```

## Practical debugging checklist

1. Confirm `deno --version` supports desktop.
2. Reproduce with a minimal entry point or framework build.
3. If it is renderer-only, try `--backend cef`.
4. If it is startup-related, run with `--inspect-wait`.
5. If it is HMR-related, run a clean production build.
6. If it is a permission problem, inspect the exact flags passed to `deno desktop`.
7. If it is an asset problem, check bundled paths and avoid `Deno.cwd()` assumptions.
