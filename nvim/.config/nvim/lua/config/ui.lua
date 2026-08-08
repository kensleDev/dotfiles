require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	integrations = { gitsigns = true, native_lsp = { enabled = true } },
})
vim.cmd.colorscheme("catppuccin")

require("neo-tree").setup({
	sources = { "filesystem", "buffers", "git_status" },
	filesystem = {
		bind_to_cwd = false,
		follow_current_file = { enabled = true },
		hijack_netrw_behavior = "open_default",
		use_libuv_file_watcher = true,
	},
	window = { position = "right" },
})

local function project_root()
	return vim.fs.root(0, ".git") or vim.uv.cwd()
end

local function neotree(opts)
	require("neo-tree.command").execute(vim.tbl_extend("force", { toggle = true, position = "right" }, opts))
end

vim.keymap.set("n", "<leader>fe", function()
	neotree({ source = "filesystem", dir = project_root() })
end, { desc = "Explorer Neo-tree (Root Dir)" })
vim.keymap.set("n", "<leader>fE", function()
	neotree({ source = "filesystem", dir = vim.uv.cwd() })
end, { desc = "Explorer Neo-tree (cwd)" })
vim.keymap.set("n", "<leader>e", "<leader>fe", { desc = "Explorer Neo-tree (Root Dir)", remap = true })
vim.keymap.set("n", "<leader>E", "<leader>fE", { desc = "Explorer Neo-tree (cwd)", remap = true })
vim.keymap.set("n", "<leader>ge", function()
	neotree({ source = "git_status" })
end, { desc = "Git Explorer" })
vim.keymap.set("n", "<leader>be", function()
	neotree({ source = "buffers" })
end, { desc = "Buffer Explorer" })

local modes = { n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", c = "COMMAND", t = "TERMINAL", R = "REPLACE" }
function _G.LeanStatusline()
	local mode = modes[vim.fn.mode()] or vim.fn.mode():upper()
	local counts = vim.diagnostic.count(0)
	local diagnostic = ""
	local labels = { [vim.diagnostic.severity.ERROR] = "E", [vim.diagnostic.severity.WARN] = "W" }
	for severity, label in pairs(labels) do
		if (counts[severity] or 0) > 0 then
			diagnostic = diagnostic .. " " .. label .. ":" .. counts[severity]
		end
	end
	return " " .. mode .. "  %f %m%=%{v:lua._lean_git_branch()}" .. diagnostic .. "  %y  %l:%c "
end

function _G._lean_git_branch()
	return vim.b.gitsigns_head and (" " .. vim.b.gitsigns_head .. "  ") or ""
end
vim.opt.statusline = "%!v:lua.LeanStatusline()"

local function floating_terminal(command)
	local buf = vim.api.nvim_create_buf(false, true)
	local job_id
	local closed = false
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.85)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
	})
	local function close_terminal()
		if closed then
			return
		end
		closed = true
		if job_id and job_id > 0 then
			vim.fn.jobstop(job_id)
		end
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	vim.keymap.set({ "n", "t" }, "<Esc><Esc>", close_terminal, { buffer = buf, silent = true })
	job_id = vim.fn.jobstart(command, {
		term = true,
		on_exit = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})
	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Lazyworktree", function()
	floating_terminal({ "lazyworktree" })
end, {})
vim.keymap.set("n", "<leader>gw", "<cmd>Lazyworktree<cr>", { desc = "Lazyworktree" })
vim.keymap.set("n", "<leader>gg", function() floating_terminal({ "lazygit" }) end, { desc = "Lazygit" })

local function show_welcome()
		local buf = vim.api.nvim_get_current_buf()
		local fzf = require("fzf-lua")
		local session = vim.fn.stdpath("state") .. "/sessions/default.vim"
		local lines = {
			"",
			"  ▗▖ ▗▖▗▞▀▚▖▄▄▄▄   ▄▄▄ █ ▗▞▀▚▖▗▄▄▄  ▗▞▀▚▖▄   ▄  ▄▄▄     ▗▖  ▗▖▗▞▀▚▖ ▄▄▄  ▄   ▄ ▄ ▄▄▄▄",
			"  ▐▌▗▞▘▐▛▀▀▘█   █ ▀▄▄  █ ▐▛▀▀▘▐▌  █ ▐▛▀▀▘█   █ ▀▄▄      ▐▛▚▖▐▌▐▛▀▀▘█   █ █   █ ▄ █ █ █",
			"  ▐▛▚▖ ▝▚▄▄▖█   █ ▄▄▄▀ █ ▝▚▄▄▖▐▌  █ ▝▚▄▄▖ ▀▄▀  ▄▄▄▀     ▐▌ ▝▜▌▝▚▄▄▖▀▄▄▄▀  ▀▄▀  █ █   █",
			"  ▐▌ ▐▌                █      ▐▙▄▄▀                     ▐▌  ▐▌                 █",
			"",
			"  ───────────────────────────────────────────────────────────────────────────────────────",
			"",
			"  f  Find file",
			"  n  New file",
			"  g  Find text",
			"  r  Recent files",
			"  c  Config",
			"  s  Restore session",
			"  q  Quit",
			"",
		}

		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].buflisted = false
		vim.bo[buf].swapfile = false
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
		vim.bo[buf].filetype = "lean-welcome"
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.cursorline = false
		vim.wo.signcolumn = "no"

		local function map(key, action, desc)
			vim.keymap.set("n", key, action, { buffer = buf, desc = desc, silent = true })
		end
		map("f", fzf.files, "Find file")
		map("n", vim.cmd.enew, "New file")
		map("g", fzf.live_grep, "Find text")
		map("r", fzf.oldfiles, "Recent files")
		map("c", function()
			fzf.files({ cwd = vim.fn.stdpath("config") })
		end, "Config")
		map("s", function()
			if vim.fn.filereadable(session) == 1 then
				vim.cmd.source(vim.fn.fnameescape(session))
			else
				vim.notify("No saved session", vim.log.levels.WARN)
			end
		end, "Restore session")
		map("q", vim.cmd.quitall, "Quit")
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("lean_welcome", { clear = true }),
	callback = function()
		if vim.fn.argc() == 0 then
			show_welcome()
		end
	end,
})

vim.keymap.set("n", "<leader>h", function()
	vim.cmd.enew()
	show_welcome()
end, { desc = "Welcome" })
