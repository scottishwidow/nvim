-- Usage: nvim --headless -c "luafile scripts/smoke-test.lua"
-- Loads every plugin, opens a buffer for each configured language, and fails on errors.

local FILETYPES = { "lua", "json", "yaml", "helm", "terraform", "hcl", "typescript", "javascript" }
local SETTLE_TIME_MS = 3000
local ERROR_PATTERNS = { "^E%d+:", "^Error ", "Error executing", "stack traceback" }
local LAZYVIM_NOTIFY_RESTORE_TIMEOUT_MS = 1000

local errors = {}

local function capture_error_notifications()
  -- LazyVim queues notifications at startup and replays them through `vim.notify`.
  -- A wrapper around the queueing function sends the replay back into the queue, so the replay never ends.
  local startup_notify = vim.notify
  vim.wait(LAZYVIM_NOTIFY_RESTORE_TIMEOUT_MS, function()
    return vim.notify ~= startup_notify
  end)

  local notify = vim.notify
  vim.notify = function(message, level, opts)
    if level == vim.log.levels.ERROR then
      table.insert(errors, message)
    end
    return notify(message, level, opts)
  end
end

local function errors_in_messages()
  local found = {}
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  for _, line in ipairs(vim.split(messages, "\n")) do
    for _, pattern in ipairs(ERROR_PATTERNS) do
      if line:match(pattern) then
        table.insert(found, line)
        break
      end
    end
  end
  return found
end

local function main()
  capture_error_notifications()

  local lazy = require("lazy")
  local plugin_names = vim.tbl_map(function(plugin)
    return plugin.name
  end, lazy.plugins())
  lazy.load({ plugins = plugin_names })

  for _, filetype in ipairs(FILETYPES) do
    vim.cmd.enew()
    vim.bo.filetype = filetype
  end
  vim.wait(SETTLE_TIME_MS)

  vim.list_extend(errors, errors_in_messages())
  if #errors > 0 then
    error("smoke test found errors:\n" .. table.concat(errors, "\n"))
  end
end

local ok, err = xpcall(main, debug.traceback)
if ok then
  io.stdout:write("smoke test passed\n")
  vim.cmd("qall!")
else
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
