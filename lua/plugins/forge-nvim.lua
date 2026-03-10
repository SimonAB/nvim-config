-- Configuration for Forge — local GTD task & project manager
-- Provides keymaps, Telescope pickers, and terminal integration

local M = {}

local FORGE_DIR = vim.fn.expand("~/Documents/Forge")
local SETUP_SCRIPT = FORGE_DIR .. "/setup.sh"

--- Project root: git root from current buffer/cwd, or directory of current file, or cwd.
---@return string
local function project_root()
	local start = ""
	local buf = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf)
	if path and path ~= "" then
		start = vim.fn.fnamemodify(path, ":p:h")
	else
		start = vim.fn.getcwd()
	end
	local root = vim.fn.trim(vim.fn.system("git -C " .. vim.fn.shellescape(start) .. " rev-parse --show-toplevel 2>/dev/null"))
	if root and root ~= "" and vim.fn.isdirectory(root) == 1 then
		return root
	end
	return start
end

--- Path to TASKS.md at the project root (git root, or current buffer dir / cwd).
---@return string
local function tasks_path_in_cwd()
	return project_root() .. "/TASKS.md"
end

--- Minimal TASKS.md skeleton: section headers only (Forge format).
--- Per-task notes use indented `>` (blockquote) lines under the task.
local TASKS_TEMPLATE = [[
## Next Actions

- [ ] Sample task @due(2026-03-15) @ctx(office)
  > Add notes for this task here using blockquote style.

## Waiting For

- [ ]
  >

## Completed

## Notes
]]

--- Check whether the forge CLI is available on PATH.
---@return boolean
function M.is_available()
	return vim.fn.executable("forge") == 1
end

--- Check whether Forge.app is installed.
---@return boolean
function M.is_app_installed()
	return vim.fn.isdirectory("/Applications/Forge.app") == 1
end

--- Check whether setup.sh exists in the Forge directory.
---@return boolean
function M.has_setup_script()
	return vim.fn.filereadable(SETUP_SCRIPT) == 1
end

--- Run a forge CLI command in a horizontal terminal (read-only output).
---@param cmd string shell command to execute
---@param opts? table toggleterm overrides
local function forge_terminal(cmd, opts)
	local ok, Terminal = pcall(function()
		return require("toggleterm.terminal").Terminal
	end)
	if not ok then
		vim.notify("toggleterm not available", vim.log.levels.WARN)
		return
	end

	local default_opts = {
		cmd = cmd,
		hidden = true,
		direction = "horizontal",
		size = 18,
		close_on_exit = false,
		on_open = function(term)
			vim.cmd("stopinsert")
			local buf_opts = { buffer = term.bufnr, noremap = true, silent = true }
			vim.keymap.set("n", "q", "<cmd>close<CR>", buf_opts)
		end,
	}

	local term = Terminal:new(vim.tbl_extend("force", default_opts, opts or {}))
	term:toggle()
end

--- Run an interactive forge command in a vertical terminal.
---@param cmd string shell command to execute
local function forge_interactive(cmd)
	forge_terminal(cmd, {
		direction = "vertical",
		size = math.floor(vim.o.columns * 0.4),
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
	})
end

--- Extract a forge task ID from the current line (the 6-hex-char id in <!-- id:XXXXXX -->).
---@return string|nil
local function task_id_from_cursor()
	local line = vim.api.nvim_get_current_line()
	return line:match("<!%-%- id:(%x+) %-%->")
end

--- Open a Forge area file by name.
---@param filename string e.g. "inbox.md"
local function open_forge_file(filename)
	local path = FORGE_DIR .. "/" .. filename
	if vim.fn.filereadable(path) == 1 then
		vim.cmd("edit " .. vim.fn.fnameescape(path))
	else
		vim.notify("File not found: " .. path, vim.log.levels.WARN)
	end
end

--- Telescope picker scoped to the Forge directory.
---@param picker string telescope builtin name
---@param prompt string prompt title
local function forge_telescope(picker, prompt)
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope not available", vim.log.levels.WARN)
		return
	end
	builtin[picker]({ cwd = FORGE_DIR, prompt_title = prompt })
end

-- ===========================================================================
-- KEYMAPS
-- ===========================================================================

