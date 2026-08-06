vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.fn.has("nvim-0.12") ~= 1 then
	error("This configuration requires Neovim 0.12 or newer")
end

require("config.options")
require("config.plugins")
require("config.autocmds")
require("config.keymaps")
require("config.ui")
require("config.lsp")
require("config.formatting")
require("config.pickers")
require("config.git")
require("config.markdown")
require("config.whichkey")
require("config.flash")
