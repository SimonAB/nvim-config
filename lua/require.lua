-- Plugin Loading Orchestration (Performance Optimised)
-- This file orchestrates the loading of all individual plugin configurations
-- Order optimised for: 1) Dependencies, 2) Core functionality, 3) UI/Appearance, 4) Specialised features

-- Priority-based loading function with error handling
local function load_plugin_with_priority(plugin_name, priority)
	local function safe_require()
		local ok, err = pcall(require, "plugins." .. plugin_name)
		if not ok then
			vim.notify("Failed to load plugin: " .. plugin_name .. " - " .. tostring(err), vim.log.levels.WARN)
		end
	end

	if priority == "immediate" then
		safe_require()
	elseif priority == "deferred" then
		vim.defer_fn(safe_require, 200)
	elseif priority == "lazy" then
		vim.defer_fn(safe_require, 1000)
	end
end

-- ============================================================================
-- PHASE 1: IMMEDIATE - CORE DEPENDENCIES (Load First)
-- ============================================================================
load_plugin_with_priority("plenary-nvim", "immediate")        -- Utility library (dependency for telescope)

-- ============================================================================
-- PHASE 2: IMMEDIATE - CORE FUNCTIONALITY (Essential for basic operation)
-- ============================================================================
load_plugin_with_priority("nvim-web-devicons", "immediate")   -- File icons (dependency for many UI plugins)
load_plugin_with_priority("nvim-treesitter", "immediate")     -- Syntax highlighting (core functionality)
load_plugin_with_priority("blink-cmp", "immediate")           -- Completion engine (core functionality)
load_plugin_with_priority("mason-nvim", "immediate")          -- LSP server manager (core functionality)
load_plugin_with_priority("nvim-lspconfig", "immediate")      -- LSP configurations (core functionality)

-- ============================================================================
-- PHASE 3: IMMEDIATE - DASHBOARD (Must be available on startup)
-- ============================================================================
load_plugin_with_priority("mini-nvim", "immediate")           -- Dashboard and text objects

-- ============================================================================
-- PHASE 4: DEFERRED - USER INTERFACE (Visual components)
-- ============================================================================
load_plugin_with_priority("bufferline-nvim", "deferred")     -- Buffer tabs
load_plugin_with_priority("lualine-nvim", "deferred")        -- Status line
load_plugin_with_priority("nvim-tree", "deferred")           -- File explorer
load_plugin_with_priority("telescope", "deferred")           -- Fuzzy finder
load_plugin_with_priority("trouble-nvim", "deferred")        -- Diagnostics viewer

-- ============================================================================
-- PHASE 5: DEFERRED - DEVELOPMENT TOOLS (Load after UI components)
-- ============================================================================
load_plugin_with_priority("gitsigns-nvim", "deferred")       -- Git integration
load_plugin_with_priority("toggleterm-nvim", "deferred")     -- Terminal management

-- ============================================================================
-- PHASE 6: DEFERRED - DOCUMENT PROCESSING (Load after core functionality)
-- ============================================================================
load_plugin_with_priority("vimtex", "deferred")              -- LaTeX support
load_plugin_with_priority("markdown-preview-nvim", "immediate") -- Markdown preview (load immediately for Obsidian)
load_plugin_with_priority("typst-preview-nvim", "deferred")  -- Typst preview
load_plugin_with_priority("obsidian-nvim", "deferred")       -- Obsidian vault support
load_plugin_with_priority("otter-nvim", "deferred")          -- Multi-language LSP in documents
load_plugin_with_priority("quarto-nvim", "deferred")         -- Quarto support

-- ============================================================================
-- PHASE 7: LAZY - THEMES & APPEARANCE (Load last - non-essential)
-- ============================================================================
-- Note: Active themes (onedark, catppuccin) are loaded immediately in init.lua
-- Other themes are loaded lazily to avoid startup overhead
load_plugin_with_priority("tokyonight-nvim", "lazy")         -- Alternative theme
load_plugin_with_priority("nord-vim", "lazy")                -- Alternative theme
load_plugin_with_priority("github-nvim-theme", "lazy")       -- Alternative theme
load_plugin_with_priority("awesome-vim-colorschemes", "lazy") -- Theme collection
load_plugin_with_priority("auto-dark-mode-nvim", "lazy")     -- Auto theme switching

-- ============================================================================
-- PHASE 8: LAZY - KEYMAP MANAGEMENT (Load last - depends on all other plugins)
-- ============================================================================
load_plugin_with_priority("which-key-nvim", "lazy")          -- Keymap discovery and management
