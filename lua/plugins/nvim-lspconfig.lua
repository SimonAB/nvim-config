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
-- Uses @nvim-lspconfig environment which needs LanguageServer.jl installed
local function build_julia_lsp_cmd(project_env)
  return {
    "julia",
    "--project=" .. project_env,
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
  }
end

-- Load immediately since Mason's handler is disabled
local julia_ok, julia_err = pcall(function()
  local project_env = "@nvim-lspconfig"
  
  vim.lsp.config('julials', {
    cmd = build_julia_lsp_cmd(project_env),
    filetypes = { 'julia' },
    root_dir = function(fname)
      -- Try to find project root, otherwise use file's directory
      local util = require('lspconfig.util')
      local found_root = util.root_pattern('Project.toml', 'JuliaProject.toml', '.git')(fname)
      if found_root then
        return found_root
      end
      -- Fallback to file's directory for standalone files
      return vim.fn.fnamemodify(fname, ':p:h')
    end,
    on_attach = on_attach,
    capabilities = _G.enhanced_lsp_capabilities or capabilities,
  })
  vim.lsp.enable('julials')
end)

if not julia_ok then
  vim.notify("Julia LSP config failed: " .. tostring(julia_err), vim.log.levels.ERROR)
end

-- Create user command to install LanguageServer.jl in the @nvim-lspconfig environment
vim.api.nvim_create_user_command('JuliaLspInstall', function()
  vim.notify("Installing LanguageServer.jl in @nvim-lspconfig environment...", vim.log.levels.INFO)
  local project_env = "@nvim-lspconfig"
  vim.fn.jobstart({
    'julia',
    '--project=' .. project_env,
    '-e',
    'using Pkg; Pkg.add("LanguageServer")'
  }, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("LanguageServer.jl installed successfully! Restart Neovim or reopen Julia files to use it.", vim.log.levels.INFO)
      else
        vim.notify("Failed to install LanguageServer.jl. You may need to run manually: julia --project=@nvim-lspconfig -e 'using Pkg; Pkg.add(\"LanguageServer\")'", vim.log.levels.ERROR)
      end
    end,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print(line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            print(line)
          end
        end
      end
    end,
  })
end, { desc = "Install Julia LanguageServer.jl in @nvim-lspconfig environment" })

-- Create autocommand to manually start julials for Julia files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "julia",
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    local util = require('lspconfig.util')
    local found_root = util.root_pattern('Project.toml', 'JuliaProject.toml', '.git')(bufname)
    local root_dir = found_root or vim.fn.fnamemodify(bufname, ':p:h')
    local project_env = "@nvim-lspconfig"
    
    vim.lsp.start({
      name = 'julials',
      cmd = build_julia_lsp_cmd(project_env),
      root_dir = root_dir,
      on_attach = on_attach,
      capabilities = _G.enhanced_lsp_capabilities or capabilities,
    })
  end,
})

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
