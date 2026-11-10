#!/usr/bin/env bash
# Cloud environment setup for activepieces/activepieces.
# Runs as root on Ubuntu 24.04 BEFORE the repo is cloned, and is cached only
# when it finishes in about 5 minutes. It installs toolchains and pre-fills
# bun's package cache (downloads only, no install scripts) from a throwaway
# clone, so the session's own `bun install` links from the cache.
#
# Pair it with these environment variables (not secrets):
#   REDISMS_DISABLE_POSTINSTALL=1
#   REDISMS_SYSTEM_BINARY=/usr/bin/redis-server
# so redis-memory-server uses the apt redis-server instead of compiling Redis.
# API tests need no other services: .env.tests uses PGLite and in-memory Redis.
set -euo pipefail

NODE_MAJOR=24
BUN_VERSION=1.4.4
WARM_DIR=/opt/ap-warm

log() { echo "[setup $(date +%T)] $*"; }

log "apt: redis-server, build tools"
apt-get update -qq >/dev/null
apt-get install -y -qq redis-server build-essential >/dev/null
systemctl disable --now redis-server >/dev/null 2>&1 || true

if ! command -v node >/dev/null || [ "$(node -p 'process.versions.node.split(".")[0]')" != "$NODE_MAJOR" ]; then
  log "installing node $NODE_MAJOR"
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - >/dev/null
  apt-get install -y -qq nodejs >/dev/null
fi
log "node $(node --version)"

if ! command -v bun >/dev/null || [ "$(bun --version)" != "$BUN_VERSION" ]; then
  log "installing bun $BUN_VERSION"
  npm install -g --silent "bun@$BUN_VERSION"
fi
log "bun $(bun --version)"

log "warming bun cache (downloads only) from a shallow clone of main"
rm -rf "$WARM_DIR"
git clone -q --depth 1 https://github.com/activepieces/activepieces "$WARM_DIR"
(cd "$WARM_DIR" && bun install --frozen-lockfile --ignore-scripts >/dev/null)
rm -rf "$WARM_DIR"
log "done"
