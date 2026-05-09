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
		light_variant = "light_high_contrast",
		transparent = {
			editor = true,
			floats = true,
			float_border = true,
			ui = true,
			menus = true,
		},
	})
end

setup()

