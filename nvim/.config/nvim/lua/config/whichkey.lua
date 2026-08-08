local which_key = require("which-key")

which_key.setup({
  preset = "helix",
  delay = 250,
  filter = function(mapping)
    return mapping.desc and mapping.desc ~= ""
  end,
  spec = {
    { "<leader>b", group = "buffers" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "find / files" },
    { "<leader>g", group = "git / tools" },
    { "<leader>h", group = "Git hunks" },
    { "<leader>q", group = "quit / cleanup" },
    { "<leader>s", group = "search / sessions" },
  },
})

vim.keymap.set("n", "<leader><leader>", function()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd("wincmd h")
  end
end, { desc = "WhichKey" })
