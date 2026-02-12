# Module-Based Structure for SvelteKit

## Philosophy

Co-locate code by **feature/function** rather than by technical role. Everything related to a specific domain (like "printer") should live together—components, services, stores, types, etc.

## Directory Structure

```
src/
├── lib/
│   ├── components/
│   │   ├── ui/              # Base UI components (buttons, inputs, etc.)
│   │   │   ├── Button.svelte
│   │   │   ├── Input.svelte
│   │   │   └── index.ts     # Barrel export for UI components
│   │   └── shared/          # Shared feature-agnostic components
│   │       ├── Header.svelte
│   │       └── index.ts
│   │
│   └── printer/             # Printer feature module
│       ├── components/      # Printer-specific UI components
│       │   ├── PrinterCard.svelte
│       │   ├── PrinterList.svelte
│       │   └── PrinterSettings.svelte
│       ├── pages/           # Page components (for shallow routes)
│       │   ├── PrinterPage.svelte           # Main page component
│       │   └── PrinterSettingsPage.svelte   # Settings page component
│       ├── services/        # Business logic, API calls
│       │   ├── print-service.ts
│       │   └── printer-api.ts
│       ├── stores/          # Svelte stores for printer state
│       │   └── printer-store.ts
│       ├── types/           # TypeScript types/interfaces
│       │   └── printer.types.ts
│       ├── utils/           # Helper functions specific to printer
│       │   └── format-paper-size.ts
│       └── index.ts         # Public API exports
│
├── routes/                  # SvelteKit routes (sh/thin wrappers)
│   └── printer/
│       ├── +page.svelte     # Thin wrapper → imports PrinterPage
│       ├── +page.server.ts  # Data loading for printer routes
│       └── settings/
│           └── +page.svelte # Thin wrapper → imports PrinterSettingsPage
│
└── app.html
```

## Example: Printer Module

### `src/lib/printer/index.ts` (Public API)

```typescript
// Export only what should be publicly consumed
export { PrinterCard } from './components/PrinterCard.svelte';
export { PrinterList } from './components/PrinterList.svelte';
export { PrinterPage } from './pages/PrinterPage.svelte';
export { PrinterSettingsPage } from './pages/PrinterSettingsPage.svelte';
export { printService } from './services/print-service';
export { printerStore } from './stores/printer-store';
export type { Printer, PrintJob } from './types/printer.types';
```

### Importing from Other Modules

```typescript
// Clean imports from the module's public API
import { PrinterPage, printService, type Printer } from '$lib/printer';
```

## Shallow Routes Pattern

Keep route files (`+page.svelte`, `+layout.svelte`) **thin**—they should only import and render the actual page component from the module. The real page logic lives in the module.

### `src/routes/printer/+page.svelte` (Thin wrapper)

```svelte
<script lang="ts">
  import { PrinterPage } from '$lib/printer';
  import type { PageData } from './$types';

  export let data: PageData;
</script>

<PrinterPage {data} />
```

### `src/lib/printer/pages/PrinterPage.svelte` (Real page)

```svelte
<script lang="ts">
  import { PrinterList } from '../components/PrinterList.svelte';
  import { printerStore } from '../stores/printer-store';
  import type { Printer } from '../types/printer.types';

  interface Props {
    data: { printers: Printer[] };
  }

  let { data }: Props = $props();
  const store = printerStore();
</script>

<div class="printer-page">
  <h1>Printers</h1>
  <PrinterList {printers} />
  <!-- All page logic lives here -->
</div>
```

### Why Shallow Routes?

| Benefit | Explanation |
|---------|-------------|
| **Separation of concerns** | Routing logic separate from page implementation |
| **Easier testing** | Test page components without SvelteKit routing |
| **Reusable pages** | Use page components in different routes |
| **Cleaner routes folder** | Routes folder only contains routing structure |
| **Better IDE navigation** | All feature code in one module location |

### Data Loading with Shallow Routes

The `+page.server.ts` (or `+page.ts`) still handles data loading:

### `src/routes/printer/+page.server.ts`

```typescript
import { printService } from '$lib/printer';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
  const printers = await printService.getAllPrinters();
  return { printers };
};
```

Data flows: `+page.server.ts` → `+page.svelte` → `PrinterPage.svelte`

## When to Co-locate vs Share

| Co-locate in module | Put in `lib/components/shared` or `lib/components/ui` |
|---------------------|--------------------------------------------------------|
| Feature-specific components | Generic UI primitives (Button, Input) |
| Domain-specific business logic | Cross-feature shared components |
| Module-specific types | Global utility functions |
| Feature-specific stores | App-wide state management |

## Benefits

1. **Easier to find related code** - Everything for a feature is in one place
2. **Simpler refactoring** - Delete a module folder, delete the feature
3. **Clearer dependencies** - Obvious what each module needs
4. **Better encapsulation** - Use `index.ts` to define public API
5. **Scalable** - Easy to add new features as new modules

## Module `index.ts` Pattern

Each feature module should have an `index.ts` that:

1. Re-exports public components
2. Re-exports public services/functions
3. Re-exports public types
4. **Does not** export internal implementation details

This gives you control over the public API and allows internal refactoring without breaking consumers.
