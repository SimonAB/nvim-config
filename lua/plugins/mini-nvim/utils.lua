-- =============================================================================
-- MINI.NVIM UTILITIES
-- PURPOSE: Common utility functions for mini.nvim setup
-- =============================================================================

local M = {}

-- Safely require a module with error handling
function M.safe_require(module_name)
	return pcall(require, module_name)
end

-- Get the plugin directory path
function M.get_plugin_directory()
	return vim.fn.stdpath("data") .. "/pack/plugins/start"
end

-- Get the configuration directory path
function M.get_config_directory()
	return vim.fn.stdpath("config")
end

-- Check if a directory exists and is accessible
function M.is_directory_accessible(path)
	return vim.fn.isdirectory(path) == 1
end

-- Check if a file exists and is accessible
function M.is_file_accessible(path)
	return vim.loop.fs_stat(path) ~= nil
end

-- Get the base name of a path
function M.get_basename(path)
	return vim.fn.fnamemodify(path, ":t")
end

-- Get the directory name of a path
function M.get_dirname(path)
	return vim.fn.fnamemodify(path, ":h")
end

-- Get the absolute path of a file
function M.get_absolute_path(path)
	return vim.fn.fnamemodify(path, ":p")
end

-- Escape a filename for use in Vim commands
function M.escape_filename(filename)
	return vim.fn.fnameescape(filename)
end

-- Execute a system command and return result with error status
function M.execute_system_command(command)
	local result = vim.fn.system(command)
	return result, vim.v.shell_error
end

-- Show a message to the user
function M.show_message(message)
	vim.cmd("echo '" .. message .. "'")
end

-- Show a progress message
function M.show_progress(message)
	vim.cmd("echo '🔄 " .. message .. "'")
end

-- Show a success message
function M.show_success(message)
	vim.cmd("echo '✅ " .. message .. "'")
end

-- Show an error message
function M.show_error(message)
	vim.cmd("echo '❌ " .. message .. "'")
end

-- Show a warning message
function M.show_warning(message)
	vim.cmd("echo '⚠ " .. message .. "'")
end

return M
