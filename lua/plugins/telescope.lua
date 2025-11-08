-- Configuration for telescope.nvim
-- Fuzzy finder with enhanced features

local ok, telescope = pcall(require, "telescope")
if ok then
	-- Safely get sorters
	local sorters_ok, sorters = pcall(require, "telescope.sorters")
	local file_sorter = sorters_ok and sorters.fuzzy_with_index_bias or nil

	telescope.setup({
		defaults = {
			debounce = 50,
			path_display = { "truncate" },
			file_sorter = file_sorter,
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "bottom",
					preview_width = 0.55,
					results_width = 0.8,
				},
			},
			preview = {
				treesitter = false,
			},
		},
		pickers = {
			find_files = {
				hidden = false,
				file_ignore_patterns = {
					"%.git/",
					"node_modules/",
					"%.DS_Store",
					"%.cache/",
					"%.local/",
					"%.pdf$",
					"%.jpg$", "%.jpeg$", "%.png$", "%.gif$", "%.bmp$", "%.tiff$", "%.svg$", "%.ico$", "%.webp$",
					"%.mp3$", "%.mp4$", "%.avi$", "%.mov$", "%.wmv$", "%.flv$", "%.mkv$", "%.webm$",
					"%.zip$", "%.tar$", "%.gz$", "%.rar$", "%.7z$", "%.bz2$",
					"%.exe$", "%.dmg$", "%.pkg$", "%.deb$", "%.rpm$",
					"%.doc$", "%.docx$", "%.xls$", "%.xlsx$", "%.ppt$", "%.pptx$",
					"%.odt$", "%.ods$", "%.odp$",
					"%.class$", "%.o$", "%.so$", "%.dll$", "%.dylib$",
					"%.pyc$", "%.pyo$", "%.pyd$",
					"%.log$", "%.tmp$", "%.temp$",
				},
			},
			live_grep = {
				additional_args = function()
					return { "--hidden" }
				end,
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
			frecency = {
				show_scores = false,
				show_unindexed = true,
				ignore_patterns = {"*.git/*", "*/tmp/*"},
			},
		},
	})

	-- Load telescope extensions
	pcall(telescope.load_extension, "fzf")
	pcall(telescope.load_extension, "frecency")
end
