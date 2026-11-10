local function locked_registry_version()
  local lockfile = vim.fn.stdpath("config") .. "/mason-lock.json"
  local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
  return lock.registry
end

local function restore_locked_packages()
  local registry = require("mason-registry")
  registry.refresh(function()
    for _, pkg in ipairs(registry.get_installed_packages()) do
      local installed = pkg:get_installed_version()
      local locked = pkg:get_latest_version()
      if installed ~= locked then
        vim.notify(("Mason: %s %s -> %s"):format(pkg.name, tostring(installed), locked))
        pkg:install({ version = locked })
      end
    end
  end)
end

return {
  "mason-org/mason.nvim",
  opts = {
    registries = { "github:mason-org/mason-registry@" .. locked_registry_version() },
  },
  init = function()
    vim.api.nvim_create_user_command("MasonRestore", restore_locked_packages, {
      desc = "Reinstall Mason packages at the versions of the locked registry",
    })
  end,
}
