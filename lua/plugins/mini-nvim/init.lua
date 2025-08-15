-- =============================================================================
-- MINI.NVIM MAIN ENTRY POINT
-- PURPOSE: Main setup and orchestration for mini.nvim modules
-- =============================================================================

local utils = require("plugins.mini-nvim.utils")
local dashboard = require("plugins.mini-nvim.dashboard")

local M = {}

-- Main setup function
function M.setup()
	dashboard.setup()
	dashboard.setup_keymaps()
	dashboard.setup_autocommands()
	dashboard.setup_debug()
end

-- Load additional mini.nvim modules
function M.load_additional_modules()
	-- Load mini.surround for text object editing
	local ok, mini_surround = utils.safe_require("mini.surround")
	if ok then
		mini_surround.setup()
	end
end

-- Initialize the module
M.setup()
M.load_additional_modules()

-- =============================================================================
-- AVAILABLE MINI.NVIM MODULES (commented for later activation)
-- =============================================================================
-- require('mini.base16').setup()
-- require('mini.ai').setup()
-- require('mini.align').setup()
-- require('mini.animate').setup()
-- require('mini.basics').setup()
-- require('mini.bracketed').setup()
-- require('mini.bufremove').setup()
-- require('mini.clue').setup()
-- require('mini.colors').setup()
-- require('mini.hipatterns').setup()
-- require('mini.comment').setup()
-- require('mini.completion').setup()
-- require('mini.cursorword').setup()
-- require('mini.extra').setup()
-- require('mini.deps').setup()
-- require('mini.diff').setup()
-- require('mini.doc').setup()
-- require('mini.files').setup()
-- require('mini.fuzzy').setup()
-- require('mini.git').setup()
-- require('mini.hues').setup()
-- require('mini.icons').setup()
-- require('mini.indentscope').setup()
-- require('mini.jump').setup()
-- require('mini.jump2d').setup()
-- require('mini.map').setup()
-- require('mini.misc').setup()
-- require('mini.move').setup()
-- require('mini.notify').setup()
-- require('mini.operators').setup()
-- require('mini.pairs').setup()
-- require('mini.pick').setup()
-- require('mini.sessions').setup()
-- require('mini.snippets').setup()
-- require('mini.splitjoin').setup()
-- require('mini.starter').setup()
-- require('mini.statusline').setup()
-- require('mini.tabline').setup()
-- require('mini.test').setup()
-- require('mini.trailspace').setup()
-- require('mini.visits').setup()

return M
