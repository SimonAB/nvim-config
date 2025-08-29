-- =============================================================================
-- MASON ENHANCED UI
-- PURPOSE: Enhanced Mason package management with progress tracking and batch operations
-- =============================================================================

local MasonUI = {}
local progress_handle = nil

-- Progress notification system
local function create_progress_notification(title, message)
	if progress_handle then
		progress_handle:finish()
	end

	local ok, fidget = pcall(require, "fidget")
	if ok then
		progress_handle = fidget.progress.handle.create({
			title = title,
			message = message,
			percentage = 0,
		})
	else
		-- Fallback to basic notification
		vim.notify(message, vim.log.levels.INFO, {
			title = title,
			timeout = 5000,
		})
	end
	return progress_handle
end

-- Enhanced notification system
local function notify(message, level, opts)
	local default_opts = {
		title = "Mason Package Manager",
		timeout = 3000,
	}
	local final_opts = vim.tbl_extend("force", default_opts, opts or {})

	vim.notify(message, level, final_opts)
end

-- Batch installation of LSP servers
function MasonUI.install_servers_batch(servers, options)
	options = options or {}
	local title = options.title or "Installing LSP Servers"
	local show_progress = options.show_progress ~= false

	local handle = nil
	if show_progress then
		handle = create_progress_notification(title, "Starting batch installation...")
	end

	local total = #servers
	local completed = 0
	local failed = {}

	-- Install servers sequentially to avoid conflicts
	local function install_next(index)
		if index > total then
			-- All done
			if handle then
				handle.message = string.format("Installation complete! %d/%d successful", completed, total)
				vim.defer_fn(function() handle:finish() end, 1000)
			end

			if #failed > 0 then
				notify(string.format("Batch installation: %d/%d successful, %d failed", completed, total, #failed),
					vim.log.levels.WARN, { timeout = 5000 })
				for _, failure in ipairs(failed) do
					notify("Failed: " .. failure, vim.log.levels.ERROR)
				end
			else
				notify(string.format("All %d LSP servers installed successfully!", total),
					vim.log.levels.INFO)
			end
			return
		end

		local server = servers[index]
		if handle then
			handle.message = string.format("Installing %s (%d/%d)", server, index, total)
			handle.percentage = ((index - 1) / total) * 100
		end

		-- Install the server
		local success = pcall(function()
			vim.cmd("MasonInstall " .. server)
		end)

		if success then
			completed = completed + 1
		else
			table.insert(failed, server)
		end

		-- Schedule next installation
		vim.defer_fn(function()
			install_next(index + 1)
		end, 500) -- Small delay between installations
	end

	-- Start the installation process
	install_next(1)
end

-- Install core academic LSP servers
function MasonUI.install_academic_servers()
	local academic_servers = {
		"pyright",     -- Python
		"texlab",      -- LaTeX
		"tinymist",    -- Typst
		"lua_ls",      -- Lua
		"bashls",      -- Bash
		"marksman",    -- Markdown
		"jsonls",      -- JSON
		"yamlls",      -- YAML
	}

	MasonUI.install_servers_batch(academic_servers, {
		title = "Installing Academic LSP Servers"
	})
end

-- Install all recommended servers
function MasonUI.install_all_recommended()
	local all_servers = {
		-- Core LSP servers
		"pyright", "texlab", "tinymist", "lua_ls", "bashls",
		"marksman", "jsonls", "yamlls", "html", "cssls",
		"ts_ls", "r_language_server"
	}

	MasonUI.install_servers_batch(all_servers, {
		title = "Installing All Recommended Servers"
	})
end

-- Update all installed packages
function MasonUI.update_all_packages()
	local handle = create_progress_notification("Updating Packages", "Checking for updates...")

	vim.defer_fn(function()
		local success = pcall(function()
			vim.cmd("MasonUpdate")
		end)

		if handle then
			if success then
				handle.message = "All packages updated successfully!"
			else
				handle.message = "Update failed or no updates available"
			end
			vim.defer_fn(function() handle:finish() end, 2000)
		end

		if success then
			notify("Package update completed", vim.log.levels.INFO)
		else
			notify("Package update failed", vim.log.levels.WARN)
		end
	end, 100)
end

-- Check Mason status and provide summary
function MasonUI.check_status()
	local handle = create_progress_notification("Mason Status", "Checking installation status...")

	vim.defer_fn(function()
		local ok, mason = pcall(require, "mason")
		if not ok then
			notify("Mason not available", vim.log.levels.ERROR)
			if handle then handle:finish() end
			return
		end

		local registry = mason.registry
		local installed = registry.installed_packages or {}
		local total_installed = 0
		local lsp_servers = 0

		for name, pkg in pairs(installed) do
			total_installed = total_installed + 1
			if pkg.spec and pkg.spec.categories then
				for _, category in ipairs(pkg.spec.categories) do
					if category == "LSP" then
						lsp_servers = lsp_servers + 1
						break
					end
				end
			end
		end

		local message = string.format("Mason Status: %d packages installed (%d LSP servers)",
			total_installed, lsp_servers)

		if handle then
			handle.message = message
			vim.defer_fn(function() handle:finish() end, 2000)
		end

		notify(message, vim.log.levels.INFO, { timeout = 5000 })
	end, 100)
end

-- Create user commands for easy access
function MasonUI.setup_commands()
	vim.api.nvim_create_user_command("MasonInstallAcademic", function()
		MasonUI.install_academic_servers()
	end, { desc = "Install academic LSP servers (Python, LaTeX, Typst, etc.)" })

	vim.api.nvim_create_user_command("MasonInstallAll", function()
		MasonUI.install_all_recommended()
	end, { desc = "Install all recommended LSP servers" })

	vim.api.nvim_create_user_command("MasonUpdateAll", function()
		MasonUI.update_all_packages()
	end, { desc = "Update all installed Mason packages" })

	vim.api.nvim_create_user_command("MasonStatus", function()
		MasonUI.check_status()
	end, { desc = "Show Mason installation status" })
end

-- Setup Mason event handlers for better notifications
function MasonUI.setup_event_handlers()
	local group = vim.api.nvim_create_augroup("MasonEnhanced", { clear = true })

	-- Enhanced installation notifications
	vim.api.nvim_create_autocmd("User", {
		pattern = "MasonInstallCompleted",
		group = group,
		callback = function(ev)
			local package_name = ev.data or "Unknown"
			notify("✓ " .. package_name .. " installed successfully", vim.log.levels.INFO)
		end,
	})

	-- Installation failure notifications
	vim.api.nvim_create_autocmd("User", {
		pattern = "MasonInstallFailed",
		group = group,
		callback = function(ev)
			local package_name = ev.data or "Unknown"
			notify("✗ Failed to install " .. package_name, vim.log.levels.ERROR)
		end,
	})

	-- Update notifications
	vim.api.nvim_create_autocmd("User", {
		pattern = "MasonUpdateCompleted",
		group = group,
		callback = function(ev)
			local package_name = ev.data or "Unknown"
			notify("✓ " .. package_name .. " updated", vim.log.levels.INFO)
		end,
	})
end

-- Initialize the enhanced Mason UI
function MasonUI.init()
	MasonUI.setup_commands()
	MasonUI.setup_event_handlers()

	vim.notify("Mason Enhanced UI initialized", vim.log.levels.INFO)
end

return MasonUI
