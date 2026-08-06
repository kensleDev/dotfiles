require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	integrations = { gitsigns = true, native_lsp = { enabled = true } },
})
vim.cmd.colorscheme("catppuccin")

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 22
vim.g.netrw_browse_split = 0
vim.g.netrw_altfile = 1

vim.keymap.set("n", "<leader>e", "<cmd>Lexplore!<cr>", {
	desc = "Explorer",
})

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
	vim.fn.jobstart(command, {
		term = true,
		on_exit = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})
	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Yazi", function()
	floating_terminal({ "yazi" })
end, {})
vim.api.nvim_create_user_command("Lazyworktree", function()
	floating_terminal({ "lazyworktree" })
end, {})
vim.keymap.set("n", "<leader>fy", "<cmd>Yazi<cr>", { desc = "Yazi" })
vim.keymap.set("n", "<leader>gw", "<cmd>Lazyworktree<cr>", { desc = "Lazyworktree" })

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("lean_welcome", { clear = true }),
	callback = function()
		if vim.fn.argc() ~= 0 then
			return
		end

		local buf = vim.api.nvim_get_current_buf()
		local fzf = require("fzf-lua")
		local session = vim.fn.stdpath("state") .. "/sessions/default.vim"
		local lines = {
			"",
			"  Julian's Neovim",
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
	end,
})
