# Research: Neovim Performance Optimization

**Date:** 2026-02-13  
**Confidence:** High

---

## Summary

This research covers comprehensive Neovim performance optimization techniques including built-in profiling tools, large file handling strategies, benchmarking approaches, and common performance optimizations for Treesitter, LSP, and plugins.

---

## 1. Neovim Built-in Profiling Tools

### 1.1 `--startuptime` Flag

The simplest way to profile Neovim startup performance.

**Usage:**
```bash
# Basic usage
nvim --startuptime /tmp/nvim-startup.log

# Open specific file
nvim --startuptime /tmp/nvim-startup.log myfile.lua

# With clean config
nvim -u NONE --startuptime /tmp/nvim-clean.log
```

**Output Format:**
```
times in msec
 clock   self+sourced   self:  sourced script
 clock   elapsed:              other lines
```

**Key metrics to look for:**
- Slowest scripts (sort by self time)
- Plugin loading overhead
- Config file processing time

### 1.2 `:profile` Command (Built-in Profiler)

For detailed function-level profiling of Vimscript/Lua.

**Usage:**
```vim
" Start profiling
:profile start /tmp/nvim-profile.log

" Profile specific function
:profile func MyFunction

" Profile all functions in a file
:profile file *.lua

" Profile file and all functions defined in it
:profile! file ~/.config/nvim/init.lua

" Pause/resume profiling
:profile pause
:profile continue

" Dump current profiling data
:profile dump

" Stop profiling
:profile stop
```

**Profile Output Example:**
```
FUNCTION Test2()
Called 1 time
Total time: 0.155251
Self time: 0.002006

count  total (s)   self (s)
    9   0.000096   for i in range(8)
    8   0.153655   0.000410   call Test3()
    8   0.000070   endfor
```

**Key options:**
- `:profile func {pattern}` - Profile functions matching pattern
- `:profile file {pattern}` - Profile scripts matching pattern
- `:profile! file {pattern}` - Profile script AND all functions defined in it

### 1.3 `vim.loop.hrtime()` for Micro-benchmarks

High-resolution timer for precise measurements in Lua.

**Usage:**
```lua
-- Simple benchmark
local start = vim.loop.hrtime()
-- ... code to benchmark ...
local elapsed = vim.loop.hrtime() - start
print(string.format("Elapsed: %.3f ms", elapsed / 1e6))

-- Benchmark helper function
local function bench(name, fn, iterations)
  iterations = iterations or 1
  local start = vim.loop.hrtime()
  for _ = 1, iterations do
    fn()
  end
  local elapsed = (vim.loop.hrtime() - start) / 1e6
  print(string.format("%s: %.3f ms (%.3f ms/iter)", name, elapsed, elapsed / iterations))
  return elapsed
end

-- Usage example
bench("Load module", function()
  require("some_module")
end, 100)
```

**Practical Example - Benchmarking File Opening:**
```lua
vim.api.nvim_create_user_command("BenchFileOpen", function(opts)
  local file = opts.args
  local iterations = 10
  local times = {}
  
  for i = 1, iterations do
    -- Clean up
    vim.cmd("bwipe!")
    
    local start = vim.loop.hrtime()
    vim.cmd("edit " .. file)
    local elapsed = (vim.loop.hrtime() - start) / 1e6
    table.insert(times, elapsed)
  end
  
  local sum = 0
  for _, t in ipairs(times) do sum = sum + t end
  print(string.format("Average: %.2f ms over %d runs", sum / iterations, iterations))
end, { nargs = 1 })
```

### 1.4 LuaJIT Profiler (if available)

When Nvim is built with LuaJIT, you can use its built-in profiler:

```lua
-- Start profiling
require('jit.p').start('ri1', '/tmp/profile')

-- Perform operations...

-- Stop and write profile
require('jit.p').stop()
```

**Profile options:**
- `r` - Show raw bytecode counts
- `i1` - Show bytecode instruction counts
- `l` - Show line information

### 1.5 `:Lazy profile` (Lazy.nvim)

Lazy.nvim provides built-in profiling for plugin loading.

**Usage:**
```lua
-- In Neovim command mode
:Lazy profile

-- Programmatic access
require("lazy").profile()
```

