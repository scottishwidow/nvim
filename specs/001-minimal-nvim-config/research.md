# Research: Minimal Neovim Configuration Rebuild

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Date**: 2026-11-10

Each section gives the decision, the rationale, and the alternatives considered.

## R0. Maintenance policy

The user does not accept tools that are not maintained. A tool or extension is accepted only when all of these are true:

- The source repository is not archived.
- The repository has commits in the last 12 months.
- The pinned version is the latest release, or the latest commit on the default branch when the latest release is more than 12 months old or there is no release.
- The package comes from the official publisher.

The audit ran on 2026-11-10 with the GitHub API, `npm view`, and the PyPI JSON API. The results are in R2 and R4.

## R1. Package management

- **Decision**: Use the built-in `vim.pack` (Neovim 0.12). Declare all extensions in one `vim.pack.add()` call. Commit the lock file `nvim-pack-lock.json`. Pin each extension with `version` set to a release tag when the tag satisfies R0, otherwise to a full commit SHA.
- **Rationale**: Requirement FR-002 and FR-003. `SECURITY.md` requires exact pins and a committed lock file. `vim.pack` writes the lock file and installs from it on a new machine.
- **Alternatives considered**: lazy.nvim (rejected by FR-001). mini.deps (an extra dependency for a feature that the editor now has).

## R2. Extension set and pins

| Extension | Purpose | Archived | Last commit | Pin | Reason no native feature is enough |
|-----------|---------|----------|-------------|-----|------------------------------------|
| `nvim-treesitter/nvim-treesitter` (branch `main`) | Parsers and queries | No | 2026-11-07 | SHA `19bdfc04f40ed2ccb3340591d125f759b0406875` (no release on `main`) | Neovim ships parsers only for C, Lua, Vim, Vimdoc, Query, and Markdown |
| `b0o/SchemaStore.nvim` | JSON and YAML schema catalog | No | 2026-11-10 | SHA `df82e0f927cbd20169265733d909b1c7042ce180` (no releases) | The JSON server does not load the public catalog by itself (FR-013) |
| `stevearc/oil.nvim` | File manager | No | 2026-10-12 | tag `v2.16.0` (2026-05-24) | netrw has no buffer-based rename, move, or copy, and its help is long |
| `nvim-tree/nvim-web-devicons` | File type icons | No | 2026-11-05 | SHA `0dc0cfb0c6858041174a53c7aa4adaf65e994b3c` (latest tag `v0.100` is from 2024-05) | No native icon set (FR-028) |
| `lewis6991/gitsigns.nvim` | Change markers, hunks, blame | No | 2026-11-05 | tag `v2.1.0` (2026-03-26) | No native Git sign column (FR-021, FR-022) |
| `craftzdog/solarized-osaka.nvim` | Default theme | No | 2026-08-24 | SHA `a21176efde15fab21fabda0bf2ba123ed6d7332d` (no releases) | User requirement (FR-026) |

The total is 6 extensions. SC-002 allows 15. All pass R0. vim-fugitive was removed on 2026-11-10 because LazyGit replaces it (R8).

## R3. Syntax highlighting

- **Decision**: Use nvim-treesitter `main`. Install these parsers: `typescript`, `tsx`, `javascript`, `jsdoc`, `hcl`, `terraform`, `yaml`, `helm`, `python`, `json`, `markdown`, `markdown_inline`, `gitcommit`, `git_config`, `git_rebase`, `gitignore`, `diff`, `bash`. Start highlighting from a `FileType` autocommand with `vim.treesitter.start()`. Enable tree-sitter folds.
- **Rationale**: The `main` branch supports Neovim 0.12. The old `master` branch is locked for Neovim 0.11. In the `main` branch, highlighting does not start automatically.
- **Requirements of `main`**: Neovim 0.12.0 or later, `tar` and `curl`, `tree-sitter-cli` 0.26.1 or later (from a package manager, not npm), and a C compiler.
- **Machine status**: All requirements are installed. `tree-sitter` 0.27.2 is installed through mise.
- **Alternatives considered**: Only regex syntax files (Helm and Terraform support is weak). The `master` branch (not for Neovim 0.12).

