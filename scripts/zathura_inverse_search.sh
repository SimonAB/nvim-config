#!/bin/bash

# Zathura inverse search script for Arch Linux
# 
# NOTE: This script is OPTIONAL. The simplest solution is to use VimTeX's built-in
# function directly in ~/.config/zathura/zathurarc:
#   set synctex-editor-command "nvim --headless -c \"VimtexInverseSearch %{line} '%{input}'\""
#
# This script provides a fallback that tries to use nvr (neovim-remote) if available,
# otherwise falls back to VimTeX's built-in function. Use this only if you need
# the nvr functionality or if the simple solution doesn't work for your setup.
#
# Zathura passes arguments as: %{input} (file) %{line} (line number)

FILE="$1"
LINE="$2"

# Detect platform and set appropriate paths
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: Homebrew paths
  NVR_DEFAULT="/opt/homebrew/bin/nvr"
  NVIM_DEFAULT="/opt/homebrew/bin/nvim"
  # Fallback for Intel Macs
  if [ ! -f "$NVIM_DEFAULT" ]; then
    NVIM_DEFAULT="/usr/local/bin/nvim"
    NVR_DEFAULT="/usr/local/bin/nvr"
  fi
else
  # Linux: standard system paths
  NVR_DEFAULT="/usr/bin/nvr"
  NVIM_DEFAULT="/usr/bin/nvim"
fi

# Prefer targeting a running Neovim via RPC server
SERVER="${NVIM_LISTEN_ADDRESS:-/tmp/nvim_server}"
NVR="$(command -v nvr 2>/dev/null || echo "$NVR_DEFAULT")"
NVIM="$(command -v nvim 2>/dev/null || echo "$NVIM_DEFAULT")"

if [ -S "$SERVER" ] && command -v "$NVR" >/dev/null 2>&1; then
  # Open file silently in the existing instance and jump to the line
  "$NVR" --servername "$SERVER" --remote-silent "$FILE"
  "$NVR" --servername "$SERVER" --remote-send ":$LINE<CR>zz"
  exit 0
fi

# Fallback: use VimTeX's built-in inverse search in a transient headless nvim
exec "$NVIM" --headless -c "VimtexInverseSearch $LINE '$FILE'"
