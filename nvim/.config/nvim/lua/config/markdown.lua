require("render-markdown").setup({
  file_types = { "markdown" },
  heading = { enabled = true, sign = false },
  code = { enabled = true, sign = false, border = "thin" },
})

local parsers = {
  "bash", "c", "c_sharp", "cmake", "comment", "css", "diff", "dockerfile",
  "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
  "html", "javascript", "json", "json5", "lua", "luadoc", "markdown",
  "markdown_inline", "query", "regex", "rust", "scss", "svelte", "toml",
  "tsx", "typescript", "vim", "vimdoc", "xml", "yaml",
}
if not vim.g.lean_skip_parser_install then
  vim.schedule(function() require("nvim-treesitter").install(parsers) end)
end
