# Skim Inverse Search Setup - Installation & Configuration Guide

This guide provides step-by-step instructions to set up Skim PDF viewer with inverse search functionality for Neovim and VimTeX.

## Prerequisites

- macOS system
- Neovim installed
- VimTeX plugin installed
- Skim PDF viewer

## Installation Steps

### Step 1: Install Dependencies

First, ensure you have all required dependencies installed:

```bash
# Install Skim PDF viewer (if not already installed)
brew install --cask skim

# Verify Neovim is installed
nvim --version

# Check if VimTeX is installed in your Neovim configuration
# You can verify this by opening Neovim and running:
# :help vimtex
```

**VimTeX Installation Options:**
- Using vim-plug: Add `Plug 'lervag/vimtex'` to your init.vim/init.lua
- Using packer.nvim: Add `use 'lervag/vimtex'`
- Using vim.pack (0.12): Follow the new package manager syntax

### Step 2: Copy `skim_inverse_search.sh` to `scripts/`

Create the scripts directory if it doesn't exist and copy the inverse search script:

```bash
# Create scripts directory in your project or home directory
mkdir -p ~/scripts

# Copy the skim_inverse_search.sh script to the scripts directory
# (Assuming the script is in your current directory)
cp skim_inverse_search.sh ~/scripts/

# Alternative: If you want to place it in a project-specific location
# mkdir -p ./scripts
# cp skim_inverse_search.sh ./scripts/
```

### Step 3: Configure Skim's PDF Sync Preferences

1. **Open Skim PDF viewer**
2. **Go to Preferences** (⌘ + ,)
3. **Navigate to the "Sync" tab**
4. **Configure the following settings:**
   - **PDF-TeX Sync support**: ✅ Check "Check for file changes"
   - **Preset**: Select "Custom"
   - **Command**: Enter the full path to your script:
     ```
     /Users/[your-username]/scripts/skim_inverse_search.sh
     ```
     (Replace `[your-username]` with your actual username)
   - **Arguments**: Enter the following arguments:
     ```
     "%file" %line
     ```

5. **Click "OK" to save the settings**

### Step 4: Update Neovim Config for VimTeX Inverse Search

Add the following configuration to your Neovim configuration file:

**For init.vim:**
```vim
" Configure VimTeX to use Skim as the PDF viewer
let g:vimtex_view_method = 'skim'

" Enable automatic activation of Skim when viewing PDFs
let g:vimtex_view_skim_activate = 1

" Optional: Additional VimTeX-Skim configuration
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_skim_reading_bar = 1
```

**For init.lua:**
```lua
-- Configure VimTeX to use Skim as the PDF viewer
vim.g.vimtex_view_method = 'skim'

-- Enable automatic activation of Skim when viewing PDFs
vim.g.vimtex_view_skim_activate = 1

-- Optional: Additional VimTeX-Skim configuration
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_reading_bar = 1
```

**Configuration File Locations:**
- init.vim: `~/.config/nvim/init.vim`
- init.lua: `~/.config/nvim/init.lua`

### Step 5: Set Executable Permissions on the Script

Make the inverse search script executable:

```bash
# Set executable permissions for the script
chmod +x ~/scripts/skim_inverse_search.sh

# Verify the permissions were set correctly
ls -la ~/scripts/skim_inverse_search.sh

# The output should show something like:
# -rwxr-xr-x  1 username  staff  [size]  [date]  skim_inverse_search.sh
```

## Verification Steps

After completing the installation, verify that everything is working:

1. **Test VimTeX compilation:**
   ```bash
   # Open a LaTeX file in Neovim
   nvim test.tex
   
   # In Neovim, compile the document
   # Press: \ll (default VimTeX compile keybinding)
   ```

2. **Test PDF viewing:**
   - The PDF should automatically open in Skim
   - Try the forward search: Press `\lv` in Neovim

3. **Test inverse search:**
   - In Skim, Cmd+Shift+Click on any text in the PDF
   - Neovim should automatically jump to the corresponding line in the source file

## Troubleshooting

### Common Issues:

1. **Script not found error:**
   - Verify the script path in Skim preferences
   - Ensure the script has executable permissions

2. **Neovim doesn't open on inverse search:**
   - Check that the script contains the correct Neovim command
   - Verify Neovim is in your PATH: `which nvim`

3. **VimTeX not working:**
   - Ensure VimTeX is properly installed
   - Check `:help vimtex` in Neovim

4. **Skim doesn't open automatically:**
   - Verify `g:vimtex_view_skim_activate = 1` is set
   - Try manually opening with `\lv` command

### Additional Configuration Options:

```vim
" Optional VimTeX settings for enhanced Skim integration
let g:vimtex_view_skim_no_select = 1          " Don't select Skim on forward search
let g:vimtex_quickfix_mode = 0                " Suppress quickfix for warnings
let g:vimtex_compiler_latexmk = {
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'options' : [
    \   '-pdf',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}
```

## Next Steps

Once the setup is complete, you'll have a fully functional LaTeX editing environment with:
- Seamless PDF compilation and viewing
- Forward search (Neovim → Skim)
- Inverse search (Skim → Neovim)
- Automatic PDF updates on file changes

Happy LaTeX editing! 🎉
