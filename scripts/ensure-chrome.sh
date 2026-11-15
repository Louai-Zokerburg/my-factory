#!/usr/bin/env bash
set -euo pipefail
port="${CHROME_DEBUG_PORT:-4222}"
if curl -fsS "http://localhost:$port/json/version" >/dev/null 2>&1; then
  echo "chrome already on :$port"
  exit 0
fi
bin="$(command -v chromium || command -v google-chrome || command -v chromium-browser || true)"
[ -n "$bin" ] || { echo "no chromium/chrome binary found" >&2; exit 1; }
profile="${XDG_STATE_HOME:-$HOME/.local/state}/my-factory/chrome-profile"
mkdir -p "$profile"
nohup "$bin" --headless=new --remote-debugging-port="$port" --user-data-dir="$profile" --no-first-run --no-default-browser-check about:blank >/dev/null 2>&1 &
for _ in $(seq 1 30); do
  curl -fsS "http://localhost:$port/json/version" >/dev/null 2>&1 && { echo "chrome started on :$port"; exit 0; }
  sleep 0.5
done
echo "chrome did not come up on :$port" >&2
exit 1