**Stats API:**
```lua
local stats = require("lazy").stats()
-- Returns:
-- {
--   startuptime = 0,        -- ms until UIEnter
--   real_cputime = false,   -- true on Linux/macOS for accurate CPU time
--   count = 0,              -- total plugins
--   loaded = 0,             -- loaded plugins
--   times = {},             -- per-plugin load times
-- }
```

**Configuration for extra profiling:**
```lua
require("lazy").setup({
  -- ... plugins ...
}, {
  profiling = {
    loader = false,  -- Enable extra stats for loader cache
    require = false, -- Track each new require() call
  },
})
```

---

## 2. Large File Handling Optimizations

### 2.1 Snacks.nvim Bigfile (LazyVim Built-in)

LazyVim uses `snacks.nvim` for large file handling.

**Default Configuration:**
```lua
-- snacks.nvim/lua/snacks/bigfile.lua
{
  notify = true,           -- Show notification when big file detected
  size = 1.5 * 1024 * 1024, -- 1.5MB threshold
  line_length = 1000,       -- Average line length (for minified files)
  
  setup = function(ctx)
    -- Disable matchparen if available
    if vim.fn.exists(":NoMatchParen") ~= 0 then
      vim.cmd([[NoMatchParen]])
    end
    
    -- Disable foldmethod, statuscolumn, conceal
    Snacks.util.wo(0, { 
      foldmethod = "manual", 
      statuscolumn = "", 
      conceallevel = 0 
    })
    
    -- Disable completion and animations
    vim.b.completion = false
    vim.b.minianimate_disable = true
    vim.b.minihipatterns_disable = true
    
    -- Use basic syntax highlighting
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ctx.buf) then
        vim.bo[ctx.buf].syntax = ctx.ft
      end
    end)
  end,
}
```

**Custom Configuration:**
```lua
-- In your LazyVim config
return {
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = {
        enabled = true,
        size = 5 * 1024 * 1024, -- 5MB
        notify = true,
        setup = function(ctx)
          -- Custom disable logic
          vim.treesitter.stop(ctx.buf)
          vim.b[ctx.buf].ts_highlight = false
        end,
      },
    },
  },
}
```

### 2.2 Alternative Plugins for Large Files

**vim-large-file:**
```lua
{
  "LunarWatcher/vim-large-file",
  config = function()
    vim.g.large_file = {
      size_mb = 5,
      pattern = "*.log,*.json",
    }
  end,
}
```

**bigfile.nvim:**
```lua
{
  "jatap/bigfile.nvim",
  config = function()
    require("bigfile").setup({
      filesize = 2, -- MB
      pattern = { "*" },
      features = {
        "lsp",
        "treesitter", 
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
      },
    })
  end,
}
```

### 2.3 Manual Large File Handling

**Autocommand approach:**
```lua
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local filesize = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if filesize > 1024 * 1024 then -- 1MB
      vim.b.bigfile = true
      vim.cmd("syntax off")
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
    end
  end,
})
```

### 2.4 Settings to Disable for Large Files

| Feature | Setting/Command | Impact |
|---------|-----------------|--------|
| Treesitter | `vim.treesitter.stop(buf)` | High |
| LSP | `vim.lsp.buf_detach_client()` | High |
| Match Paren | `:NoMatchParen` | Medium |
| Folding | `foldmethod = "manual"` | High |
| Conceal | `conceallevel = 0` | Medium |
| Indent Blankline | Disable per buffer | Medium |
| Swap File | `swapfile = false` | Low |
| Undo File | `undofile = false` | Low |
| Syntax | `syntax off` or manual | High |
| Statuscolumn | Clear complex statuscolumn | Medium |

---

## 3. Benchmarking Approaches

### 3.1 Automated Startup Benchmarks

