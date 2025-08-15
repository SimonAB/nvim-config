-- Configuration for telescope.nvim
-- Fuzzy finder with enhanced features

local ok, telescope = pcall(require, "telescope")
if ok then
	telescope.setup({
		defaults = {
			-- Default configuration for telescope
			-- You can add more config here (e.g., mappings, layout, etc.)
		},
		pickers = {
			-- Configuration for specific pickers
			find_files = {
				hidden = true, -- Show hidden files
			},
			live_grep = {
				additional_args = function()
					return { "--hidden" } -- Include hidden files in grep
				end,
			},
		},
		extensions = {
			-- Extensions configuration
		},
	})
end
