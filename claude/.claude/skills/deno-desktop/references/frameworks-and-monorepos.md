# Frameworks and Monorepos

Read this when the user has SvelteKit, Next.js, Astro, Fresh, Remix, Nuxt, SolidStart, TanStack Start, Vite, Bun, npm, pnpm, or Turborepo.

## Default approach

Preserve the user's existing app. Do not recommend a rewrite just because Deno Desktop exists.

For development:

```bash
deno desktop --hmr .
```

For production packaging:

```bash
npm run build      # or bun run build / pnpm build / deno task build
deno desktop .
```

`deno desktop .` can detect supported framework projects and package them, but production packaging should happen after the framework build output exists.

## Framework detection

Framework detection is based on project files and dependencies. Typical signals include:

- SvelteKit: `svelte.config.*` and Vite/SvelteKit dependencies.
- Vite: `vite.config.*` or a Vite dependency.
- Next.js: `next.config.*` and Next dependencies.
- Astro: `astro.config.*`.
- Nuxt: `nuxt.config.*`.
- Fresh: Fresh project files and build output.

Do not promise detection for unusual custom builds. If detection fails, use an explicit Deno entry point that serves the built output or starts the app's production server.

## SvelteKit guidance

Prefer this for a normal SvelteKit package:

```jsonc
{
  "scripts": {
    "build": "vite build",
    "desktop:dev": "deno desktop --hmr .",
    "desktop:build": "bun run build && deno desktop ."
  }
}
```

If using npm or pnpm, preserve that package manager:

```jsonc
{
  "scripts": {
    "desktop:build": "npm run build && deno desktop ."
  }
}
```

If the app is static-only, a small explicit server can be clearer than framework detection:

```ts
// desktop.ts
import { serveDir } from "jsr:@std/http/file-server";

Deno.serve((req) => serveDir(req, { fsRoot: "./build" }));
```

```bash
bun run build
deno desktop desktop.ts
```

## Vite/static guidance

For a plain Vite SPA:

```ts
// desktop.ts
import { serveDir } from "jsr:@std/http/file-server";

Deno.serve((req) => serveDir(req, {
  fsRoot: "./dist",
  showDirListing: false,
}));
```

```jsonc
{
  "scripts": {
    "build": "vite build",
    "desktop:dev": "deno desktop --hmr .",
    "desktop:build": "vite build && deno desktop desktop.ts"
  }
}
```

## Turborepo guidance

When the user uses Turborepo, distinguish package-manager scripts from Turbo task execution.

Correct Turbo shape:

```bash
bunx turbo run desktop:dev --filter=desktop
bunx turbo run desktop:build --filter=desktop
```

or, if Turbo is installed in the workspace:

```bash
bun run turbo run desktop:dev --filter=desktop
```

Do not tell users this will work unless the selected package actually has a matching script/task:

```bash
bun run desktop:dev --filter=desktop
```

That usually asks Bun to run a root script named `desktop:dev`; it does not mean “run this script in the filtered Turbo package.”

## Recommended monorepo layout

```text
apps/
  web/
  desktop/
packages/
  ui/
  shared/
turbo.json
package.json
```

Inside `apps/desktop/package.json`:

```jsonc
{
  "name": "desktop",
  "scripts": {
    "build": "vite build",
    "desktop:dev": "deno desktop --hmr .",
    "desktop:build": "bun run build && deno desktop ."
  }
}
```

Inside `turbo.json`:

```jsonc
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".svelte-kit/**", "build/**"]
    },
    "desktop:dev": {
      "cache": false,
      "persistent": true
    },
    "desktop:build": {
      "dependsOn": ["build"],
      "outputs": ["dist/**", "builds/**"]
    }
  }
}
```

## Troubleshooting framework packaging

If `deno desktop .` does not detect the app:

1. Run it from the app directory, not the monorepo root.
2. Confirm the expected config file exists.
3. Confirm dependencies are installed.
4. Build the framework first.
5. Fall back to an explicit `desktop.ts` entry point.