**Shell Script Benchmark:**
```bash
#!/bin/bash
# benchmark-nvim.sh

ITERATIONS=10
LOG_FILE="/tmp/nvim-benchmark.log"

echo "Benchmarking Neovim startup..." > "$LOG_FILE"
echo "Iterations: $ITERATIONS" >> "$LOG_FILE"
echo "========================" >> "$LOG_FILE"

for i in $(seq 1 $ITERATIONS); do
  echo "Run $i..."
  nvim --startuptime /tmp/nvim-startup-$i.log \
       -c "qa!" \
       2>/dev/null
  
  # Extract total time
  tail -1 /tmp/nvim-startup-$i.log >> "$LOG_FILE"
done

echo "Results saved to $LOG_FILE"
```

### 3.2 Using Hyperfine (Statistical Benchmarking)

**Installation:**
```bash
# Arch Linux
sudo pacman -S hyperfine

# Ubuntu/Debian
sudo apt install hyperfine

# Cargo (Rust)
cargo install hyperfine
```

**Usage:**
```bash
# Basic benchmark
hyperfine 'nvim -c "qa!"'

# Multiple configurations
hyperfine \
  'nvim -c "qa!"' \
  'nvim -u NONE -c "qa!"' \
  'nvim --clean -c "qa!"'

# With warmup and more runs
hyperfine --warmup 3 --runs 20 'nvim -c "qa!"'

# Export results
hyperfine --export-markdown benchmark.md 'nvim -c "qa!"'
hyperfine --export-json benchmark.json 'nvim -c "qa!"'

# Benchmark file opening
hyperfine 'nvim large_file.json -c "qa!"'

# Compare with different configs
hyperfine \
  -n "Default Config" 'nvim -c "qa!"' \
  -n "No Plugins" 'nvim -u NONE -c "qa!"' \
  -n "Clean" 'nvim --clean -c "qa!"'
```

### 3.3 Benchmarking Specific File Opening

**Lua Benchmark Script:**
```lua
-- Save as benchmark-file.lua
local file = arg[1] or vim.fn.expand("%")
local iterations = tonumber(arg[2]) or 10

local times = {}
for i = 1, iterations do
  vim.cmd("bwipeall!")
  collectgarbage("collect")
  
  local start = vim.loop.hrtime()
  vim.cmd("edit " .. file)
  vim.cmd("redraw")
  local elapsed = (vim.loop.hrtime() - start) / 1e6
  
  table.insert(times, elapsed)
  print(string.format("Run %d: %.2f ms", i, elapsed))
end

table.sort(times)
local median = times[math.ceil(#times / 2)]
local sum = 0
for _, t in ipairs(times) do sum = sum + t end

print("\n=== Results ===")
print(string.format("Min: %.2f ms", times[1]))
print(string.format("Max: %.2f ms", times[#times]))
print(string.format("Median: %.2f ms", median))
print(string.format("Average: %.2f ms", sum / #times))
```

**Run with:**
```bash
nvim -l benchmark-file.lua myfile.lua 20
```

### 3.4 Plugin Load Time Analysis

```lua
-- Analyze lazy.nvim load times
local stats = require("lazy").stats()

print("=== Plugin Load Times ===")
print(string.format("Total startup: %.2f ms", stats.startuptime))
print(string.format("Plugins loaded: %d/%d", stats.loaded, stats.count))

-- Sort by load time
local sorted = {}
for name, time in pairs(stats.times) do
  table.insert(sorted, { name = name, time = time })
end
table.sort(sorted, function(a, b) return a.time > b.time end)

print("\n=== Slowest Plugins ===")
for i, plugin in ipairs(sorted) do
  if i > 10 then break end
  print(string.format("%2d. %-30s %.2f ms", i, plugin.name, plugin.time))
end
```

---

## 4. Common Neovim Performance Optimizations

### 4.1 Treesitter Optimizations

