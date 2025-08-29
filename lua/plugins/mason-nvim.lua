-- Configuration for mason.nvim
-- Portable package manager for Neovim that runs everywhere Neovim runs
-- Easily install and manage LSP servers, DAP servers, linters, and formatters

local ok, mason = pcall(require, "mason")
if ok then
	mason.setup({
		-- The directory in which to install packages
		install_root_dir = vim.fn.stdpath("data") .. "/mason",

		-- Where Mason should put its bin location in your PATH
		-- Can be "prepend" (default), "append", or "skip"
		PATH = "prepend",

		-- Controls to which degree logs are written to the log file
		log_level = vim.log.levels.INFO,

		-- Limit for the maximum amount of packages to be installed at the same time
		max_concurrent_installers = 4,

		-- The registries to source packages from
		registries = {
			"github:mason-org/mason-registry",
		},

		-- The provider implementations to use for resolving supplementary package metadata
		providers = {
			"mason.providers.registry-api",
			"mason.providers.client",
		},

		-- GitHub configuration for downloading assets
		github = {
			download_url_template = "https://github.com/%s/releases/download/%s/%s",
		},

		-- pip configuration
		pip = {
			upgrade_pip = false,
			install_args = {},
		},

		-- UI configuration
		ui = {
			-- Whether to automatically check for new versions when opening the :Mason window
			check_outdated_packages_on_open = true,

			-- The border to use for the UI window
			border = "rounded",

			-- The backdrop opacity. 0 is fully opaque, 100 is fully transparent
			backdrop = 60,

			-- Width of the window (0.8 = 80% of screen width)
			width = 0.8,

			-- Height of the window (0.9 = 90% of screen height)
			height = 0.9,

			-- Icons for different package states
			icons = {
				package_installed = "✓",
				package_pending = "⟳",
				package_uninstalled = "✗",
			},

			-- Keymaps for the Mason UI
			keymaps = {
				toggle_package_expand = "<CR>",
				install_package = "i",
				update_package = "u",
				check_package_version = "c",
				update_all_packages = "U",
				check_outdated_packages = "C",
				uninstall_package = "X",
				cancel_installation = "<C-c>",
				apply_language_filter = "<C-f>",
				toggle_package_install_log = "<CR>",
				toggle_help = "g?",
			},
		},
	})
else
	vim.notify("❌ Mason not available - LSP server management will be limited", vim.log.levels.WARN)
end

-- Mason LSP Config integration (deferred for performance)
vim.defer_fn(function()
	local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
	if ok_mason_lspconfig then
		mason_lspconfig.setup({
			-- Automatically install configured servers (with lspconfig)
			automatic_installation = true, -- Enable auto-install for LSP servers

		-- Ensure these servers are installed (minimal set for startup)
		ensure_installed = {
			-- Core language servers for your academic workflow
			-- "julials",           -- Julia language server (temporarily disabled due to Julia 1.11.6 bug)
			"pyright",           -- Python language server (preferred)
			"texlab",            -- LaTeX language server
            "tinymist",          -- Typst language server
			"lua_ls",            -- Lua language server
			"bashls",            -- Bash language server
			"jsonls",            -- JSON language server
			"yamlls",            -- YAML language server
			"marksman",          -- Markdown language server
			"html",              -- HTML language server
			"cssls",             -- CSS language server
			"ts_ls", -- TypeScript/JavaScript language server
		},

		-- Optional: Configure specific servers
		handlers = {
			-- Default handler for installing servers
			function(server_name)
				require("lspconfig")[server_name].setup({})
			end,

			-- Custom handler for Julia LSP (temporarily disabled due to Julia 1.11.6 bug)
			-- ["julials"] = function()
			-- 	require("lspconfig").julials.setup({
			-- 		-- Ensure Julia is in PATH for the LSP server
			-- 		cmd = { vim.fn.stdpath("data") .. "/mason/bin/julia-lsp" },
			-- 		-- Set environment variables to ensure Julia is available
			-- 		env = {
			-- 			PATH = vim.fn.expand("$HOME/.juliaup/bin") .. ":" .. vim.fn.getenv("PATH"),
			-- 		},
			-- 		-- Your existing Julia LSP configuration
			-- 		settings = {
			-- 			julia = {
			-- 				symbolCacheDownload = false,
			-- 				lint = {
			-- 					run = true,
			-- 					missingrefs = "all",
			-- 					call = true,
			-- 					iter = true,
			-- 					nothingcomp = true,
			-- 					constif = true,
			-- 					lazy = true,
			-- 					datadecl = true,
			-- 					typeparam = true,
			-- 					modname = true,
			-- 				},
			-- 				completionmode = "qualify",
			-- 				useRevise = true,
			-- 				execution = {
			-- 					resultDisplay = "both",
			-- 					errorDisplay = "both",
			-- 					},
			-- 				},
			-- 			},
			-- 			init_options = {
			-- 				storagePath = vim.fn.stdpath("cache") .. "/julia_ls",
			-- 				experimentalFeatures = {
			-- 					lspMacroExpansion = true,
			-- 					inlayHints = true,
			-- 				},
			-- 			},
			-- 		})
			-- 	end,

			-- Custom handler for Python LSP
			["pyright"] = function()
				require("lspconfig").pyright.setup({
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
				})
			end,

			-- Custom handler for R LSP
			["r-languageserver"] = function()
				require("lspconfig").r_language_server.setup({
					settings = {
						r = {
							lsp = {
								rich_documentation = false,
							},
						},
					},
				})
			end,

			-- Custom handler for LaTeX LSP
			["texlab"] = function()
				require("lspconfig").texlab.setup({
					settings = {
						texlab = {
							auxDirectory = ".",
							bibtexFormatter = "texlab",
							build = {
								executable = "latexmk",
								args = {
									"-pdf",
									"-pdflatex=lualatex",
									"-interaction=nonstopmode",
									"-synctex=1",
									"-file-line-error",
									"%f",
								},
								onSave = false,
								forwardSearchAfter = false,
							},
							chktex = {
								onOpenAndSave = false,
								onEdit = false,
							},
							diagnosticsDelay = 300,
							formatterLineLength = 80,
							forwardSearch = {
								executable = nil,
								args = {},
							},
							latexFormatter = "latexindent",
							latexindent = {
								["local"] = nil,
								modifyLineBreaks = false,
							},
						},
					},
				})
			end,
		},
	})
	else
		vim.notify("❌ Mason LSP Config not available - LSP server installation will be manual", vim.log.levels.WARN)
	end
end, 500) -- Defer LSP setup for better startup performance
