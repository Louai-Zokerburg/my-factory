#!/usr/bin/env bash
# Run this yourself (it installs a background service that starts at login).
# Keeps `claude remote-control` running for ~/work/activepieces so the phone
# can always reach the laptop. Remove with:
#   systemctl --user disable --now claude-remote-control && rm ~/.config/systemd/user/claude-remote-control.service
set -euo pipefail

# Use the real binary, not a shell wrapper: ~/.local/bin/claude runs
# `mise x claude -- claude`, which under systemd's PATH finds the wrapper again
# and loops forever. mise's `latest` symlink follows claude updates.
MISE_LATEST=$HOME/.local/share/mise/installs/claude/latest/claude
if [ -x "$MISE_LATEST" ]; then
  CLAUDE_BIN=$MISE_LATEST
else
  CLAUDE_BIN=$(command -v claude)
fi
if ! file -L "$CLAUDE_BIN" | grep -q ELF; then
  echo "error: $CLAUDE_BIN is not the claude binary (a wrapper script?); set CLAUDE_BIN to the real binary" >&2
  exit 1
fi
REPO=${1:-$HOME/work/activepieces}
UNIT=$HOME/.config/systemd/user/claude-remote-control.service

mkdir -p "$(dirname "$UNIT")"
cat > "$UNIT" <<EOF
[Unit]
Description=Claude Code Remote Control for activepieces (my-factory)
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=$REPO
Environment=PATH=$PATH
ExecStart=/usr/bin/script -qfec "$CLAUDE_BIN remote-control --name factory --spawn=worktree" /dev/null
StandardInput=null
Restart=always
RestartSec=15

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable claude-remote-control.service
systemctl --user restart claude-remote-control.service
sleep 10
systemctl --user --no-pager status claude-remote-control.service | head -5
