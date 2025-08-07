-- Debug key mappings to see actual format
print("=== Debugging Key Mappings ===")

-- Show a sample of actual key mappings to understand the format
local mappings = vim.api.nvim_get_keymap('n')
print("Sample of normal mode mappings:")
for i = 1, math.min(10, #mappings) do
    local map = mappings[i]
    print(string.format("  LHS: '%s', RHS: '%s', Description: '%s'", 
        map.lhs or "nil", 
        map.rhs or map.callback and "function" or "nil", 
        map.desc or "no description"))
end

-- Look specifically for window navigation mappings
print("\nLooking for window navigation mappings:")
for _, map in ipairs(mappings) do
    if map.lhs and (map.lhs:match("C%-h") or map.lhs:match("C%-j") or map.lhs:match("C%-k") or map.lhs:match("C%-l")) then
        print(string.format("  Found: '%s' -> '%s'", map.lhs, map.rhs or "function"))
    end
end

-- Look for buffer navigation
print("\nLooking for buffer navigation mappings:")
for _, map in ipairs(mappings) do
    if map.lhs and (map.lhs:match("S%-h") or map.lhs:match("S%-l")) then
        print(string.format("  Found: '%s' -> '%s'", map.lhs, map.rhs or "function"))
    end
end

-- Check terminal mode mappings
local t_mappings = vim.api.nvim_get_keymap('t')
print("\nTerminal mode mappings:")
for _, map in ipairs(t_mappings) do
    print(string.format("  LHS: '%s', RHS: '%s', Description: '%s'", 
        map.lhs or "nil", 
        map.rhs or map.callback and "function" or "nil", 
        map.desc or "no description"))
end

-- Show leader mappings
print("\nLeader mappings (first 10):")
local leader_count = 0
for _, map in ipairs(mappings) do
    if map.lhs and map.lhs:match("^%s") and leader_count < 10 then
        print(string.format("  '%s' -> '%s' (%s)", 
            map.lhs, 
            map.rhs or "function", 
            map.desc or "no description"))
        leader_count = leader_count + 1
    end
end

print("=== Debug Complete ===")
