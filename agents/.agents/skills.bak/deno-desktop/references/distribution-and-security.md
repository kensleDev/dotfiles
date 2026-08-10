# Distribution and Security

Read this when the user asks about installers, output formats, cross-compilation, CI, compression, code signing, auto-update, or production permissions.

## Output formats

The output extension controls the package format.

| Platform | Common outputs |
| --- | --- |
| macOS | `.app`, `.dmg` |
| Windows | app directory, `.msi` |
| Linux | app directory, `.AppImage`, `.deb`, `.rpm` |

Examples:

```bash
deno desktop --output ./dist/MyApp.app main.ts
deno desktop --output ./dist/MyApp.dmg main.ts
deno desktop --output ./dist/MyApp.msi main.ts
deno desktop --output ./dist/my-app.AppImage main.ts
deno desktop --output ./dist/my-app.deb main.ts
deno desktop --output ./dist/my-app.rpm main.ts
```

## Supported targets

```text
aarch64-apple-darwin
x86_64-apple-darwin
x86_64-pc-windows-msvc
aarch64-unknown-linux-gnu
x86_64-unknown-linux-gnu
```

```bash
deno desktop --target aarch64-apple-darwin main.ts
deno desktop --target x86_64-pc-windows-msvc main.ts
deno desktop --all-targets main.ts
```

Deno downloads the matching runtime and backend artifacts for the target. Do not tell users they need a Rust toolchain for normal Deno Desktop cross-compilation.

## Compression

Use compression when the distributed artifact size matters:

```bash
deno desktop --compress main.ts
deno desktop --compress=xz main.ts
deno desktop --compress=zstd main.ts
```

General guidance:

- `xz`: smaller output, slower first launch.
- `zstd`: larger than `xz`, faster first launch.
- Compression can trade install/download size for first-run extraction cost.

## CI shape

Use platform CI for release artifacts, especially macOS packaging/signing:

```yaml
jobs:
  build:
    strategy:
      matrix:
        include:
          - { os: macos-14, target: aarch64-apple-darwin }
          - { os: windows-latest, target: x86_64-pc-windows-msvc }
          - { os: ubuntu-latest, target: x86_64-unknown-linux-gnu }
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: denoland/setup-deno@v2
      - run: deno task build
      - run: deno desktop --target ${{ matrix.target }} .
      - uses: actions/upload-artifact@v4
        with:
          name: my-app-${{ matrix.target }}
          path: dist/
```

For framework apps, keep `deno task build` / `npm run build` / `bun run build` before `deno desktop .`.

## Code signing guidance

On macOS, development/ad-hoc signing may be enough for local use, but public distribution normally needs a real Developer ID identity and notarization.

Use `deno.json` for signing metadata when the user is preparing a release:

```jsonc
{
  "desktop": {
    "app": {
      "identifier": "com.example.myapp"
    },
    "macos": {
      "codesignIdentity": "Developer ID Application: Acme, Inc. (TEAMID)"
    }
  }
}
```

Do not imply that signing/notarization is optional for smooth public macOS distribution.

## Security checklist

- Scope permissions; avoid `--allow-all` in production.
- Keep privileged operations on the Deno side.
- Validate every binding input.
- Avoid generic bindings such as `runCommand(command)` unless heavily constrained.
- Use explicit allowlists for file paths, hosts, and commands.
- Do not expose the local server beyond loopback.
- Treat renderer state as user-controllable.
- Keep secrets out of bundled client-side code.

## Auto-update and error reporting

Only recommend auto-update or error reporting config when the user has the needed server/release infrastructure.

```jsonc
{
  "desktop": {
    "release": {
      "baseUrl": "https://releases.example.com/my-app"
    },
    "errorReporting": {
      "url": "https://errors.example.com/report"
    }
  }
}
```

If the user is only building a local/internal app, avoid adding release infrastructure prematurely.
