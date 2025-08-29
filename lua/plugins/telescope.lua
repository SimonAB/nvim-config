-- Configuration for telescope.nvim
-- Fuzzy finder with enhanced features

local ok, telescope = pcall(require, "telescope")
if ok then
	-- Load telescope extensions
	pcall(telescope.load_extension, "fzf")
	pcall(telescope.load_extension, "frecency")

	-- Safely get sorters
	local sorters_ok, sorters = pcall(require, "telescope.sorters")
	local file_sorter = sorters_ok and sorters.fuzzy_with_index_bias or nil

	telescope.setup({
		defaults = {
			-- Performance optimisations
			debounce = 50, -- Reduce debounce for faster response
			-- Show only filename, not full path
			path_display = { "truncate" },
			-- Use built-in sorter that considers when items were added
			file_sorter = file_sorter,
			-- Better layout for performance
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "bottom",
					preview_width = 0.55,
					results_width = 0.8,
				},
			},
			-- Faster preview
			preview = {
				treesitter = false, -- Disable treesitter for faster preview
			},
		},
		-- Configuration for specific pickers
		pickers = {
			find_files = {
				hidden = false, -- Hide hidden files
				file_ignore_patterns = {
					"%.git/",
					"node_modules/",
					"%.DS_Store",
					"%.cache/",
					"%.local/",
					-- Non-editable files
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
					return { "--hidden" } -- Include hidden files in grep
				end,
			},
		},
		-- FZF extension configuration
		extensions = {
			fzf = {
				fuzzy = true,                    -- false will only do exact matching
				override_generic_sorter = true,  -- override the generic sorter
				override_file_sorter = true,     -- override the file sorter
				case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
			},
			frecency = {
				-- Show files you access most frequently and recently
				show_scores = false, -- Enable to see frecency scores
				show_unindexed = true,
				ignore_patterns = {"*.git/*", "*/tmp/*"},
			},
		},
	})
end
