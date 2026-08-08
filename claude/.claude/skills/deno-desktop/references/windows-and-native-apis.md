# Windows and Native APIs

Read this when the user asks about `Deno.BrowserWindow`, multiple windows, window lifecycle, native UI integration, dialogs, menus, tray/dock, or notifications.

## BrowserWindow basics

`Deno.BrowserWindow` controls native windows. Deno opens an initial startup window automatically. The first `new Deno.BrowserWindow()` adopts that startup window; later constructions open additional windows.

```ts
const main = new Deno.BrowserWindow({
  title: "My App",
  width: 1000,
  height: 700,
});
```

## Multiple windows

Use `DENO_SERVE_ADDRESS` only when you need to construct a route URL for another window:

```ts
const addr = Deno.env.get("DENO_SERVE_ADDRESS")!; // tcp:127.0.0.1:<port>
const port = addr.split(":").pop();

const settings = new Deno.BrowserWindow({
  title: "Settings",
  width: 420,
  height: 320,
});

settings.navigate(`http://127.0.0.1:${port}/settings`);
```

Do not use a hard-coded framework dev-server port for production windows.

## Common window operations

```ts
win.show();
win.hide();
win.focus();
win.reload();
win.close();

const [width, height] = win.getSize();
win.setSize(900, 700);

const [x, y] = win.getPosition();
win.setPosition(x, y);

win.setResizable(false);
win.setAlwaysOnTop(true);
```

Persist window size and position yourself if needed. Do not assume the OS or runtime will restore application-specific layout state for you.

## Native API guidance

Use native integrations sparingly and keep behaviour predictable:

- Menus: app menus and context menus.
- Tray/dock: background/status apps and macOS dock behaviour.
- Dialogs: native `alert()`, `confirm()`, and `prompt()` behaviour where appropriate.
- Notifications: use the Web `Notification` API and configure a stable app identifier for real apps.

## When to use bindings instead

If the renderer needs to ask Deno to perform privileged work, use `win.bind()` rather than trying to expose privileged operations through browser-only code.

Examples:

- Read or write settings.
- Pick a file and then read it.
- Call a local model or system command.
- Access credentials or private paths.

## Window architecture tips

- Use URL routes for screens: `/`, `/settings`, `/about`, `/debug`.
- Keep window creation on the Deno side.
- Keep UI state inside the framework where possible.
- Use bindings for native actions, not for every tiny UI event.
- Avoid opening many windows for state that could be a modal or route.
