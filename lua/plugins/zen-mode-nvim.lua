-- Configuration for zen-mode.nvim
-- Distraction-free writing; toggle with <leader>z (not enabled by default for markdown)

local ok, zen_mode = pcall(require, "zen-mode")
if not ok then
	vim.notify("zen-mode.nvim not found", vim.log.levels.WARN)
	return
end

zen_mode.setup({
	-- Configure Zen Mode to behave like a lightweight option toggle
	-- rather than a centred overlay window.
	window = {
		-- No dimming and 60% editor width.
		backdrop = 1,
		width = 0.6,
		options = {
			number = false,
			relativenumber = false,
			signcolumn = "no",
			-- Fully opaque Zen window (no window-level transparency).
			winblend = 0,
		},
	},
	plugins = {
		options = {
			showcmd = false,
			laststatus = 0,
		},
	},
})


