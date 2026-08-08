#!/usr/bin/env python3
"""Submit one bounded browser job to the local ipw-api service."""

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

DEFAULT_BASE_URL = "http://127.0.0.1:8787"
TOKEN_PATH = Path.home() / ".config/ipw-api/token"
CHALLENGE_RE = re.compile(
    r"captcha|re[- ]?captcha|hcaptcha|turnstile|cloudflare|"
    r"verify\s+(?:you\s+are\s+)?human|bot\s+(?:check|detection)|security\s+check",
    re.IGNORECASE,
)
TRANSPORT_RE = re.compile(
    r"timeout|timed out|net::|navigation|connection|dns|proxy|reset|refused|unreachable",
    re.IGNORECASE,
)

EXIT_CHALLENGE = 10
EXIT_UNAVAILABLE = 20
EXIT_API_FAILURE = 30


def error(message: str, code: int) -> int:
    print(message, file=sys.stderr)
    return code


def read_token() -> str:
    try:
        token = TOKEN_PATH.read_text(encoding="utf-8").strip()
    except OSError as exc:
        raise RuntimeError(f"token unavailable at {TOKEN_PATH}: {exc.strerror or 'cannot read file'}") from exc
    if not token:
        raise RuntimeError(f"token unavailable at {TOKEN_PATH}: file is empty")
    return token


def request_json(url: str, method: str, token: str | None = None, body: dict | None = None, timeout: float = 5.0):
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    payload = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        payload = json.dumps(body, separators=(",", ":")).encode("utf-8")
    request = urllib.request.Request(url, data=payload, headers=headers, method=method)
    try:
        response = urllib.request.urlopen(request, timeout=timeout)
    except urllib.error.HTTPError as response:
        pass
    with response:
        raw = response.read().decode("utf-8", "replace")
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            parsed = {"error": raw[:500]}
        return response.status, parsed


def has_challenge(result: object) -> bool:
    if isinstance(result, dict):
        return any(has_challenge(value) for value in result.values())
    return isinstance(result, str) and bool(CHALLENGE_RE.search(result))


def safe_output(value: object, token: str) -> None:
    rendered = json.dumps(value, ensure_ascii=False, separators=(",", ":"))
    print(rendered.replace(token, "[REDACTED_TOKEN]"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default=os.environ.get("IPW_API_BASE_URL", DEFAULT_BASE_URL))
    parser.add_argument("--timeout", type=float, default=10.0, help="HTTP timeout in seconds")
    parser.add_argument("--proxy-id", help="Configured proxy-pool ID")
    parser.add_argument("--direct", action="store_true", help="Disable the configured proxy pool")
    args = parser.parse_args()

    try:
        job = json.load(sys.stdin)
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        return error(f"invalid JSON job: {exc}", 2)
    if not isinstance(job, dict) or not isinstance(job.get("url"), str):
        return error("job must be a JSON object with an http(s) url", 2)

    try:
        token = read_token()
    except RuntimeError as exc:
        return error(str(exc), EXIT_UNAVAILABLE)

    base = args.base_url.rstrip("/")
    try:
        status, health = request_json(f"{base}/healthz", "GET", timeout=args.timeout)
        if status != 200 or not isinstance(health, dict) or not health.get("ok"):
            return error("ipw-api health check failed", EXIT_UNAVAILABLE)
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        detail = exc.reason if isinstance(exc, urllib.error.URLError) else exc
        return error(f"ipw-api unavailable: {detail}", EXIT_UNAVAILABLE)

    job = dict(job)
    if args.proxy_id:
        job["proxyId"] = args.proxy_id
    if args.direct:
        job["direct"] = True
    if "direct" not in job and "proxyId" not in job:
        job["direct"] = False
    http_timeout = max(args.timeout, float(job.get("timeoutMs", 20000)) / 1000 + 5)

    attempts = 2 if not job.get("actions") and not job.get("direct") else 1
    for attempt in range(attempts):
        if attempt and not job.get("direct"):
            job.pop("proxyId", None)
        try:
            status, result = request_json(f"{base}/v1/jobs", "POST", token, job, http_timeout)
        except (urllib.error.URLError, TimeoutError, OSError) as exc:
            if attempt == 0 and attempts == 2:
                continue
            detail = exc.reason if isinstance(exc, urllib.error.URLError) else exc
            return error(f"ipw-api request failed: {detail}", EXIT_API_FAILURE)

        if status == 200:
            if has_challenge(result):
                safe_output(result, token)
                return EXIT_CHALLENGE
            safe_output(result, token)
            return 0

        message = result.get("error", "ipw-api job failed") if isinstance(result, dict) else "ipw-api job failed"
        if attempt == 0 and attempts == 2 and status >= 500 and TRANSPORT_RE.search(str(message)):
            continue
        return error(f"ipw-api error ({status}): {message}", EXIT_API_FAILURE)

    return error("ipw-api job failed", EXIT_API_FAILURE)


if __name__ == "__main__":
    raise SystemExit(main())
