# Bindings

Read this when the user needs webview-to-Deno calls, `win.bind()`, type safety, serialization rules, or native privileged actions from UI code.

## When to use bindings

Use bindings when renderer code needs Deno-side privileges:

- File system reads/writes.
- App settings.
- OS dialogs or native operations.
- Access to secrets or local credentials.
- Work that should not be exposed as a public HTTP route.

Use normal `fetch()` for ordinary app API routes.

## Minimal example

Deno side:

```ts
const win = new Deno.BrowserWindow({ title: "Settings demo" });

win.bind("readSettings", async () => {
  const text = await Deno.readTextFile("settings.json");
  return JSON.parse(text);
});

win.bind("saveSettings", async (settings) => {
  await Deno.writeTextFile(
    "settings.json",
    JSON.stringify(settings, null, 2),
  );
});
```

Webview side:

```ts
const settings = await bindings.readSettings();
settings.theme = "dark";
await bindings.saveSettings(settings);
```

## Rules

- Binding calls from the webview return `Promise`s.
- Keep payloads JSON-compatible.
- Supported shapes include plain objects, arrays, strings, numbers, booleans, `null`, and `Uint8Array`.
- Convert `Date`, `Map`, `Set`, `RegExp`, custom class instances, and non-`Uint8Array` typed arrays before sending.
- Do not send DOM nodes, functions, prototypes, symbols, or cyclic objects.
- Do not rely on `undefined`; it may be dropped during serialization.
- Thrown Deno-side errors should be treated as serialized error data in the renderer.

## Type declarations

For framework apps, add a global declaration file:

```ts
// src/desktop-bindings.d.ts
export {};

interface Settings {
  theme: "light" | "dark";
}

declare global {
  const bindings: {
    readSettings(): Promise<Settings>;
    saveSettings(settings: Settings): Promise<void>;
  };
}
```

## Validation pattern

Validate data crossing the boundary. Treat renderer input as untrusted even though it is your UI.

```ts
interface SaveSettingsInput {
  theme: "light" | "dark";
}

function isSaveSettingsInput(value: unknown): value is SaveSettingsInput {
  return typeof value === "object" &&
    value !== null &&
    ((value as { theme?: unknown }).theme === "light" ||
      (value as { theme?: unknown }).theme === "dark");
}

win.bind("saveSettings", async (input: unknown) => {
  if (!isSaveSettingsInput(input)) {
    throw new TypeError("Invalid settings payload");
  }

  await Deno.writeTextFile("settings.json", JSON.stringify(input, null, 2));
});
```

## Design guidance

Good binding design:

- Coarse-grained actions: `readSettings`, `saveSettings`, `selectProjectFolder`.
- Plain inputs and outputs.
- Deno-side validation.
- Clear error messages.
- Small, documented surface area.

Avoid:

- One binding per UI event.
- Passing framework objects across the boundary.
- Sending class instances and expecting prototypes to survive.
- Giving the renderer a generic “run anything” binding.
