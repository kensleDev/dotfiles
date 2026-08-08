---
name: ipw-browser
description: Use the local ipw-api browser service for browser-required navigation, dynamic-page inspection, extraction, and explicitly requested ordinary non-irreversible interactions such as clicks, fills, keypresses, and waits. Trigger when a page cannot be handled reliably with HTTP or static tools, requires JavaScript/rendering, or the user asks for browser automation. Do not use for login/account changes, payments, purchases, messages, destructive actions, CAPTCHA, Turnstile, Cloudflare challenges, or other anti-bot controls.
---

# IPW Browser

Use the bundled `scripts/run_job.py` helper to submit jobs to the local `ipw-api` service. It reads the shared token from `~/.config/ipw-api/token` and never requires a second credential.

## Workflow

1. Confirm the task is within scope. Browser navigation, bounded extraction, and ordinary public-page interactions are allowed. Stop before authentication, account or permission changes, checkout/payment/purchase, sending messages, deletion, or other irreversible effects.
2. Run the helper with a JSON job on stdin. It checks service health and token availability, uses the configured proxy pool by default, and returns the API JSON on stdout.
3. Inspect the returned title and text for CAPTCHA, reCAPTCHA, hCaptcha, Turnstile, Cloudflare, “verify you are human”, bot checks, or similar challenge language. Stop and report the URL and visible context; never solve, bypass, or repeatedly retry it.
4. Report extracted results and the final URL. Treat browser sessions as fresh and non-persistent: a user handoff cannot resume the same session.

Example:

```bash
printf '%s' '{
  "url": "https://example.com",
  "extract": {"title": true, "text": true, "links": true}
}' | python3 ~/.codex/skills/ipw-browser/scripts/run_job.py
```

Supported job fields are `url`, `actions`, `extract`, `proxyId`, `seed`, `timezone`, `timeoutMs`, and `direct`. Actions are `click`, `fill`, `press`, `waitFor`, and bounded `wait`. Keep extraction bounded to the page title, URL, body text, links, and at most 20 selectors; do not request arbitrary script execution.

The helper may make one additional navigation-only attempt through the proxy pool when a transport/navigation failure occurs and the job has no actions. It must not retry after any action, on challenge detection, or for API validation/authentication failures. A proxy ID is a pool selector, not a place to provide proxy credentials.

## Safety and privacy

- Ask the user before any action that could submit data, create an account, change an account, send communication, spend money, or alter/delete remote state; refuse if it is explicitly irreversible or outside this skill’s scope.
- If a page presents a CAPTCHA, Turnstile, Cloudflare challenge, bot check, or similar control, stop. Do not attempt workarounds, stealth changes, solving, or challenge retries.
- Do not print or expose the shared bearer token, proxy usernames/passwords, cookies, or other secrets. Redact secrets if they appear in diagnostic output.
- Do not infer consent to log in or continue through a sensitive flow merely because a page is reachable.

## Failure handling

Exit code 10 means a challenge was detected; exit code 20 means the local service or token is unavailable; exit code 30 means the API rejected or failed the job. Preserve the error context without secrets and stop rather than retrying broadly.
