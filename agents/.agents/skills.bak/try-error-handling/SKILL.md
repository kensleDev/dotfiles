---
name: try-error-handling
description: Error handling with @julian-i/try-error. Wrap throwable code with tryPromise (async) or tryThrow (sync). Forces reflection on error types, handling location, audience, and recovery.
---

<!--
PROGRESSIVE DISCLOSURE GUIDELINES:
- Keep this file ~50 lines total (max ~150 lines)
- Use 1-2 code blocks only (recommend 1)
- Keep description <200 chars for Level 1 efficiency
- Move detailed docs to references/ for Level 3 loading
- This is Level 2 - quick reference ONLY, not a manual
-->

# Error Handling with @julian-i/try-error

Wrap all throwable operations. Before handling, ask:

1. **What errors?** — Use context7 MCP to check library docs
2. **Handle here or propagate?** — Can you recover, or should caller decide?
3. **Who's the audience?** — End user (friendly) or developer (detailed)?
4. **Recovery strategy?** — Retry, fallback, degrade, or fail fast?

## Usage

```typescript
import { tryPromise, tryThrow } from '@julian-i/try-error';

// Async: fetch, db, auth, file I/O
const [data, error] = await tryPromise(fetch('/api/users'));

// Sync: JSON.parse, validation, transforms
const [parsed, error] = tryThrow(() => JSON.parse(raw));

if (error) {
  // Handle based on error type and audience
}
```

## Quick Reference

| Operation | Wrapper | Example |
|-----------|---------|---------|
| fetch/API | `tryPromise` | `tryPromise(fetch(url))` |
| Database | `tryPromise` | `tryPromise(db.query(...))` |
| JSON parse | `tryThrow` | `tryThrow(() => JSON.parse(s))` |
| Validation | `tryThrow` | `tryThrow(() => schema.parse(d))` |
| Auth | `tryPromise` | `tryPromise(auth.signIn(...))` |

## References

- **Error types by library**: `references/error-sources.md` — Prisma, Drizzle, better-auth, Zod, fetch, Stripe
- **SvelteKit patterns**: `references/sveltekit-patterns.md` — actions, load, endpoints, hooks
- **Next.js patterns**: `references/nextjs-patterns.md` — server actions, route handlers, middleware
- **TypeScript patterns**: `references/typescript-patterns.md` — services, utilities, testing
