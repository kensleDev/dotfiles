# Backends

Read this when the user is choosing between `webview`, `cef`, and `raw`, or when rendering/debugging differs by platform.

## Backend choices

| Backend | Use when | Tradeoff |
| --- | --- | --- |
| `webview` | Small apps, internal tools, apps that use broadly supported web features | Smallest bundles, but rendering depends on WKWebView, WebView2, or WebKitGTK |
| `cef` | Consistent Chromium rendering, WebGPU/WebRTC-heavy apps, renderer DevTools, cross-platform visual parity | Larger bundles because Chromium Embedded Framework is included |
| `raw` | Custom-rendered apps with no HTML/webview | No webview, no `Deno.serve()` auto-binding, no `bindings.<name>()` bridge |

Default to `webview`. Recommend `cef` only when the user needs its benefits.

## Commands

```bash
deno desktop --backend webview main.ts
deno desktop --backend cef main.ts
```

The `raw` backend is configured in `deno.json`:

```jsonc
{
  "desktop": {
    "backend": "raw"
  }
}
```

## Practical recommendations

Use `webview` when:

- The app is mostly forms, dashboards, settings, CRUD, or internal tooling.
- Small app size matters.
- The UI avoids cutting-edge browser APIs.
- Differences between system webviews are acceptable.

Use `cef` when:

- The UI must look the same across macOS, Windows, and Linux.
- The app depends on Chromium-specific behaviour.
- The user needs WebGPU or consistent WebRTC support.
- The user needs unified DevTools for renderer and Deno runtime.
- The issue is difficult to debug with the system webview.

Use `raw` when:

- The app does not render HTML.
- The user is building a custom rendering stack.
- The app needs windows/input/clipboard/native APIs but not a webview.

## Debugging backend issues

When a rendering bug appears only on one platform:

1. Ask which backend they are using.
2. Reproduce with `--backend cef` to separate app bugs from system-webview differences.
3. If `cef` fixes it, decide whether consistent rendering is worth the larger bundle.
4. If `cef` does not fix it, debug normal browser/app code.

## DevTools caveat

Unified DevTools are strongest with the CEF backend. With other backends, Deno-side inspection may still work, but renderer inspection may not be available in the same unified way.
