-- Configuration for quarto-nvim
-- Quarto document authoring support with multi-language LSP

local ok, quarto = pcall(require, "quarto")
if ok then
	quarto.setup({
		debug = false,
		closePreviewOnExit = true,
		lspFeatures = {
			enabled = true,
			chunks = "curly",
			languages = { "r", "python", "julia", "bash", "html" },
			diagnostics = {
				enabled = true,
				triggers = { "BufWritePost" },
			},
			completion = {
				enabled = true,
			},
		},
		codeRunner = {
			enabled = true,
			default_method = "otter", -- Use otter for code execution
			ft_runners = {}, -- filetype to runner, ie. `{ python = "otter" }`
			never_run = { "yaml" }, -- filetypes which are never sent to a code runner
		},
	})
end
