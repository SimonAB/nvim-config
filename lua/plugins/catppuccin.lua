-- Configuration for catppuccin.nvim
-- Beautiful and modern colour scheme

local ok, catppuccin = pcall(require, "catppuccin")
if ok then
	catppuccin.setup({
		flavour = "latte", -- latte, frappe, macchiato, mocha (changed to latte for light mode)
		background = { -- :h background
			light = "latte",
			dark = "mocha",
		},
		transparent_background = false, -- Disable transparent background
		term_colors = false, -- Disable terminal colours
		dim_inactive = {
			enabled = false, -- Disable dimming of inactive windows
			shade = "dark",
			percentage = 0.15,
		},
		styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
			comments = { "italic" }, -- Change the style of comments
			conditionals = { "italic" },
			loops = {},
			functions = {},
			keywords = {},
			strings = {},
			variables = {},
			numbers = {},
			booleans = {},
			properties = {},
			types = {},
			operators = {},
		},
		integrations = {
			-- For various plugins integrations. https://github.com/catppuccin/nvim#integrations
			cmp = true,
			gitsigns = true,
			nvimtree = true,
			telescope = true,
			treesitter = true,
			-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
		},
		color_overrides = {},
		custom_highlights = {},
	})
end
