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

# The cloud image ships /opt/node22 and /opt/node24, and its fixed PATH puts
# /opt/node22/bin ahead of /usr/bin. A Node installed anywhere else is shadowed,
# so point /opt/node22 at /opt/node24 and carry over the old global packages.
node_major() { node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo none; }

if [ -d "/opt/node${NODE_MAJOR}" ] && [ -d /opt/node22 ] && [ ! -L /opt/node22 ] && [ "$NODE_MAJOR" != 22 ]; then
  log "pointing /opt/node22 at /opt/node${NODE_MAJOR}"
  OLD_GLOBALS=$(ls /opt/node22/lib/node_modules 2>/dev/null | grep -v -E '^(npm|corepack)$' || true)
  rm -rf /opt/node22.orig
  mv /opt/node22 /opt/node22.orig
  ln -s "/opt/node${NODE_MAJOR}" /opt/node22
  hash -r
  for pkg in $OLD_GLOBALS; do
    log "re-installing global $pkg"
    npm install -g --silent "$pkg" >/dev/null 2>&1 || log "could not re-install $pkg; skipping"
  done
fi

if [ "$(node_major)" != "$NODE_MAJOR" ]; then
  log "installing node $NODE_MAJOR from nodesource"
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - >/dev/null
  apt-get install -y -qq nodejs >/dev/null
  hash -r
fi
log "node $(node --version) at $(command -v node)"
if [ "$(node_major)" != "$NODE_MAJOR" ]; then
  log "ERROR: node on PATH is $(node --version), expected v${NODE_MAJOR}"
  exit 1
fi

if ! command -v bun >/dev/null || [ "$(bun --version)" != "$BUN_VERSION" ]; then
  log "installing bun $BUN_VERSION"
  npm install -g --silent "bun@$BUN_VERSION"
  hash -r
fi
log "bun $(bun --version)"

log "warming bun cache (downloads only) from a shallow clone of main"
rm -rf "$WARM_DIR"
git clone -q --depth 1 https://github.com/activepieces/activepieces "$WARM_DIR"
(cd "$WARM_DIR" && bun install --frozen-lockfile --ignore-scripts >/dev/null)
rm -rf "$WARM_DIR"

# Install Louai's my-factory plugin (workflows + reviewer agents) for the session.
# It is a private repo; if the clone fails, the session still works, just without it.
# The cloud copy refreshes whenever this environment's cache rebuilds.
FACTORY_DIR=/opt/my-factory
log "installing the my-factory plugin"
rm -rf "$FACTORY_DIR"
if git clone -q --depth 1 https://github.com/Louai-Zokerburg/my-factory "$FACTORY_DIR" 2>/tmp/factory-clone.err; then
  CLAUDE=$(command -v claude || ls /opt/claude-code/bin/claude 2>/dev/null || true)
  if [ -n "$CLAUDE" ] && "$CLAUDE" plugin marketplace add "$FACTORY_DIR" >/dev/null 2>&1 \
      && "$CLAUDE" plugin install my-factory@my-factory --scope user >/dev/null 2>&1; then
    log "my-factory $(grep -o '"version": *"[^"]*"' "$FACTORY_DIR/.claude-plugin/plugin.json") installed"
  else
    log "WARNING: my-factory cloned but plugin install failed (claude=${CLAUDE:-not found})"
  fi
else
  log "WARNING: could not clone my-factory: $(tail -1 /tmp/factory-clone.err)"
fi
log "done"
