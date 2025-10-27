-- Enhanced markdown-preview.nvim configuration
-- Based on official documentation: https://github.com/iamcco/markdown-preview.nvim

-- Basic settings
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 1

-- Enable external access for local file browsing (essential for local images)
vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_open_ip = "127.0.0.1"

-- Browser settings
vim.g.mkdp_browser = "" -- Use default browser
vim.g.mkdp_echo_preview_url = 0

-- Enhanced preview options with image support and LaTeX rendering
vim.g.mkdp_preview_options = {
    mkit = {
        image = { loading = "lazy", sizes = "auto" },
        linkify = true,
        typographer = true,
    },
    -- KaTeX configuration for LaTeX math rendering
    katex = {
        -- Enable KaTeX for math rendering
        throwOnError = false,
        errorColor = "#cc0000",
        strict = false,
        -- Support for various LaTeX environments
        macros = {
            ["\\f"] = "#1f(#2)",
            ["\\RR"] = "\\mathbb{R}",
            ["\\NN"] = "\\mathbb{N}",
            ["\\ZZ"] = "\\mathbb{Z}",
            ["\\QQ"] = "\\mathbb{Q}",
            ["\\CC"] = "\\mathbb{C}",
        },
        -- Trust settings for security
        trust = true,
        -- Display settings
        displayMode = true,
        fleqn = false,
        leqno = false,
    },
    -- Mermaid diagram support
    mermaid = {
        theme = "default",
        themeVariables = {
            primaryColor = "#ff0000",
            primaryTextColor = "#000000",
            primaryBorderColor = "#7C0000",
            lineColor = "#333333",
            secondaryColor = "#006100",
            tertiaryColor = "#fff"
        },
        flowchart = {
            useMaxWidth = true,
            htmlLabels = true
        },
        sequence = {
            diagramMarginX = 50,
            diagramMarginY = 10,
            actorMargin = 50,
            width = 150,
            height = 65,
            boxMargin = 10,
            boxTextMargin = 5,
            noteMargin = 10,
            messageMargin = 35
        },
        gantt = {
            titleTopMargin = 25,
            barHeight = 20,
            fontFamily = '"Open-Sans", "sans-serif"',
            fontSize = 11,
            gridLineStartPadding = 35,
            bottomPadding = 25
        }
    },
    -- PlantUML support (for UML diagrams)
    uml = {
        server = "https://www.plantuml.com/plantuml/svg/"
    },
    -- Mermaid integration
    maid = {},
    disable_sync_scroll = 0,
    sync_scroll_type = "middle",
    hide_yaml_meta = 1,
    -- Sequence diagrams (using Mermaid)
    sequence_diagrams = {
        theme = "default"
    },
    -- Flowchart diagrams (using Mermaid)
    flowchart_diagrams = {
        theme = "default"
    },
    content_editable = false,
    disable_filename = 0,
    toc = {}
}

-- Styling
vim.g.mkdp_markdown_css = ""
vim.g.mkdp_highlight_css = ""
vim.g.mkdp_port = ""
vim.g.mkdp_page_title = "${name}"

-- Image path configuration (from official documentation)
-- This tells the plugin where to look for image files
-- Will be set dynamically by Obsidian plugin when needed
vim.g.mkdp_images_path = ""

-- Additional LaTeX and math rendering settings
vim.g.mkdp_math_enable = 1 -- Enable math rendering
vim.g.mkdp_math_delimiters = {
    inline = { { "\\(", "\\)" }, { "$", "$" } },
    block = { { "\\[", "\\]" }, { "$$", "$$" } }
}

-- TikZ Support Note:
-- TikZ diagrams need to be converted to SVG/PNG for HTML preview
-- Use external tools like tikz2svg or manual conversion
-- For now, TikZ blocks will be rendered as LaTeX code blocks

-- Recommendation: Use Mermaid for diagrams in markdown documents
-- Mermaid provides excellent HTML rendering and wide platform support

-- Mermaid diagram support
vim.g.mkdp_mermaid_enable = 1
vim.g.mkdp_mermaid_delimiters = {
    block = { { "```mermaid", "```" } }
}

-- Enhanced filetype support for LaTeX and math-heavy documents
vim.g.mkdp_filetypes = { "markdown", "tex", "latex", "pandoc" }
