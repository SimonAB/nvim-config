-- Test script for markdown preview configuration
-- Run this in Neovim to debug image rendering issues

local function test_markdown_preview()
    print("=== Markdown Preview Debug Test ===")

    -- Check if plugin is loaded
    if vim.fn.exists('g:mkdp_images_path') == 1 then
        print("✓ mkdp_images_path is set to: " .. vim.g.mkdp_images_path)
    else
        print("✗ mkdp_images_path is not set")
    end

    -- Check other settings
    print("mkdp_open_to_the_world: " .. tostring(vim.g.mkdp_open_to_the_world))
    print("mkdp_open_ip: " .. tostring(vim.g.mkdp_open_ip))
    print("mkdp_browser: " .. tostring(vim.g.mkdp_browser))

    -- Check current working directory
    local cwd = vim.fn.getcwd()
    print("Current working directory: " .. cwd)

    -- Check if we're in Obsidian vault
    if string.find(cwd, "Notebook") then
        print("✓ In Obsidian vault directory")

        -- Check if attachments directory exists
        local attachments_path = cwd .. "/attachments"
        if vim.fn.isdirectory(attachments_path) == 1 then
            print("✓ Attachments directory exists: " .. attachments_path)

            -- List some files in attachments
            local files = vim.fn.glob(attachments_path .. "/*.jpg", false, true)
            if #files > 0 then
                print("✓ Found " .. #files .. " JPG files in attachments")
                for i = 1, math.min(3, #files) do
                    print("  - " .. vim.fn.fnamemodify(files[i], ":t"))
                end
            else
                print("✗ No JPG files found in attachments")
            end
        else
            print("✗ Attachments directory not found: " .. attachments_path)
        end
    else
        print("✗ Not in Obsidian vault directory")
    end

    -- Check if markdown preview commands are available
    if vim.fn.exists(':MarkdownPreview') == 2 then
        print("✓ MarkdownPreview command is available")
    else
        print("✗ MarkdownPreview command not found")
    end

    print("=== End Debug Test ===")
end

-- Run the test
test_markdown_preview()
