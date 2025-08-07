#!/bin/bash

LINE="$1"
FILE="$2"

# Prefer targeting a running Neovim via RPC server
SERVER="${NVIM_LISTEN_ADDRESS:-/tmp/nvim_server}"
NVR="$(command -v nvr 2>/dev/null || echo /opt/homebrew/bin/nvr)"

if [ -S "$SERVER" ] && command -v "$NVR" >/dev/null 2>&1; then
  # Open file silently in the existing instance and jump to the line
  "$NVR" --servername "$SERVER" --remote-silent "$FILE"
  "$NVR" --servername "$SERVER" --remote-send ":$LINE<CR>zz"
  exit 0
fi

# Fallback: use VimTeX’s built-in inverse search in a transient headless nvim
exec /opt/homebrew/bin/nvim --headless -c "VimtexInverseSearch $LINE '$FILE'"
