# Implementation Plan: Minimal Neovim Configuration Rebuild

**Branch**: `worktree-001-minimal-nvim-config` | **Date**: 2026-11-10 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-minimal-nvim-config/spec.md`

## Summary

Remove the LazyVim configuration and write a new configuration from an empty base. The new configuration uses the Neovim 0.12 built-in package manager (`vim.pack`). It has 6 pinned extensions. Language servers come from the system `PATH` and have one config file each in `lsp/`. Completion, formatting, fuzzy search, the terminal overlay, and the LazyGit window use only native features. A new `README.md` lists the setup steps and all dependencies with exact versions.

User input for this plan:

1. Delete the old configuration. Start from an empty base.
2. Write `README.md` with setup steps and requirements, including dependencies.
3. The result is a new project that does not use Lazy.

## Technical Context

**Language/Version**: Lua (LuaJIT 2.1) in Neovim 0.12 or later. Machine version: 0.12.5.

**Primary Dependencies**: 6 extensions, listed in [research.md](research.md) R2: nvim-treesitter (`main`), SchemaStore.nvim, oil.nvim, nvim-web-devicons, gitsigns.nvim, solarized-osaka.nvim. LazyGit 0.66.3 is the Git interface (external tool, not installed on this machine).

**External tools**: `git`, `rg`, `curl`, `tar`, a C compiler, `tree-sitter-cli` 0.26.1 or later (0.27.2 installed), a Nerd Font, 9 language server commands, and `prettier` (research.md R4, R6). All tools passed the maintenance audit (research.md R0, R4).

**Storage**: Files. `nvim-pack-lock.json` is committed.

**Testing**: Headless Neovim checks, `:checkhealth config`, and the manual steps in [quickstart.md](quickstart.md).

**Target Platform**: Linux under WSL2. Also plain Linux and macOS without the WSL clipboard.

**Project Type**: Editor configuration (single project).

**Performance Goals**: Startup in less than 100 ms after first install (SC-001).

**Constraints**: 15 extensions or fewer (SC-002). No lazy-loading framework. Each extension pinned (`SECURITY.md`).

**Scale/Scope**: About 20 Lua files, about 600 lines in total.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The gates come from `CLAUDE.md` (a link to `AGENTS.md`) and `SECURITY.md`. The user decided that these rules are sufficient. The spec-kit constitution stays an empty template.

| Gate | Source | Pre-design | Post-design |
|------|--------|------------|-------------|
| Work in a git worktree | AGENTS.md Git | Pass | Pass |
| Self-documenting code, comments only when required | AGENTS.md Code Comments | Pass | Pass (no code yet; tasks must obey) |
| Document only when asked | AGENTS.md | Pass: the user asks for README.md | Pass |
| ASD-STE100 style, no emojis in Markdown | AGENTS.md | Pass | Pass |
| Pin each dependency to an exact version | SECURITY.md | Pass | Pass: tags or SHAs in R2; README pins tool versions |
| Commit lock files | SECURITY.md | Pass | Pass: `nvim-pack-lock.json` |
| Verify each package exists in its registry | SECURITY.md | Pass for extensions | Pass: all tools checked in npm, PyPI, and GitHub releases (research.md R4) |
| Use only maintained tools | User decision | Pass | Pass: audit in research.md R0, R2, R4 |
| Prefer native features to new dependencies | SECURITY.md, FR-004 | Pass | Pass: 6 extensions, each with a reason |
| Tell the user about each new dependency | SECURITY.md | Pass | Pass: R2 table |
| No `curl ... \| sh` | SECURITY.md | Pass | Pass: README must use package managers or release archives |

No violations. Complexity Tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-minimal-nvim-config/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── keymaps.md       # Phase 1
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

Delete:

```text
lua/config/autocmds.lua
lua/config/keymaps.lua
lua/config/lazy.lua
lua/config/lspconfig.lua
lua/config/options.lua
lua/plugins/                # all files
lazy-lock.json
lazyvim.json
.neoconf.json
README.md                   # replaced
init.lua                    # replaced
```

Create:

```text
init.lua                    # version check, leader keys, load modules in order
nvim-pack-lock.json         # written by vim.pack, committed
README.md                   # setup, requirements, dependencies, update and removal steps
stylua.toml                 # kept
lsp/
├── tsc.lua
├── terraformls.lua
├── yamlls.lua
├── helm_ls.lua
├── basedpyright.lua
├── ruff.lua
├── ansiblels.lua
├── marksman.lua
└── jsonls.lua
lua/config/
├── options.lua             # editor options, WSL clipboard, findfunc, grepprg
├── keymaps.lua             # global keys (kept keys, search, appearance)
├── autocmds.lua            # yank highlight, other small autocommands
├── plugins.lua             # one vim.pack.add() call with pinned versions
├── filetypes.lua           # Helm, Ansible, Terraform detection
├── treesitter.lua          # parser install, highlight and fold start
├── lsp.lua                 # PATH check, vim.lsp.enable, completion, LSP keys, diagnostics
├── files.lua               # oil setup and its keys
├── git.lua                 # gitsigns setup, LazyGit key
├── terminal.lua            # floating terminal: shell overlay and LazyGit window
├── appearance.lua          # theme, icons
└── health.lua              # :checkhealth config
after/ftplugin/
└── markdown.lua            # formatprg = prettier
lazygit/
└── config.yml              # os.editPreset: nvim-remote, merged with the user's LazyGit config
```

**Structure Decision**: Single project. `lsp/` uses the native Neovim 0.12 runtime directory for server configs. `lua/config/` has one module for each concern. `init.lua` loads the modules in this order: options, filetypes, plugins, appearance, treesitter, lsp, files, git, terminal, keymaps, autocmds.

## Implementation Phases

1. **Remove the old configuration.** Delete the files in the list above. Commit.
2. **Base.** `init.lua`, `options.lua`, `keymaps.lua`, `autocmds.lua`. The editor starts with native features only. (User Story 1)
3. **Extensions.** `plugins.lua` with pinned versions. First start writes `nvim-pack-lock.json`. Commit the lock file. (User Story 1)
4. **Languages.** `filetypes.lua`, `treesitter.lua`, `lsp.lua`, `lsp/*.lua`, `after/ftplugin/markdown.lua`. (User Story 2)
5. **File manager.** `files.lua`. (User Story 3)
6. **Terminal.** `terminal.lua`. (User Story 5)
7. **Git.** `git.lua`, `lazygit/config.yml`. Depends on phase 6. (User Story 4)
8. **Appearance.** `appearance.lua`. (User Story 6)
9. **Health and README.** `health.lua`. Check the current version of each external tool in its registry. Write `README.md` with exact versions.
10. **Validation.** Run [quickstart.md](quickstart.md).

## README.md contents

- Purpose of the configuration
- Requirements: Neovim version, system tools, Nerd Font
- Language tools: one table with the language, tool, exact version, and install command
- Install steps: clone, first start, `:checkhealth config`
- Removal of old LazyVim data: `~/.local/share/nvim/lazy`, `~/.local/state/nvim/lazy`, `~/.cache/nvim` (the user runs these commands)
- Update steps: `vim.pack.update()`, `:TSUpdate`, commit the lock file
- Structure: one line for each file
- Keys: link to the key list, or a short table

## Risks

| Risk | Mitigation |
|------|------------|
| `tree-sitter-cli` is missing on a new machine, so parsers do not build | README lists it as a requirement. `:checkhealth config` reports it. The editor falls back to regex syntax. |
| The TypeScript 7 server does not give all features (for example formatting or code actions) | Check the server capabilities in phase 4. Use `prettier` through `formatprg` for formatting if necessary. Report other gaps to the user before a workaround. |
| A tool stops being maintained | Run the R0 audit again before each update of tools or extensions. |
| nvim-treesitter `main` changes its API | Pinned to a SHA. Update only on request. |
| `helm` and `yaml.ansible` detection conflicts with `yaml` | Specific patterns in `filetypes.lua`. Quickstart step 6 tests each one. |
| Native completion is slower or has fewer features than blink.cmp | Accepted for simplicity. Revisit only if the user asks. |
| `<A-t>` does not reach Neovim in the WSL terminal | Quickstart step 9 tests it. Change the key in `terminal.lua` if necessary. |
| A file opened from LazyGit opens in a nested editor | `lazygit/config.yml` sets `os.editPreset: nvim-remote`. Quickstart step 8 tests it. |

## Complexity Tracking

No violations.
