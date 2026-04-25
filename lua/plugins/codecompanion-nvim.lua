-- Configuration for codecompanion.nvim
-- PURPOSE: Use ACP (Cursor CLI) for chat, with optional Ollama HTTP adapter for local models

local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
	vim.notify("codecompanion.nvim not found", vim.log.levels.WARN)
	return {}
end

codecompanion.setup({
	interactions = {
		-- ACP adapters are chat-only. This makes Cursor CLI the default for :CodeCompanionChat.
		chat = {
			adapter = "cursor_cli",
		},

		-- Keep non-chat interactions conservative; you can switch these later if desired.
		background = {
			adapter = {
				name = "ollama",
				model = "llama3.1:8b",
			},
		},
	},
	adapters = {
		acp = {
			cursor_cli = function()
				return require("codecompanion.adapters").extend("cursor_cli", {
					-- Cursor CLI auth is handled by `agent login` in your shell.
					-- Session config options (models/modes/etc.) vary by agent; use the debug window to inspect.
					defaults = {
						session_config_options = {},
					},
				})
			end,
		},
		http = {
			ollama = function()
				return require("codecompanion.adapters").extend("ollama", {
					-- For remote Ollama, set OLLAMA_HOST in your environment (preferred),
					-- or configure `env.url` here. Local default is typically http://127.0.0.1:11434.
					schema = {
						model = {
							default = "llama3.1:8b",
						},
					},
				})
			end,
		},
	},
})

return {}

