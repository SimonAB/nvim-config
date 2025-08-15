-- Configuration for nvim-web-devicons
-- File type icons with custom overrides

local ok, devicons = pcall(require, "nvim-web-devicons")
if ok then
	devicons.setup({
		color_icons = true, -- Enable colored icons
		default = true, -- Enable default icons for unknown filetypes
		strict = true, -- Strict icon matching
		override_by_filename = {
			[".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" },
			["yarn.lock"] = { icon = "", color = "#2C8EBB", name = "YarnLock" },
			["requirements.txt"] = { icon = "", color = "#3776ab", name = "Requirements" },
			["docker-compose.yml"] = { icon = "", color = "#2496ED", name = "DockerCompose" },
		},
		override_by_extension = {
			["jl"] = { icon = "", color = "#9558B2", name = "Julia" },
			["qmd"] = { icon = "", color = "#75AADB", name = "Quarto" },
			["ipynb"] = { icon = "", color = "#F37626", name = "Jupyter" },
		},
		-- You can add more config here (e.g., custom icons, more overrides, etc.)
	})
end
