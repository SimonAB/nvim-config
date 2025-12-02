-- Plugin Management with vim.pack (Neovim 0.12+)
-- Comprehensive plugin configuration migrated from nvim-cmp to blink.cmp
-- Includes core functionality, UI themes, navigation, and Julia LSP support

-- Plugin list with lazy loading
local essential_plugins = {
	-- Core functionality - Essential development tools (load immediately)
	{ url = "https://github.com/folke/trouble.nvim",              name = "trouble.nvim" },                                          -- Diagnostics viewer
	{ url = "https://github.com/Saghen/blink.cmp",                name = "blink.cmp",               build = "cargo build --release" }, -- Modern completion engine

	-- LSP and Language Support - Enhanced with Mason for server management
	{ url = "https://github.com/mason-org/mason.nvim",            name = "mason.nvim" },           -- LSP server manager
	{ url = "https://github.com/mason-org/mason-lspconfig.nvim",  name = "mason-lspconfig.nvim" }, -- Mason integration for lspconfig
	{ url = "https://github.com/neovim/nvim-lspconfig",           name = "nvim-lspconfig" }, -- LSP configurations

	-- UI and themes - Visual enhancements and colourschemes
	{ url = "https://github.com/catppuccin/nvim",                 name = "catppuccin" },            -- Modern pastel theme
	{ url = "https://github.com/navarasu/onedark.nvim",           name = "onedark.nvim" },          -- OneDark theme
	{ url = "https://github.com/ellisonleao/gruvbox.nvim",        name = "gruvbox.nvim" },          -- Gruvbox theme
	{ url = "https://github.com/folke/tokyonight.nvim",           name = "tokyonight.nvim" },       -- Tokyo Night theme
	{ url = "https://github.com/arcticicestudio/nord-vim",        name = "nord-vim" },              -- Nord theme
	{ url = "https://github.com/rafi/awesome-vim-colorschemes",   name = "awesome-vim-colorschemes" }, -- Collection of themes
	{ url = "https://github.com/projekt0n/github-nvim-theme",     name = "github-nvim-theme" },     -- GitHub theme
	{ url = "https://github.com/f-person/auto-dark-mode.nvim",    name = "auto-dark-mode.nvim" },   -- Auto theme switching
	{ url = "https://github.com/JuliaEditorSupport/julia-vim",    name = "julia-vim" },             -- Julia syntax/indent plugin
	{ url = "https://github.com/lewis6991/gitsigns.nvim",         name = "gitsigns.nvim" },         -- Git integration
	{ url = "https://github.com/nvim-lualine/lualine.nvim",       name = "lualine.nvim" },          -- Status line
	{ url = "https://github.com/akinsho/bufferline.nvim",         name = "bufferline.nvim" },       -- Buffer tabs

	-- Navigation - File and project navigation tools
	{ url = "https://github.com/nvim-telescope/telescope.nvim",   name = "telescope.nvim" }, -- Fuzzy finder
	{ url = "https://github.com/nvim-lua/plenary.nvim",           name = "plenary.nvim" },   -- Utility library (required by telescope)
	{ url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", name = "telescope-fzf-native.nvim", build = "make" }, -- FZF sorter for telescope
	{ url = "https://github.com/nvim-telescope/telescope-frecency.nvim", name = "telescope-frecency.nvim", dependencies = { "sqlite.lua" } }, -- Frequency and recency based sorting
	{ url = "https://github.com/kkharji/sqlite.lua", name = "sqlite.lua" }, -- SQLite for telescope-frecency
	{ url = "https://github.com/nvim-tree/nvim-tree.lua",         name = "nvim-tree.lua" },  -- File explorer
	{ url = "https://github.com/nvim-tree/nvim-web-devicons",     name = "nvim-web-devicons" }, -- File icons
	{ url = "https://github.com/folke/which-key.nvim",            name = "which-key.nvim" }, -- Keymap popup helper

	-- Terminal integration - Enhanced terminal workflow
	{ url = "https://github.com/akinsho/toggleterm.nvim",         name = "toggleterm.nvim" }, -- Terminal management

	-- Document processing - LaTeX, Typst and Markdown support
	{ url = "https://github.com/lervag/vimtex",                   name = "vimtex" },             -- LaTeX support
	{ url = "https://github.com/iamcco/markdown-preview.nvim",    name = "markdown-preview.nvim", build = "cd app && ./install.sh" }, -- Markdown preview
	{ url = "https://github.com/chomosuke/typst-preview.nvim",    name = "typst-preview.nvim" }, -- Typst preview
	{ url = "https://github.com/epwalsh/obsidian.nvim",           name = "obsidian.nvim" },      -- Obsidian vault support
	{ url = "https://github.com/3rd/image.nvim",                  name = "image.nvim" },         -- Image viewing in Neovim
	{ url = "https://github.com/gaoDean/autolist.nvim",           name = "autolist.nvim" },      -- Automatic list continuation and formatting

	{ url = "https://github.com/jmbuhr/otter.nvim",               name = "otter.nvim" },         -- Code execution in Quarto
	{ url = "https://github.com/quarto-dev/quarto-nvim",          name = "quarto-nvim" },        -- Quarto support

	-- Language support - Syntax highlighting and LSP
	{ url = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" }, -- Syntax highlighting

	-- Text manipulation
	{ url = "https://github.com/echasnovski/mini.nvim",           name = "mini.nvim" }, -- mini.nvim collection
}

-- Plugin installation
local pack_path = vim.fn.stdpath("data") .. "/pack/plugins"
local start_path = pack_path .. "/start"
vim.fn.mkdir(start_path, "p")

-- Install plugins only if missing
for _, plugin in ipairs(essential_plugins) do
	local plugin_path = start_path .. "/" .. plugin.name
	if vim.fn.isdirectory(plugin_path) == 0 then
		print("Installing " .. plugin.name .. "...")
		vim.fn.system({ "git", "clone", "--depth=1", plugin.url, plugin_path })
		if vim.v.shell_error == 0 then
			print("✓ " .. plugin.name .. " installed")

			-- Execute build command if specified
			if plugin.build then
				print("Building " .. plugin.name .. "...")
				local build_result = vim.fn.system("cd " .. vim.fn.shellescape(plugin_path) .. " && " .. plugin.build)
				if vim.v.shell_error == 0 then
					print("✓ " .. plugin.name .. " built successfully")
				else
					print("✗ Failed to build " .. plugin.name .. ": " .. build_result)
				end
			end
		else
			print("✗ Failed to install " .. plugin.name)
		end
	end
end

-- Load plugins
vim.cmd("packloadall!")
vim.cmd("silent! helptags ALL")

-- Add plugins to runtime path
local plugin_dirs = vim.fn.glob(start_path .. "/*", false, true)
for _, dir in ipairs(plugin_dirs) do
	if vim.fn.isdirectory(dir) == 1 then
		vim.opt.rtp:append(dir)
	end
end

-- Defer plugin configurations
vim.defer_fn(function()
	-- Load critical plugins that need immediate setup
	vim.cmd("packadd nvim-lspconfig")
	vim.cmd("packadd mason.nvim")
	vim.cmd("packadd mason-lspconfig.nvim")

	-- Defer other plugin configurations
	vim.defer_fn(function()
		-- Load plugin configurations
		local plugin_configs = {
			"plugins.blink-cmp",
			"plugins.nvim-treesitter",
			"plugins.telescope",
			"plugins.nvim-tree",
			"plugins.lualine-nvim",
			"plugins.bufferline-nvim",
			"plugins.gitsigns-nvim",
			"plugins.which-key-nvim",
			"plugins.toggleterm-nvim",
			"plugins.vimtex",
			"plugins.markdown-preview-nvim",
			"plugins.typst-preview-nvim",
			"plugins.obsidian-nvim",
			"plugins.autolist-nvim",
			"plugins.otter-nvim",
			"plugins.quarto-nvim",
			"plugins.trouble-nvim",
			"plugins.auto-dark-mode-nvim",
			"plugins.gruvbox-nvim",
			"plugins.github-nvim-theme",
			"plugins.nord-vim",
			"plugins.awesome-vim-colorschemes",
			"plugins.tokyonight-nvim",
			"plugins.onedark-nvim",
			"plugins.catppuccin",
			"plugins.julia-vim",
		}

		for _, config in ipairs(plugin_configs) do
			pcall(require, config)
		end
	end, 100)
end, 50)

-- Store plugins table globally for other modules to access
_G.neovim_plugins = essential_plugins

-- Return the plugins list to consumers that `require` or `dofile` this file
return essential_plugins
