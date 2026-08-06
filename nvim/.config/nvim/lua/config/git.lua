require("gitsigns").setup({
  current_line_blame = false,
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc }) end
    map("]h", gs.next_hunk, "Next Git hunk")
    map("[h", gs.prev_hunk, "Previous Git hunk")
    map("<leader>hp", gs.preview_hunk, "Preview hunk")
    map("<leader>hs", gs.stage_hunk, "Stage hunk")
    map("<leader>hr", gs.reset_hunk, "Reset hunk")
    map("<leader>hb", gs.blame_line, "Blame line")
  end,
})

