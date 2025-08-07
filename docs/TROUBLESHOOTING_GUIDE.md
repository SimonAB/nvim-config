# Troubleshooting Guide for Neovim Inverse Search

## Common Issues and Solutions

### No response on inverse search
- **Skim Sync settings**: Preferences → Sync → Command `nvim`, Arguments `--headless -c "VimtexInverseSearch %line '%file'"`.
- **Neovim path**: Verify `which nvim` points to your Neovim 0.12 install.
- **Synctex**: Ensure your build includes `-synctex=1` (configured via VimTeX latexmk options here).

### nvr (optional) not used
- This config does not require `nvr`. If you still prefer it, start Neovim with `nvim --listen /tmp/nvim_server` and configure Skim to call `nvr` accordingly. Otherwise, ignore this.

### Skim doesn’t focus or steals focus
- Control focus via VimTeX options already set: `g:vimtex_view_skim_activate = 0`.

### Logging and debugging
- Use `:VimtexInfo` and `:messages` in Neovim.
- If needed, test Skim’s command directly in a terminal: `nvim --headless -c "VimtexInverseSearch 123 '/absolute/path/to/file.tex'"`.

### Paths and permissions on macOS
- Confirm Skim has permissions to control your Mac if using AppleScript elsewhere. Not required for this minimal setup.

### Path Configuration Problems
- Verify Script Path: In Skim preferences, use the full canonical absolute path to the script; do not use tilde (~) and do not use symlinks. Use exactly: <Full/path/to>/nvim/scripts/skim_inverse_search.sh
- Test Script Manually: Run <Full/path/to>/nvim/scripts/skim_inverse_search.sh 10 "/absolute/path/to/test.tex" to validate the script directly.
- Check nvr Installation: Verify nvr is installed at /opt/homebrew/bin/nvr with which nvr.
- Homebrew Path Issues: If nvr is installed elsewhere, update the script path accordingly.
