-- Keymaps entrypoint (compatibility wrapper)
--
-- Most of the configuration now loads keymaps via `init.lua`:
-- - `require("keymaps-core")` immediately
-- - `require("keymaps-plugins")` deferred
--
-- This wrapper remains so any existing `require("keymaps")` calls (plugins, tests, old docs)
-- continue to work. It loads both modules unconditionally.
require("keymaps-core")
require("keymaps-plugins")
