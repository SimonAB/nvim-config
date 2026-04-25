-- Configuration for codecompanion.nvim
-- Purpose: AI chat in Neovim with ACP via Cursor CLI

local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
	vim.notify("codecompanion.nvim not found", vim.log.levels.WARN)
	return
end

codecompanion.setup({
	interactions = {
		chat = {
			-- ACP adapters are chat-only; use Cursor CLI by default.
			adapter = "cursor_cli",
		},
	},
	adapters = {
		acp = {
			cursor_cli = function()
				return require("codecompanion.adapters").extend("cursor_cli", {})
			end,
		},
	},
})

return {}
