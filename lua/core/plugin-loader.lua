-- =============================================================================
-- OPTIMIZED PLUGIN LOADER
-- PURPOSE: Consolidated plugin loading with 3 optimized phases
-- =============================================================================

local PluginLoader = {}

---Return true if startup debug notifications are enabled.
---@return boolean
local function is_startup_debug()
	return vim.g.startup_debug == 1 or vim.g.startup_debug == true
end

-- Map plugin config modules ("lua/plugins/<module>.lua") to vim.pack plugin names.
-- This keeps phased loading while using vim.pack's opt-only install location.
local MODULE_TO_PACK = {
	["plenary-nvim"] = "plenary.nvim",
	["nvim-web-devicons"] = "nvim-web-devicons",
	["blink-cmp"] = "blink.cmp",
	["mason-nvim"] = "mason.nvim",
	["nvim-lspconfig"] = "nvim-lspconfig",
	["nvim-treesitter"] = "nvim-treesitter",
	["mini-nvim"] = "mini.nvim",

	["bufferline-nvim"] = "bufferline.nvim",
	["lualine-nvim"] = "lualine.nvim",
	["nvim-tree"] = "nvim-tree.lua",
	["telescope"] = "telescope.nvim",
	["trouble-nvim"] = "trouble.nvim",
	["gitsigns-nvim"] = "gitsigns.nvim",
	["toggleterm-nvim"] = "toggleterm.nvim",
	["markdown-preview-nvim"] = "markdown-preview.nvim",
	["zen-mode-nvim"] = "zen-mode.nvim",
	["vimtex"] = "vimtex",
	["typst-preview-nvim"] = "typst-preview.nvim",
	["obsidian-nvim"] = "obsidian.nvim",
	["autolist-nvim"] = "autolist.nvim",
	["table-nvim"] = "table-nvim",
	["otter-nvim"] = "otter.nvim",
	["quarto-nvim"] = "quarto-nvim",
	["julia-vim"] = "julia-vim",

	["which-key-nvim"] = "which-key.nvim",
	["auto-dark-mode-nvim"] = "auto-dark-mode.nvim",
	["gruvbox-nvim"] = "gruvbox.nvim",
	["tokyonight-nvim"] = "tokyonight.nvim",
	["nord-vim"] = "nord-vim",
	["github-nvim-theme"] = "github-nvim-theme",
	["awesome-vim-colorschemes"] = "awesome-vim-colorschemes",
	["onedark-nvim"] = "onedark.nvim",
	["catppuccin"] = "catppuccin",
}

---Ensure a plugin is on runtimepath before requiring its config.
---@param module_name string
local function ensure_packadd(module_name)
	local pack_name = MODULE_TO_PACK[module_name]
	if not pack_name then
		return
	end
	pcall(vim.cmd.packadd, pack_name)
end

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
		"markdown-preview-nvim", -- Markdown preview
		"zen-mode-nvim",      -- Distraction-free writing for prose
		"vimtex",             -- LaTeX support
		"typst-preview-nvim", -- Typst preview
		"obsidian-nvim",      -- Obsidian vault support
		"autolist-nvim",      -- List continuation
		"table-nvim",         -- Markdown tables
		"otter-nvim",         -- Code execution (Quarto)
		"quarto-nvim",        -- Quarto support
		"julia-vim",          -- Julia syntax/indent
		"forge-nvim",         -- Forge task & project manager
	},

	-- Phase 3: LAZY (500ms) - Non-essentials and themes
	lazy = {
		"which-key-nvim",     -- Keymap discovery
		"auto-dark-mode-nvim", -- Auto theme switching
		-- Themes (loaded on-demand)
		"gruvbox-nvim",
		"tokyonight-nvim",
		"nord-vim",
		"github-nvim-theme",
		"awesome-vim-colorschemes",
		"onedark-nvim",
		"catppuccin",
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
			ensure_packadd(plugin)
			local ok, err = pcall(require, "plugins." .. plugin)
			if not ok then
				vim.notify("Failed to load " .. plugin .. ": " .. tostring(err), vim.log.levels.WARN)
			end
		end
	else
		-- Load with delay
		vim.defer_fn(function()
			for _, plugin in ipairs(plugins) do
				ensure_packadd(plugin)
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
	if is_startup_debug() then
		vim.notify("Loading plugins in optimized phases...", vim.log.levels.INFO)
	end

	-- Phase 1: Immediate
	PluginLoader.load_with_phase("immediate", LOAD_PHASES.immediate)

	-- Phase 2: Deferred
	PluginLoader.load_with_phase("deferred", LOAD_PHASES.deferred)

	-- Phase 3: Lazy
	PluginLoader.load_with_phase("lazy", LOAD_PHASES.lazy)

	if is_startup_debug() then
		vim.notify("Plugin loading complete", vim.log.levels.INFO)
	end
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
