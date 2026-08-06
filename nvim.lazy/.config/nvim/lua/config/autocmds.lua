-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Performance: Disable treesitter for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "log", "json", "yaml" },
  callback = function()
    pcall(vim.treesitter.stop)
  end,
  desc = "Disable treesitter for large file types",
})

-- Performance: Optimize large files (>2MB)
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local filepath = vim.fn.expand("<afile>:p")
    local ok, stats = pcall(vim.uv.fs_stat, filepath)
    if ok and stats and stats.size > 2 * 1024 * 1024 then
      vim.b.bigfile = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.foldenable = false
      vim.opt_local.swapfile = false
      vim.opt_local.list = false
    end
  end,
  desc = "Optimize settings for large files",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.b.bigfile then
      pcall(vim.treesitter.stop)
    end
  end,
  desc = "Disable treesitter for large files",
})
