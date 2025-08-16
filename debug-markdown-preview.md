# Markdown Preview Debug Test

Testing image rendering with various path formats and configurations.

## Test 1: Standard Markdown Images (Relative Paths)

![Test Image 1](attachments/0*CduMoQjTz_kyxAFu.jpg)
![Test Image 2](attachments/0*VWygbW_Tfr7vM5EY.jpg)

## Test 2: Absolute Paths

![Absolute Path 1](/Users/s_a_b/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook/attachments/0*CduMoQjTz_kyxAFu.jpg)
![Absolute Path 2](/Users/s_a_b/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook/attachments/0*VWygbW_Tfr7vM5EY.jpg)

## Test 3: File Protocol URLs

![File URL 1](file:///Users/s_a_b/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook/attachments/0*CduMoQjTz_kyxAFu.jpg)
![File URL 2](file:///Users/s_a_b/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook/attachments/0*VWygbW_Tfr7vM5EY.jpg)

## Test 4: URL Encoded Paths

![Encoded Path 1](file:///Users/s_a_b/Library/Mobile%20Documents/iCloud~md~obsidian/Documents/Notebook/attachments/0*CduMoQjTz_kyxAFu.jpg)
![Encoded Path 2](file:///Users/s_a_b/Library/Mobile%20Documents/iCloud~md~obsidian/Documents/Notebook/attachments/0*VWygbW_Tfr7vM5EY.jpg)

## Test 5: Online Images (Should Always Work)

![Online Test](https://via.placeholder.com/400x300/007acc/ffffff?text=Online+Image+Test)

## Test 6: Wikilink Format (Obsidian Style)

![[0*CduMoQjTz_kyxAFu.jpg]]
![[0*VWygbW_Tfr7vM5EY.jpg]]

## Debug Information

Current working directory: Check with `:pwd`
Current file path: Check with `:echo expand('%:p')`
Markdown preview settings: Check with `:echo g:mkdp_images_path`

## Instructions

1. Open this file in Neovim from your Obsidian vault directory
2. Use `<leader>Ov` to start markdown preview
3. Check browser console for any errors
4. Verify which image formats work and which don't
