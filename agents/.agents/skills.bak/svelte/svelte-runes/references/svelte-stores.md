# Svelte Runes Store Pattern

## Class-Based Stores with Runes

Use classes with `$state`, `$derived`, and `$effect` runes for all store logic. Never use `writable`, `readable`, or derived from Svelte's stores API unless dealing with legacy libraries that require them.

### Example Store Class

```typescript
// src/stores/printers.ts
import { getContext, setContext } from 'svelte';
import type { Printer, PrinterState } from '@/types/printer';

export interface PrinterWithStatus extends Printer {
	connected: boolean;
	connecting: boolean;
	status: PrinterState | null;
	error: string | null;
}

const PRINTERS_CONTEXT_KEY = Symbol('printers-store');

export class PrintersStore {
	printers = $state<PrinterWithStatus[]>([]);

	// Derived values
	get activePrinters() {
		return this.printers.filter((p) => p.status?.status === 'PRINTING');
	}

	get idlePrinters() {
		return this.printers.filter((p) => p.status?.status === 'IDLE');
	}

	get errorPrinters() {
		return this.printers.filter((p) => p.status?.status === 'ERROR');
	}

	get connectedPrinters() {
		return this.printers.filter((p) => p.connected);
	}

	get disconnectedPrinters() {
		return this.printers.filter((p) => !p.connected && !p.connecting);
	}

	get activeCount() {
		return this.activePrinters.length;
	}

	get idleCount() {
		return this.idlePrinters.length;
	}

	get errorCount() {
		return this.errorPrinters.length;
	}

	get connectedCount() {
		return this.connectedPrinters.length;
	}

	set(printers: PrinterWithStatus[]) {
		this.printers = printers;
	}

	addPrinter(printer: PrinterWithStatus) {
		const existing = this.printers.find((p) => p.id === printer.id);
		if (existing) {
			this.printers = this.printers.map((p) => (p.id === printer.id ? printer : p));
		} else {
			this.printers = [...this.printers, printer];
		}
	}

	removePrinter(id: number) {
		this.printers = this.printers.filter((p) => p.id !== id);
	}

	updatePrinterStatus(id: number, status: PrinterState) {
		this.printers = this.printers.map((p) => (p.id === id ? { ...p, status } : p));
	}

	setConnected(id: number, connected: boolean) {
		this.printers = this.printers.map((p) => (p.id === id ? { ...p, connected } : p));
	}

	setConnecting(id: number, connecting: boolean) {
		this.printers = this.printers.map((p) => (p.id === id ? { ...p, connecting } : p));
	}

	setError(id: number, error: string | null) {
		this.printers = this.printers.map((p) => (p.id === id ? { ...p, error } : p));
	}

	getPrinter(id: number): PrinterWithStatus | undefined {
		return this.printers.find((p) => p.id === id);
	}
}

// Singleton instance for global access
export const printersStore = new PrintersStore();

// Context helpers for component tree access
export function setPrintersContext(store: PrintersStore = printersStore) {
	setContext(PRINTERS_CONTEXT_KEY, store);
	return store;
}

export function getPrintersContext(): PrintersStore {
	return getContext<PrintersStore>(PRINTERS_CONTEXT_KEY) ?? printersStore;
}
```

## Usage in Components

### Setting Context

```svelte
<!-- src/routes/+layout.svelte -->
<script>
	import { setPrintersContext } from '$lib/stores/printers';
	import { onMount } from 'svelte';

	onMount(() => {
		setPrintersContext();
	});
</script>

<slot />
```

### Using Context in Components

```svelte
<!-- src/components/PrinterList.svelte -->
<script>
	import { getPrintersContext } from '$lib/stores/printers';

	const store = getPrintersContext();
</script>

<div class="printer-list">
	<h2>Printers ({store.activeCount} active)</h2>

	{#each store.printers as printer}
		<div class:printing={printer.status?.status === 'PRINTING'}>
			{printer.name}
		</div>
	{/each}

	{#each store.errorPrinters as printer}
		<div class="error">
			{printer.name}: {printer.error}
		</div>
	{/each}
</div>
```

### With Actions

```svelte
<!-- src/components/PrinterControls.svelte -->
<script>
	import { getPrintersContext } from '$lib/stores/printers';

	const store = getPrintersContext();

	async function connectPrinter(id: number) {
		store.setConnecting(id, true);
		try {
			await api.connectPrinter(id);
			store.setConnected(id, true);
		} catch (error) {
			store.setError(id, error.message);
		} finally {
			store.setConnecting(id, false);
		}
	}
</script>

{#each store.printers as printer}
	<div>
		{printer.name}
		<button onclick={() => connectPrinter(printer.id)}>
			{printer.connecting ? 'Connecting...' : 'Connect'}
		</button>
	</div>
{/each}
```

## Benefits of Class-Based Stores with Runes

- **Type Safety**: Classes provide full TypeScript support
- **Computed Values**: Use getters for derived state
- **Encapsulation**: Logic lives with data
- **No Boilerplate**: No need for `set()` functions like writable stores
- **Performance**: Runes are optimized by the compiler
- **Testability**: Easy to create instances for testing

## When to Use Legacy Stores

Only use `writable`, `readable`, or derived when:

1. **Legacy Libraries**: Integrating with third-party libraries that expect Svelte stores
2. **External APIs**: When an API explicitly requires store subscriptions

```typescript
// Only for legacy integration
import { writable } from 'svelte/store';

export const legacyStore = writable(initialValue);

// Wrap for runes compatibility
export class LegacyWrapper {
	#store = writable(null);
	$value = $state(null);

	constructor() {
		this.#store.subscribe((v) => (this.$value = v));
	}
}
```

## $derived Keyword for Computed Values

Use `$derived` for reactive computed values that track dependencies:

```typescript
export class StatsStore {
	counters = $state({ a: 0, b: 0, c: 0 });

	// Using $derived keyword
	total = $derived(this.counters.a + this.counters.b + this.counters.c);
	average = $derived(this.total / 3);

	// Computed based on derived values
	isAboveThreshold = $derived(this.average > 10);
}
```

## $effect for Side Effects

Use `$effect` for side effects that depend on reactive values:

```typescript
export class PrinterStore {
	printers = $state<Printer[]>([]);

	constructor() {
		$effect(() => {
			localStorage.setItem('printers', JSON.stringify(this.printers));
		});
	}
}
```
