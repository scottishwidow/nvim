local M = {}

local health = vim.health
local minimum_tree_sitter = "0.26.1"
local maximum_extensions = 15

local function check_neovim()
  local version = tostring(vim.version())
  if vim.fn.has("nvim-0.12") == 1 then
    health.ok("Neovim " .. version)
  else
    health.error("Neovim " .. version .. " is too old. Install Neovim 0.12 or later.")
  end
end

local function check_executable(name, purpose)
  if vim.fn.executable(name) == 1 then
    health.ok(name .. " found")
  else
    health.warn(name .. " not found on PATH. " .. purpose)
  end
end

local function check_c_compiler()
  for _, compiler in ipairs({ "cc", "gcc", "clang" }) do
    if vim.fn.executable(compiler) == 1 then
      health.ok("C compiler found: " .. compiler)
      return
    end
  end
  health.warn("No C compiler found (cc, gcc, or clang). Tree-sitter parsers cannot be built.")
end

local function check_tree_sitter()
  if vim.fn.executable("tree-sitter") == 0 then
    health.warn("tree-sitter not found on PATH. Install tree-sitter-cli " .. minimum_tree_sitter .. " or later.")
    return
  end
  local output = vim.system({ "tree-sitter", "--version" }, { text = true }):wait().stdout or ""
  local version = vim.version.parse(output:match("%d+%.%d+%.%d+") or "")
  if version and vim.version.ge(version, minimum_tree_sitter) then
    health.ok("tree-sitter " .. tostring(version))
  else
    health.warn(("tree-sitter %s is older than %s."):format(tostring(version or "unknown"), minimum_tree_sitter))
  end
end

local function check_language_servers()
  local server_executables = require("config.lsp").server_executables
  for name, executable in vim.spairs(server_executables) do
    if vim.fn.executable(executable) == 1 then
      health.ok(("%s: %s found"):format(name, executable))
    else
      health.warn(("%s: %s not found on PATH"):format(name, executable))
    end
  end
end

local function check_extensions()
  local count = #vim.pack.get()
  if count <= maximum_extensions then
    health.ok(("%d extensions installed (limit %d)"):format(count, maximum_extensions))
  else
    health.error(("%d extensions installed. The limit is %d."):format(count, maximum_extensions))
  end
end

function M.check()
  health.start("Neovim")
  check_neovim()

  health.start("External tools")
  check_executable("git", "Git features and extension install do not work.")
  check_executable("rg", "File search and text search do not work.")
  check_executable("curl", "Tree-sitter parsers cannot be downloaded.")
  check_executable("tar", "Tree-sitter parsers cannot be unpacked.")
  check_c_compiler()
  check_tree_sitter()
  check_executable("lazygit", "<leader>gg does not work.")
  check_executable("prettier", "Markdown formatting does not work.")

  health.start("Language servers")
  check_language_servers()

  health.start("Extensions")
  check_extensions()
end

return M
