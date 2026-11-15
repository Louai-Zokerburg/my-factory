#!/usr/bin/env bash
set -euo pipefail
dir="${XDG_STATE_HOME:-$HOME/.local/state}/ap-dev/app.lock.d"
stale_min="${APP_LOCK_STALE_MIN:-45}"
cmd="${1:-status}"
owner="${2:-unknown}"
mkdir -p "$(dirname "$dir")"
held_by() { cat "$dir/owner" 2>/dev/null || echo "?"; }
is_stale() { [ -d "$dir" ] && [ -n "$(find "$dir" -maxdepth 0 -mmin +"$stale_min" 2>/dev/null)" ]; }
case "$cmd" in
  acquire)
    waited=0
    until mkdir "$dir" 2>/dev/null; do
      if is_stale; then echo "lock held by $(held_by) is older than ${stale_min}m, taking it"; rm -rf "$dir"; continue; fi
      [ $((waited % 60)) -eq 0 ] && echo "waiting for the app lock (held by $(held_by))..."
      sleep 5; waited=$((waited + 5))
    done
    echo "$owner" > "$dir/owner"
    echo "app lock acquired by $owner"
    ;;
  touch) [ -d "$dir" ] && touch "$dir" && echo "lock refreshed" ;;
  release)
    if [ -d "$dir" ] && [ "$(held_by)" = "$owner" ]; then rm -rf "$dir"; echo "app lock released by $owner"
    elif [ -d "$dir" ]; then echo "lock is held by $(held_by), not $owner: left alone"
    else echo "lock was free"; fi
    ;;
  status) [ -d "$dir" ] && echo "held by $(held_by)" || echo "free" ;;
  *) echo "usage: app-lock.sh acquire|touch|release|status <owner>" >&2; exit 1 ;;
esac
