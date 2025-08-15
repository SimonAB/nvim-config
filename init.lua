-- Modern Neovim Configuration with vim.pack

-- Set leader keys early (must be before loading plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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
local project_plugins = vim.fn.stdpath("config") .. "/lua/plugins.lua"
local ok, err = pcall(dofile, project_plugins)
if not ok then
	vim.notify("Failed to load project plugins.lua: " .. tostring(err), vim.log.levels.ERROR)
end

-- Use the require.lua from the project directory for plugin loading
local project_require = vim.fn.stdpath("config") .. "/lua/require.lua"
local ok, err = pcall(dofile, project_require)
if not ok then
	vim.notify("Failed to load project require.lua: " .. tostring(err), vim.log.levels.ERROR)
end

-- Load core configuration
require("config")
require("keymaps")

-- Ensure VimTeX is loaded for TeX files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "tex",
	callback = function()
		vim.g.vimtex_enabled = 1
	end,
})

-- Julia LSP auto-start (simplified)
vim.api.nvim_create_augroup("JuliaLSPAutoStart", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "JuliaLSPAutoStart",
	pattern = "julia",
	callback = function()
		-- Trigger manual LSP start if needed
		vim.defer_fn(function()
			vim.cmd("LspStart julials")
		end, 200)
	end,
})

-- Configure colourschemes and auto-dark-mode after plugins are loaded
vim.defer_fn(function()
	-- Configure catppuccin theme
	local ok, catppuccin = pcall(require, "catppuccin")
	if ok then
		catppuccin.setup({
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "mocha",
			},
			transparent_background = false,
			show_end_of_buffer = false,
			term_colors = false,
			dim_inactive = {
				enabled = false,
				shade = "dark",
				percentage = 0.15,
			},
			integrations = {
				gitsigns = true,
				nvimtree = true,
				telescope = true,
				treesitter = true,
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
			},
		})
	end

	-- Configure onedark theme
	local ok_onedark, onedark = pcall(require, "onedark")
	if ok_onedark then
		onedark.setup({
			style = "dark", -- dark, darker, cool, deep, warm, warmer, light
			transparent = false,
			term_colors = true,
			ending_tildes = false,
			cmp_itemkind_reverse = false,
			code_style = {
				comments = "italic",
				keywords = "none",
				functions = "none",
				strings = "none",
				variables = "none",
			},
		})
	end

	-- Configure tokyonight theme
	local ok_tokyo, tokyonight = pcall(require, "tokyonight")
	if ok_tokyo then
		tokyonight.setup({
			style = "night", -- night, storm, day, moon
			light_style = "day",
			transparent = false,
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "dark",
				floats = "dark",
			},
		})
	end

	-- Apply system theme once (macOS) to avoid polling timers that can leak FDs
	local function apply_system_theme_once()
		local is_dark = false
		local ok_sys, out = pcall(vim.fn.systemlist, { "/usr/bin/defaults", "read", "-g", "AppleInterfaceStyle" })
		if ok_sys and type(out) == "table" then
			for _, line in ipairs(out) do
				if type(line) == "string" and line:match("Dark") then
					is_dark = true
					break
				end
			end
		end
		if is_dark then
			pcall(vim.cmd.colorscheme, "onedark")
		else
			local light_ok = pcall(vim.cmd.colorscheme, "onehalflight")
			if not light_ok then
				pcall(vim.cmd.colorscheme, "catppuccin-latte")
			end
		end
	end
	apply_system_theme_once()

	-- Customise which-key highlights to match colourschemes
	vim.defer_fn(function()
		-- Get current colourscheme colours if available
		local colourscheme_name = vim.g.colors_name or "default"

		-- Set which-key highlights based on colourscheme
		if colourscheme_name:match("catppuccin") then
			-- Catppuccin theme integration
			vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "String" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
		elseif colourscheme_name:match("onedark") then
			-- OneDark theme integration
			vim.api.nvim_set_hl(0, "WhichKey", { fg = "#61AFEF" }) -- Blue
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#C678DD" }) -- Purple
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#5C6370" }) -- Comment grey
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#98C379" }) -- Green
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#282C34" }) -- Dark background
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#3E4451" }) -- Border grey
		elseif colourscheme_name:match("tokyonight") then
			-- TokyoNight theme integration
			vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "String" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
		else
			-- Default theme integration
			vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "Delimiter" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
		end
	end, 500)

	-- Auto-update which-key highlights when colourscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			vim.defer_fn(function()
				local colorscheme_name = vim.g.colors_name or "default"

				if colorscheme_name:match("catppuccin") then
					vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" })
					vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" })
					vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "Comment" })
					vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "String" })
					vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
					vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
				elseif colorscheme_name:match("onedark") then
					vim.api.nvim_set_hl(0, "WhichKey", { fg = "#61AFEF" })
					vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#C678DD" })
					vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#5C6370" })
					vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#98C379" })
					vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#3E4451" })
				elseif colorscheme_name:match("tokyonight") then
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
			end, 50) -- Small delay to ensure colorscheme is fully loaded
		end,
	})

	-- Configuration complete
end, 300)
