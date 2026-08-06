local set = vim.keymap.set
local silent = { silent = true }

vim.g.neovide_input_macos_option_key_is_meta = true

-- Preserve Julian's j/k/l/; movement layout and move the original ; to h.
for _, mode in ipairs({ "n", "x" }) do
	set(mode, ";", "l", silent)
	set(mode, "l", "k", silent)
	set(mode, "k", "j", silent)
	set(mode, "j", "h", silent)
	set(mode, "h", ";", silent)
end

set("n", "<M-p>", "G", silent)
set("n", "<M-u>", "gg", silent)
set("n", "<M-i>", "<C-d>", silent)
set("n", "<M-o>", "<C-u>", silent)

set("i", "jj", "<Esc>", silent)
set("i", "jk", "<Esc><C-w>w", silent)
set("t", "jj", [[<C-\><C-n>]], silent)
set("t", "jk", [[<C-\><C-n><C-w>w]], silent)

set("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
set("n", "<leader>m", "<cmd>bnext<cr>", { desc = "Next buffer" })
set("n", "<leader>n", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
set("n", "U", "<C-r>", { desc = "Redo" })
set("x", "<leader>;", [['_dP]], { desc = "Paste without replacing register" })
set("n", "+", "<C-a>", { desc = "Increment number" })
set("n", "-", "<C-x>", { desc = "Decrement number" })

set("n", "ya", function()
	local cursor = vim.api.nvim_win_get_cursor(0)
	vim.cmd.normal({ "ggVGy", bang = true })
	vim.api.nvim_win_set_cursor(0, cursor)
end, { desc = "Yank entire document" })

set("n", "<leader>qr", function()
	vim.cmd([[silent! %s/\t/  /g]])
end, { desc = "Replace tabs with spaces" })

set("n", "<leader>d", function()
	vim.diagnostic.setqflist()
	vim.cmd.copen()
end, { desc = "Diagnostics (quickfix)" })

set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "Undo tree" })
set("n", "<leader>ss", function()
	local dir = vim.fn.stdpath("state") .. "/sessions"
	vim.fn.mkdir(dir, "p")
	vim.cmd.mksession({ args = { dir .. "/default.vim" }, bang = true })
	vim.notify("Session saved")
end, { desc = "Save session" })
set("n", "<leader>sl", function()
	vim.cmd.source(vim.fn.stdpath("state") .. "/sessions/default.vim")
end, { desc = "Load session" })

local function tmux_navigate(direction, tmux_flag)
	local before = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. direction)
	if vim.api.nvim_get_current_win() == before and vim.env.TMUX then
		vim.system({ "tmux", "select-pane", tmux_flag }, { detach = true })
	end
end

set("n", "<M-m>", function()
	tmux_navigate("h", "-L")
end, { desc = "Split/tmux left" })
set("n", "<M-,>", function()
	tmux_navigate("j", "-D")
end, { desc = "Split/tmux down" })
set("n", "<M-.>", function()
	tmux_navigate("k", "-U")
end, { desc = "Split/tmux up" })
set("n", "<M-/>", function()
	tmux_navigate("l", "-R")
end, { desc = "Split/tmux right" })
