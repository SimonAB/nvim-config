-- Icon Explorer Script
-- Run this with: nvim --headless -l explore_icons.lua

print('=== EXPLORING AVAILABLE ICONS ===\n')

-- Explore mini.icons
local mini_ok, mini_icons = pcall(require, 'mini.icons')
if mini_ok then
  print('🎨 MINI.ICONS CATEGORIES:')
  local categories = vim.tbl_keys(mini_icons.config.default)
  table.sort(categories)
  
  for _, category in ipairs(categories) do
    local icons = mini_icons.config.default[category]
    local count = vim.tbl_count(icons)
    print(string.format('  %s (%d icons)', category, count))
    
    -- Show some examples
    local names = vim.tbl_keys(icons)
    table.sort(names)
    print('    Examples:')
    for i = 1, math.min(5, #names) do
      local name = names[i]
      local icon_data = icons[name]
      local icon = type(icon_data) == 'string' and icon_data or (icon_data.glyph or '?')
      print(string.format('      %s → %s', name, icon))
    end
    print('')
  end
else
  print('❌ mini.icons not available')
end

print('\n' .. string.rep('=', 50) .. '\n')

-- Explore nvim-web-devicons
local devicons_ok, devicons = pcall(require, 'nvim-web-devicons')
if devicons_ok then
  print('🎨 NVIM-WEB-DEVICONS:')
  local icons = devicons.get_icons()
  local count = vim.tbl_count(icons)
  print(string.format('  Total icons: %d', count))
  
  -- Group by categories (rough grouping)
  local categories = {
    config = {},
    programming = {},
    data = {},
    web = {},
    other = {}
  }
  
  for name, data in pairs(icons) do
    local lower_name = name:lower()
    if lower_name:match('config') or lower_name:match('%.json$') or lower_name:match('%.yml$') or lower_name:match('%.yaml$') then
      table.insert(categories.config, {name = name, icon = data.icon})
    elseif lower_name:match('%.py$') or lower_name:match('%.js$') or lower_name:match('%.lua$') or lower_name:match('%.jl$') then
      table.insert(categories.programming, {name = name, icon = data.icon})
    elseif lower_name:match('%.csv$') or lower_name:match('%.json$') or lower_name:match('%.xml$') then
      table.insert(categories.data, {name = name, icon = data.icon})
    elseif lower_name:match('%.html$') or lower_name:match('%.css$') or lower_name:match('%.scss$') then
      table.insert(categories.web, {name = name, icon = data.icon})
    else
      table.insert(categories.other, {name = name, icon = data.icon})
    end
  end
  
  for cat_name, cat_icons in pairs(categories) do
    if #cat_icons > 0 then
      print(string.format('\n  %s (%d icons):', cat_name:upper(), #cat_icons))
      table.sort(cat_icons, function(a, b) return a.name < b.name end)
      for i = 1, math.min(5, #cat_icons) do
        local item = cat_icons[i]
        print(string.format('    %s → %s', item.name, item.icon))
      end
      if #cat_icons > 5 then
        print(string.format('    ... and %d more', #cat_icons - 5))
      end
    end
  end
else
  print('❌ nvim-web-devicons not available')
end

print('\n' .. string.rep('=', 50))
print('💡 TIP: You can also explore icons interactively in Neovim:')
print('   :lua print(require("mini.icons").get("file", "config.json"))')
print('   :lua print(vim.inspect(require("nvim-web-devicons").get_icons()))')
