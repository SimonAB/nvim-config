#!/bin/bash

# Safe Neovim Server Startup Script
# Handles stale socket files automatically

SERVER_ADDRESS="/tmp/nvim_server"

# Function to check if a socket is actually active
is_socket_active() {
    if [ -S "$1" ]; then
        # Try to connect to see if it's active
        if lsof "$1" >/dev/null 2>&1; then
            return 0  # Socket is active
        else
            return 1  # Socket file exists but is stale
        fi
    else
        return 1  # No socket file
    fi
}

# Clean up stale socket if needed
cleanup_stale_socket() {
    if [ -S "$SERVER_ADDRESS" ] && ! is_socket_active "$SERVER_ADDRESS"; then
        echo "🧹 Removing stale socket file: $SERVER_ADDRESS"
        rm -f "$SERVER_ADDRESS"
    fi
}

# Main function
start_nvim_with_server() {
    cleanup_stale_socket
    
    if is_socket_active "$SERVER_ADDRESS"; then
        echo "✅ Neovim server already running at $SERVER_ADDRESS"
        nvim "$@"
    else
        echo "🚀 Starting Neovim with server at $SERVER_ADDRESS"
        nvim --listen "$SERVER_ADDRESS" "$@"
    fi
}

# Run the main function with all arguments passed to the script
start_nvim_with_server "$@"
