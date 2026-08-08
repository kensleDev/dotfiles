local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.laststatus = 3
opt.cmdheight = 0
opt.showmode = false

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git"
opt.grepformat = "%f:%l:%c:%m"

opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.showbreak = "⤷ "
opt.scrolloff = 5
opt.sidescrolloff = 5

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.list = true
opt.listchars = { tab = " ┊", leadtab = " ┊", leadmultispace = " ┊" }

opt.undofile = true
opt.swapfile = false
opt.autoread = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.ttimeoutlen = 10
opt.completeopt = { "menu", "menuone", "noselect", "fuzzy", "popup" }
opt.pumborder = "rounded"
opt.winborder = "rounded"
opt.autocomplete = true

opt.splitbelow = true
opt.splitright = true
opt.confirm = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Native OSC52 clipboard for SSH/tmux sessions. Local sessions continue to use
-- the platform clipboard provider discovered by :checkhealth.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end
