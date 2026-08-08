local flash = require("flash")

flash.setup({})

vim.keymap.set({ "n", "x", "o" }, "s", function()
  flash.jump()
end, {
  desc = "Flash jump",
})

vim.keymap.set({ "n", "x", "o" }, "S", function()
  flash.treesitter()
end, {
  desc = "Flash Treesitter",
})