function M.setup_keymaps()
	local map = vim.keymap.set

	-- View commands (read-only terminal output)
	map("n", "<leader>Fn", function()
		forge_terminal("forge next")
	end, { desc = "Next actions" })

	map("n", "<leader>Fb", function()
		forge_terminal("forge board --list")
	end, { desc = "Kanban board" })

	map("n", "<leader>Fp", function()
		forge_terminal("forge projects")
	end, { desc = "Tasks per project" })

	map("n", "<leader>Ft", function()
		forge_terminal("forge status")
	end, { desc = "Project status" })

	map("n", "<leader>Fw", function()
		forge_terminal("forge waiting")
	end, { desc = "Waiting-for items" })

	map("n", "<leader>Fx", function()
		forge_terminal("forge contexts")
	end, { desc = "Tasks by context" })

	map("n", "<leader>Fm", function()
		forge_terminal("forge someday")
	end, { desc = "Someday / maybe" })

	map("n", "<leader>FD", function()
		forge_terminal("forge due")
	end, { desc = "Overdue & due tasks" })

	-- Interactive commands (need user input)
	map("n", "<leader>Fr", function()
		forge_interactive("forge review")
	end, { desc = "Weekly review" })

	map("n", "<leader>FI", function()
		forge_interactive("forge process")
	end, { desc = "Process inbox" })

	-- Sync
	map("n", "<leader>Fs", function()
		forge_terminal("forge sync --verbose")
	end, { desc = "Sync Reminders & Calendar" })

	-- Quick capture — prompts for text, runs forge inbox "<text>"
	map("n", "<leader>Fc", function()
		vim.ui.input({ prompt = "Capture to inbox: " }, function(text)
			if text and text ~= "" then
				local escaped = text:gsub('"', '\\"')
				vim.fn.system('forge inbox "' .. escaped .. '"')
				vim.notify("Captured: " .. text, vim.log.levels.INFO)
			end
		end)
	end, { desc = "Quick capture" })

	-- Complete task — reads ID from cursor line, or prompts
	map("n", "<leader>Fd", function()
		local id = task_id_from_cursor()
		if id then
			vim.fn.system("forge done " .. id)
			vim.notify("Completed task " .. id, vim.log.levels.INFO)
			-- Re-read the buffer to reflect the change
			vim.cmd("edit")
		else
			vim.ui.input({ prompt = "Task ID to complete: " }, function(input)
				if input and input ~= "" then
					local result = vim.fn.system("forge done " .. input)
					vim.notify(vim.trim(result), vim.log.levels.INFO)
					vim.cmd("edit")
				end
			end)
		end
	end, { desc = "Complete task" })

	-- File access
	map("n", "<leader>Fi", function()
		open_forge_file("inbox.md")
	end, { desc = "Open inbox" })

	-- Open TASKS.md in current directory (create from template if missing)
	map("n", "<leader>FT", function()
		local path = tasks_path_in_cwd()
		if vim.fn.filereadable(path) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		else
			local dir = vim.fn.fnamemodify(path, ":h")
			if vim.fn.isdirectory(dir) == 0 then
				vim.fn.mkdir(dir, "p")
			end
			local ok = pcall(vim.fn.writefile, vim.split(TASKS_TEMPLATE, "\n"), path)
			if ok then
				vim.cmd("edit " .. vim.fn.fnameescape(path))
			else
				vim.notify("Could not create " .. path, vim.log.levels.ERROR)
			end
		end
	end, { desc = "Open TASKS.md (current dir)" })

	-- Telescope: browse area files
	map("n", "<leader>Fa", function()
		forge_telescope("find_files", "Forge Files")
	end, { desc = "Browse Forge files" })

	-- Telescope: search across all Forge files
	map("n", "<leader>Fg", function()
		forge_telescope("live_grep", "Search Forge")
	end, { desc = "Search Forge files" })

	-- Focus sessions
	map("n", "<leader>Fo", function()
		forge_terminal("forge focus")
	end, { desc = "Show current focus" })

	map("n", "<leader>Ff", function()
		vim.ui.select({ "work", "personal", "spiritual", "clear" }, { prompt = "Focus session:" }, function(choice)
			if not choice then return end
			if choice == "clear" then
				vim.fn.system("forge focus --clear")
				vim.notify("Focus cleared", vim.log.levels.INFO)
			else
				vim.fn.system("forge focus " .. choice)
				vim.notify("Focus: " .. choice, vim.log.levels.INFO)
			end
		end)
	end, { desc = "Set focus session" })
end

-- ===========================================================================
-- SETUP
-- ===========================================================================

--- Run setup.sh in a full-screen terminal so the user can watch the build.
function M.run_setup()
	if not M.has_setup_script() then
		vim.notify("setup.sh not found at " .. SETUP_SCRIPT, vim.log.levels.ERROR)
		return
	end

	local ok, Terminal = pcall(function()
		return require("toggleterm.terminal").Terminal
	end)
	if not ok then
		vim.notify("toggleterm not available — run manually:\n  zsh " .. SETUP_SCRIPT, vim.log.levels.WARN)
		return
	end

	local term = Terminal:new({
		cmd = "/opt/homebrew/bin/zsh " .. vim.fn.shellescape(SETUP_SCRIPT),
		hidden = true,
		direction = "float",
		close_on_exit = false,
		on_open = function(t)
			vim.cmd("startinsert!")
		end,
		on_exit = function()
			vim.schedule(function()
				if M.is_available() then
					vim.notify("Forge installed successfully", vim.log.levels.INFO)
				end
			end)
		end,
	})
	term:toggle()
