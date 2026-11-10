local parsers = {
  "typescript",
  "tsx",
  "javascript",
  "jsdoc",
  "hcl",
  "terraform",
  "yaml",
  "helm",
  "python",
  "json",
  "markdown",
  "markdown_inline",
  "gitcommit",
  "git_config",
  "git_rebase",
  "gitignore",
  "diff",
  "bash",
}

if vim.fn.executable("tree-sitter") == 1 then
  require("nvim-treesitter").install(parsers)
else
  vim.notify("tree-sitter-cli not found on PATH. Parsers are not installed. Regex syntax is used.", vim.log.levels.WARN)
end

vim.treesitter.language.register("yaml", "yaml.ansible")
vim.treesitter.language.register("terraform", "terraform-vars")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
  callback = function(args)
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end
    local win = vim.fn.bufwinid(args.buf)
    if win == -1 then
      return
    end
    vim.wo[win][0].foldmethod = "expr"
    vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[win][0].foldlevel = 99
  end,
})
