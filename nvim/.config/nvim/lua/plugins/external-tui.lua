return {
  {
    "gfontenot/nvim-external-tui",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal_provider = {
        snacks = {
          win = {
            style = "float",
            width = 0.9,
            height = 0.9,
            backdrop = 60,
          },
        },
      },
    },
    config = function(_, opts)
      local external_tui = require("external-tui")
      external_tui.setup(opts)
      external_tui.add({
        user_cmd = "Yazi",
        cmd = "yazi",
      })
      external_tui.add({
        user_cmd = "Lazyworktree",
        cmd = "lazyworktree",
      })
    end,
    keys = {
      { "<leader>fy", "<cmd>Yazi<cr>", desc = "Yazi File Manager" },
      { "<leader>gw", "<cmd>Lazyworktree<cr>", desc = "Lazyworktree" },
    },
  },
}