end

-- ===========================================================================
-- USER COMMANDS
-- ===========================================================================

function M.setup_commands()
	vim.api.nvim_create_user_command("ForgeNext", function()
		forge_terminal("forge next")
	end, { desc = "Forge: show next actions" })

	vim.api.nvim_create_user_command("ForgeBoard", function()
		forge_terminal("forge board --list")
	end, { desc = "Forge: kanban board" })

	vim.api.nvim_create_user_command("ForgeProjects", function(opts)
		local arg = opts.args
		if arg and arg ~= "" then
			forge_terminal("forge projects -p " .. arg)
		else
			forge_terminal("forge projects")
		end
	end, { nargs = "?", desc = "Forge: tasks per project" })

	vim.api.nvim_create_user_command("ForgeDue", function(opts)
		local arg = opts.args
		if arg and arg ~= "" then
			forge_terminal("forge due -d " .. arg)
		else
			forge_terminal("forge due")
		end
	end, { nargs = "?", desc = "Forge: show overdue and due tasks" })

	vim.api.nvim_create_user_command("ForgeSync", function()
		forge_terminal("forge sync --verbose")
	end, { desc = "Forge: sync with Reminders & Calendar" })

	vim.api.nvim_create_user_command("ForgeReview", function()
		forge_interactive("forge review")
	end, { desc = "Forge: weekly review" })

	vim.api.nvim_create_user_command("ForgeCapture", function(opts)
		if opts.args and opts.args ~= "" then
			local escaped = opts.args:gsub('"', '\\"')
			vim.fn.system('forge inbox "' .. escaped .. '"')
			vim.notify("Captured: " .. opts.args, vim.log.levels.INFO)
		else
			vim.ui.input({ prompt = "Capture to inbox: " }, function(text)
				if text and text ~= "" then
					local escaped = text:gsub('"', '\\"')
					vim.fn.system('forge inbox "' .. escaped .. '"')
					vim.notify("Captured: " .. text, vim.log.levels.INFO)
				end
			end)
		end
	end, { nargs = "?", desc = "Forge: capture task to inbox" })

	vim.api.nvim_create_user_command("ForgeFocus", function(opts)
		local arg = opts.args
		if not arg or arg == "" then
			forge_terminal("forge focus")
		elseif arg == "clear" then
			vim.fn.system("forge focus --clear")
			vim.notify("Focus cleared", vim.log.levels.INFO)
		else
			vim.fn.system("forge focus " .. arg)
			vim.notify("Focus: " .. arg, vim.log.levels.INFO)
		end
	end, { nargs = "?", desc = "Forge: set or show focus session" })

	vim.api.nvim_create_user_command("ForgeSetup", function()
		M.run_setup()
	end, { desc = "Forge: build and install Forge on this Mac" })

	vim.api.nvim_create_user_command("ForgeDone", function(opts)
		local id = opts.args
		if not id or id == "" then
			id = task_id_from_cursor()
		end
		if id and id ~= "" then
			local result = vim.fn.system("forge done " .. id)
			vim.notify(vim.trim(result), vim.log.levels.INFO)
			vim.cmd("edit")
		else
			vim.notify("No task ID provided or found on current line", vim.log.levels.WARN)
		end
	end, { nargs = "?", desc = "Forge: complete a task by ID" })

	vim.api.nvim_create_user_command("ForgeNvimTasks", function()
		local path = tasks_path_in_cwd()
		if vim.fn.filereadable(path) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		else
			local dir = vim.fn.fnamemodify(path, ":h")
			if vim.fn.isdirectory(dir) == 0 then
				vim.fn.mkdir(dir, "p")
			end
			local ok = pcall(vim.fn.writefile, vim.split(TASKS_TEMPLATE, "\n"), path)
			if ok then
				vim.cmd("edit " .. vim.fn.fnameescape(path))
			else
				vim.notify("Could not create " .. path, vim.log.levels.ERROR)
			end
		end
	end, { desc = "Forge: open TASKS.md in current directory" })

	vim.api.nvim_create_user_command("ForgeTASKSTemplate", function()
		local line = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, line - 1, line - 1, true, vim.split(TASKS_TEMPLATE, "\n"))
		vim.notify("Inserted TASKS.md template", vim.log.levels.INFO)
	end, { desc = "Forge: insert TASKS.md section template at cursor" })
end

-- ===========================================================================
-- ENTRY POINT — auto-setup on require (matches plugin-loader convention)
-- ===========================================================================

M.setup_commands()

if M.is_available() then
	M.setup_keymaps()
else
	vim.defer_fn(function()
		if M.has_setup_script() then
			vim.notify(
				"Forge CLI not found. Run :ForgeSetup to build and install.",
				vim.log.levels.WARN
			)
		end
	end, 500)
end

return M
