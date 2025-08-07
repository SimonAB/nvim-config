# Skim SyncTeX — Installation & Configuration

Minimal configuration using VimTeX’s native Skim backend.

## Prerequisites
- macOS
- Neovim 0.12+
- VimTeX
- Skim

## Steps
1) Install tools
```bash
brew install neovim
brew install --cask skim
brew install --cask mactex-no-gui
```

2) Configure Skim → Preferences → Sync
- Preset: Custom
- Command: `~/.config/nvim/scripts/skim_inverse_search.sh`
- Arguments: `%line "%file"`

3) Use
- Compile: `\ll` or `<localleader>ll`
- Forward search: `<localleader>lv`
- Inverse search: Cmd+Shift+Click in Skim
