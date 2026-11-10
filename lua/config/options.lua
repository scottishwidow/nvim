local M = {}

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.scrolloff = 8
opt.clipboard = "unnamedplus"

opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"
opt.wildoptions = "pum,fuzzy"

local cached_files

function M.find_files(cmdarg)
  if not cached_files then
    cached_files = vim.fn.systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" })
  end
  if cmdarg == "" then
    return cached_files
  end
  return vim.fn.matchfuzzy(cached_files, cmdarg)
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = vim.api.nvim_create_augroup("config_find_cache", { clear = true }),
  callback = function()
    cached_files = nil
  end,
})

opt.findfunc = "v:lua.require'config.options'.find_files"

if vim.fn.has("wsl") == 1 then
  local paste_command = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
    paste = { ["+"] = paste_command, ["*"] = paste_command },
    cache_enabled = 0,
  }
end

return M
