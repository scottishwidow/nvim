return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  settings = {
    json = { validate = { enable = true } },
  },
  -- The client keeps a reference to this settings table, so change it in place.
  before_init = function(_, config)
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
}
