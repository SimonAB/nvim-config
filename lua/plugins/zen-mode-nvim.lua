-- Configuration for zen-mode.nvim
-- Distraction-free writing, enabled by default for markdown buffers

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

--- Enable Zen Mode automatically for markdown buffers, once per buffer.
---@param _ table|nil Autocommand callback data (unused).
local function enable_markdown_zen_mode(_)
	-- Only act on markdown buffers
	if vim.bo.filetype ~= "markdown" then
		return
	end

	-- Avoid reopening repeatedly for the same buffer
	if vim.b.zen_markdown_initialised then
		return
	end
	vim.b.zen_markdown_initialised = true

	-- Capture the current window and buffer so we can reliably
	-- open Zen Mode from that exact context after Neovim finishes
	-- running any pending autocommands. This ensures that the
	-- cursor is placed correctly in the Zen window.
	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()

	vim.schedule(function()
		if not (vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_win_is_valid(win)) then
			return
		end
		if vim.api.nvim_win_get_buf(win) ~= bufnr then
			return
		end

		-- Ensure we are in the original window when opening Zen Mode
		vim.api.nvim_set_current_win(win)
		pcall(vim.cmd, "ZenMode")
	end)
end

local markdown_zen_group = vim.api.nvim_create_augroup("ZenModeMarkdown", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = markdown_zen_group,
	pattern = "markdown",
	callback = enable_markdown_zen_mode,
})

