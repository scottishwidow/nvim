# Neovim + LazyVim configuration

Personal Neovim config that layers a handful of opinionated tweaks on top of [LazyVim](https://lazyvim.org). It lives in `~/.config/nvim` and bootstraps LazyVim with the Solarized Osaka colorscheme and a set of LazyVim language extras. Mason installs all language servers, linters, and formatters.

## Highlights

- LazyVim 16.x with Snacks, fzf-lua, blink.cmp, and the solarized-osaka theme
- LazyVim language extras (see `lazyvim.json`):

  | Extra | Language server | Other tools |
  | ----- | --------------- | ----------- |
  | `lang.helm` | `helm_ls` | - |
  | `lang.json` | `jsonls` | SchemaStore |
  | `lang.markdown` | `marksman` | `markdownlint-cli2`, `markdown-toc`, render-markdown, markdown-preview |
  | `lang.python` | `basedpyright`, `ruff` | venv-selector |
  | `lang.rust` | `rust-analyzer` (from rustup, through rustaceanvim) | `codelldb`, crates.nvim |
  | `lang.terraform` | `terraformls` | `tflint`, `terraform_fmt`, `packer_fmt` |
  | `lang.typescript` | `vtsls` | - |
  | `lang.yaml` | `yamlls` | SchemaStore |

- Formatting with `conform.nvim` and tree-sitter parsers, both set by the extras above
- Quality-of-life keymaps for resizing windows, buffer management, and quick “select all”
- Optional clipboard bridge for WSL that mirrors the Windows clipboard when `clip.exe`/`powershell.exe` are available

## Requirements & dependencies

| Need | Why |
| ---- | --- |
| Neovim ≥ 0.11.2 | LazyVim hard-requirement (`lazyvim/plugins/init.lua`) |
| `git`, `curl` | bootstrap `lazy.nvim` & install plugins |
| `rg` (ripgrep), `fd`, `fzf` | file and text search in the fzf-lua and Snacks pickers |
| `tree-sitter` CLI, a C compiler | compile tree-sitter parsers (nvim-treesitter `main` branch) |
| `node`, `npm` | Mason installs Node-based servers (`vtsls`, `yamlls`, `jsonls`, `markdownlint-cli2`) |
| `rustup` with the `rust-analyzer` component | Rust language server (rustaceanvim does not use Mason for it) |
| `terraform` CLI | `terraform_fmt` formatter and `terraform_validate` linter |
| `packer` CLI (optional) | `packer_fmt` formatter for HCL files |
| `lazygit` (optional) | `<leader>gg` / `<leader>gG` |
| `clip.exe`, `powershell.exe` (optional) | only necessary if you want the WSL clipboard bridge from `lua/config/options.lua` |

## Repository layout

```
init.lua                  -- bootstraps lazy.nvim
lua/config/               -- lazy.lua, options.lua, keymaps.lua, autocmds.lua only
lua/plugins/              -- user plugin specs (colorscheme)
lazy-lock.json            -- pinned plugin commits
lazyvim.json              -- enabled LazyVim extras
stylua.toml               -- formatting config for Lua code
AGENTS.md                 -- rules for coding agents
SECURITY.md               -- supply-chain rules
.github/AI_POLICY.md      -- AI usage policy for contributions
```

LazyVim loads only `options`, `keymaps`, `autocmds`, and `lazy` from `lua/config/`. Put each plugin spec in `lua/plugins/`.

## Getting started

1. Back up any existing `~/.config/nvim`.
2. Clone this repo (or copy these files) into `~/.config/nvim`.
3. Start Neovim. Lazy will bootstrap itself and install plugins.
4. Run `:Lazy restore` to install the plugin commits from `lazy-lock.json`. Then open a file and run `:Mason` to confirm that the language servers are installed.
5. Open a project directory and start editing.

## Everyday commands

| Command | Description |
| ------- | ----------- |
| `:Lazy`, `:Lazy restore` | Manage plugins / install the commits from `lazy-lock.json` |
| `:Lazy update` | Update plugins and `lazy-lock.json` (only on purpose) |
| `:LazyExtras` | UI for enabling/disabling LazyVim extras |
| `:LazyHealth` | Force-load all plugins and run `:checkhealth` |
| `:Mason`, `:MasonInstall <package>` | Install and manage language servers, linters, and formatters |
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
| `<leader>co` | normal | Organize imports (any server that supports it) |
| `<leader>cM`, `<leader>cD` | normal | TypeScript add missing imports / fix all diagnostics (`vtsls`) |
| `gD`, `gR` | normal | Source definition / file references for TS buffers |
| `<leader>cV` | normal | Pick TypeScript version (workspace vs bundled) |

### Git & tools

| Keys | Description |
| ---- | ----------- |
| `<leader>gg` / `<leader>gG` | Open LazyGit rooted at project / cwd (requires `lazygit`) |
| `<leader>gl` | Git log picker for project (Snacks) |
| `<leader>gb` | Git blame current line history |
| `<leader>ft` / `<leader>fT` | Floating terminal (root / cwd) |
| `<c-/>` (normal/terminal) | Focus floating terminal |

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
- Add or remove language support with `:LazyExtras`, not with custom `nvim-lspconfig` specs.
- Mason puts its `bin` directory first in `PATH` inside Neovim. Do not install the same servers globally.
- `fd` must be a real binary on `PATH`. A shell alias (for example `alias fd=fdfind`) is not visible to Neovim.
- To test a branch without changing your main config, check it out at `~/.config/nvim-<name>` and run `NVIM_APPNAME=nvim-<name> nvim`.
- On WSL, confirm `clip.exe` and `powershell.exe` are on `PATH` before enabling the clipboard bridge in `lua/config/options.lua`.
- `stylua.toml` pins indentation/column widths—run `stylua .` before committing Lua changes.

Happy hacking!