**Disable for specific filetypes:**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "bigfile", "log", "json" },
  callback = function()
    vim.treesitter.stop()
  end,
})
```

**Limit injection queries (can be slow):**
```lua
-- Disable injection queries for large files
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local size = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if size > 500000 then -- 500KB
      vim.treesitter.stop()
    end
  end,
})
```

**Treesitter configuration:**
```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- Only install needed parsers
    ensure_installed = { "lua", "vim", "vimdoc" },
    
    -- Disable slow modules
    highlight = { enable = true },
    indent = { enable = true },
    
    -- Disable slow features
    incremental_selection = { enable = false },
    textobjects = { enable = false },
  },
}
```

### 4.2 LSP Optimizations

**Lazy load LSP:**
```lua
{
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  -- Not on VeryLazy to ensure LSP is ready when needed
}
```

**Disable LSP for large files:**
```lua
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local size = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if size > 1024 * 1024 then -- 1MB
      vim.b.lsp_enabled = false
    end
  end,
})
```

**Limit LSP capabilities:**
```lua
-- Reduce diagnostic frequency
vim.diagnostic.config({
  update_in_insert = false,  -- Don't update in insert mode
  virtual_text = false,      -- Disable virtual text for performance
})
```

### 4.3 Lazy.nvim Performance Settings

```lua
require("lazy").setup({
  -- ... plugins ...
}, {
  performance = {
    cache = {
      enabled = true,  -- Enable module caching
    },
    reset_packpath = true,  -- Reset packpath for cleaner startup
    rtp = {
      reset = true,  -- Reset runtime path
      paths = {},    -- Additional paths
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",  -- Keep if you use it
        "netrwPlugin", -- Keep if you use netrw
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

### 4.4 Plugin-Specific Optimizations

**nvim-cmp:**
```lua
{
  "hrsh7th/nvim-cmp",
  opts = {
    completion = {
      autocomplete = false,  -- Manual trigger only
    },
    performance = {
      debounce = 150,
      throttle = 150,
    },
  },
}
```

**indent-blankline:**
```lua
{
  "lukas-reineke/indent-blankline.nvim",
  opts = {
    enabled = true,
    debounce = 200,  -- Increase debounce
    viewport_buffer = {
      min = 10,
      max = 50,  -- Reduce viewport buffer
    },
  },
}
```

**Telescope:**
```lua
{
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        "dist/",
        "build/",
      },
    },
  },
}
```

### 4.5 General Vim Options

```lua
-- Faster completion
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10  -- Limit popup height

-- Faster redrawing
vim.opt.redrawtime = 1500  -- Default 2000ms
vim.opt.timeoutlen = 300   -- Faster key sequence completion
vim.opt.ttimeoutlen = 10   -- Faster key code timeout

-- Reduce swap/undo for large files
vim.opt.updatecount = 100  -- Write swap less frequently
vim.opt.updatetime = 250   -- Faster CursorHold

-- Disable unnecessary features
vim.opt.synmaxcol = 300    -- Don't syntax highlight long lines
```

---

## 5. Quick Reference Commands

| Purpose | Command |
|---------|---------|
| Profile startup | `nvim --startuptime /tmp/nvim.log` |
| Profile functions | `:profile start /tmp/prof.log` + `:profile func *` |
| Lazy profile | `:Lazy profile` |
| Check stats | `:lua print(vim.inspect(require("lazy").stats()))` |
| Clean startup | `nvim --clean` |
| No config | `nvim -u NONE` |
| Benchmark with hyperfine | `hyperfine 'nvim -c qa!'` |
| Disable treesitter | `:TSDisable highlight` |
| Check startup time | `:StartupTime` (if vim-startuptime installed) |

---

## Sources

1. **Neovim Documentation**
   - https://neovim.io/doc/user/starting.html (--startuptime, initialization)
   - https://neovim.io/doc/user/lua.html (vim.loop.hrtime, LuaJIT profiler)
   - https://neovim.io/doc/user/repeat.html (:profile command)
   - https://neovim.io/doc/user/treesitter.html (Treesitter configuration)

2. **Lazy.nvim Documentation**
   - https://github.com/folke/lazy.nvim (profiling, performance settings, stats API)

3. **LazyVim Documentation**
   - https://github.com/LazyVim/LazyVim (configuration, snacks.nvim)

4. **Snacks.nvim Source**
   - snacks.nvim/lua/snacks/bigfile.lua (large file handling implementation)

---

## Next Steps

1. [ ] Implement bigfile configuration if handling large files frequently
2. [ ] Add hyperfine benchmarking script for startup comparison
3. [ ] Profile current config with `nvim --startuptime` to identify slow plugins
4. [ ] Review lazy.nvim stats to find slowest loading plugins
5. [ ] Consider lazy-loading strategies for rarely used plugins
