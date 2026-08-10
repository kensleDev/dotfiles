# Next.js Error Handling Patterns

Patterns for using `@julian-i/try-error` across Next.js contexts (App Router).

## Table of Contents

1. [Server Actions](#server-actions)
2. [Server Components](#server-components)
3. [Route Handlers](#route-handlers)
4. [Client Components](#client-components)
5. [Middleware](#middleware)

---

## Server Actions

```typescript
// actions/user.ts
'use server';

import { tryPromise, tryThrow } from '@julian-i/try-error';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createUser(formData: FormData) {
  const email = formData.get('email') as string;
  const name = formData.get('name') as string;

  // Validate
  const [validated, validationError] = tryThrow(() =>
    userSchema.parse({ email, name })
  );
  if (validationError) {
    return { error: 'Invalid input', fields: validationError.errors };
  }

  // Database operation
  const [user, dbError] = await tryPromise(
    db.user.create({ data: validated })
  );

  if (dbError) {
    if (dbError.code === 'P2002') {
      return { error: 'Email already registered' };
    }
    console.error('[createUser]', dbError);
    return { error: 'Failed to create account' };
  }

  revalidatePath('/users');
  redirect(`/users/${user.id}`);
}

export async function deleteUser(id: string) {
  const session = await getSession();
  if (!session) {
    return { error: 'Unauthorized' };
  }

  const [_, error] = await tryPromise(
    db.user.delete({ where: { id, ownerId: session.userId } })
  );

  if (error) {
    if (error.code === 'P2025') {
      return { error: 'User not found' };
    }
    console.error('[deleteUser]', error);
    return { error: 'Failed to delete user' };
  }

  revalidatePath('/users');
  return { success: true };
}
```

### With useActionState (React 19)

```typescript
// actions/contact.ts
'use server';

import { tryPromise } from '@julian-i/try-error';

export type ContactState = {
  success?: boolean;
  error?: string;
  fieldErrors?: Record<string, string>;
};

export async function submitContact(
  prevState: ContactState,
  formData: FormData
): Promise<ContactState> {
  const [validated, validationError] = tryThrow(() =>
    contactSchema.parse(Object.fromEntries(formData))
  );

  if (validationError) {
    return {
      fieldErrors: validationError.flatten().fieldErrors
    };
  }

  const [_, sendError] = await tryPromise(
    sendEmail({
      to: 'support@example.com',
      subject: `Contact: ${validated.subject}`,
      body: validated.message
    })
  );

  if (sendError) {
    console.error('[submitContact]', sendError);
    return { error: 'Failed to send message. Try again.' };
  }

  return { success: true };
}
```

---

## Server Components

```typescript
// app/posts/[id]/page.tsx
import { tryPromise } from '@julian-i/try-error';
import { notFound } from 'next/navigation';

export default async function PostPage({ 
  params 
}: { 
  params: { id: string } 
}) {
  const [post, error] = await tryPromise(
    db.post.findUnique({ 
      where: { id: params.id },
      include: { author: true }
    })
  );

  if (error) {
    console.error('[PostPage]', { id: params.id, error });
    throw new Error('Failed to load post');
  }

  if (!post) {
    notFound();
  }

  return (
    <article>
      <h1>{post.title}</h1>
      <p>By {post.author.name}</p>
      <div>{post.content}</div>
    </article>
  );
}
```

### Parallel Data Fetching

```typescript
// app/dashboard/page.tsx
import { tryPromise } from '@julian-i/try-error';

export default async function DashboardPage() {
  const session = await getSession();
  if (!session) redirect('/login');

  // Parallel fetches
  const [
    [stats, statsError],
    [notifications, notifError],
    [recentActivity, activityError]
  ] = await Promise.all([
    tryPromise(db.stats.findFirst({ where: { userId: session.userId } })),
    tryPromise(db.notification.findMany({ 
      where: { userId: session.userId },
      take: 5 
    })),
    tryPromise(db.activity.findMany({ 
      where: { userId: session.userId },
      take: 10 
    }))
  ]);

  // Stats are critical
  if (statsError) {
    throw new Error('Failed to load dashboard');
  }

  // Others degrade gracefully
  if (notifError) {
    console.warn('[Dashboard] Notifications unavailable', notifError);
  }

  return (
    <div>
      <StatsCard stats={stats} />
      <NotificationList items={notifications ?? []} />
      <ActivityFeed items={recentActivity ?? []} />
    </div>
  );
}
```

---

## Route Handlers

```typescript
// app/api/items/route.ts
import { tryPromise, tryThrow } from '@julian-i/try-error';
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const session = await getSession();
  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' }, 
      { status: 401 }
    );
  }

  const searchParams = request.nextUrl.searchParams;
  const page = parseInt(searchParams.get('page') ?? '1');
  const limit = Math.min(parseInt(searchParams.get('limit') ?? '20'), 100);

  const [items, error] = await tryPromise(
    db.item.findMany({
      where: { userId: session.userId },
      skip: (page - 1) * limit,
      take: limit
    })
  );

  if (error) {
    console.error('[GET /api/items]', error);
    return NextResponse.json(
      { error: 'Failed to fetch items' }, 
      { status: 500 }
    );
  }

  return NextResponse.json({ items, page, limit });
}

export async function POST(request: NextRequest) {
  const session = await getSession();
  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' }, 
      { status: 401 }
    );
  }

  // Parse body
  const [body, parseError] = await tryPromise(request.json());
  if (parseError) {
    return NextResponse.json(
      { error: 'Invalid JSON' }, 
      { status: 400 }
    );
  }

  // Validate
  const [validated, validationError] = tryThrow(() =>
    createItemSchema.parse(body)
  );
  if (validationError) {
    return NextResponse.json(
      { error: 'Validation failed', details: validationError.errors },
      { status: 400 }
    );
  }

  // Create
  const [item, dbError] = await tryPromise(
    db.item.create({
      data: { ...validated, userId: session.userId }
    })
  );

  if (dbError) {
    console.error('[POST /api/items]', dbError);
    return NextResponse.json(
      { error: 'Failed to create item' }, 
      { status: 500 }
    );
  }

  return NextResponse.json(item, { status: 201 });
}
```

### Dynamic Route Handler

```typescript
// app/api/items/[id]/route.ts
import { tryPromise } from '@julian-i/try-error';
import { NextRequest, NextResponse } from 'next/server';

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await getSession();
  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' }, 
      { status: 401 }
    );
  }

  const [_, error] = await tryPromise(
    db.item.delete({
      where: { id: params.id, userId: session.userId }
    })
  );

  if (error) {
    if (error.code === 'P2025') {
      return NextResponse.json(
        { error: 'Item not found' }, 
        { status: 404 }
      );
    }
    console.error('[DELETE /api/items]', error);
    return NextResponse.json(
      { error: 'Failed to delete' }, 
      { status: 500 }
    );
  }

  return new NextResponse(null, { status: 204 });
}
```

---

## Client Components

```tsx
'use client';

import { tryPromise } from '@julian-i/try-error';
import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';

export function CreateItemForm() {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setError(null);

    const formData = new FormData(e.currentTarget);
    const data = Object.fromEntries(formData);

    const [response, fetchError] = await tryPromise(
      fetch('/api/items', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      })
    );

    if (fetchError) {
      setError('Network error. Check your connection.');
      return;
    }

    const [result, parseError] = await tryPromise(response.json());

    if (parseError) {
      setError('Invalid response from server');
      return;
    }

    if (!response.ok) {
      setError(result.error ?? 'Something went wrong');
      return;
    }

    startTransition(() => {
      router.push(`/items/${result.id}`);
      router.refresh();
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      {error && <div className="error">{error}</div>}
      <input name="name" disabled={isPending} />
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
    </form>
  );
}
```

### With Server Actions

```tsx
'use client';

import { useActionState } from 'react';
import { submitContact, type ContactState } from '@/actions/contact';

const initialState: ContactState = {};

export function ContactForm() {
  const [state, formAction, isPending] = useActionState(
    submitContact,
    initialState
  );

  if (state.success) {
    return <p>Message sent!</p>;
  }

  return (
    <form action={formAction}>
      {state.error && <div className="error">{state.error}</div>}
      
      <input 
        name="email" 
        type="email"
        aria-invalid={!!state.fieldErrors?.email}
      />
      {state.fieldErrors?.email && (
        <span className="field-error">{state.fieldErrors.email}</span>
      )}
      
      <textarea name="message" />
      {state.fieldErrors?.message && (
        <span className="field-error">{state.fieldErrors.message}</span>
      )}
      
      <button disabled={isPending}>
        {isPending ? 'Sending...' : 'Send'}
      </button>
    </form>
  );
}
```

---

## Middleware

```typescript
// middleware.ts
import { tryPromise } from '@julian-i/try-error';
import { NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('session')?.value;

  // Public routes - skip auth
  if (request.nextUrl.pathname.startsWith('/public')) {
    return NextResponse.next();
  }

  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  const [session, error] = await tryPromise(validateSession(token));

  if (error) {
    console.warn('[middleware] Session validation failed', error);
    const response = NextResponse.redirect(new URL('/login', request.url));
    response.cookies.delete('session');
    return response;
  }

  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Add user info to headers for downstream use
  const requestHeaders = new Headers(request.headers);
  requestHeaders.set('x-user-id', session.userId);

  return NextResponse.next({
    request: { headers: requestHeaders }
  });
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*']
};
```

---

## Error Boundaries

```tsx
// app/dashboard/error.tsx
'use client';

import { useEffect } from 'react';

export default function DashboardError({
  error,
  reset
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error('[DashboardError]', error);
  }, [error]);

  return (
    <div>
      <h2>Something went wrong</h2>
      <p>Error ID: {error.digest}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```
