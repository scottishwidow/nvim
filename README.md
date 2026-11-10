# Neovim Configuration

## Purpose

This is a small personal Neovim configuration. It uses only native Neovim 0.12 features and 6 pinned extensions. It does not use a distribution or a lazy-loading framework.

The configuration gives:

- Syntax highlighting with tree-sitter
- Language servers for TypeScript, JavaScript, Terraform, YAML, Helm, Python, Ansible, Markdown, and JSON
- Native completion, fuzzy file search, and text search
- A file manager with a cheat sheet
- Git change markers and a LazyGit window
- A floating terminal

## Requirements

| Item | Version | Purpose |
|------|---------|---------|
| Neovim | 0.12 or later | Editor |
| `git` | Any current version | Extension install, Git features |
| `rg` (ripgrep) | Any current version | File search and text search |
| `curl` and `tar` | Any current version | Tree-sitter parser download |
| C compiler (`cc`, `gcc`, or `clang`) | Any current version | Tree-sitter parser build |
| `tree-sitter-cli` | 0.26.1 or later (tested with 0.27.2) | Tree-sitter parser build |
| Nerd Font | Any | File icons. Without it, icons show as boxes. |
| LazyGit | 0.66.3 | Git interface |

Install `tree-sitter-cli` with Cargo. Do not use the npm package.

```sh
cargo install --locked tree-sitter-cli@0.27.2
```

Install LazyGit from the release archive and verify the checksum:

```sh
cd "$(mktemp -d)"
curl -fsSLO https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_x86_64.tar.gz
curl -fsSLO https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/checksums.txt
grep ' lazygit_0.66.3_linux_x86_64.tar.gz$' checksums.txt | sha256sum -c -
tar -xzf lazygit_0.66.3_linux_x86_64.tar.gz lazygit
install -m 755 lazygit ~/.local/bin/lazygit
```

## Language tools

The editor uses each tool from `PATH`. If a tool is missing, the editor shows one warning and continues without it.

