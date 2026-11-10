# Cloud environment: activepieces

One claude.ai cloud environment for factory runs on activepieces with the laptop off.
Environments can only be created in the web UI.

## Create it (about 3 minutes)

1. Open https://claude.ai/code, start a new session, click the environment selector under the message box, then **New environment**.
2. Name: `factory-activepieces`.
3. Network access: **Full**.
4. Environment variables (not secrets):
   ```
   REDISMS_DISABLE_POSTINSTALL=1
   REDISMS_SYSTEM_BINARY=/usr/bin/redis-server
   ```
5. Setup script: paste the contents of `setup-activepieces.sh`.
6. Save.

## What the session still does itself

The setup script runs before the repo is cloned, so each session runs this in the repo first:

```sh
bun install --frozen-lockfile && npx turbo run build --filter=api^... --filter=worker^... --filter=worker --output-logs=errors-only
```

Measured in a clean Ubuntu 24.04 container (4 CPU, 16 GB): setup script 232 s (cached), `bun install` 3 s,
build 36 s, then `test/integration/ce/flows`: 26 files, 380 tests passed in 203 s.

## Repo access

- `activepieces/activepieces` is public, so cloud sessions can clone and read it.
- Pushing branches and opening PRs needs the Claude GitHub App on the activepieces org (asked an org owner on 2026-11-10).
- `Louai-Zokerburg/my-factory`: app installed on the personal account.
