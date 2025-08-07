# Troubleshooting Guide for Neovim Inverse Search

## Common Issues and Solutions

### No Response on Inverse Search
- **Check Skim Settings**: Ensure that the Sync tab in Skim preferences is correctly configured with the path to your `skim_inverse_search.sh` script.
- **Verify PATH**: Make sure Neovim is in your PATH. You can verify this by running `which nvim`.
- **Permissions**: Verify that the inverse search script has executable permissions. Use `chmod +x ~/scripts/skim_inverse_search.sh` if needed.

### NVR Socket Not Found
- **Verify `nvim --listen` Usage**: Ensure that Neovim is started with the correct listen address. You should have `nvim --listen ...` running before attempting to use `nvr`.

### Fallback Not Triggering
- **Inspect Fallback osascript Block**: Review the fallback AppleScript block in your configuration or script to ensure it triggers under the right conditions.

### How to Enable and Read Debug Logs
- **Enable Debug Logs**: Debug logging is automatically enabled in the `skim_inverse_search.sh` script. All operations are logged to `/tmp/inverse_search.log`.
- **Read Debug Logs**: Use `cat /tmp/inverse_search.log` or `tail -f /tmp/inverse_search.log` to view the log file in real-time.
- **Clear Old Logs**: To start fresh, run `rm /tmp/inverse_search.log` before testing.
- **Log Analysis**: Look for patterns like:
  - "Trying VimtexInverseSearch" - indicates VimTeX native method attempted (Method 1)
  - "Trying nvr with existing server" - indicates nvr fallback method (Method 2)
  - "No nvim instance found" - indicates terminal automation fallback (Method 3)
  - Error messages that show specific failure reasons

### Script Permissions Issues
- **Check Executable Permissions**: Run `ls -la ~/scripts/skim_inverse_search.sh` to verify the script is executable (`-rwxr-xr-x`).
- **Fix Permissions**: If not executable, run `chmod +x ~/scripts/skim_inverse_search.sh`.
- **Security Settings**: On macOS, you may need to allow the script in System Preferences > Security & Privacy.

### Path Configuration Problems
- **Verify Script Path**: In Skim preferences, ensure the full path to your script is correct.
- **Test Script Manually**: Run `~/scripts/skim_inverse_search.sh 10 /path/to/test.tex` to test the script directly.
- **Check nvr Installation**: Verify nvr is installed at `/opt/homebrew/bin/nvr` with `which nvr`.
- **Homebrew Path Issues**: If nvr is installed elsewhere, update the script path accordingly.

