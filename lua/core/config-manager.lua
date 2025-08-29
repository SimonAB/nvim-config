-- =============================================================================
-- CENTRALIZED CONFIGURATION MANAGER
-- PURPOSE: Unified configuration system for all plugins and settings
-- =============================================================================

local ConfigManager = {
	themes = {},
	plugins = {},
	lsp = {},
	ui = {},
	performance = {}
}

-- =============================================================================
-- THEME CONFIGURATIONS
-- =============================================================================

ConfigManager.themes.catppuccin = {
	flavour = "mocha",
	background = {
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
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
	},
	integrations = {
		cmp = true,
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
}

ConfigManager.themes.onedark = {
	style = "dark",
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
	diagnostics = {
		darker = true,
		undercurl = true,
		background = true,
	},
}

ConfigManager.themes.tokyonight = {
	style = "night",
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
	day_brightness = 0.3,
	hide_inactive_statusline = false,
	dim_inactive = false,
	lualine_bold = false,
}

-- =============================================================================
-- PLUGIN CONFIGURATIONS
-- =============================================================================

ConfigManager.plugins.telescope = {
	defaults = {
		debounce = 50,
		path_display = { "truncate" },
		file_sorter = require("telescope.sorters").fuzzy_with_index_bias,
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
}

ConfigManager.plugins.treesitter = {
	ensure_installed = {
		"lua", "vim", "vimdoc", "javascript", "typescript",
		"python", "julia", "r", "bash", "json", "yaml",
		"markdown", "html", "css", "scss", "latex", "bibtex",
		"toml", "dockerfile", "gitignore", "comment", "regex"
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<CR>",
			node_decremental = "<BS>",
			scope_incremental = "<TAB>",
		},
	},
	textobjects = {
		enable = true,
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
	},
}

ConfigManager.plugins.bufferline = {
	options = {
		diagnostics = "nvim_lsp",
		separator_style = "slant",
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_close_icon = true,
		show_tab_indicators = true,
	},
}

ConfigManager.plugins.lualine = {
	options = {
		theme = "auto",
		component_separators = "|",
		section_separators = "",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
}

ConfigManager.plugins.gitsigns = {
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true,
	numhl = false,
	linehl = false,
	word_diff = false,
	watch_gitdir = { interval = 1000, follow_files = true },
	attach_to_untracked = true,
	current_line_blame = false,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol",
		delay = 1000,
		ignore_whitespace = false,
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil,
	max_file_length = 40000,
	preview_config = {
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
}

ConfigManager.plugins.trouble = {
	-- Default configuration with enhanced diagnostics
}

-- =============================================================================
-- LSP CONFIGURATIONS
-- =============================================================================

ConfigManager.lsp.servers = {
	-- Core academic servers
	pyright = {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	},
	texlab = {
		settings = {
			texlab = {
				auxDirectory = ".",
				bibtexFormatter = "texlab",
				build = {
					executable = "latexmk",
					args = {
						"-pdf", "-pdflatex=lualatex", "-interaction=nonstopmode",
						"-synctex=1", "-file-line-error", "%f"
					},
					onSave = false,
					forwardSearchAfter = false,
				},
				chktex = { onOpenAndSave = false, onEdit = false },
				diagnosticsDelay = 300,
				formatterLineLength = 80,
				latexFormatter = "latexindent",
				latexindent = { ["local"] = nil, modifyLineBreaks = false },
			},
		},
	},
	tinymist = {}, -- Typst LSP
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
				diagnostics = { globals = { "vim" } },
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
					},
				},
			},
		},
	},
	r_language_server = {
		settings = {
			r = { lsp = { rich_documentation = false } },
		},
	},
}

-- =============================================================================
-- UI CONFIGURATIONS
-- =============================================================================

ConfigManager.ui.which_key = {
	preset = "classic",
	delay = 500,
	plugins = {
		marks = true,
		registers = true,
		spelling = { enabled = true, suggestions = 20 },
		presets = {
			operators = true, motions = true, text_objects = true,
			windows = true, nav = true, z = true, g = true
		},
	},
	win = {
		border = "rounded",
		padding = { 1, 2 },
		wo = { winblend = 0 },
	},
	layout = {
		height = { min = 4, max = 25 },
		width = { min = 20, max = 50 },
		spacing = 3,
		align = "center",
	},
	icons = {
		breadcrumb = "»",
		separator = "→",
		group = "+",
		ellipsis = "...",
		mappings = false,
		colors = false,
		keys = {
			Up = " ", Down = " ", Left = " ", Right = " ",
			C = "󰘴 ", M = "󰘵 ", D = "󰘳 ", S = "󰘶 ",
			CR = "󰌑 ", Esc = "󱊷 ", ScrollWheelDown = "󱕐 ", ScrollWheelUp = "󱕑 ",
			NL = "󰌑 ", BS = "󰁮", Space = "󱁐 ", Tab = "󰌒 ",
		},
	},
}

-- =============================================================================
-- PERFORMANCE SETTINGS
-- =============================================================================

ConfigManager.performance = {
	-- Plugin loading phases (in milliseconds)
	loading_phases = {
		immediate = 0,
		deferred = 100,
		lazy = 500,
	},
	-- Update intervals
	update_debounce = {
		which_key = 100,
		lsp = 250,
		git = 1000,
	},
	-- Cache settings
	cache = {
		theme_highlights = true,
		file_icons = true,
		lsp_capabilities = true,
	},
}

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

function ConfigManager.load_theme_config(theme_name)
	return ConfigManager.themes[theme_name] or {}
end

function ConfigManager.load_plugin_config(plugin_name)
	return ConfigManager.plugins[plugin_name] or {}
end

function ConfigManager.load_lsp_config(server_name)
	return ConfigManager.lsp.servers[server_name] or {}
end

function ConfigManager.get_performance_setting(key)
	local keys = vim.split(key, ".", { plain = true })
	local value = ConfigManager.performance
	for _, k in ipairs(keys) do
		value = value[k]
		if not value then return nil end
	end
	return value
end

function ConfigManager.validate_config()
	-- Basic validation to ensure configurations are well-formed
	local function validate_section(section_name, section)
		if type(section) ~= "table" then
			vim.notify("Config validation failed: " .. section_name .. " must be a table", vim.log.levels.ERROR)
			return false
		end
		return true
	end

	local valid = true
	valid = valid and validate_section("themes", ConfigManager.themes)
	valid = valid and validate_section("plugins", ConfigManager.plugins)
	valid = valid and validate_section("lsp", ConfigManager.lsp)
	valid = valid and validate_section("ui", ConfigManager.ui)
	valid = valid and validate_section("performance", ConfigManager.performance)

	if valid then
		vim.notify("Configuration validation passed", vim.log.levels.INFO)
	else
		vim.notify("Configuration validation failed", vim.log.levels.ERROR)
	end

	return valid
end

-- Initialize configuration validation
vim.defer_fn(function()
	ConfigManager.validate_config()
end, 100)

return ConfigManager
