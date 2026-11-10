---

description: "Task list for the minimal Neovim configuration rebuild"
---

# Tasks: Minimal Neovim Configuration Rebuild

**Input**: Design documents from `specs/001-minimal-nvim-config/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/keymaps.md, quickstart.md

**Tests**: The spec does not request automated tests. Each story phase ends with a validation task that runs the related step in [quickstart.md](quickstart.md).

**Organization**: Tasks are grouped by user story, so you can implement and validate each story independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: The user story of the task (US1 to US6)
- All paths are relative to the worktree root `.claude/worktrees/001-minimal-nvim-config/`

## Rules for all tasks

- Work only in the worktree. Use relative paths.
- Obey the comment rules in `AGENTS.md`: self-documenting names, comments only for non-obvious behavior, no references to chats or PRs.
- Give each key mapping a `desc` (FR-009).
- Format Lua with the existing `stylua.toml`.
- Do not add an extension that is not in research.md R2. Do not change a pin without user approval (`SECURITY.md`).

---

## Phase 1: Setup (Remove the old configuration)

**Purpose**: Start from an empty base (research.md R13).

- [X] T001 Confirm that the session runs in the worktree `.claude/worktrees/001-minimal-nvim-config` on branch `worktree-001-minimal-nvim-config` with `git worktree list` and `git branch --show-current`. Stop and ask the user if it does not.
- [X] T002 Delete the old configuration with `git rm`: `lua/config/autocmds.lua`, `lua/config/keymaps.lua`, `lua/config/lazy.lua`, `lua/config/lspconfig.lua`, `lua/config/options.lua`, `lua/plugins/` (all files), `lazy-lock.json`, `lazyvim.json`, `.neoconf.json`, `README.md`, `init.lua`. Keep `stylua.toml`, `AGENTS.md`, `CLAUDE.md`, `SECURITY.md`, `.github/`, `.specify/`, `.claude/`, `.agents/`, `specs/`.
- [X] T003 Commit the removal with the message `chore(config): remove LazyVim configuration`. Let pre-commit hooks run.

---

## Phase 2: Foundational (Blocking prerequisites)

**Purpose**: The entry point, the editor options, and the shared floating terminal helper. User stories 4 and 5 both use the helper.

**CRITICAL**: No user story work can start until this phase is complete.

- [X] T004 Create `init.lua`. First, if `vim.fn.has("nvim-0.12") == 0`, show the error message `This configuration requires Neovim 0.12 or later.` with `vim.api.nvim_echo` and `return` (FR-005). Then set `vim.g.mapleader = " "` and `vim.g.maplocalleader = "\\"` (FR-007). Then `require("config.options")`. Later tasks add the other modules in this final order: options, filetypes, plugins, appearance, treesitter, lsp, files, git, terminal, keymaps, autocmds.
- [X] T005 [P] Create `lua/config/options.lua` with editor options: `number`, `relativenumber`, `signcolumn = "yes"`, `termguicolors`, `undofile`, `ignorecase`, `smartcase`, `splitright`, `splitbelow`, `expandtab`, `shiftwidth = 2`, `tabstop = 2`, `scrolloff = 8`, `clipboard = "unnamedplus"`. Add native search (research.md R11): `grepprg = "rg --vimgrep --smart-case"`, `grepformat = "%f:%l:%c:%m"`, `wildoptions = "pum,fuzzy"`, and `findfunc` set to a function that runs `rg --files --hidden --glob !.git` once per command line, caches the result, and returns `vim.fn.matchfuzzy(files, cmdarg)`. Add the WSL clipboard (FR-029) when `vim.fn.has("wsl") == 1`: `vim.g.clipboard = { name = "WslClipboard", copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" }, paste = { ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))', ["*"] = <same command> }, cache_enabled = 0 }`.
- [X] T006 [P] Create `lua/config/terminal.lua` with a module table `M` and the function `M.open_float(opts)`. It opens a centered floating window (80% of `vim.o.columns` and `vim.o.lines`, `border = "rounded"`). If `opts.buf` is a valid buffer, it shows that buffer. Otherwise it creates a buffer and starts `vim.fn.jobstart(opts.cmd, { term = true, cwd = opts.cwd, env = opts.env, on_exit = opts.on_exit })` in it. It returns the buffer and window handles and calls `startinsert`. Return `M`. This task adds no keys.

**Checkpoint**: `nvim --headless +qa` exits with code 0 and no error output.

---

## Phase 3: User Story 1 - Own and understand the configuration (Priority: P1) MVP

**Goal**: The editor starts with a configuration that the user owns. `vim.pack` installs the 6 pinned extensions and writes the lock file. The kept custom keys work.

**Independent Test**: Start the editor with an isolated `NVIM_APPNAME`. It installs all extensions, starts without errors, and writes `nvim-pack-lock.json`. A search for the old distribution gives no result (quickstart.md steps 1, 3, 4).

### Implementation for User Story 1

- [X] T007 [P] [US1] Create `lua/config/keymaps.lua` with the kept keys (FR-008), each with `desc`: n `+` to `<C-a>` (`Increment number`), n `-` to `<C-x>` (`Decrement number`), n `<C-a>` to `gg<S-v>G` (`Select full buffer`), n `<C-w><Left>` to `<C-w><` (`Decrease window width`), n `<C-w><Right>` to `<C-w>>` (`Increase window width`), n `<C-w><Up>` to `<C-w>+` (`Increase window height`), n `<C-w><Down>` to `<C-w>-` (`Decrease window height`). Add the search keys from contracts/keymaps.md: n `<leader>ff` to `:find ` (`Find file`), n `<leader>fg` to `:grep ` (`Search text`), n `<leader>fb` to `:buffer ` (`Switch buffer`). These three keys put the command on the command line and do not press Enter.
- [X] T008 [P] [US1] Create `lua/config/autocmds.lua` with the augroup `config` (`clear = true`) and a `TextYankPost` autocommand that calls `vim.hl.on_yank()`.
- [X] T009 [P] [US1] Create `lua/config/plugins.lua` with one `vim.pack.add()` call. Use these exact specs from research.md R2: `{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "19bdfc04f40ed2ccb3340591d125f759b0406875" }`, `{ src = "https://github.com/b0o/SchemaStore.nvim", version = "df82e0f927cbd20169265733d909b1c7042ce180" }`, `{ src = "https://github.com/stevearc/oil.nvim", version = "v2.16.0" }`, `{ src = "https://github.com/nvim-tree/nvim-web-devicons", version = "0dc0cfb0c6858041174a53c7aa4adaf65e994b3c" }`, `{ src = "https://github.com/lewis6991/gitsigns.nvim", version = "v2.1.0" }`, `{ src = "https://github.com/craftzdog/solarized-osaka.nvim", version = "a21176efde15fab21fabda0bf2ba123ed6d7332d" }`. Pass `{ confirm = false }` so the first start installs without a prompt.
- [X] T010 [US1] In `init.lua`, add `require("config.plugins")` after options, and `require("config.keymaps")` and `require("config.autocmds")` at the end (depends on T007, T008, T009).
- [X] T011 [US1] Do the first start: link the worktree to `~/.config/nvim-test` (`ln -s "$PWD" ~/.config/nvim-test`), then run `NVIM_APPNAME=nvim-test nvim --headless +qa`. Confirm exit code 0, no error output, and a new `nvim-pack-lock.json` in the worktree root with 6 entries that match the pins in T009 (FR-003, SC-005).
- [X] T012 [US1] Run quickstart.md step 3 (`grep -rniE "lazyvim|lazy\.nvim|require\(.lazy.\)" --include=*.lua --include=*.json .`) and step 4 (extension count is 6). Confirm no output for step 3 (SC-008).
- [X] T013 [US1] Commit `init.lua`, `lua/config/options.lua`, `lua/config/terminal.lua`, `lua/config/keymaps.lua`, `lua/config/autocmds.lua`, `lua/config/plugins.lua`, and `nvim-pack-lock.json` with the message `feat(config): add base configuration with vim.pack`.

**Checkpoint**: The editor starts with the own base configuration and all extensions installed. This is the MVP.

---

## Phase 4: User Story 2 - Edit code with language support (Priority: P1)

**Goal**: Highlighting, diagnostics, completion, hover, navigation, and formatting for TypeScript, JavaScript, Terraform, YAML, Helm, Python, Ansible, Markdown, JSON, and Git files.

**Independent Test**: quickstart.md step 6. Each sample file gets the expected file type and server. `<leader>cf` formats `main.tf`. A schema diagnostic shows in `package.json`. A missing server gives one warning that names it.

### Implementation for User Story 2

- [X] T014 [P] [US2] Create `lua/config/filetypes.lua` with one `vim.filetype.add()` call (research.md R7, FR-014). `extension`: `tf = "terraform"`, `tfvars = "terraform-vars"`. `pattern`: for `.*/templates/.*%.ya?ml`, `.*/templates/.*%.tpl`, and `.*/templates/.*%.txt`, a function that returns `"helm"` when the parent directory of the `templates` directory has `Chart.yaml`, else `nil`. For `.*/playbooks/.*%.ya?ml`, `.*/roles/.*/tasks/.*%.ya?ml`, `.*/roles/.*/handlers/.*%.ya?ml`, `.*/group_vars/.*`, `.*/host_vars/.*` return `"yaml.ansible"`. `filename`: `site.yml` and `playbook.yml` to `"yaml.ansible"`. Give the Helm patterns a higher `priority` than the Ansible patterns, so Helm wins inside a chart.
- [X] T015 [P] [US2] Create `lua/config/treesitter.lua` (research.md R3). If `tree-sitter` is on `PATH`, call `require("nvim-treesitter").install({ "typescript", "tsx", "javascript", "jsdoc", "hcl", "terraform", "yaml", "helm", "python", "json", "markdown", "markdown_inline", "gitcommit", "git_config", "git_rebase", "gitignore", "diff", "bash" })`. If not, show one warning that names `tree-sitter-cli` and continue with regex syntax. Register parsers for compound or alias file types where `vim.treesitter.language.get_lang()` gives no parser: `vim.treesitter.language.register("yaml", "yaml.ansible")` and `vim.treesitter.language.register("terraform", "terraform-vars")`. Add a `FileType` autocommand in augroup `config_treesitter` that calls `pcall(vim.treesitter.start, args.buf)` and, on success, sets window-local `foldmethod = "expr"`, `foldexpr = "v:lua.vim.treesitter.foldexpr()"`, and `foldlevel = 99`. A file without a parser opens with no error (spec User Story 2, scenario 7).
- [X] T016 [P] [US2] Create `lsp/tsc.lua`. `cmd` is a function that uses `<root>/node_modules/.bin/tsc` when that file exists and `tsc --version` gives major version 7 or more, else `tsc` on `PATH`, with the arguments `--lsp --stdio` (research.md R4). `filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }`. `root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" }`.
- [X] T017 [P] [US2] Create `lsp/terraformls.lua`: `cmd = { "terraform-ls", "serve" }`, `filetypes = { "terraform", "terraform-vars", "hcl" }`, `root_markers = { ".terraform", ".git" }`.
- [X] T018 [P] [US2] Create `lsp/yamlls.lua`: `cmd = { "yaml-language-server", "--stdio" }`, `filetypes = { "yaml" }`, `root_markers = { ".git" }`. In `before_init`, set `settings.yaml.schemaStore = { enable = false, url = "" }` and `settings.yaml.schemas = require("schemastore").yaml.schemas()` (FR-013). Do not attach to `helm` or `yaml.ansible`.
- [X] T019 [P] [US2] Create `lsp/helm_ls.lua`: `cmd = { "helm_ls", "serve" }`, `filetypes = { "helm" }`, `root_markers = { "Chart.yaml" }`, `settings = { ["helm-ls"] = { yamlls = { path = "yaml-language-server" } } }`.
- [X] T020 [P] [US2] Create `lsp/basedpyright.lua`: `cmd = { "basedpyright-langserver", "--stdio" }`, `filetypes = { "python" }`, `root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrightconfig.json", ".git" }`.
- [X] T021 [P] [US2] Create `lsp/ruff.lua`: `cmd = { "ruff", "server" }`, `filetypes = { "python" }`, `root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" }`.
- [X] T022 [P] [US2] Create `lsp/ansiblels.lua`: `cmd = { "ansible-language-server", "--stdio" }`, `filetypes = { "yaml.ansible" }`, `root_markers = { "ansible.cfg", ".ansible-lint", ".git" }`.
- [X] T023 [P] [US2] Create `lsp/marksman.lua`: `cmd = { "marksman", "server" }`, `filetypes = { "markdown" }`, `root_markers = { ".marksman.toml", ".git" }`.
- [X] T024 [P] [US2] Create `lsp/jsonls.lua`: `cmd = { "vscode-json-languageserver", "--stdio" }`, `filetypes = { "json", "jsonc" }`, `root_markers = { ".git" }`. In `before_init`, set `settings.json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } }` (FR-013).
- [X] T025 [P] [US2] Create `after/ftplugin/markdown.lua` that sets `vim.bo.formatprg = "prettier --parser markdown"` (research.md R6).
- [X] T026 [US2] Create `lua/config/lsp.lua` (depends on T016 to T024). Define a table that maps each server name to its executable: `tsc = "tsc"`, `terraformls = "terraform-ls"`, `yamlls = "yaml-language-server"`, `helm_ls = "helm_ls"`, `basedpyright = "basedpyright-langserver"`, `ruff = "ruff"`, `ansiblels = "ansible-language-server"`, `marksman = "marksman"`, `jsonls = "vscode-json-languageserver"`. Call `vim.lsp.enable()` only for servers whose executable is on `PATH` (FR-016). For each missing server, add a `FileType` autocommand on `vim.lsp.config[name].filetypes` that shows one warning per session, for example `marksman not found on PATH. Install it to get language features.` Set `vim.o.completeopt = "menuone,noselect,popup,fuzzy"` and `vim.o.autocomplete = true` (research.md R5). Call `vim.diagnostic.config({ virtual_text = true, severity_sort = true })`. In an `LspAttach` autocommand (augroup `config_lsp`): call `vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })` when the client supports `textDocument/completion`; map buffer-local n `gd` to `vim.lsp.buf.definition` (`Go to definition`); map n and v `<leader>cf` to `vim.lsp.buf.format` (`Format buffer or selection`) and fall back to `gq` with `formatprg` when no attached client supports formatting; map n `<leader>cd` to `vim.diagnostic.setloclist` (`Buffer diagnostics to location list`). For `terraformls`, add a buffer-local `BufWritePre` autocommand that formats with that client (spec User Story 2, scenario 2).
- [X] T027 [US2] In `init.lua`, add `require("config.filetypes")` after options and before plugins, and `require("config.treesitter")` and `require("config.lsp")` after plugins (depends on T014, T015, T026).
- [X] T028 [US2] Check the `tsc` server capabilities (research.md R4). Open a sample `a.ts`, then print `vim.lsp.get_clients({ name = "tsc" })[1].server_capabilities`. Record whether `hoverProvider`, `definitionProvider`, `referencesProvider`, `renameProvider`, `codeActionProvider`, `completionProvider`, and `documentFormattingProvider` exist. If `documentFormattingProvider` is missing, create `after/ftplugin/typescript.lua`, `after/ftplugin/typescriptreact.lua`, `after/ftplugin/javascript.lua`, and `after/ftplugin/javascriptreact.lua`, each with `vim.bo.formatprg = "prettier --stdin-filepath " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0))`. Report any other missing capability to the user before you add a workaround.
- [ ] T029 [US2] Run quickstart.md step 6 for all 10 samples, including the three extra checks (Terraform format, JSON schema diagnostic, missing `marksman` warning). Confirm 10 of 10 pass (SC-004).
- [X] T030 [US2] Commit `lua/config/filetypes.lua`, `lua/config/treesitter.lua`, `lua/config/lsp.lua`, `lsp/`, `after/ftplugin/`, and `init.lua` with the message `feat(config): add language support`.

**Checkpoint**: User Stories 1 and 2 work. The editor is usable for daily work.

---

## Phase 5: User Story 3 - Navigate files with a file manager and cheat sheet (Priority: P2)

**Goal**: oil.nvim opens at the directory of the current file. Each oil key has a description, so `g?` is the cheat sheet.

**Independent Test**: quickstart.md step 7.

### Implementation for User Story 3

- [ ] T031 [US3] Create `lua/config/files.lua` (research.md R9, FR-017 to FR-020). Call `require("oil").setup()` with `default_file_explorer = true`, `use_default_keymaps = false`, `view_options = { show_hidden = false }`, and `keymaps` that give each key an action and a `desc`: `<CR>` `actions.select` (`Open file or directory`), `-` `actions.parent` (`Go to parent directory`), `_` `actions.open_cwd` (`Go to current working directory`), `g.` `actions.toggle_hidden` (`Show or hide hidden files`), `g?` `actions.show_help` (`Show this cheat sheet`), `<C-v>` `actions.select` with `opts = { vertical = true }` (`Open in vertical split`), `<C-s>` `actions.select` with `opts = { horizontal = true }` (`Open in horizontal split`), `<C-p>` `actions.preview` (`Preview file`), `q` `actions.close` (`Close file manager`). Map global n `<leader>e` to `require("oil").open()` (`Open file manager`). Do not map global `-` (it is the decrement key).
- [ ] T032 [US3] In `init.lua`, add `require("config.files")` after lsp (depends on T031).
- [ ] T033 [US3] Run quickstart.md step 7. Also rename, move (`dd` then `p` in another directory), copy (`yy` then `p`), and delete a file, and save with `:w`. Confirm each change on disk (FR-018). Press `g.` and confirm hidden files show (FR-019).
- [ ] T034 [US3] Commit `lua/config/files.lua` and `init.lua` with the message `feat(config): add oil file manager`.

**Checkpoint**: The file manager and its cheat sheet work.

---

## Phase 6: User Story 4 - Work with Git (Priority: P2)

**Goal**: gitsigns gives change markers, hunk actions, blame, and the side-by-side diff. LazyGit opens in a floating window and opens files in the current editor.

**Independent Test**: quickstart.md step 8.

### Implementation for User Story 4

- [ ] T035 [P] [US4] Create `lazygit/config.yml` with this content only: `os:` and the nested key `editPreset: "nvim-remote"` (research.md R8, FR-022b).
- [ ] T036 [US4] Create `lua/config/git.lua` with the gitsigns setup (FR-021, FR-022, FR-022a). Call `require("gitsigns").setup({ on_attach = function(buf) ... end })`. In `on_attach`, map buffer-local keys with `desc`: n `]h` to `nav_hunk("next")` (`Next change`), n `[h` to `nav_hunk("prev")` (`Previous change`), n `<leader>hp` to `preview_hunk` (`Preview change`), n `<leader>hr` to `reset_hunk` (`Reset change`), n `<leader>hs` to `stage_hunk` (`Stage change`), n `<leader>hb` to `blame_line({ full = true })` (`Blame for current line`), n `<leader>gd` to `diffthis` (`Diff against index`).
- [ ] T037 [US4] In `lua/config/git.lua`, add the LazyGit window (depends on T006, T035, T036). Map global n `<leader>gg` (`Open LazyGit`). If `lazygit` is not on `PATH`, show one message `lazygit not found on PATH.` and return. Otherwise get the Git root with `vim.fs.root(0, ".git")`, or the current directory when there is no root. Build `LG_CONFIG_FILE` from the user config file (`<output of lazygit --print-config-dir>/config.yml`, only if it exists) and `vim.fn.stdpath("config") .. "/lazygit/config.yml"`, separated by a comma. Call `require("config.terminal").open_float({ cmd = "lazygit", cwd = root, env = { LG_CONFIG_FILE = ... }, on_exit = ... })`. The `on_exit` callback closes the window, wipes the buffer, and runs `checktime`. Each press starts a new LazyGit process. Do not map `<Esc><Esc>` in this buffer, so `<Esc>` goes to LazyGit.
- [ ] T038 [US4] In `init.lua`, add `require("config.git")` after files (depends on T036, T037).
- [ ] T039 [US4] Install LazyGit 0.66.3 from the GitHub release archive with checksum verification, or ask the user to install it (research.md R4 says it is not installed on this machine). Then run quickstart.md step 8, items 1 to 7. Open a file outside a Git repository and confirm no error.
- [ ] T040 [US4] Commit `lua/config/git.lua`, `lazygit/config.yml`, and `init.lua` with the message `feat(config): add gitsigns and LazyGit window`.

**Checkpoint**: Git markers, hunk actions, and LazyGit work.

---

## Phase 7: User Story 5 - Use a terminal overlay (Priority: P3)

**Goal**: `<A-t>` shows and hides one floating shell. The session stays alive while hidden.

**Independent Test**: quickstart.md step 9.

### Implementation for User Story 5

- [ ] T041 [US5] In `lua/config/terminal.lua`, add the shell overlay (research.md R10, FR-023 to FR-025). Keep the state `{ buf, win }`. Add `M.toggle_shell()`: if the window is valid, hide it with `vim.api.nvim_win_hide`; else call `M.open_float({ buf = state.buf, cmd = vim.o.shell, on_exit = <reset state> })` and store the new handles. Map n and t `<A-t>` to `M.toggle_shell` (`Show or hide terminal`). When the shell buffer is created, map buffer-local t `<Esc><Esc>` to `<C-\><C-n>` (`Leave terminal mode`).
- [ ] T042 [US5] In `init.lua`, add `require("config.terminal")` after git and before keymaps (depends on T041).
- [ ] T043 [US5] Run quickstart.md step 9. If `<A-t>` does not reach Neovim in the WSL terminal, tell the user and agree on a different key before you change it.
- [ ] T044 [US5] Commit `lua/config/terminal.lua` and `init.lua` with the message `feat(config): add floating terminal overlay`.

**Checkpoint**: The terminal overlay works.

---

## Phase 8: User Story 6 - Appearance: color themes and icons (Priority: P3)

**Goal**: Solarized Osaka is the default theme. The user can switch to a built-in theme. Files show icons.

**Independent Test**: quickstart.md step 10.

### Implementation for User Story 6

- [ ] T045 [US6] Create `lua/config/appearance.lua` (research.md R12, FR-026 to FR-028). Call `require("nvim-web-devicons").setup()`. Call `require("solarized-osaka").setup({})`, then `vim.cmd.colorscheme("solarized-osaka")` inside `pcall`. If it fails (for example, the extension is not installed because there is no network), use `habamax` with no error.
- [ ] T046 [US6] In `lua/config/keymaps.lua`, add n `<leader>uc` to `:colorscheme ` without Enter (`Select theme`).
- [ ] T047 [US6] In `init.lua`, add `require("config.appearance")` after plugins and before treesitter (depends on T045).
- [ ] T048 [US6] Run quickstart.md step 10. Then start the editor with `TERM=xterm` in a terminal without a Nerd Font and confirm no errors (spec User Story 6, scenario 4).
- [ ] T049 [US6] Commit `lua/config/appearance.lua`, `lua/config/keymaps.lua`, and `init.lua` with the message `feat(config): add theme and icons`.

**Checkpoint**: All user stories work independently.

---

## Phase 9: Polish and cross-cutting concerns

**Purpose**: Health check, README, and full validation.

- [ ] T050 [P] Create `lua/config/health.lua` with `M.check()` for `:checkhealth config` (research.md R15). Use `vim.health.start`, `ok`, `warn`, and `error`. Report: the Neovim version (error if older than 0.12); the tools `git`, `rg`, `curl`, `tar`, a C compiler (`cc`, `gcc`, or `clang`), `tree-sitter` (warn if older than 0.26.1), `lazygit`, `prettier`; each server executable from the table in `lua/config/lsp.lua` (warn when missing); the extension count from `vim.pack.get()` (error if more than 15, SC-002). Reuse the server table from `lua/config/lsp.lua` through a module field, so the list exists in one place.
- [ ] T051 [P] Check the current version of each external tool in its registry with `npm view <pkg> version`, the PyPI JSON API, and the GitHub releases API: `typescript`, `terraform-ls`, `yaml-language-server`, `helm-ls`, `basedpyright`, `ruff`, `@ansible/ansible-language-server`, `marksman`, `vscode-json-languageserver`, `prettier`, `lazygit`, `tree-sitter-cli`. Apply the R0 maintenance rules in research.md. Tell the user about each version that differs from research.md R4 before you use it in the README.
- [ ] T052 Write `README.md` (depends on T050, T051) with the sections from plan.md "README.md contents": purpose; requirements (Neovim 0.12 or later, `git`, `rg`, `curl`, `tar`, a C compiler, `tree-sitter-cli` 0.26.1 or later, a Nerd Font, LazyGit); one table of language tools with language, tool, exact version, and install command; install steps (clone, first start, `:checkhealth config`); removal of old LazyVim data (`~/.local/share/nvim/lazy`, `~/.local/state/nvim/lazy`, `~/.cache/nvim`) as commands for the user to run; update steps (`:lua vim.pack.update()`, `:TSUpdate`, commit `nvim-pack-lock.json`); structure with one line per file; a link to `specs/001-minimal-nvim-config/contracts/keymaps.md` or a short key table. Pin each install command to an exact version. Use package managers or release archives with checksum verification. Do not use `curl ... | sh` (`SECURITY.md`). Write in ASD-STE100. Use no emojis.
- [ ] T053 Run `stylua --check .` if `stylua` is installed and fix each reported file in `init.lua`, `lua/`, `lsp/`, and `after/`.
- [ ] T054 Review all Lua files in `init.lua`, `lua/`, `lsp/`, and `after/` for the comment rules in `AGENTS.md`. Remove comments that restate code. Confirm no file references a chat, a PR, or the old distribution.
- [ ] T055 Run quickstart.md steps 1 to 5 on a clean `NVIM_APPNAME=nvim-test` data directory: first start with exit code 0, `:checkhealth config` without `ERROR`, no old references, 15 or fewer extensions, and startup time less than 100 ms (SC-001, SC-002, SC-005, SC-008). Report each result to the user.
- [ ] T056 Run the quickstart.md cleanup step for `nvim-test` and remove the `~/.config/nvim-test` link from T011.
- [ ] T057 Commit `lua/config/health.lua` and `README.md` with the message `feat(config): add health check and README`.

---

## Dependencies and execution order

### Phase dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Phase 1. Blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2. It installs the extensions that all later stories configure.
- **User Stories 2 to 6 (Phases 4 to 8)**: Depend on Phase 3, because `lua/config/plugins.lua` installs their extensions. After Phase 3, they are independent of each other.
- **Polish (Phase 9)**: Depends on all user stories.

### User story dependencies

- **US1 (P1)**: Foundational only.
- **US2 (P1)**: US1 (treesitter and SchemaStore are installed).
- **US3 (P2)**: US1 (oil is installed).
- **US4 (P2)**: US1 (gitsigns is installed) and the terminal helper from T006. It does not depend on US5.
- **US5 (P3)**: Foundational (T006) only.
- **US6 (P3)**: US1 (theme and icons are installed). US3 shows the icons, but US6 does not need US3.

### Shared files

- `init.lua` changes in T004, T010, T027, T032, T038, T042, T047. Do these tasks one at a time.
- `lua/config/keymaps.lua` changes in T007 and T046.
- `lua/config/terminal.lua` changes in T006 and T041.
- `lua/config/git.lua` changes in T036 and T037.

### Parallel opportunities

- Phase 2: T005 and T006.
- Phase 3: T007, T008, T009.
- Phase 4: T014, T015, T016 to T024, T025 (12 tasks, all different files).
- Phase 6: T035 parallel with T036.
- Phase 9: T050 and T051.
- After Phase 3, one person can do US2, another US3, another US4 or US5, if each person edits `init.lua` in turn.

---

## Parallel example: User Story 2

```text
Task: "Create lua/config/filetypes.lua"            (T014)
Task: "Create lua/config/treesitter.lua"           (T015)
Task: "Create lsp/tsc.lua"                         (T016)
Task: "Create lsp/terraformls.lua"                 (T017)
Task: "Create lsp/yamlls.lua"                      (T018)
Task: "Create lsp/helm_ls.lua"                     (T019)
Task: "Create lsp/basedpyright.lua"                (T020)
Task: "Create lsp/ruff.lua"                        (T021)
Task: "Create lsp/ansiblels.lua"                   (T022)
Task: "Create lsp/marksman.lua"                    (T023)
Task: "Create lsp/jsonls.lua"                      (T024)
Task: "Create after/ftplugin/markdown.lua"         (T025)
```

Then T026 (`lua/config/lsp.lua`), T027 (`init.lua`), T028 (capability check).

## Parallel example: User Story 1

```text
Task: "Create lua/config/keymaps.lua"   (T007)
Task: "Create lua/config/autocmds.lua"  (T008)
Task: "Create lua/config/plugins.lua"   (T009)
```

---

## Implementation strategy

### MVP first (User Story 1 only)

1. Complete Phase 1: remove the old configuration.
2. Complete Phase 2: entry point, options, terminal helper.
3. Complete Phase 3: User Story 1.
4. Stop and validate: quickstart.md steps 1, 3, 4.

### Incremental delivery

1. Setup and Foundational: empty base that starts.
2. US1: own configuration with pinned extensions (MVP).
3. US2: language support. The editor is ready for daily work.
4. US3: file manager.
5. US4: Git.
6. US5: terminal overlay.
7. US6: appearance.
8. Polish: health check, README, full validation.

Each story ends with a commit, so each increment is a known good state.

---

## Notes

- [P] tasks change different files and have no dependency on incomplete tasks.
- Each validation task uses quickstart.md, because the spec does not request automated tests.
- Ask the user before a destructive git command or before you delete files that this task list did not create.
