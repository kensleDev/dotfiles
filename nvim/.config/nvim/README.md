# Julian's lean Neovim 0.12 configuration

This is a purpose-built replacement for the LazyVim configuration in
`kensledev/dotfiles`. It keeps the unusual movement layout,
tmux navigation, remote clipboard, fuzzy finding, Git signs, formatting,
Treesitter and the language coverage from the enabled LazyVim extras, while
cutting the managed plugin set from 51 to 13.

## What remains a plugin

| Plugin                 | Why it stays                                                        |
| ---------------------- | ------------------------------------------------------------------- |
| `catppuccin`           | The existing colour scheme                                          |
| `fzf-lua`              | Fast `.gitignore`-aware files, grep, buffers, symbols and keymaps   |
| `nvim-treesitter`      | Parser/query installation for modern highlighting                   |
| `conform.nvim`         | Reliable format-on-save and formatter fallback                      |
| `gitsigns.nvim`        | Inline Git state and hunk actions                                   |
| `flash.nvim`           | Fast native jump and search motions                                 |
| `render-markdown.nvim` | The existing rendered Markdown workflow                             |
| `which-key.nvim`       | The existing modern mapping-discovery popup                         |
| `mason.nvim`           | Installs language-server executables inside Neovim's data directory |
| `mason-lspconfig.nvim` | Automatically installs and enables the configured servers           |
| `nvim-lspconfig`       | Maintained server definitions for native Neovim LSP                 |
| `mini.pairs`           | Smart insertion of matching quotes and brackets                     |
| `wrapwidth`            | Visual wrapping toggle for selected code buffers                    |

Native Neovim replaces Lazy.nvim/LazyVim, Blink, Neo-tree,
Lualine, Trouble, persistence, vim-oscyank, tmux-navigation and the
external-TUI wrapper.

## Install

### Automated Ubuntu prerequisites

The included idempotent bootstrap installs the compiler toolchain, Clang and
libclang, Git, ripgrep, fzf, Node/npm, Python, Rustup/Cargo and
`tree-sitter-cli`. It also checks
that the `nvim` resolved from your PATH is version 0.12 or newer:

```sh
chmod +x scripts/bootstrap-ubuntu.sh
./scripts/bootstrap-ubuntu.sh
```

Package installation is non-interactive, although Ubuntu may ask for your
`sudo` password once. It is safe to run the script again when updating or
repairing the toolchain. Neovim itself remains managed by Bob and is therefore
verified rather than installed by this script.

### Link the configuration

Back up the current config, then link or copy this directory:

```sh
mv ~/.config/nvim ~/.config/nvim.lazyvim-backup
ln -s /path/to/lean-nvim ~/.config/nvim
nvim
```

The first launch installs the thirteen plugins, configured language servers and
Treesitter parsers. Neovim
0.12, Git, `rg`, `fzf`, a C compiler, `tar`, `curl`, and tree-sitter-cli 0.26.1+
must already be available.

Useful maintenance commands:

```vim
:lua vim.pack.update()
:TSUpdate
:checkhealth
```

Commit the generated `nvim-pack-lock.json` beside `init.lua` once the setup is
working. That makes installs reproducible.

## Language tools

Mason automatically installs and enables the language servers listed in
`lua/config/lsp.lua`. Use `:Mason` to inspect their state, `:MasonUpdate` to
refresh the registry and `:LspInfo` or `:checkhealth vim.lsp` to inspect the
server attached to the current buffer.

Formatters and standalone tools are still external. Install the ones you use:
`prettier`, `stylua`, `csharpier`, `shfmt`, `lazyworktree`. Conform falls back to LSP formatting when an external formatter is
not available.

## Important mappings retained

| Mapping                               | Action                                   |
| ------------------------------------- | ---------------------------------------- |
| `j / k / l / ;`                       | left / down / up / right                 |
| `h`                                   | original `;` motion                      |
| `Alt-m/,/./`                          | move across Neovim splits and tmux panes |
| `<leader>p`, `<leader>/`              | files, live grep                         |
| `<leader>P`, `<leader>fc`              | recent files, config files              |
| `<leader>fk`                           | filterable keymap list                   |
| `<leader>e`                           | native explorer                          |
| `<leader>d`                           | diagnostics in quickfix                  |
| `<leader>cf`                          | format                                   |
| `<leader>tw`                          | toggle 100-column visual wrapping        |
| `<leader>gw`                          | Lazyworktree float                       |
| `<leader>ss`, `<leader>sl`            | save/load the default native session     |

## Intentional differences from LazyVim

- Native completion is LSP-only. It does not complete buffer words, paths,
  snippets or Copilot suggestions. Add Blink only if that becomes limiting.
- Netrw replaces Neo-tree. Git and buffer views are available through fzf-lua.
- Diagnostics use quickfix rather than Trouble.
- Mason manages language servers; project compilers, formatters and CLIs remain
  normal system or project dependencies.
- Copilot, Copilot Chat, Dadbod and CMake UI are omitted. Their language/server
  support remains, but add the UI plugins back only if you genuinely miss them.
