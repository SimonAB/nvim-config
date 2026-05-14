-- Configuration for auto-dark-mode.nvim
-- Automatic theme switching based on system appearance

local ok, auto_dark_mode = pcall(require, "auto-dark-mode")
if ok then
	auto_dark_mode.setup({
		update_interval = 1000,
		set_dark_mode = function()
			vim.env.JULIA_REPL_THEME = "dark"
			vim.o.background = "dark"

			local ok_theme, ThemeManager = pcall(require, "core.theme-manager")
			if ok_theme and ThemeManager and ThemeManager.load_immediate then
				-- Pass appearance so we do not rely on `defaults read` racing the OS toggle.
				ThemeManager.load_immediate({ appearance = "dark" })
			end
		end,
		set_light_mode = function()
			vim.env.JULIA_REPL_THEME = "light"
			vim.o.background = "light"

			local ok_theme, ThemeManager = pcall(require, "core.theme-manager")
			if ok_theme and ThemeManager and ThemeManager.load_immediate then
				ThemeManager.load_immediate({ appearance = "light" })
			end
		end,
	})
end

