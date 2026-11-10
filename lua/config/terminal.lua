local M = {}

function M.open_float(opts)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  local buf = opts.buf
  local is_new_buffer = not (buf and vim.api.nvim_buf_is_valid(buf))
  if is_new_buffer then
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    border = "rounded",
  })

  if is_new_buffer then
    vim.fn.jobstart(opts.cmd, { term = true, cwd = opts.cwd, env = opts.env, on_exit = opts.on_exit })
  end

  vim.cmd.startinsert()
  return buf, win
end

return M
