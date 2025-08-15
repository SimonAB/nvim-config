-- Plugin management keymaps for Blink.cmp
-- This plugin provides fast, extensible autocompletion for Neovim.
-- See https://github.com/glepnir/blink.nvim for more details and advanced usage.

local map = vim.keymap.set -- For custom keymaps if needed

-- Blink.cmp completion setup with simplified config
local ok, blink = pcall(require, "blink.cmp")
if ok then
	blink.setup({
		keymap = {
			preset = "default", -- Use default keymap preset
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" }, -- Show completion/documentation
			["<C-e>"] = { "hide" }, -- Hide completion menu
			["<CR>"] = { "accept", "fallback" }, -- Accept completion
			["<Tab>"] = { "select_next", "fallback" }, -- Next item
			["<S-Tab>"] = { "select_prev", "fallback" }, -- Previous item
		},
		appearance = {
			use_nvim_cmp_as_default = false, -- Do not override nvim-cmp if present
			nerd_font_variant = "mono", -- Use monospaced nerd font icons
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" }, -- Completion sources
		},
		completion = {
			accept = {
				auto_brackets = {
					enabled = true, -- Auto-insert brackets for functions
				},
			},
			menu = {
				enabled = true,
				auto_show = true, -- Show menu automatically
			},
			documentation = {
				auto_show = true, -- Show docs automatically
				auto_show_delay_ms = 200, -- Delay for docs popup
			},
			ghost_text = {
				enabled = true, -- Show ghost text for suggestions
			},
		},
		signature = {
			enabled = true, -- Enable signature help
		},
		fuzzy = {
			implementation = "prefer_rust", -- Use Rust for fuzzy matching if available
			prebuilt_binaries = {
				download = false, -- Do not auto-download binaries
				ignore_version_mismatch = true, -- Ignore version mismatch warnings
			},
		},
	})
end
