# Quickstart: Validate the Minimal Neovim Configuration

**Feature**: [spec.md](spec.md) | **Keys**: [contracts/keymaps.md](contracts/keymaps.md)

## Prerequisites

- Neovim 0.12 or later
- The tools that the README lists (`git`, `rg`, `tree-sitter-cli`, a C compiler, language servers)

## 1. Isolated first start

Use an isolated application name, so the test does not change your real data.

```sh
NVIM_APPNAME=nvim-test git clone <repo> ~/.config/nvim-test
NVIM_APPNAME=nvim-test nvim --headless +qa
```

Expected: exit code 0, no error output. All extensions install (SC-005).

## 2. Health check

```sh
NVIM_APPNAME=nvim-test nvim --headless "+checkhealth config" "+w! /tmp/health.txt" +qa
grep -E "ERROR|WARNING" /tmp/health.txt
```

Expected: no `ERROR`. A `WARNING` shows only for tools that are not installed.

## 3. No old references (SC-008)

```sh
grep -rniE "lazyvim|lazy\.nvim|require\(.lazy.\)" --include=*.lua --include=*.json .
```

Expected: no output.

## 4. Extension count (SC-002)

```sh
NVIM_APPNAME=nvim-test nvim --headless "+lua print(#vim.pack.get())" +qa
```

Expected: 15 or fewer.

## 5. Startup time (SC-001)

```sh
NVIM_APPNAME=nvim-test nvim --startuptime /tmp/st.log +qa && tail -1 /tmp/st.log
```

Expected: less than 100 ms.

## 6. Languages (SC-004)

Open one sample file for each language. Check highlighting with `:Inspect` and server attachment with `:checkhealth vim.lsp`.

| Sample | Expected file type | Expected server |
|--------|--------------------|-----------------|
| `a.ts` | `typescript` | `tsc` |
| `a.js` | `javascript` | `tsc` |
| `main.tf` | `terraform` | `terraformls` |
| `a.yaml` | `yaml` | `yamlls` |
| `chart/templates/a.yaml` (with `chart/Chart.yaml`) | `helm` | `helm_ls` |
| `a.py` | `python` | `basedpyright`, `ruff` |
| `playbooks/site.yml` | `yaml.ansible` | `ansiblels` |
| `README.md` | `markdown` | `marksman` |
| `package.json` | `json` | `jsonls` |
| `COMMIT_EDITMSG` in a repository | `gitcommit` | none |

Also check:

- In `main.tf`, add extra spaces and press `<leader>cf`. The spaces are removed.
- In `package.json`, type an unknown key. A schema diagnostic shows.
- Remove `marksman` from `PATH` and open `README.md`. One warning names `marksman`. No error shows.

## 7. File manager and cheat sheet

1. Open a file. Press `<leader>e`. The file manager opens at the directory of the file.
2. Press `g?`. The cheat sheet shows all keys (SC-006).
3. Add a line `new.txt`, then `:w`. The file exists on disk.
4. Press `q`. The previous buffer shows.

## 8. Git

1. Change a tracked file. Markers show in the sign column.
2. Press `]h`, `<leader>hp`, `<leader>hb`. The cursor moves, the preview shows, the blame shows.
3. Press `<leader>gd`. The current file and its index version show side by side.
4. Press `<leader>gg`. LazyGit opens in a floating window. Stage the file with `<Space>`. Press `c`, write a message, and press Enter. The commit exists.
5. In LazyGit, press `4`. The log shows.
6. In LazyGit, select a file and press `e`. The file opens in the current editor, not in a nested editor. The LazyGit window hides.
7. Remove `lazygit` from `PATH` and press `<leader>gg`. One message names LazyGit.

## 9. Terminal overlay

1. Press `<A-t>`. Run `echo hello`.
2. Press `<A-t>`. The editor shows.
3. Press `<A-t>`. `hello` is still there (SC-007).
4. Press `<Esc><Esc>`. You can scroll and copy.

## 10. Appearance

1. On start, the theme is `solarized-osaka`.
2. Press `<leader>uc`, type `habamax`, press Enter. The theme changes.
3. In the file manager, files show icons.

## Cleanup

```sh
rm -rf ~/.config/nvim-test ~/.local/share/nvim-test ~/.local/state/nvim-test ~/.cache/nvim-test
```
