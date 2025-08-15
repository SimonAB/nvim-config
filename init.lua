-- Modern Neovim Configuration with vim.pack (Performance Optimised)

-- Set leader keys early (must be before loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Cache frequently used paths
local config_path = vim.fn.stdpath("config")
local data_path = vim.fn.stdpath("data")
local cache_path = vim.fn.stdpath("cache")

-- Wrap vim.notify to always run outside fast event contexts to avoid E5560
do
	-- Preserve the original notify function
	local original_notify = vim.notify
	--- Safely schedule notifications outside of fast event contexts.
	--- This prevents errors such as E5560 (nvim_echo in fast event).
	--- Also suppresses known upstream deprecation warnings until plugins update
	--- to Neovim 0.12 API changes. Adjust patterns below to re-enable if needed.
	---@param msg any
	---@param level? integer
	---@param opts? table
	vim.notify = function(msg, level, opts)
		vim.schedule(function()
			local safe_msg = msg
			if type(msg) ~= "string" and type(msg) ~= "table" then
				safe_msg = vim.inspect(msg)
			end
			-- Suppress specific upstream deprecation notices (temporary)
			if type(safe_msg) == "string" then
				if safe_msg:match("client%.stop is deprecated") then
					return
				end
				if safe_msg:match("vim%.validate") and safe_msg:match("is deprecated") then
					return
				end
			end
			original_notify(safe_msg, level, opts)
		end)
	end
end

-- Load plugins first (install and add to runtime path)
local project_plugins = config_path .. "/lua/plugins.lua"
local ok, err = pcall(dofile, project_plugins)
if not ok then
	vim.notify("Failed to load project plugins.lua: " .. tostring(err), vim.log.levels.ERROR)
end

-- Use the require.lua from the project directory for plugin loading
local project_require = config_path .. "/lua/require.lua"
local ok, err = pcall(dofile, project_require)
if not ok then
	vim.notify("Failed to load project require.lua: " .. tostring(err), vim.log.levels.ERROR)
end

-- Load core configuration
require("config")
require("keymaps")

-- Consolidated autocmds for better performance
local function setup_optimized_autocmds()
	local augroup = vim.api.nvim_create_augroup("OptimizedConfig", { clear = true })

	-- Single autocmd for multiple filetypes
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = { "tex", "julia", "python", "r", "qmd" },
		callback = function(args)
			local ft = args.match
			if ft == "tex" then
				vim.g.vimtex_enabled = 1
			elseif ft == "julia" then
				-- Trigger manual LSP start if needed
				vim.defer_fn(function()
					vim.cmd("LspStart julials")
				end, 200)
			end
		end,
	})

	-- Early file type detection for faster LSP startup
	vim.api.nvim_create_autocmd("BufReadPre", {
		group = augroup,
		callback = function()
			local ft = vim.bo.filetype
			if ft == "julia" then
				-- Pre-load Julia LSP
				vim.defer_fn(function()
					local ok, lspconfig = pcall(require, "lspconfig")
					if ok then
						lspconfig.julials.setup()
					end
				end, 100)
			end
		end,
	})
end

setup_optimized_autocmds()

-- Optimised theme loading - load only active theme immediately
local function load_active_theme_only()
	local is_dark = false
	local ok_sys, out = pcall(vim.fn.systemlist, { "/usr/bin/defaults", "read", "-g", "AppleInterfaceStyle" })
	if ok_sys and type(out) == "table" and #out > 0 then
		-- Check if any line contains "Dark"
		for _, line in ipairs(out) do
			if type(line) == "string" and line:match("Dark") then
				is_dark = true
				break
			end
		end
	end

	local theme = is_dark and "onedark" or "catppuccin-latte"

	-- Load only the active theme immediately (bypass priority system for immediate theme)
	if is_dark then
		pcall(require, "plugins.onedark-nvim")
		pcall(vim.cmd.colorscheme, "onedark")
	else
		pcall(require, "plugins.catppuccin")
		pcall(vim.cmd.colorscheme, "catppuccin") -- Use base theme name, flavor is configured in setup
	end
end

-- Debounced which-key highlight updates
local highlight_update_timer
local function debounced_highlight_update()
	if highlight_update_timer then
		vim.loop.timer_stop(highlight_update_timer)
	end
	highlight_update_timer = vim.defer_fn(function()
		local colourscheme_name = vim.g.colors_name or "default"

		if colourscheme_name:match("catppuccin") then
			vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "String" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
		elseif colourscheme_name:match("onedark") then
			vim.api.nvim_set_hl(0, "WhichKey", { fg = "#61AFEF" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#C678DD" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#5C6370" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#98C379" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#282C34" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#3E4451" })
		elseif colourscheme_name:match("tokyonight") then
			vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "String" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
		else
			vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "Delimiter" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
		end
	end, 100)
end

-- Configure colourschemes and auto-dark-mode after plugins are loaded
vim.defer_fn(function()
	-- Load active theme first
	load_active_theme_only()

	-- Apply which-key highlights with debouncing
	debounced_highlight_update()

	-- Auto-update which-key highlights when colourscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = debounced_highlight_update,
	})

	-- Configuration complete
end, 300)
