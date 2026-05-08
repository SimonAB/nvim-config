---Flexoki theme configuration.
---
---This module is loaded by the phased plugin loader (`core/plugin-loader.lua`).
---It configures Flexoki to keep backgrounds transparent so the UI inherits the
---terminal backdrop (Ghostty is transparent in this setup).
---
---The active colourscheme names are `flexoki-dark` and `flexoki-light`.
---
---@return nil
local function setup()
	local ok, flexoki = pcall(require, "flexoki")
	if not ok then
		return
	end

	flexoki.setup({
		-- Use the same background for code + floats, then we force bg=none below.
		float_window_style = "solid",
		highlight_groups = {
			Normal = { bg = "none" },
			NormalNC = { bg = "none" },
			SignColumn = { bg = "none" },
			EndOfBuffer = { bg = "none" },

			NormalFloat = { bg = "none" },
			FloatBorder = { bg = "none" },
			FloatTitle = { bg = "none" },
		},
	})
end

setup()

