local gitsigns = require("gitsigns")

gitsigns.setup({
  on_attach = function(buf)
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
    end

    map("]h", function()
      gitsigns.nav_hunk("next")
    end, "Next change")
    map("[h", function()
      gitsigns.nav_hunk("prev")
    end, "Previous change")
    map("<leader>hp", gitsigns.preview_hunk, "Preview change")
    map("<leader>hr", gitsigns.reset_hunk, "Reset change")
    map("<leader>hs", gitsigns.stage_hunk, "Stage change")
    map("<leader>hb", function()
      gitsigns.blame_line({ full = true })
    end, "Blame for current line")
    map("<leader>gd", gitsigns.diffthis, "Diff against index")
  end,
})

local function lazygit_config_files()
  local files = {}
  local user_config_dir = vim.trim(vim.fn.system({ "lazygit", "--print-config-dir" }))
  local user_config = user_config_dir .. "/config.yml"
  if vim.v.shell_error == 0 and vim.uv.fs_stat(user_config) then
    table.insert(files, user_config)
  end
  table.insert(files, vim.fn.stdpath("config") .. "/lazygit/config.yml")
  return table.concat(files, ",")
end

local function open_lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit not found on PATH.", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(0, ".git") or vim.uv.cwd()
  local buf, win
  buf, win = require("config.terminal").open_float({
    cmd = "lazygit",
    cwd = root,
    env = { LG_CONFIG_FILE = lazygit_config_files() },
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
        vim.cmd.checktime()
      end)
    end,
  })
end

vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "Open LazyGit" })
