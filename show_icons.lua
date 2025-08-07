local devicons = require('nvim-web-devicons')

-- Show actual icons with their hex codes
local files = {
  'test.jl', 'test.py', 'test.lua', 'test.js', 'test.css', 
  'test.json', 'test.md', '.gitignore', 'package.json',
  'tsconfig.json', 'webpack.config.js', '.eslintrc.js',
  'test.ipynb', 'docker-compose.yml', 'test.yml'
}

for _, file in ipairs(files) do
  local icon, _ = devicons.get_icon(file)
  if icon then
    -- Print the icon and its UTF-8 bytes
    print(string.format("%s: [%s] bytes: ", file, icon))
    for i = 1, #icon do
      print(string.format("  %02x", string.byte(icon, i)))
    end
  end
end
