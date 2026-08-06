local group = vim.api.nvim_create_augroup("lean_nvim", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  desc = "Save the default session on exit",
  callback = function()
    local dir = vim.fn.stdpath("state") .. "/sessions"
    vim.fn.mkdir(dir, "p")
    pcall(vim.cmd.mksession, { args = { dir .. "/default.vim" }, bang = true })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Restore the last cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  group = group,
  desc = "Reduce work for files larger than 2 MiB",
  callback = function(args)
    local stat = vim.uv.fs_stat(args.file)
    if stat and stat.size > 2 * 1024 * 1024 then
      vim.b[args.buf].bigfile = true
      vim.bo[args.buf].swapfile = false
      vim.bo[args.buf].undofile = false
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "*",
  desc = "Start Treesitter where a parser exists",
  callback = function(args)
    if vim.b[args.buf].bigfile then return end
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "cs", "rust" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "101"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "json", "yaml", "markdown" },
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "81"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "typescript", "typescriptreact", "svelte" },
  desc = "Visually wrap code at 100 columns",
  callback = function(args)
    vim.opt_local.colorcolumn = "101"

    local function set_wrap(enabled)
      vim.opt_local.wrap = enabled
      vim.cmd("Wrapwidth " .. (enabled and 100 or 0))
      vim.b[args.buf].wrapwidth_enabled = enabled
    end

    set_wrap(true)
    vim.keymap.set("n", "<leader>tw", function()
      set_wrap(not vim.b[args.buf].wrapwidth_enabled)
    end, { buffer = args.buf, desc = "Toggle 100-column wrap" })
  end,
})
