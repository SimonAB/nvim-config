-- Performance Test Script for Neovim Configuration
-- Measures startup time and plugin loading performance

local start_time = vim.loop.now()

-- Function to measure time taken
local function measure_time(label, func)
    local start = vim.loop.now()
    local result = func()
    local elapsed = vim.loop.now() - start
    print(string.format("⏱️  %s: %dms", label, elapsed))
    return result, elapsed
end

-- Test plugin loading performance
local function test_plugin_loading()
    print("\n🔍 Plugin Loading Performance Test")
    print("=" .. string.rep("=", 50))
    
    -- Test immediate plugins
    measure_time("Plenary (immediate)", function()
        return pcall(require, "plenary")
    end)
    
    measure_time("Treesitter (immediate)", function()
        return pcall(require, "nvim-treesitter")
    end)
    
    measure_time("Blink CMP (immediate)", function()
        return pcall(require, "blink.cmp")
    end)
    
    -- Test deferred plugins
    measure_time("Telescope (deferred)", function()
        return pcall(require, "telescope")
    end)
    
    measure_time("Bufferline (deferred)", function()
        return pcall(require, "bufferline")
    end)
    
    -- Test lazy plugins
    measure_time("Which-key (lazy)", function()
        return pcall(require, "which-key")
    end)
end

-- Test LSP performance
local function test_lsp_performance()
    print("\n🔍 LSP Performance Test")
    print("=" .. string.rep("=", 50))
    
    measure_time("LSP Config Setup", function()
        return pcall(require, "lspconfig")
    end)
    
    measure_time("Mason Setup", function()
        return pcall(require, "mason")
    end)
end

-- Test dashboard performance
local function test_dashboard_performance()
    print("\n🔍 Dashboard Performance Test")
    print("=" .. string.rep("=", 50))
    
    measure_time("Mini Starter", function()
        return pcall(require, "mini.starter")
    end)
    
    measure_time("Project Cache", function()
        -- Simulate project list generation
        local oldfiles = vim.v.oldfiles or {}
        local count = 0
        for i = 1, math.min(100, #oldfiles) do
            if type(oldfiles[i]) == "string" then
                count = count + 1
            end
        end
        return count
    end)
end

-- Main performance test
local function run_performance_test()
    print("🚀 Neovim Performance Test")
    print("=" .. string.rep("=", 50))
    
    test_plugin_loading()
    test_lsp_performance()
    test_dashboard_performance()
    
    local total_time = vim.loop.now() - start_time
    print(string.format("\n⏱️  Total Test Time: %dms", total_time))
    print("✅ Performance test completed!")
end

-- Run the test
run_performance_test()
