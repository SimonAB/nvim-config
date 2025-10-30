-- Configuration for github-nvim-theme
-- GitHub-inspired colour scheme

local ok, github_theme = pcall(require, "github-theme")
if ok then
	github_theme.setup({
		-- Use vim's builtin :colorscheme command to select theme style
		-- Available styles: "light", "dark_default", "dark_colorblind", "dark_tritanopia", "dark_dimmed"
		-- Example: :colorscheme github_dark_default

		light_style = "light_default", -- Choose between "light", "light_colorblind", "light_tritanopia", "light_high_contrast"
		terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
		styles = {
			-- Style to be applied to different syntax groups
			comments = { italic = true },
			-- Match Gruvbox: do not italicise keywords
			keywords = {},
			functions = {},
			variables = {},
			sidebars = "dark", -- style for sidebars, see below
			floats = "dark", -- style for floating windows
		},
		day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style
		dim_inactive = false, -- dims inactive windows
		lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

		-- New options structure (replaces deprecated options)
		options = {
			transparent = false, -- Enable this to disable setting the background color
			hide_nc_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead
			-- Sidebar darkening configuration
			darken = {
				sidebars = {
					list = { "qf", "help" }, -- Set a darker background on sidebar-like windows
				},
			},
		},

		-- You can override specific color groups to use other groups or a hex color
		-- function will be called with a ColorScheme table
		-- @param colors ColorScheme
		on_colors = function(colors) end,
		-- You can override specific highlights to use other groups or a hex color
		-- function will be called with a Highlights and ColorScheme table
		-- @param highlights Highlights
		-- @param colors ColorScheme
		on_highlights = function(highlights, colors) end,
	})
end
