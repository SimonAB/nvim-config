-- =============================================================================
-- OPTIMIZED PLUGIN LOADING ORCHESTRATION
-- Consolidated from 8 phases to 3 optimized phases for better performance
-- =============================================================================

local PluginLoader = require("core.plugin-loader")

-- Initialize optimized plugin loading
PluginLoader.load_all()

-- Print loading statistics
local stats = PluginLoader.get_stats()
vim.notify(string.format("Plugin loading: %d immediate, %d deferred, %d lazy (total: %d)",
	stats.immediate, stats.deferred, stats.lazy, stats.total), vim.log.levels.INFO)

-- Legacy compatibility: expose a function to manually trigger plugin loading
_G.load_plugin_with_priority = function(plugin_name, priority)
	vim.notify("Using legacy loading for: " .. plugin_name, vim.log.levels.WARN)
	local ok, err = pcall(require, "plugins." .. plugin_name)
	if not ok then
		vim.notify("Failed to load plugin: " .. plugin_name .. " - " .. tostring(err), vim.log.levels.WARN)
	end
end


