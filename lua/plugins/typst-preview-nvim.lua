-- Configuration for typst-preview-nvim
-- Low latency Typst preview for Neovim

local ok, typst_preview = pcall(require, "typst-preview")
if ok then
	typst_preview.setup({
		debug = false,
		port = 0, -- Use random port
		invert_colors = 'never',
		follow_cursor = true,
		extra_args = nil,
		-- Get root directory for Typst project
		get_root = function(path_of_main_file)
			local root = os.getenv('TYPST_ROOT')
			if root then
				return root
			end
			return vim.fn.fnamemodify(path_of_main_file, ':p:h')
		end,
		-- Get main Typst file
		get_main_file = function(path)
			return path
		end,
	})
end
