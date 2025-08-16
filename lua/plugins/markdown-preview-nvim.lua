-- Enhanced markdown-preview.nvim configuration
-- Based on official documentation: https://github.com/iamcco/markdown-preview.nvim

-- Basic settings
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 0

-- Enable external access for local file browsing (essential for local images)
vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_open_ip = "127.0.0.1"

-- Browser settings
vim.g.mkdp_browser = "" -- Use default browser
vim.g.mkdp_echo_preview_url = 0

-- Enhanced preview options with image support
vim.g.mkdp_preview_options = {
    mkit = {
        image = { loading = "lazy", sizes = "auto" },
        linkify = true,
        typographer = true,
    },
    katex = {},
    uml = {},
    maid = {},
    disable_sync_scroll = 0,
    sync_scroll_type = "middle",
    hide_yaml_meta = 1,
    sequence_diagrams = {},
    flowchart_diagrams = {},
    content_editable = false,
    disable_filename = 0,
    toc = {}
}

-- Styling
vim.g.mkdp_markdown_css = ""
vim.g.mkdp_highlight_css = ""
vim.g.mkdp_port = ""
vim.g.mkdp_page_title = "${name}"
vim.g.mkdp_filetypes = { "markdown" }

-- Image path configuration (from official documentation)
-- This tells the plugin where to look for image files
-- Will be set dynamically by Obsidian plugin when needed
vim.g.mkdp_images_path = ""
