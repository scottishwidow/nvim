local function setup_default_theme()
  require("solarized-osaka").setup({})
  vim.cmd.colorscheme("solarized-osaka")
end

pcall(function()
  require("nvim-web-devicons").setup()
end)

if not pcall(setup_default_theme) then
  vim.cmd.colorscheme("habamax")
end
