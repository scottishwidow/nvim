# Data Model: Minimal Neovim Configuration Rebuild

**Feature**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

This project has no database. These entities are the units of the configuration.

## Configuration module

One Lua file with one purpose.

| Field | Description |
|-------|-------------|
| Path | Path relative to the repository root, for example `lua/config/options.lua` |
| Purpose | One sentence. The file name must show it. |
| Load order | Position in `init.lua` |

Rules:

- `init.lua` checks the Neovim version first and stops with a message if it is older than 0.12 (FR-005).
- `init.lua` sets the leader keys before any module sets a key (FR-007).
- `init.lua` loads `plugins` before modules that call extension code.
- A module must not call code from the old distribution (FR-001).

## Extension

A third-party addition that `vim.pack` installs.

| Field | Description |
|-------|-------------|
| Source | Full Git URL |
| Version | Release tag, or full commit SHA if there is no tag |
| Reason | Requirement that no native feature satisfies |
| Configured in | Configuration module that sets it up |

Rules:

- Each extension must have a pinned `version` (`SECURITY.md`).
- Each extension must be in `nvim-pack-lock.json`.
- The total number of extensions must be 15 or fewer (SC-002).
- The list of extensions is in [research.md](research.md), section R2.

## Lock file

`nvim-pack-lock.json`. `vim.pack` writes it. It is committed. It records the source and the exact revision of each extension.

## Language profile

The full support for one language.

| Field | Description |
|-------|-------------|
| File types | Neovim file types, for example `typescript`, `typescriptreact` |
| Detection rule | Built-in, or a `vim.filetype.add()` rule |
| Parsers | Tree-sitter parsers |
| Server config | Files in `lsp/` |
| Server command | Executable that must be on `PATH` |
| Formatter | LSP server, `formatprg`, or none |
| Schemas | SchemaStore catalog, or none |

| Language | File types | Parsers | Server config | Formatter | Schemas |
|----------|-----------|---------|---------------|-----------|---------|
| TypeScript | `typescript`, `typescriptreact` | `typescript`, `tsx`, `jsdoc` | `tsc` | `tsc`, or `prettier` via `formatprg` | none |
| JavaScript | `javascript`, `javascriptreact` | `javascript`, `jsdoc` | `tsc` | `tsc`, or `prettier` via `formatprg` | none |
| Terraform | `terraform`, `terraform-vars`, `hcl` | `terraform`, `hcl` | `terraformls` | `terraformls` | none |
| YAML | `yaml` | `yaml` | `yamlls` | `yamlls` | SchemaStore |
| Helm | `helm` | `helm`, `yaml` | `helm_ls` | none | via `helm_ls` |
| Python | `python` | `python` | `basedpyright`, `ruff` | `ruff` | none |
| Ansible | `yaml.ansible` | `yaml` | `ansiblels` | none | none |
| Markdown | `markdown` | `markdown`, `markdown_inline` | `marksman` | `prettier` via `formatprg` | none |
| JSON | `json`, `jsonc` | `json` | `jsonls` | `jsonls` | SchemaStore |
| Git | `gitcommit`, `gitconfig`, `gitrebase`, `gitignore`, `diff` | `gitcommit`, `git_config`, `git_rebase`, `gitignore`, `diff` | none | none | none |

States of a profile in a buffer:

```text
file opened -> file type set -> parser found? -> highlight on
                              -> server command on PATH? -> yes: server attaches
                                                         -> no: one warning, native features only
```

## Cheat sheet

The oil help window (`g?`). Each oil key in the configuration has a `desc` field. The help window lists each key with its `desc`.

## Keymap

| Field | Description |
|-------|-------------|
| Mode | `n`, `v`, `t`, and so on |
| Keys | Key sequence |
| Action | Command or function |
| Description | Text that the editor shows (FR-009) |
| Scope | Global or buffer-local |

The full list is in [contracts/keymaps.md](contracts/keymaps.md).
