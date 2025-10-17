# Troubleshooting Guide for Neovim Configuration

## Common Issues and Solutions

### LaTeX Inverse Search Issues

#### No response on inverse search
- **Skim Sync settings**: Preferences → Sync → Command `nvim`, Arguments `--headless -c "VimtexInverseSearch %line '%file'"`.
- **Neovim path**: Verify `which nvim` points to your Neovim 0.12 install.
- **Synctex**: Ensure your build includes `-synctex=1` (configured via VimTeX latexmk options here).

#### Path Configuration Problems
- **Verify Script Path**: In Skim preferences, use the full canonical absolute path to the script; do not use tilde (~) and do not use symlinks. Use exactly: `<Full/path/to>/nvim/scripts/skim_inverse_search.sh`
- **Test Script Manually**: Run `<Full/path/to>/nvim/scripts/skim_inverse_search.sh 10 "/absolute/path/to/test.tex"` to validate the script directly.
- **Check nvr Installation**: Verify nvr is installed at `/opt/homebrew/bin/nvr` with `which nvr`.
- **Homebrew Path Issues**: If nvr is installed elsewhere, update the script path accordingly.

#### Files not found with relative paths in LaTeX projects
- The script now includes intelligent path resolution
- For custom project layouts, export `INVERSE_SEARCH_PROJECT_ROOT=/path/to/project`
- Check debug log: `tail -f /tmp/inverse_search.log` whilst testing inverse search
- Verify your project structure matches supported patterns

### Plugin and Configuration Issues

#### Plugins not loading
- Restart Neovim (auto-installs on first run)
- Clear cache: `rm -rf ~/.local/share/nvim/pack/`
- Check individual plugin files for configuration errors
- Check error messages in `:messages` for specific plugin failures

#### Configuration changes not taking effect
- Use `<leader>Cs` to reload all configuration files
- Check for syntax errors in individual plugin files
- Verify plugin dependencies are installed

#### Markdown preview not working
- Ensure the plugin is built: check `~/.local/share/nvim/pack/plugins/start/markdown-preview.nvim/app/bin/`
- Use `<leader>Kp` to start preview
- Check browser permissions for local file access

### Language Server Issues

#### Julia LSP not starting
- Install LanguageServer.jl: `using Pkg; Pkg.add("LanguageServer")`
- Verify Julia is in PATH
- Check Mason interface: `<leader>Mm` to see available servers

#### Python LSP issues
- Install pyright: `npm install -g pyright`
- Or use Mason: `<leader>Mm` then install `pyright`
- Verify Python is in PATH

#### LaTeX LSP issues
- Install texlab: `brew install texlab`
- Or use Mason: `<leader>Mm` then install `texlab`
- Verify LaTeX distribution is properly installed

### Terminal Integration Issues

#### Terminal not opening
- Check if toggleterm plugin is loaded
- Try `<leader>Th` for horizontal terminal or `<leader>Tv` for vertical
- Verify terminal emulator is properly configured

#### Code block execution not working
- Ensure you're in a supported file type (Julia, Python, R, etc.)
- Check if the appropriate language server is installed
- Verify terminal integration is properly configured

### Theme and Appearance Issues

#### Theme not cycling
- Use `<leader>Yc` to cycle through available themes
- Check if auto-dark-mode is working: `<leader>Ys` to toggle
- Verify theme plugins are properly installed

#### Icons not displaying
- Ensure nvim-web-devicons is installed
- Check if your terminal supports icons
- Verify font supports the required glyphs

### Performance Issues

#### Slow startup
- Check which plugins are loading: `:profile start profile.log` then `:profile func *` and `:profile file *`
- Use `<leader>Cs` to reload configuration
- Check for plugin conflicts in `:messages`

#### High memory usage
- Monitor plugin memory usage with `:lua print(vim.inspect(vim.lsp.get_active_clients()))`
- Check for memory leaks in long-running sessions
- Restart Neovim periodically for long editing sessions

### Debugging Commands

#### General Debugging
```vim
:messages          " View error messages
:checkhealth       " Run Neovim health checks
:lua print(vim.inspect(vim.lsp.get_active_clients()))  " Check LSP clients
:VimtexInfo        " Check VimTeX status
:Mason             " Open Mason interface
```

#### Plugin Debugging
```vim
:WhichKey          " Show all available keymaps
:Telescope keymaps " Search through keymaps
:lua print(vim.inspect(vim.g))  " Check global variables
```

### Log Files

#### Important Log Locations
- **Inverse Search**: `/tmp/inverse_search.log`
- **Neovim**: `~/.local/share/nvim/log/`
- **Mason**: `~/.local/share/nvim/mason/`
- **LSP**: Check `:lua print(vim.lsp.get_log_path())`

### Getting Help

#### Built-in Help
- `:help` - General Neovim help
- `:help vimtex` - VimTeX documentation
- `:help telescope` - Telescope documentation
- `:help which-key` - Which-key documentation

#### External Resources
- [Neovim Documentation](https://neovim.io/doc/)
- [VimTeX Documentation](https://github.com/lervag/vimtex)
- [Mason Documentation](https://github.com/mason-org/mason.nvim)
- [Telescope Documentation](https://github.com/nvim-telescope/telescope.nvim)

---

*For additional support, check the configuration files in `lua/plugins/` for detailed comments and usage examples.*
