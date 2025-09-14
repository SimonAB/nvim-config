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

-- Dashboard sections
M.SECTIONS = {
	"Shortcuts",
	"Projects",
	"Recent files",
	"Sessions",
	"Builtin actions"
}

return M
