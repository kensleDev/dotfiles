local fzf = require("fzf-lua")
fzf.setup({
	winopts = { border = "rounded", preview = { layout = "horizontal", horizontal = "right:50%" } },
	files = { rg_opts = "--color=never --files --hidden --follow -g '!.git'" },
})

vim.keymap.set("n", "<leader>p", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>P", fzf.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fc", function()
    fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Config files" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fg", fzf.git_status, { desc = "Git status" })
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })

local function keymaps()
    local entries, seen = {}, {}
    local function clean(value)
        return tostring(value or ""):gsub("%s+", " ")
    end
    local function source_name(source)
        local config = vim.fn.stdpath("config") .. "/"
        if source.path:sub(1, #config) == config then
            return source.path:sub(#config + 1)
        end
        if source.path:sub(1, 1) == "[" then
            return source.path
        end
        return vim.fn.fnamemodify(source.path, ":h:t") .. "/" .. vim.fn.fnamemodify(source.path, ":t")
    end
    local function add(mode, map)
        local map_mode = map.mode or mode
        local id = table.concat({ map.buffer, map_mode, map.lhs }, "\0")
        if seen[id] then
            return
        end
        seen[id] = true
        local key = vim.api.nvim_replace_termcodes(map.lhs, true, true, true)
        local source = vim._lean_keymap_sources[table.concat({ map_mode, key, map.buffer }, "\0")]
        local location = source
                and string.format("%s:%s", source_name(source), source.line)
            or (map.sid and map.sid < 0 and "[built-in]" or "[unknown]")
        local detail = map.desc or map.rhs or (map.callback and "<Lua callback>") or "<no description>"
        table.insert(entries, string.format("%-2s %-18s %-28s %s", map_mode, map.lhs:gsub("%s", "<Space>"), location, clean(detail)))
    end

    for _, mode in ipairs({ "n", "i", "c", "v", "x", "s", "o", "t" }) do
        for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
            add(mode, map)
        end
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
            add(mode, map)
        end
    end

    table.sort(entries)
    table.insert(entries, 1, string.format("%-2s %-18s %-28s %s", "M", "Key", "Source", "What it does"))
    fzf.fzf_exec(entries, {
        prompt = "Keymaps> ",
        fzf_opts = { ["--header-lines"] = "1" },
        winopts = { width = 0.95 },
    })
end

vim.keymap.set("n", "<leader>fk", keymaps, { desc = "Keymaps" })
