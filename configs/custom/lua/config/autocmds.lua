vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 0
    vim.bo.tabstop = 8
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.tabstop = 2
  end,
})

-- format on save

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    require("conform").format({ async = true })
  end,
})
