-- Configuration for toggleterm.nvim
-- Terminal management with enhanced features

local ok, toggleterm = pcall(require, "toggleterm")
if ok then
	toggleterm.setup({
		size = function(term)
			-- Dynamically set terminal size based on direction
			if term.direction == "horizontal" then
				return 15 -- 15 lines for horizontal terminals
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4 -- 40% of editor width for vertical
			end
		end,
		direction = "vertical", -- Default to vertical split
		float_opts = {
			border = "curved", -- Use curved border for floating terminals
		},
	})
	-- You can toggle the terminal with <leader>tt (if mapped in your keymaps)
end
