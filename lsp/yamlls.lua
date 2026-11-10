return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_markers = { ".git" },
  settings = {
    yaml = { schemaStore = { enable = false, url = "" } },
  },
  -- The client keeps a reference to this settings table, so change it in place.
  before_init = function(_, config)
    config.settings.yaml.schemas = require("schemastore").yaml.schemas()
  end,
}
