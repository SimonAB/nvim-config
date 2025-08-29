-- =============================================================================
-- OPTIMIZED PLUGIN LOADER
-- PURPOSE: Consolidated plugin loading with 3 optimized phases
-- =============================================================================

local PluginLoader = {}

-- Optimized loading phases (reduced from 8 to 3)
local LOAD_PHASES = {
	-- Phase 1: IMMEDIATE (0ms) - Core essentials
	immediate = {
		"plenary-nvim",        -- Utility library
		"nvim-web-devicons",   -- File icons
		"blink-cmp",          -- Completion engine
		"mason-nvim",         -- LSP server manager
		"nvim-lspconfig",     -- LSP configurations
		"nvim-treesitter",    -- Syntax highlighting
		"mini-nvim",          -- Dashboard and text objects
		"mason-enhanced",     -- Enhanced Mason UI
	},

	-- Phase 2: DEFERRED (100ms) - UI and functionality
	deferred = {
		"bufferline-nvim",    -- Buffer tabs
		"lualine-nvim",       -- Status line
		"nvim-tree",          -- File explorer
		"telescope",          -- Fuzzy finder
		"trouble-nvim",       -- Diagnostics viewer
		"gitsigns-nvim",      -- Git integration
		"toggleterm-nvim",    -- Terminal management
	},

	-- Phase 3: LAZY (500ms) - Non-essentials and themes
	lazy = {
		"which-key-nvim",     -- Keymap discovery
		"auto-dark-mode-nvim", -- Auto theme switching
		-- Themes (loaded on-demand)
		"tokyonight-nvim",
		"nord-vim",
		"github-nvim-theme",
		"awesome-vim-colorschemes",
	}
}

-- Optimized loading function with error handling
function PluginLoader.load_with_phase(phase_name, plugins)
	local phase_delay = {
		immediate = 0,
		deferred = 100,
		lazy = 500
	}

	local delay = phase_delay[phase_name] or 0

	if delay == 0 then
		-- Load immediately
		for _, plugin in ipairs(plugins) do
			local ok, err = pcall(require, "plugins." .. plugin)
			if not ok then
				vim.notify("Failed to load " .. plugin .. ": " .. tostring(err), vim.log.levels.WARN)
			end
		end
	else
		-- Load with delay
		vim.defer_fn(function()
			for _, plugin in ipairs(plugins) do
				local ok, err = pcall(require, "plugins." .. plugin)
				if not ok then
					vim.notify("Failed to load " .. plugin .. ": " .. tostring(err), vim.log.levels.WARN)
				end
			end
		end, delay)
	end
end

-- Load all plugins in optimized phases
function PluginLoader.load_all()
	vim.notify("Loading plugins in optimized phases...", vim.log.levels.INFO)

	-- Phase 1: Immediate
	self.load_with_phase("immediate", LOAD_PHASES.immediate)

	-- Phase 2: Deferred
	self.load_with_phase("deferred", LOAD_PHASES.deferred)

	-- Phase 3: Lazy
	self.load_with_phase("lazy", LOAD_PHASES.lazy)

	vim.notify("Plugin loading complete", vim.log.levels.INFO)
end

-- Get loading statistics
function PluginLoader.get_stats()
	local stats = {
		immediate = #LOAD_PHASES.immediate,
		deferred = #LOAD_PHASES.deferred,
		lazy = #LOAD_PHASES.lazy,
		total = 0
	}

	stats.total = stats.immediate + stats.deferred + stats.lazy
	return stats
end

return PluginLoader
