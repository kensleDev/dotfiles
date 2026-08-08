vim.g.mapleader = " "
vim.g.maplocalleader = " "

if not vim._lean_keymap_sources then
	local keymap_set = vim.keymap.set
	vim._lean_keymap_sources = {}
	vim.keymap.set = function(mode, lhs, rhs, opts)
		local info = debug.getinfo(2, "Sl")
		local source = info and info.source or ""
		if source:sub(1, 1) == "@" then
			source = source:sub(2)
		end
		local buffer = type(opts) == "table" and opts.buffer or 0
		buffer = buffer == true and vim.api.nvim_get_current_buf() or buffer
		buffer = type(buffer) == "number" and buffer or 0
		local modes = mode == "!" and { "i", "c" } or type(mode) == "table" and mode or { mode }
		for _, map_mode in ipairs(modes) do
			local key = vim.api.nvim_replace_termcodes(lhs, true, true, true)
			vim._lean_keymap_sources[table.concat({ map_mode, key, buffer }, "\0")] = {
				path = source,
				line = info and info.currentline,
			}
		end
		return keymap_set(mode, lhs, rhs, opts)
	end
end

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
