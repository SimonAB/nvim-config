-- Configuration for obsidian.nvim
-- A Neovim plugin for writing and navigating Obsidian vaults

local ok, obsidian = pcall(require, "obsidian")
if not ok then
    vim.notify("obsidian.nvim not found", vim.log.levels.WARN)
    return
end

obsidian.setup({
    -- Your Obsidian vault path
    workspaces = {
        {
            name = "notebook",
            path = "/Users/s_a_b/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook",
        },
    },

    -- Note settings
    notes_subdir = "notes",
    new_notes_location = "notes_subdir",
    note_id_func = function(title)
        -- Create note IDs with timestamp prefix
        local suffix = ""
        if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
            -- If title is nil, just add timestamp
            suffix = tostring(os.time())
        end
        return suffix
    end,

    -- Templates
    templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- Custom substitutions
        substitutions = {
            yesterday = function()
                return os.date("%Y-%m-%d", os.time() - 86400)
            end,
            tomorrow = function()
                return os.date("%Y-%m-%d", os.time() + 86400)
            end,
        },
    },

    -- Completion and navigation
    completion = {
        nvim_cmp = false, -- Disable nvim-cmp since we're using blink.cmp
        min_chars = 2,
        new_notes_location = "current_dir",
    },

    -- Wiki link function (replaces deprecated completion options)
    wiki_link_func = function(opts)
        if opts.id then
            return string.format("[[%s]]", opts.id)
        elseif opts.path then
            return string.format("[[%s]]", opts.path)
        else
            return string.format("[[%s]]", opts.alias)
        end
    end,

    -- Key mappings
    mappings = {
        -- Override the 'gf' mapping to work within the vault
        ["gf"] = {
            action = function()
                return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
        },
        -- Create new note
        ["<leader>on"] = {
            action = function()
                return require("obsidian").util.new_note()
            end,
            opts = { desc = "New Obsidian note" },
        },
        -- Insert link
        ["<leader>ol"] = {
            action = function()
                return require("obsidian").util.insert_link()
            end,
            opts = { desc = "Insert Obsidian link" },
        },
        -- Follow link
        ["<leader>of"] = {
            action = function()
                return require("obsidian").util.follow_link()
            end,
            opts = { desc = "Follow Obsidian link" },
        },
        -- Toggle checkbox
        ["<leader>oc"] = {
            action = function()
                return require("obsidian").util.toggle_checkbox()
            end,
            opts = { desc = "Toggle Obsidian checkbox" },
        },
        -- Show backlinks
        ["<leader>ob"] = {
            action = function()
                return require("obsidian").util.show_backlinks()
            end,
            opts = { desc = "Show Obsidian backlinks" },
        },
        -- Show outgoing links
        ["<leader>oo"] = {
            action = function()
                return require("obsidian").util.show_outgoing_links()
            end,
            opts = { desc = "Show Obsidian outgoing links" },
        },
    },

    -- Note frontmatter
    note_frontmatter_func = function(note)
        -- Add default frontmatter to new notes
        if note.title then
            note:add_alias(note.title)
        end
        return {
            id = note.id,
            aliases = note.aliases,
            tags = note.tags,
            created = os.date("%Y-%m-%d"),
            modified = os.date("%Y-%m-%d"),
        }
    end,

    -- Search settings
    search = {
        max_results = 20,
        max_search_results = 50,
    },

    -- UI settings
    ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "󰄲", hl_group = "ObsidianDone" },
            [">"] = { char = "󰐕", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰘸", hl_group = "ObsidianTilde" },
        },
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "󰉹", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
            ObsidianTodo = { bold = true, fg = "#ff6b6b" },
            ObsidianDone = { bold = true, fg = "#51cf66" },
            ObsidianRightArrow = { bold = true, fg = "#5c7cfa" },
            ObsidianTilde = { bold = true, fg = "#ffd43b" },
            ObsidianBullet = { bold = true, fg = "#339af0" },
            ObsidianRefText = { underline = true, fg = "#9c88ff" },
            ObsidianExtLinkIcon = { fg = "#339af0" },
            ObsidianTag = { italic = true, fg = "#e599f7" },
            ObsidianBlockID = { italic = true, fg = "#7a7a7a" },
            ObsidianHighlightText = { bg = "#756bb1", fg = "#ffffff" },
        },
    },

    -- Callbacks
    callbacks = {
        post_setup = function(client)
            -- Called after obsidian.nvim is set up
            vim.notify("Obsidian.nvim configured for your vault", vim.log.levels.INFO)
        end,
        enter_note = function(note)
            -- Called when entering a note
        end,
        leave_note = function(note)
            -- Called when leaving a note
        end,
        pre_write_note = function(note)
            -- Called before writing a note
        end,
        post_write_note = function(note)
            -- Called after writing a note
        end,
    },

    -- Performance settings
    daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        template = nil,
    },

    -- Advanced settings
    disable_frontmatter = false,
    note_path_func = function(spec)
        -- Custom note path function
        if spec.id and spec.id ~= "" then
            return spec.id
        end
        if spec.title then
            return spec.title:gsub(" ", "-"):lower()
        end
        return tostring(os.time())
    end,
})
