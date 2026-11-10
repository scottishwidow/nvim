local minimum_native_server_major = 7

local function project_tsc(root_dir)
  if not root_dir then
    return nil
  end
  local local_tsc = root_dir .. "/node_modules/.bin/tsc"
  if vim.fn.executable(local_tsc) == 0 then
    return nil
  end
  local result = vim.system({ local_tsc, "--version" }, { text = true }):wait()
  local major = tonumber((result.stdout or ""):match("(%d+)%."))
  if major and major >= minimum_native_server_major then
    return local_tsc
  end
end

return {
  cmd = function(dispatchers, config)
    local executable = project_tsc(config.root_dir) or "tsc"
    return vim.lsp.rpc.start({ executable, "--lsp", "--stdio" }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
}
