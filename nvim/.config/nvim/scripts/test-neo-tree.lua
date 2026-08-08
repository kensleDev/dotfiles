local function tree_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
			return true
		end
	end
end

local function invoke(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "mx", false)
	assert(vim.wait(500, tree_open), keys .. " did not open Neo-tree")
	vim.cmd("Neotree close")
end

vim.cmd("edit lua/config/ui.lua")
invoke("<Space>fe")
invoke("<Space>fE")
invoke("<Space>ge")
invoke("<Space>be")
vim.cmd("edit .")
assert(vim.wait(500, tree_open), "directory edit did not open Neo-tree")
assert(require("neo-tree").config.window.position == "right", "Neo-tree is not configured on the right")
