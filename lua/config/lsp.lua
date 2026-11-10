local M = {}

M.server_executables = {
  tsc = "tsc",
  terraformls = "terraform-ls",
  yamlls = "yaml-language-server",
  helm_ls = "helm_ls",
  basedpyright = "basedpyright-langserver",
  ruff = "ruff",
  ansiblels = "ansible-language-server",
  marksman = "marksman",
  jsonls = "vscode-json-languageserver",
}

local group = vim.api.nvim_create_augroup("config_lsp", { clear = true })

-- A PATH lookup for a missing command is slow under WSL, because PATH has Windows directories.
-- So each server is checked only when the first file of one of its file types opens.
local checked_servers = {}

local function enable_servers_for(filetype)
  for name, executable in vim.spairs(M.server_executables) do
    if not checked_servers[name] and vim.tbl_contains(vim.lsp.config[name].filetypes, filetype) then
      checked_servers[name] = true
      if vim.fn.executable(executable) == 1 then
        vim.lsp.enable(name)
      else
        vim.notify(
          ("%s not found on PATH. Install it to get language features."):format(executable),
          vim.log.levels.WARN
        )
      end
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    enable_servers_for(args.match)
  end,
})

vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.autocomplete = true

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

local function format_buffer_or_selection()
  local formatting_clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/formatting" })
  if #formatting_clients > 0 then
    vim.lsp.buf.format()
    return
  end
  if vim.fn.mode():match("^[vV\22]") then
    vim.cmd("normal! gq")
    return
  end
  local view = vim.fn.winsaveview()
  vim.cmd("normal! gggqG")
  vim.fn.winrestview(view)
end

vim.keymap.set({ "n", "v" }, "<leader>cf", format_buffer_or_selection, { desc = "Format buffer or selection" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local buf = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
    vim.keymap.set(
      "n",
      "<leader>cd",
      vim.diagnostic.setloclist,
      { buffer = buf, desc = "Buffer diagnostics to location list" }
    )

    if client.name == "terraformls" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = buf, id = client.id })
        end,
      })
    end
  end,
})

return M
