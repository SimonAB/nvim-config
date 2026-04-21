-- Catppuccin.nvim — Mocha (dark) / Latte (light), synced via `background`.
-- Canonical table: `core.config-manager` → `themes.catppuccin`.

local ConfigManager = require("core.config-manager")
local ok, catppuccin = pcall(require, "catppuccin")
if ok then
	catppuccin.setup(vim.deepcopy(ConfigManager.themes.catppuccin))
end
