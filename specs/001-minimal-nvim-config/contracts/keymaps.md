# Contract: Keymaps and Commands

**Feature**: [../spec.md](../spec.md)

This is the user interface of the configuration. Leader is `<Space>`. Local leader is `\`.

## Kept from the old configuration (FR-008)

| Mode | Keys | Action |
|------|------|--------|
| n | `+` | Increment number |
| n | `-` | Decrement number |
| n | `<C-a>` | Select full buffer |
| n | `<C-w><Left>` / `<Right>` | Decrease / increase window width |
| n | `<C-w><Up>` / `<Down>` | Increase / decrease window height |

## Files and search

| Mode | Keys | Action |
|------|------|--------|
| n | `<leader>e` | Open file manager at the directory of the current file |
| n | `<leader>ff` | `:find ` (fuzzy file search) |
| n | `<leader>fg` | `:grep ` (search text with `rg`) |
| n | `<leader>fb` | `:buffer ` (switch buffer) |

## File manager (buffer-local, shown by `g?`)

| Keys | Action |
|------|--------|
| `<CR>` | Open file or directory |
| `-` | Go to parent directory |
| `_` | Go to current working directory |
| `g.` | Show or hide hidden files |
| `g?` | Show the cheat sheet |
| `<C-v>` | Open in vertical split |
| `<C-s>` | Open in horizontal split |
| `<C-p>` | Preview file |
| `q` | Close file manager |

File operations use normal edit commands. The user saves the buffer with `:w` to apply them.

| Operation | Edit |
|-----------|------|
| Create | Add a line. A name that ends with `/` is a directory. |
| Rename | Change the text of a line |
| Move | Cut a line (`dd`) and paste it (`p`) in another directory |
| Copy | Copy a line (`yy`) and paste it (`p`) in another directory |
| Delete | Delete a line (`dd`) |

## Language features

Neovim 0.12 sets these keys by default when a server attaches. The configuration keeps them.

| Mode | Keys | Action |
|------|------|--------|
| n | `K` | Hover documentation |
| n | `grn` | Rename |
| n, v | `gra` | Code action |
| n | `grr` | References |
| n | `gri` | Implementation |
| n | `grt` | Type definition |
| n | `gO` | Document symbols |
| i | `<C-s>` | Signature help |
| n | `]d` / `[d` | Next / previous diagnostic |
| n | `<C-w>d` | Show diagnostic under cursor |

The configuration adds:

| Mode | Keys | Action |
|------|------|--------|
| n | `gd` | Go to definition |
| n, v | `<leader>cf` | Format buffer or selection |
| n | `<leader>cd` | Put buffer diagnostics in the location list |

Completion uses native keys: `<C-n>` / `<C-p>` to select, `<C-y>` to accept, `<C-e>` to cancel.

## Git

| Mode | Keys | Action |
|------|------|--------|
| n | `]h` / `[h` | Next / previous change |
| n | `<leader>hp` | Preview change |
| n | `<leader>hr` | Reset change |
| n | `<leader>hs` | Stage change |
| n | `<leader>hb` | Blame for current line |
| n | `<leader>gg` | Open LazyGit in a floating window at the Git root |
| n | `<leader>gd` | Side-by-side diff of current file against the index |

Inside LazyGit, the LazyGit keys apply. `?` shows them. Most used: `<Space>` stage or unstage, `c` commit, `e` open file in the editor, `q` quit. To see the log, go to the commits panel (`4`).

## Terminal

| Mode | Keys | Action |
|------|------|--------|
| n, t | `<A-t>` | Show or hide floating terminal |
| t | `<Esc><Esc>` | Leave terminal mode |

## Appearance

| Mode | Keys | Action |
|------|------|--------|
| n | `<leader>uc` | `:colorscheme ` (select theme) |

## Commands

| Command | Action |
|---------|--------|
| `:checkhealth config` | Report Neovim version, external tools, and language servers |
| `:lua vim.pack.update()` | Update extensions and the lock file |
| `:TSUpdate` | Update tree-sitter parsers |
