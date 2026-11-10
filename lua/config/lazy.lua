local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"

local function run_or_exit(cmd, failure_message)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { failure_message .. "\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

local committed_lock
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  committed_lock = vim.fn.readfile(lockfile)
  local locked_commit = vim.json.decode(table.concat(committed_lock, "\n"))["lazy.nvim"].commit
  run_or_exit({ "git", "clone", "--filter=blob:none", lazyrepo, lazypath }, "Failed to clone lazy.nvim:")
  run_or_exit({ "git", "-C", lazypath, "checkout", locked_commit }, "Failed to check out locked lazy.nvim commit:")
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", opts = { colorscheme = "solarized-osaka" }, import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "lazyvim.plugins.extras.lang.helm" },
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  lockfile = lockfile,
  rocks = { enabled = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- On a fresh install, lazy.nvim rewrites the lockfile before it installs the plugins that
-- LazyVim imports, and then installs those plugins at their latest commit.
-- Put the committed lockfile back and restore every plugin to it.
if committed_lock then
  vim.fn.writefile(committed_lock, lockfile)
  require("lazy.manage.lock")._loaded = false
  require("lazy").restore({ wait = true, show = false })
end
