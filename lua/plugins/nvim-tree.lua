-- Configuration for nvim-tree.lua
-- File explorer with enhanced visual features

local ok, nvim_tree = pcall(require, "nvim-tree")
if ok then
	nvim_tree.setup({
		view = {
			side = "left", -- Show tree on the left
			width = 30, -- Set width of the tree window
		},
		renderer = {
			icons = {
				show = {
					git = true, -- Show git status icons
					folder = true, -- Show folder icons
					file = true, -- Show file icons
				},
			},
		},
		filters = {
			dotfiles = false, -- Show dotfiles by default
		},
		-- You can add more config here (e.g., actions, git integration, etc.)
	})
end
