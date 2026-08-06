local fzf = require("fzf-lua")
fzf.setup({
	winopts = { border = "rounded", preview = { layout = "horizontal", horizontal = "right:50%" } },
	files = { rg_opts = "--color=never --files --hidden --follow -g '!.git'" },
})

vim.keymap.set("n", "<leader>p", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>P", fzf.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fg", fzf.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
