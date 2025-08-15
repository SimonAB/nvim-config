-- Configuration for markdown-preview.nvim
-- Markdown preview with enhanced features

-- Markdown preview configuration (vim variables)
vim.g.mkdp_auto_start = 0 -- Don't auto-start preview
vim.g.mkdp_auto_close = 1 -- Auto-close preview when leaving buffer
vim.g.mkdp_refresh_slow = 0 -- Refresh on save
vim.g.mkdp_command_for_global = 0 -- Don't make command global
vim.g.mkdp_open_to_the_world = 0 -- Don't open to the world
vim.g.mkdp_open_ip = "" -- IP to open preview
vim.g.mkdp_browser = "" -- Browser to open preview
vim.g.mkdp_echo_preview_url = 0 -- Don't echo preview URL
vim.g.mkdp_browserfunc = "" -- Custom browser function
vim.g.mkdp_preview_options = {
	mkit = {},
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
	toc = {},
}
vim.g.mkdp_markdown_css = "" -- Custom CSS file
vim.g.mkdp_highlight_css = "" -- Custom highlight CSS
vim.g.mkdp_port = "" -- Port for preview server
vim.g.mkdp_page_title = "${name}" -- Page title format
vim.g.mkdp_filetypes = { "markdown" } -- File types to enable
