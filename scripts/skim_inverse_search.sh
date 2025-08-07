#!/bin/bash

#==============================================================================
# VimTeX Inverse Search Script for Skim PDF Viewer Integration
#==============================================================================
# Purpose: Enables bidirectional sync between Skim PDF viewer and Neovim
#          for LaTeX document editing. When a location in a PDF is clicked,
#          this script opens the corresponding source file at the correct line.
#
# Usage: skim_inverse_search.sh LINE_NUMBER FILE_PATH
#
# Integration: Configure in Skim.app preferences:
#   Sync -> PDF-TeX Sync support -> Preset: Custom
#   Command: /path/to/skim_inverse_search.sh
#   Arguments: %line %file
#
# Dependencies:
#   - Neovim with VimTeX plugin
#   - nvr (Neovim remote) for server communication
#   - Warp terminal application
#   - macOS AppleScript support
#
# Configuration Notes:
#   - Server socket path: /tmp/nvim_server (configurable via NVIM_SERVER_SOCKET)
#   - Debug log location: /tmp/inverse_search.log
#   - nvr path: /opt/homebrew/bin/nvr (adjust for your installation)
#   - Requires executable permissions: chmod +x skim_inverse_search.sh
#
# See README.md for complete setup instructions and troubleshooting
#==============================================================================

# Parameter validation and assignment
# $1: Line number in the source file (provided by Skim)
# $2: Full path to the LaTeX source file (provided by Skim)
LINE="$1"
FILE="$2"

# Debug logging format:
#   [timestamp]: Inverse search action
# Example entry:
#   2023-05-01 12:00:00: Inverse search called with LINE=24, FILE=main.tex
echo "$(date): Inverse search called with LINE=$LINE, FILE=$FILE" >> /tmp/inverse_search.log

# Method 1: VimTeX Native Command - Preferred method
# Uses VimTeX's built-in inverse search functionality in headless mode.
# Benefits: Works without server setup, uses VimTeX's native implementation
# Limitations: May not preserve existing editor state
echo "$(date): Trying VimtexInverseSearch" >> /tmp/inverse_search.log
/opt/homebrew/bin/nvim --headless -c "VimtexInverseSearch $LINE '$FILE'" 2>&1 >> /tmp/inverse_search.log

# Method 2: Neovim Remote (nvr) - Alternative method
# Uses nvr to communicate with an existing Neovim server instance.
# Benefits: Fast, preserves editor state, maintains cursor position
# Requirements: nvr installed, Neovim server running with socket at /tmp/nvim_server
if command -v /opt/homebrew/bin/nvr > /dev/null 2>&1 && [ -S "/tmp/nvim_server" ]; then
    echo "$(date): Trying nvr with existing server" >> /tmp/inverse_search.log
    # Open the file in Neovim if it's not open
    /opt/homebrew/bin/nvr --servername /tmp/nvim_server --remote-silent "$FILE" 2>&1 >> /tmp/inverse_search.log
    
    # Direct Neovim to jump to specified line number
    /opt/homebrew/bin/nvr --servername /tmp/nvim_server --remote-send ":$LINE<CR>" 2>&1 >> /tmp/inverse_search.log
    echo "$(date): Positioned cursor at line $LINE" >> /tmp/inverse_search.log
    
    # Activate Warp terminal for user interaction
    osascript -e 'tell application "Warp" to activate' 2>/dev/null
    echo "$(date): nvr command completed" >> /tmp/inverse_search.log
    exit 0
fi

# Method 3: Terminal Automation - Last resort fallback
# Uses AppleScript to automate terminal input when no server is available.
# Benefits: Always works, creates new Neovim instance if needed
# Limitations: Slower, may interfere with existing terminal sessions
if pgrep nvim > /dev/null; then
    echo "$(date): Neovim instance found, focusing Warp" >> /tmp/inverse_search.log
    # Focus Warp terminal where nvim is likely running
    osascript -e 'tell application "Warp" to activate' 2>/dev/null
else
    echo "$(date): No nvim instance found, opening new instance" >> /tmp/inverse_search.log
    # Open new nvim instance in Warp as fallback
    osascript -e "
        tell application \"Warp\"
            activate
            delay 0.5
            tell application \"System Events\"
                keystroke \"nvim +$LINE \"$FILE\"\" 
                key code 36
            end tell
        end tell
    " 2>&1 >> /tmp/inverse_search.log
fi
