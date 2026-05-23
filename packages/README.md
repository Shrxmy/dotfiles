# Package manifests

These files help rebuild a machine with roughly the same CLI/tooling setup.

## Export current manifests

```bash
./scripts/export-packages.sh
```

## Restore packages

### apt

Raw export:

```bash
./scripts/install-packages-apt.sh
```

Curated install set:

```bash
./scripts/install-packages-apt-curated.sh
```

Uses:
- `packages/apt-manual.txt`
- `packages/apt-curated.txt`

### Node globals

```bash
./scripts/install-node-globals.sh
```

Uses:
- `packages/pnpm-global.json`
- `packages/npm-global.json`

Notes:
- `@pnpm/exe`, `npm`, and `corepack` are skipped intentionally
- package-manager globals are best-effort and may differ by OS

## Install source categories

Document tools by source so future rebuilds are less confusing:

- `apt`: system packages on Debian/Ubuntu
- `pnpm`: JS CLI tools you want globally
- `npm`: fallback JS global tools if needed
- `curl`/standalone: tools like `opencode`
- `manual`: anything intentionally installed outside package managers

## Private/local state

Do not put these in manifests or dotfiles unless encrypted:

- auth tokens
- session databases
- SSH keys
- machine-specific caches
- editor local history
