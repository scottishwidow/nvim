-- Usage: nvim --headless -c "luafile scripts/build-parsers.lua"
-- Installs the treesitter parsers from LazyVim's `ensure_installed` with a limit on parallel builds.
-- Without the limit, nvim-treesitter compiles all parsers at once, which uses all memory on small machines.

local MAX_JOBS = tonumber(vim.env.TS_MAX_JOBS) or 2
local TIMEOUT_MS = 15 * 60 * 1000

local function main()
  local Config = require("lazy.core.config")
  local Plugin = require("lazy.core.plugin")
  local treesitter = Config.plugins["nvim-treesitter"]
  assert(treesitter, "nvim-treesitter is not in the plugin spec")
  assert(not treesitter._.loaded, "nvim-treesitter loaded before its config could be replaced")

  local opts = Plugin.values(treesitter, "opts", false)
  -- LazyVim's config starts its own install of missing parsers with no job limit.
  treesitter.config = function(_, plugin_opts)
    require("nvim-treesitter").setup(plugin_opts)
  end

  local cli_ok, cli_err
  LazyVim.treesitter.ensure_treesitter_cli(function(ok, err)
    cli_ok, cli_err = ok, err
  end)
  assert(
    vim.wait(TIMEOUT_MS, function()
      return cli_ok ~= nil
    end),
    "timed out while installing the tree-sitter CLI"
  )
  assert(cli_ok, cli_err)

  local function install_missing()
    return require("nvim-treesitter")
      .install(opts.ensure_installed, { max_jobs = MAX_JOBS, summary = true })
      :wait(TIMEOUT_MS)
  end

  if not install_missing() then
    io.stdout:write("retrying parsers that failed to build\n")
    assert(install_missing(), "some parsers did not install, see :TSLog")
  end
end

local ok, err = xpcall(main, debug.traceback)
if ok then
  io.stdout:write("parsers installed\n")
  vim.cmd("qall!")
else
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