## R4. Language servers and tools

- **Decision**: Do not use nvim-lspconfig. Write one file for each server in `lsp/<name>.lua`. Enable the servers with `vim.lsp.enable()`. Before the editor enables a server, it checks that the server command is on `PATH`. If the command is missing, the editor shows one warning that names the missing commands.
- **Rationale**: The user wants to own and understand the configuration. Each server file is 5 to 30 lines. The Neovim 0.12 `lsp/` runtime directory is the native method.
- **Alternatives considered**: nvim-lspconfig (one more extension, with configs that the user does not own). mason.nvim (rejected by the FR-016 clarification).

### Audit result

| Language | Config name | Command | Package and source | Version (release date) | Repository status |
|----------|-------------|---------|--------------------|------------------------|-------------------|
| TypeScript, JavaScript | `tsc` | `tsc --lsp --stdio` | npm `typescript` (Microsoft) | 7.0.2 (2026-11) | Active |
| Terraform | `terraformls` | `terraform-ls serve` | HashiCorp release `terraform-ls` | 0.39.1 (2026-10-28) | Active |
| YAML | `yamlls` | `yaml-language-server --stdio` | npm `yaml-language-server` (Red Hat) | 2.0.0 (2026-11-05) | Active |
| Helm | `helm_ls` | `helm_ls serve` | GitHub release `mrjosh/helm-ls`, file `helm_ls_linux_amd64` with `.sha256sum` | 0.5.4 (2025-11-26) | Active, last commit 2026-10-30 |
| Python | `basedpyright` | `basedpyright-langserver --stdio` | PyPI `basedpyright` | 1.40.2 (2026-10-04) | Active |
| Python | `ruff` | `ruff server` | PyPI `ruff` (Astral) | 0.17.4 (2026-11-05) | Active |
| Ansible | `ansiblels` | `ansible-language-server --stdio` | npm `@ansible/ansible-language-server`, built from `ansible/vscode-ansible` | 26.6.0 (2026-06-01) | Active |
| Markdown | `marksman` | `marksman server` | GitHub release `artempyanykh/marksman`, file `marksman-linux-x64` | 2026-02-08 | Active, last commit 2026-09-14 |
| JSON | `jsonls` | `vscode-json-language-server --stdio` | npm `vscode-langservers-extracted` (JSON server extracted from `microsoft/vscode`) | 4.10.0 (2024-05-08) | Not active, no newer source |
| Markdown format | none | `prettier` | npm `prettier` | 3.9.10 (2026-10-10) | Active |
| Git interface | none | `lazygit` | GitHub release `jesseduffield/lazygit` | 0.66.3 (2026-11-07) | Active, not installed on this machine |

### Changes after the audit

| Before | After | Reason |
|--------|-------|--------|
| `vtsls` (npm `@vtsls/language-server` 0.3.0) | TypeScript 7 native server `tsc --lsp --stdio` | TypeScript 7.0 is the current release. It has a built-in LSP server. vtsls wraps the TypeScript 5 and 6 `tsserver`. TypeScript 7 does not ship a JavaScript API, so vtsls cannot use the TypeScript 7 version in a project. The last vtsls release is 2025-12-24. |
| npm `vscode-json-languageserver` 1.3.4 | npm `vscode-langservers-extracted` 4.10.0 | `vscode-json-languageserver` 1.3.4 is from 2021-02-22. `vscode-langservers-extracted` 4.10.0 (2024-05-08) has a newer JSON server. No maintained npm package has a newer one. |
| Old repository `ansible/ansible-language-server` | Same npm package, now built from `ansible/vscode-ansible` | The old repository is archived. Its code moved to the `vscode-ansible` monorepo. The npm package is current. |

