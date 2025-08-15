-- Plugin Loading Orchestration (Optimised for Speed)
-- This file orchestrates the loading of all individual plugin configurations
-- Order optimised for: 1) Dependencies, 2) Lightweight first, 3) Core functionality, 4) UI/Appearance

-- ============================================================================
-- PHASE 1: LIGHTWEIGHT UTILITIES & DEPENDENCIES (Load First)
-- ============================================================================
require("plugins.plenary-nvim")        -- Utility library (dependency for telescope)

-- ============================================================================
-- PHASE 2: CORE FUNCTIONALITY (Essential for basic operation)
-- ============================================================================
require("plugins.nvim-web-devicons")   -- File icons (dependency for many UI plugins)
require("plugins.nvim-treesitter")     -- Syntax highlighting (core functionality)
require("plugins.blink-cmp")           -- Completion engine (core functionality)
require("plugins.mason-nvim")          -- LSP server manager (core functionality)
require("plugins.nvim-lspconfig")      -- LSP configurations (core functionality)

-- ============================================================================
-- PHASE 3: USER INTERFACE (Visual components)
-- ============================================================================
require("plugins.bufferline-nvim")     -- Buffer tabs
require("plugins.lualine-nvim")        -- Status line
require("plugins.nvim-tree")           -- File explorer
require("plugins.telescope")           -- Fuzzy finder
require("plugins.trouble-nvim")        -- Diagnostics viewer

-- ============================================================================
-- PHASE 4: THEMES & APPEARANCE (Load after UI components)
-- ============================================================================
require("plugins.catppuccin")          -- Primary theme
require("plugins.onedark-nvim")        -- Alternative theme
require("plugins.tokyonight-nvim")     -- Alternative theme
require("plugins.nord-vim")            -- Alternative theme
require("plugins.github-nvim-theme")   -- Alternative theme
require("plugins.awesome-vim-colorschemes") -- Theme collection
require("plugins.auto-dark-mode-nvim") -- Auto theme switching

-- ============================================================================
-- PHASE 5: DEVELOPMENT TOOLS (Load after core functionality)
-- ============================================================================
require("plugins.gitsigns-nvim")       -- Git integration
require("plugins.mini-nvim")           -- Dashboard and text objects

-- ============================================================================
-- PHASE 6: TERMINAL & EXECUTION (Load after core functionality)
-- ============================================================================
require("plugins.toggleterm-nvim")     -- Terminal management


-- ============================================================================
-- PHASE 7: DOCUMENT PROCESSING (Load last - specialised functionality)
-- ============================================================================
require("plugins.vimtex")              -- LaTeX support
require("plugins.markdown-preview-nvim") -- Markdown preview
require("plugins.typst-preview-nvim")  -- Typst preview

require("plugins.otter-nvim")          -- Multi-language LSP in documents
require("plugins.quarto-nvim")         -- Quarto support
-- ============================================================================
-- PHASE 8: KEYMAP MANAGEMENT (Load last - depends on all other plugins)
-- ============================================================================
require("plugins.which-key-nvim")      -- Keymap discovery and management
