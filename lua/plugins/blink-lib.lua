-- Configuration for blink.lib
-- Shared library dependency for blink.cmp v2.

local ok, _ = pcall(require, "blink.lib")
if not ok then
	vim.notify("blink.lib not found", vim.log.levels.WARN)
end