### TypeScript 7 server details

- Sources: TypeScript 7.0 announcement (devblogs.microsoft.com/typescript, 2026-07-08). The `typescript-go` README. The nvim-lspconfig `lsp/tsc.lua` file. The `typescript-go` repository is archived because the code moved to the main TypeScript repository.
- The command `tsc --lsp --stdio` started and sent LSP messages in a local test with `typescript@7.0.2`. The full capability list was not checked. The implementation step must check it.
- The config prefers the project-local `node_modules/.bin/tsc` when it exists and its major version is 7 or more. Otherwise it uses `tsc` on `PATH`.
- If the server does not give formatting, the editor formats TypeScript and JavaScript with `prettier` through `formatprg`. The implementation step decides this from the capability check.

### Notes

- `helm_ls` uses `yaml-language-server` internally for YAML diagnostics in templates.
- `ansiblels` gives better diagnostics when `ansible-lint` is installed. This tool is optional.
- Install release files only with checksum verification. Do not pipe a remote script into a shell (`SECURITY.md`).
- The README pins each install command to the version in the audit table.

## R5. Completion

- **Decision**: Use native completion. Set `autocomplete` and `completeopt` options. On `LspAttach`, call `vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })`.
- **Rationale**: FR-015. Neovim 0.12 gives automatic completion from LSP servers.
- **Alternatives considered**: blink.cmp and nvim-cmp (extra dependencies).

## R6. Formatting

- **Decision**: Use `vim.lsp.buf.format()` with the key `<leader>cf`. Servers that format: `terraformls` (standard `terraform fmt`), `yamlls`, `ruff`, `jsonls`, and `tsc` if its capability check passes (R4). For Markdown, set buffer `formatprg` to `prettier --parser markdown` and use `gq`.
- **Rationale**: Each supported language except Markdown has a formatting server. This removes the need for conform.nvim.
- **Alternatives considered**: conform.nvim (it is in the old configuration, but it is not necessary).

## R7. File type detection

- **Decision**: Use `vim.filetype.add()`.
  - Helm: `*.yaml`, `*.yml`, `*.tpl`, and `*.txt` in a `templates/` directory of a directory that has `Chart.yaml` set file type `helm`.
  - Ansible: YAML files in `playbooks/`, `roles/*/tasks/`, `roles/*/handlers/`, `group_vars/`, `host_vars/`, and the files `site.yml`, `playbook.yml` set file type `yaml.ansible`.
  - Terraform: `*.tfvars` sets `terraform-vars`. `*.tf` sets `terraform`.
- **Rationale**: FR-014. These rules are native and short.

## R8. Git

- **Decision**: gitsigns.nvim for markers, hunks, blame, and the side-by-side diff of the current file (`:Gitsigns diffthis`). LazyGit for status, stage, unstage, commit, and log.
- **Integration**:
  - The terminal module (R10) has a second floating terminal for LazyGit. `<leader>gg` opens it in the Git root of the current file. LazyGit exits when the user quits it, so each open starts a new LazyGit process.
  - Inside an editor terminal, Neovim sets `$NVIM` to the server address of the editor. The LazyGit config in the repository, `lazygit/config.yml`, sets `os.editPreset: nvim-remote`. With this preset, LazyGit opens files in the current editor and not in a new one.
  - The editor starts LazyGit with `LG_CONFIG_FILE` set to the default LazyGit config file and the repository file, separated by a comma. LazyGit merges them, so the personal LazyGit config of the user stays active.
  - When a file opens from LazyGit, the LazyGit window hides.
  - Before the editor opens LazyGit, it checks that `lazygit` is on `PATH`. If not, it shows one message.
