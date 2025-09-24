-- LSP Configuration with Mason Integration
-- This file sets up language server protocol (LSP) support for multiple languages in Neovim using nvim-lspconfig.
-- Mason handles server installation and management automatically.
-- Keymaps for LSP actions are set per buffer on attach. Completion is enhanced if blink.cmp is available.

-- Use the new vim.lsp.config API (Neovim 0.11+)
-- No need to require lspconfig anymore

-- Set up LSP client capabilities with performance optimisations
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Minimal capabilities by default for better performance
capabilities.textDocument.completion.completionItem.snippetSupport = false
capabilities.textDocument.completion.completionItem.resolveSupport = nil

-- Enhance capabilities only for specific servers that need them
local blink_ok, blink_lsp = pcall(require, "blink.cmp.lsp")
if blink_ok then
	-- Create enhanced capabilities for servers that need full features
	local enhanced_capabilities = blink_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
	enhanced_capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = { "documentation", "detail", "additionalTextEdits" },
	}
	-- Store enhanced capabilities for use with specific servers
	_G.enhanced_lsp_capabilities = enhanced_capabilities
end

-- Common on_attach function for all LSP servers
local function on_attach(client, bufnr)
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc" -- Enable omnifunc for completion
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- LSP keymaps for navigation and actions
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<localleader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<localleader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("i", "<C-Space>", function()
		require("blink.cmp").show() -- Manual completion trigger
	end, { buffer = bufnr })
end

-- Note: Most LSP server configurations are now handled by mason-lspconfig
-- This file contains only custom configurations that extend the default Mason setup

-- Additional LSP servers not covered by Mason's ensure_installed
-- or servers that need custom configuration beyond the defaults

-- Julia LSP setup (bypass Mason due to current instability)
pcall(function()
  vim.lsp.config('julials', {
    cmd = {
      "julia",
      "--project=@nvim-lspconfig",
      "--startup-file=no",
      "--history-file=no",
      "-e",
      [[
        try
          using LanguageServer, Pkg
          project_path = try
            Base.current_project() |> dirname
          catch
            dirname(Pkg.Types.Context().env.project_file)
          end
          server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, "")
          run(server)
        catch err
          Base.println(stderr, err)
          Base.println(stderr, sprint(showerror, err, catch_backtrace()))
          flush(stderr)
          exit(1)
        end
      ]],
    },
    on_attach = on_attach,
    capabilities = _G.enhanced_lsp_capabilities or capabilities,
  })
  vim.lsp.enable('julials')
end)

-- Lua LSP setup (if not handled by Mason)
vim.lsp.config('lua_ls', {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
		},
	},
})
vim.lsp.enable('lua_ls')

-- Additional language servers can be added here as needed
-- Mason will handle the installation, and this file can provide custom configuration

-- Example: Custom configuration for a specific server
-- vim.lsp.config('some_server', {
--     capabilities = capabilities,
--     on_attach = on_attach,
--     settings = {
--         -- Custom settings here
--     },
-- })
-- vim.lsp.enable('some_server')
