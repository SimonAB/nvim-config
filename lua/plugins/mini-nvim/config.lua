-- =============================================================================
-- MINI.NVIM CONFIGURATION
-- PURPOSE: Centralised configuration constants for mini.nvim setup
-- =============================================================================

local M = {}

-- Dashboard configuration
M.DASHBOARD = {
	MAX_PROJECTS = 4,
	MAX_RECENT_FILES = 4,
	RECENT_FILE_KEYS = { "a", "b", "c", "d" },
	FORGE_KEYS = { "I", "N", "B", "R" },
	HEADER_COLOUR = "#4A6D8C", -- Muted blue-black
	REFRESH_DELAY = 50,
	PLUGIN_UPDATE_DELAY = 100,
}

-- Dashboard header ASCII art
M.HEADER = [[
███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]]

-- Plugin management configuration
M.PLUGIN_MANAGER = {
	PLUGIN_DIR = vim.fn.stdpath("data") .. "/pack/plugins/start",
	CONFIG_DIR = vim.fn.stdpath("config"),
}

-- Sections indexed by mini.starter's auto-indexing hook
-- (Forge is excluded because it uses explicit keymaps)
M.INDEXED_SECTIONS = {
	"Shortcuts",
	"Projects",
	"Recent files",
	"Sessions",
	"Builtin actions",
}

-- All dashboard sections (display order)
M.SECTIONS = {
	"Shortcuts",
	"Forge",
	"Projects",
	"Recent files",
	"Sessions",
	"Builtin actions",
}

return M