- **Rationale**: User decision on 2026-11-10. LazyGit is maintained (R4). It removes one extension. The integration uses native terminal features and needs no extension.
- **Alternatives considered**: vim-fugitive (replaced by user decision). lazygit.nvim extension (an extension for a task that about 20 lines of native code do). neogit (needs plenary.nvim and diffview.nvim).

## R9. File manager and cheat sheet

- **Decision**: oil.nvim. Open with `<leader>e` at the directory of the current file. The oil key `g?` shows the cheat sheet. The configuration gives every oil key a `desc`, so the oil help window becomes the cheat sheet (FR-020). `g.` toggles hidden files. `q` closes.
- **Rationale**: Oil edits the file system as a buffer, so the user uses normal edit commands. Its help window satisfies FR-020 without extra code.
- **Note**: The oil default key to open is `-`. The user maps `-` to decrement, so the global key is `<leader>e`. Inside oil, `-` goes to the parent directory (buffer-local key).
- **Alternatives considered**: netrw (no help that is short enough). mini.files (column view, more keys to learn).

## R10. Terminal overlay

- **Decision**: Write a native module of about 60 lines. It opens a terminal buffer in a floating window. It has two uses: the shell overlay and LazyGit (R8). The shell overlay keeps its buffer while hidden. `<A-t>` toggles the shell overlay in normal and terminal mode. `<Esc><Esc>` leaves terminal mode. In the LazyGit window, `<Esc>` goes to LazyGit and does not leave terminal mode.
- **Rationale**: FR-023 to FR-025. `nvim_open_win` and `jobstart({ term = true })` give the full behavior.
- **Alternatives considered**: toggleterm.nvim, snacks.nvim terminal (extra dependencies).
- **Key choice**: The toggle key must work in terminal mode, so it cannot be a printable key or the leader. `<A-t>` has no native function.

## R11. Fuzzy file search and grep

- **Decision**: Native. Set `findfunc` to a function that uses `rg --files` and `matchfuzzy()`. Set `grepprg` to `rg --vimgrep --smart-case`. Use `wildoptions=pum,fuzzy`. Keys: `<leader>ff` to `:find `, `<leader>fg` to `:grep `, `<leader>fb` to `:buffer `.
- **Rationale**: The spec assumption says native fuzzy search. `rg` is installed.

## R12. Appearance

- **Decision**: Solarized Osaka is the default theme. The built-in themes (for example `habamax`, `retrobox`, `sorbet`, `unokai`) satisfy FR-027. The user switches with `:colorscheme <Tab>` or `<leader>uc`. Icons come from nvim-web-devicons.
- **Rationale**: Built-in themes need no extension.

## R13. Removal of the old configuration

- **Decision**: Delete `lua/config/`, `lua/plugins/`, `lazy-lock.json`, `lazyvim.json`, and `.neoconf.json`. Write a new `init.lua`. Keep `stylua.toml`, `AGENTS.md`, `CLAUDE.md`, `SECURITY.md`, `.github/`, `.specify/`, `.claude/`, and `.agents/`.
- **Rationale**: User input: "Old configuration gets purged, so we start from scratch." SC-008.
- **Out of repository**: The old data directories (`~/.local/share/nvim/lazy`, `~/.local/state/nvim/lazy`) are not part of the repository. The README tells the user how to remove them. The agent does not delete them.

## R14. Governance

- **Decision**: The project rules are `CLAUDE.md` (a link to `AGENTS.md`) and `SECURITY.md`. The spec-kit constitution stays an empty template.
- **Rationale**: The user decided on 2026-11-10 that the `CLAUDE.md` rules are sufficient.

## R15. Verification

- **Decision**: Use headless checks: `nvim --headless "+checkhealth config" +qa`, `nvim --headless +qa` (startup errors), and `nvim --startuptime`. Add `lua/config/health.lua` that reports the Neovim version, external tools, and language servers.
- **Rationale**: An editor configuration has no unit test framework. `:checkhealth` is the native method. It also satisfies the missing tool edge case.
