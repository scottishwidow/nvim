-- Usage: nvim --headless -c "luafile scripts/install-mason-packages.lua"
-- Installs the Mason packages from LazyVim's mason `ensure_installed` and waits until they finish.
-- LazyVim starts these installs in the background, and they stop when Neovim exits.

local TIMEOUT_MS = 10 * 60 * 1000

local function main()
  local package_names = LazyVim.opts("mason.nvim").ensure_installed
  local registry = require("mason-registry")

  local refreshed = false
  registry.refresh(function()
    refreshed = true
  end)
  assert(
    vim.wait(TIMEOUT_MS, function()
      return refreshed
    end, 200),
    "timed out while refreshing the Mason registry"
  )

  local pending, failed = {}, {}
  for _, name in ipairs(package_names) do
    local package = registry.get_package(name)
    if not package:is_installed() then
      pending[name] = true
      local function finish(success)
        pending[name] = nil
        if not success then
          table.insert(failed, name)
        end
      end

      if package:is_installing() then
        package:once("install:success", function()
          finish(true)
        end)
        package:once("install:failed", function()
          finish(false)
        end)
      else
        package:install({}, finish)
      end
    end
  end

  local all_finished = vim.wait(TIMEOUT_MS, function()
    return next(pending) == nil
  end, 200)
  assert(all_finished, "timed out while installing Mason packages: " .. table.concat(vim.tbl_keys(pending), ", "))
  assert(#failed == 0, "Mason packages failed to install: " .. table.concat(failed, ", "))
end

local ok, err = xpcall(main, debug.traceback)
if ok then
  io.stdout:write("mason packages installed\n")
  vim.cmd("qall!")
else
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
