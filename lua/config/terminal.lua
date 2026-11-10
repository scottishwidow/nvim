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

local shell = { buf = nil, win = nil }

function M.toggle_shell()
  if shell.win and vim.api.nvim_win_is_valid(shell.win) then
    vim.api.nvim_win_hide(shell.win)
    shell.win = nil
    return
  end

  local previous_buf = shell.buf
  shell.buf, shell.win = M.open_float({
    buf = shell.buf,
    cmd = vim.o.shell,
    on_exit = function()
      vim.schedule(function()
        if shell.win and vim.api.nvim_win_is_valid(shell.win) then
          vim.api.nvim_win_close(shell.win, true)
        end
        if shell.buf and vim.api.nvim_buf_is_valid(shell.buf) then
          vim.api.nvim_buf_delete(shell.buf, { force = true })
        end
        shell.buf, shell.win = nil, nil
      end)
    end,
  })

  if shell.buf ~= previous_buf then
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = shell.buf, desc = "Leave terminal mode" })
  end
end

vim.keymap.set({ "n", "t" }, "<A-t>", M.toggle_shell, { desc = "Show or hide terminal" })

return M
