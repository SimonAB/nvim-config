-- LSP Configuration with Mason Integration
-- This file sets up language server protocol (LSP) support for multiple languages in Neovim using nvim-lspconfig.
-- Mason handles server installation and management automatically.
-- Keymaps for LSP actions are set per buffer on attach. Completion is enhanced if blink.cmp is available.

local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
	vim.notify("❌ lspconfig not available - LSP functionality will be limited", vim.log.levels.WARN)
	return
end

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

-- Lua LSP setup (if not handled by Mason)
lspconfig.lua_ls.setup({
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

-- Additional language servers can be added here as needed
-- Mason will handle the installation, and this file can provide custom configuration

-- Example: Custom configuration for a specific server
-- lspconfig.some_server.setup({
--     capabilities = capabilities,
--     on_attach = on_attach,
--     settings = {
--         -- Custom settings here
--     },
-- })
