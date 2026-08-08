require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier", stop_after_first = true },
    javascriptreact = { "prettier", stop_after_first = true },
    typescript = { "prettier", stop_after_first = true },
    typescriptreact = { "prettier", stop_after_first = true },
    svelte = { "prettier", stop_after_first = true },
    json = { "prettier", stop_after_first = true },
    jsonc = { "prettier", stop_after_first = true },
    yaml = { "prettier", stop_after_first = true },
    markdown = { "prettier", stop_after_first = true },
    css = { "prettier", stop_after_first = true },
    scss = { "prettier", stop_after_first = true },
    html = { "prettier", stop_after_first = true },
    cs = { "csharpier", stop_after_first = true },
    rust = { "rustfmt" },
    sh = { "shfmt" },
  },
  format_on_save = function(bufnr)
    if vim.b[bufnr].bigfile then return end
    return { timeout_ms = 1500, lsp_format = "fallback" }
  end,
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })

