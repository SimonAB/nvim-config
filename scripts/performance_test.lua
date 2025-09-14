-- =============================================================================
-- PERFORMANCE TEST SCRIPT
-- PURPOSE: Measure and analyse Neovim startup performance
-- =============================================================================

local M = {}

-- Performance measurement utilities
local function measure_startup_time()
    local start_time = vim.loop.hrtime()

    -- Simulate startup by loading core modules
    local modules_to_test = {
        "config",
        "keymaps",
        "plugins",
        "core.theme-manager",
        "core.plugin-manager",
        "plugins.mini-nvim.dashboard",
        "plugins.mini-nvim.dashboard-content"
    }

    local results = {}
    for _, module in ipairs(modules_to_test) do
        local module_start = vim.loop.hrtime()
        local ok, _ = pcall(require, module)
        local module_end = vim.loop.hrtime()

        results[module] = {
            success = ok,
            time_ms = (module_end - module_start) / 1e6
        }
    end

    local end_time = vim.loop.hrtime()
    local total_time = (end_time - start_time) / 1e6

    return {
        total_time = total_time,
        module_times = results
    }
end

-- Analyse plugin loading performance
local function analyse_plugin_performance()
    local plugin_dir = vim.fn.stdpath("data") .. "/pack/plugins/start"
    local plugins = vim.fn.glob(plugin_dir .. "/*", false, true)

    local results = {}
    for _, plugin_path in ipairs(plugins) do
        local plugin_name = vim.fn.fnamemodify(plugin_path, ":t")
        local start_time = vim.loop.hrtime()

        -- Try to load the plugin
        local ok = pcall(vim.cmd, "packadd " .. plugin_name)
        local end_time = vim.loop.hrtime()

        results[plugin_name] = {
            success = ok,
            time_ms = (end_time - start_time) / 1e6,
            path = plugin_path
        }
    end

    return results
end

-- Generate performance report
local function generate_report()
    print("=== NEOVIM PERFORMANCE ANALYSIS ===")
    print()

    -- Measure startup time
    print("Measuring startup performance...")
    local startup_results = measure_startup_time()

    print(string.format("Total startup time: %.2f ms", startup_results.total_time))
    print()

    print("Module loading times:")
    for module, data in pairs(startup_results.module_times) do
        local status = data.success and "✓" or "✗"
        print(string.format("  %s %s: %.2f ms", status, module, data.time_ms))
    end
    print()

    -- Analyse plugin performance
    print("Analysing plugin performance...")
    local plugin_results = analyse_plugin_performance()

    print("Plugin loading times:")
    local sorted_plugins = {}
    for name, data in pairs(plugin_results) do
        table.insert(sorted_plugins, {name = name, data = data})
    end

    table.sort(sorted_plugins, function(a, b)
        return a.data.time_ms > b.data.time_ms
    end)

    for _, plugin in ipairs(sorted_plugins) do
        local status = plugin.data.success and "✓" or "✗"
        print(string.format("  %s %s: %.2f ms", status, plugin.name, plugin.data.time_ms))
    end
    print()

    -- Performance recommendations
    print("=== PERFORMANCE RECOMMENDATIONS ===")

    local slow_modules = {}
    for module, data in pairs(startup_results.module_times) do
        if data.time_ms > 10 then
            table.insert(slow_modules, {module = module, time = data.time_ms})
        end
    end

    if #slow_modules > 0 then
        print("Slow modules (>10ms):")
        for _, item in ipairs(slow_modules) do
            print(string.format("  - %s (%.2f ms)", item.module, item.time))
        end
        print("Consider deferring these modules using vim.defer_fn()")
    end

    local slow_plugins = {}
    for _, plugin in ipairs(sorted_plugins) do
        if plugin.data.time_ms > 5 then
            table.insert(slow_plugins, {name = plugin.name, time = plugin.data.time_ms})
        end
    end

    if #slow_plugins > 0 then
        print("Slow plugins (>5ms):")
        for _, plugin in ipairs(slow_plugins) do
            print(string.format("  - %s (%.2f ms)", plugin.name, plugin.time))
        end
        print("Consider lazy loading these plugins")
    end

    print()
    print("=== OPTIMISATION TIPS ===")
    print("1. Use vim.defer_fn() for non-critical initialisations")
    print("2. Implement lazy loading for heavy plugins")
    print("3. Cache frequently accessed data")
    print("4. Limit the number of autocmds during startup")
    print("5. Use pcall() to handle plugin loading errors gracefully")
end

-- Export functions
M.measure_startup_time = measure_startup_time
M.analyse_plugin_performance = analyse_plugin_performance
M.generate_report = generate_report

return M
