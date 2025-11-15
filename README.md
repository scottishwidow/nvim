# Neovim + LazyVim configuration

Personal Neovim config that layers a handful of opinionated tweaks on top of [LazyVim](https://lazyvim.org). It lives in `~/.config/nvim` and bootstraps LazyVim with the Solarized Osaka colorscheme, Helm extra modules, TypeScript improvements, and formatter/language tweaks for Terraform/HCL-heavy workflows.

## Highlights

- LazyVim 15.x with Snacks, blink.cmp, solarized-osaka theme, and newsletter/news integration
- Language support for Helm charts, Terraform/HCL, TypeScript/JavaScript (via `vtsls`), YAML schema completion
- Auto-formatting powered by `conform.nvim` and tree-sitter installations for the languages above
- Quality-of-life keymaps for resizing windows, buffer management, and quick “select all”
- Optional clipboard bridge for WSL that mirrors the Windows clipboard when `clip.exe`/`powershell.exe` are available

## Requirements & dependencies

| Need | Why |
| ---- | --- |
| Neovim ≥ 0.11.2 | LazyVim hard-requirement (`lazyvim/plugins/init.lua`) |
| `git`, `curl` | bootstrap `lazy.nvim` & install plugins |
| `rg` (ripgrep) | leveraged by Telescope/Snacks pickers |
| `terraform`, `packer` CLIs | required by `conform.nvim` formatters for Terraform + Packer |
| `clip.exe`, `powershell.exe` (optional) | only necessary if you want the WSL clipboard bridge from `lua/config/options.lua` |

## Repository layout

```
init.lua                  -- bootstraps lazy.nvim
lua/config/               -- lazy, options, keymaps, lsp tweaks
lua/plugins/              -- user plugin specs (colorscheme, conform, treesitter)
lazy-lock.json            -- pinned plugin commits
lazyvim.json              -- LazyVim extras metadata
stylua.toml               -- formatting config for Lua code
```

## Getting started

1. Back up any existing `~/.config/nvim`.
2. Clone this repo (or copy these files) into `~/.config/nvim`.
3. Start Neovim. Lazy will bootstrap itself and install plugins.
4. Run `:Lazy sync` once to ensure everything is installed, then `:Mason` to confirm relevant language servers (yamlls, terraformls, vtsls) are installed.
5. Open a project directory and start editing.

## Everyday commands

| Command | Description |
| ------- | ----------- |
| `:Lazy`, `:Lazy sync`, `:Lazy update` | Manage/update plugins |
| `:LazyExtras` | UI for enabling/disabling LazyVim extras |
| `:LazyHealth` | Force-load all plugins and run `:checkhealth` |
| `:Mason`, `:MasonInstall <server>` | Install & manage external LSPs/linters |
| `:LspInfo` | Inspect active language servers for current buffer |
| `:ConformInfo` | Show which formatters `conform.nvim` will run |
| `:TSUpdate` | Update installed tree-sitter parsers |
| `:checkhealth` | Verify Neovim, providers, and plugin health |
| `:PersistenceLoad`, `:PersistenceStop` | Session management (from `persistence.nvim`) |
| `:Snacks scratch`, `:Snacks terminal` | Use Snacks scratch buffers or floating terminals |

## Useful keybindings

LazyVim sets `<Space>` as the global leader and provides a rich default keymap set. Below are the bindings that tend to be most useful day-to-day (additions from `lua/config/keymaps.lua` are noted).

### Motion, windows & buffers

| Keys | Mode | Source | Description |
| ---- | ---- | ------ | ----------- |
| `<C-h/j/k/l>` | normal | LazyVim | Move focus between splits |
| `<C-Up/Down/Left/Right>` | normal | LazyVim | Resize the current split |
| `<leader>-` / `<leader>|` | normal | LazyVim | Horizontal / vertical split |
| `<leader>wd` | normal | LazyVim | Close current window |
| `<S-h>` / `<S-l>` | normal | LazyVim | Previous / next buffer |
| `<leader>bb` | normal | LazyVim | Switch to alternate buffer |
| `<leader>bd` / `<leader>bo` | normal | LazyVim | Close current buffer / all others |
| `<leader>wm` | normal | LazyVim / Snacks | Toggle window zoom |

### Diagnostics, LSP & formatting

| Keys | Mode | Description |
| ---- | ---- | ----------- |
| `<leader>cd` | normal | Show line diagnostics |
| `[d` / `]d` | normal | Jump to previous / next diagnostic |
| `<leader>cf` | normal/visual | Format buffer/selection via `conform.nvim` |
| `<leader>co`, `<leader>cM`, `<leader>cu`, `<leader>cD` | normal | TypeScript organize/add/remove/fix code actions (`vtsls`) |
| `gD`, `gR` | normal | Source definition / file references for TS buffers |
| `<leader>cV` | normal | Pick TypeScript version (workspace vs bundled) |

### Git & tools

| Keys | Description |
| ---- | ----------- |
| `<leader>gg` / `<leader>gG` | Open LazyGit rooted at project / cwd (requires `lazygit`) |
| `<leader>gl` | Git log picker for project (Snacks) |
| `<leader>gb` | Git blame current line history |
| `<leader>ft` / `<leader>fT` | Floating terminal (root / cwd) |
| `<c-/>` (normal/terminal) | Toggle floating terminal |

### Toggles & utilities

| Keys | Description |
| ---- | ----------- |
| `<leader>us`, `<leader>uw`, `<leader>ul` | Toggle spell-check, wrapping, relative numbers |
| `<leader>ud`, `[e` / `]e`, `[w` / `]w` | Toggle diagnostics view or jump by severity |
| `<leader>ua`, `<leader>uT`, `<leader>ug` | Toggle animations, Tree-sitter, indent guides |
| `<leader>l` | Open Lazy UI |
| `<leader>L` | Show LazyVim changelog |
| `<leader>qq` | Quit all |

### Custom mappings from this repo

| Keys | Mode | Description |
| ---- | ---- | ----------- |
| `+` / `-` | normal | Increment/decrement numbers under cursor |
| `<C-a>` | normal | Select the entire buffer (`gg<S-v>G`) |
| `<C-w><Left/Right/Up/Down>` | normal | Resize splits (arrow-friendly alternative) |

Standard Neovim motions (`gg`, `G`, `w`, `b`, `%`), editing commands (`ci"`, `yy`, `p`), undo/redo (`u`, `<C-r>`), saving (`:w`, `<C-s>`) and quitting (`:q`, `:qa!`) all behave as expected because LazyVim layers on top of Neovim defaults rather than replacing them.

## Tips

- Keep `lazy-lock.json` under version control so plugin versions remain reproducible across machines.
- If you remove `SchemaStore.nvim`, wrap `require("schemastore")` in `lua/config/lspconfig.lua` to prevent `yamlls` from failing to attach.
- On WSL, confirm `clip.exe` and `powershell.exe` are on `PATH` before enabling the clipboard bridge in `lua/config/options.lua`.
- `stylua.toml` pins indentation/column widths—run `stylua .` before committing Lua changes.

Happy hacking!
