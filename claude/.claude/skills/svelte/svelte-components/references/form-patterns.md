# Form Patterns

## Form Attribute Trick

When you can't nest a form (e.g., inside tables), use the `form`
attribute:

```svelte
<script>
	import { addItem } from './data.remote';
</script>

<form id="add-item" {...addItem}></form>

<table>
	<tbody>
		{#each items as item}
			<tr>
				<td>{item.name}</td>
				<td>{item.price}</td>
			</tr>
		{/each}
		<tr>
			<td><input form="add-item" name="name" required /></td>
			<td
				><input
					form="add-item"
					name="price"
					type="number"
					required
				/></td
			>
			<td><button form="add-item">Add</button></td>
		</tr>
	</tbody>
</table>
```

**Benefits:**

- Form can be anywhere in the document
- Submit with Enter works
- FormData collection works
- Accessible by default
- Works with remote functions progressive enhancement

## Default Values and Reset

Forms support `defaultValue` for easy resets:

```svelte
<script>
	let name = $state('');
</script>

<form onreset={() => (name = '')}>
	<input bind:value={name} defaultValue="" />
	<button type="submit">Save</button>
	<button type="reset">Reset</button>
</form>
```

### Reset After Remote Function Submission

```svelte
<script>
	import { submitData } from './data.remote';
</script>

<form
	{...submitData.enhance(async ({ form, submit }) => {
		await submit();
		form.reset();
	})}
>
	<input name="name" />
	<button>Submit</button>
</form>
```

## Progressive Enhancement with Remote Functions

```svelte
<!-- src/routes/+page.svelte -->
<script>
	import { subscribe } from './data.remote';
</script>

<form {...subscribe}>
	<input name="email" type="email" required />
	<button>Publish!</button>
</form>

{#if subscribe.result?.success}
	<p>Successfully published!</p>
{/if}
```

### Custom Enhancement

```svelte
<!-- src/routes/+page.svelte -->
<script>
	import { createPost } from './data.remote';
	import { showToast } from '$lib/toast';

	let submitting = $state(false);
</script>

<form
	{...createPost.enhance(async ({ form, data, submit }) => {
		submitting = true;
		try {
			await submit();
			form.reset();
			showToast('Successfully published!');
		} catch (error) {
			showToast('Oh no! Something went wrong');
		} finally {
			submitting = false;
		}
	})}
>
	<input name="email" type="email" required />
	<button disabled={submitting}>
		{submitting ? 'Saving...' : 'Save'}
	</button>
</form>
```

```typescript
// src/routes/data.remote.ts
import * as v from 'valibot';
import { form } from '$app/server';

export const subscribe = form(
	v.object({
		email: v.pipe(v.string(), v.email()),
	}),
	async (data) => {
		await saveSubscription(data.email);
		return { success: true };
	}
);

export const createPost = form(
	v.object({
		title: v.string(),
		content: v.string(),
	}),
	async (data) => {
		await savePost(data);
		return { success: true };
	}
);
```

## Form Validation with Valibot

```typescript
// src/routes/contact/data.remote.ts
import * as v from 'valibot';
import { form } from '$app/server';

const ContactSchema = v.object({
	email: v.pipe(v.string(), v.email()),
	message: v.pipe(v.string(), v.minLength(10)),
});

export const contact = form(ContactSchema, async (data) => {
	await saveContact(data);
	return { success: true };
});
```

```svelte
<!-- src/routes/contact/+page.svelte -->
<script>
	import { contact } from './data.remote';
</script>

<form {...contact}>
	<label>
		Email
		<input
			name="email"
			type="email"
		/>
		{#if contact.error?.nested?.email}
			<span class="error">{contact.error.nested.email[0]}</span>
		{/if}
	</label>

	<label>
		Message
		<textarea name="message" required></textarea>
		{#if contact.error?.nested?.message}
			<span class="error">{contact.error.nested.message[0]}</span>
		{/if}
	</label>

	<button>Send</button>
</form>

{#if contact.result?.success}
	<p>Message sent successfully!</p>
{/if}
```

## Multiple Forms on One Page

```svelte
<!-- src/routes/+page.svelte -->
<script>
	import { subscribe, contact } from './data.remote';
</script>

<form {...subscribe}>
	<input name="email" type="email" />
	<button>Subscribe</button>
</form>

<form {...contact}>
	<input name="message" />
	<button>Send</button>
</form>
```

```typescript
// src/routes/data.remote.ts
import * as v from 'valibot';
import { form } from '$app/server';

export const subscribe = form(
	v.object({
		email: v.pipe(v.string(), v.email()),
	}),
	async (data) => {
		await saveSubscription(data.email);
		return { success: true };
	}
);

export const contact = form(
	v.object({
		message: v.pipe(v.string(), v.minLength(1)),
	}),
	async (data) => {
		await sendMessage(data.message);
		return { success: true };
	}
);
```
