-- Inline Lua function for restarting LSP with feedback
local function restart_lsp()
  local clients = vim.lsp.get_active_clients({bufnr = 0})
  if #clients == 0 then
    print("No active LSP clients to restart")
  else
    print("Restarting LSP...")
    vim.cmd('LspRestart')
  end
end

-- Call the function
restart_lsp()