| Language | Tool | Version | Install command |
|----------|------|---------|-----------------|
| TypeScript, JavaScript | `tsc` (npm `typescript`) | 7.0.2 | `npm install --global typescript@7.0.2` |
| Terraform | `terraform-ls` | 0.39.1 | See [Terraform](#terraform) |
| YAML | `yaml-language-server` | 2.0.0 | `npm install --global yaml-language-server@2.0.0` |
| Helm | `helm_ls` | 0.5.4 | See [Helm](#helm) |
| Python | `basedpyright` | 1.40.2 | `uv tool install basedpyright==1.40.2` |
| Python | `ruff` | 0.17.4 | `uv tool install ruff==0.17.4` |
| Ansible | `ansible-language-server` | 26.6.0 | `npm install --global @ansible/ansible-language-server@26.6.0` |
| Markdown | `marksman` | 2026-02-08 | See [Markdown](#markdown) |
| JSON | `vscode-json-language-server` | 4.10.0 | `npm install --global vscode-langservers-extracted@4.10.0` |
| Markdown format | `prettier` | 3.9.10 | `npm install --global prettier@3.9.10` |

A project can have its own TypeScript. When `node_modules/.bin/tsc` exists in the project and its major version is 7 or later, the editor uses it.

`ansible-language-server` gives better diagnostics when `ansible-lint` is installed. This tool is optional.

### Terraform

```sh
cd "$(mktemp -d)"
curl -fsSLO https://releases.hashicorp.com/terraform-ls/0.39.1/terraform-ls_0.39.1_linux_amd64.zip
curl -fsSLO https://releases.hashicorp.com/terraform-ls/0.39.1/terraform-ls_0.39.1_SHA256SUMS
grep ' terraform-ls_0.39.1_linux_amd64.zip$' terraform-ls_0.39.1_SHA256SUMS | sha256sum -c -
unzip terraform-ls_0.39.1_linux_amd64.zip terraform-ls
install -m 755 terraform-ls ~/.local/bin/terraform-ls
```

### Helm

The checksum file names a different path, so the command uses only the hash from it.

```sh
cd "$(mktemp -d)"
curl -fsSLO https://github.com/mrjosh/helm-ls/releases/download/v0.5.4/helm_ls_linux_amd64
curl -fsSLO https://github.com/mrjosh/helm-ls/releases/download/v0.5.4/helm_ls_linux_amd64.sha256sum
echo "$(cut -d ' ' -f 1 helm_ls_linux_amd64.sha256sum)  helm_ls_linux_amd64" | sha256sum -c -
install -m 755 helm_ls_linux_amd64 ~/.local/bin/helm_ls
```

### Markdown

The release has no checksum file. The digest below comes from the GitHub release data for this file.

```sh
cd "$(mktemp -d)"
curl -fsSLO https://github.com/artempyanykh/marksman/releases/download/2026-02-08/marksman-linux-x64
echo "be5098e8213219269c47fc0d916a66fa31ce0602ec967475c722260aabf26087  marksman-linux-x64" | sha256sum -c -
install -m 755 marksman-linux-x64 ~/.local/bin/marksman
```

## Install

1. Clone the repository:

   ```sh
   git clone <repository-url> ~/.config/nvim
   ```

2. Start Neovim once. The first start installs the extensions from `nvim-pack-lock.json` and builds the tree-sitter parsers:

   ```sh
   nvim
   ```

3. Run the health check. Fix each `ERROR`. A `WARNING` shows for each tool that is not installed.

   ```vim
   :checkhealth config
   ```

## Remove old LazyVim data

The old LazyVim configuration kept data outside the repository. The new configuration does not use it. To remove it, run:

```sh
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy
rm -rf ~/.cache/nvim
```

## Update

1. Update the extensions and the lock file:

   ```vim
   :lua vim.pack.update()
   ```

2. Update the tree-sitter parsers:

   ```vim
   :TSUpdate
   ```

3. Commit `nvim-pack-lock.json`.

Before you update, make sure that each extension and tool is still maintained.

## Structure

| File | Purpose |
|------|---------|
| `init.lua` | Checks the Neovim version, sets the leader keys, and loads the modules in order |
| `nvim-pack-lock.json` | Exact revision of each extension |
| `lua/config/options.lua` | Editor options, WSL clipboard, file search, and text search |
| `lua/config/filetypes.lua` | File type detection for Helm, Ansible, and Terraform |
| `lua/config/plugins.lua` | Pinned extension list |
| `lua/config/appearance.lua` | Theme and icons |
| `lua/config/treesitter.lua` | Parser install, highlighting, and folds |
| `lua/config/lsp.lua` | Language server start, completion, diagnostics, and language keys |
| `lua/config/files.lua` | File manager and its keys |
| `lua/config/git.lua` | Git change markers and the LazyGit window |
| `lua/config/terminal.lua` | Floating terminal for the shell and LazyGit |
| `lua/config/keymaps.lua` | Global keys |
| `lua/config/autocmds.lua` | Yank highlight |
| `lua/config/health.lua` | `:checkhealth config` |
| `lsp/*.lua` | One configuration file for each language server |
| `after/ftplugin/markdown.lua` | Markdown formatting with `prettier` |
| `lazygit/config.yml` | Opens files from LazyGit in the current editor |

## Keys

The leader key is `<Space>`. The full list is in [specs/001-minimal-nvim-config/contracts/keymaps.md](specs/001-minimal-nvim-config/contracts/keymaps.md).

| Keys | Action |
|------|--------|
| `<leader>ff` | Find file |
| `<leader>fg` | Search text |
| `<leader>fb` | Switch buffer |
| `<leader>e` | Open file manager. Press `g?` in it for the cheat sheet. |
| `gd` | Go to definition |
| `<leader>cf` | Format buffer or selection |
| `<leader>cd` | Buffer diagnostics to location list |
| `]h` / `[h` | Next / previous Git change |
| `<leader>gg` | Open LazyGit |
| `<leader>gd` | Diff current file against the Git index |
| `<A-t>` | Show or hide terminal |
| `<leader>uc` | Select theme |
