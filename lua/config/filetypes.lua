local helm_priority = 20
local ansible_priority = 10

local function helm_if_chart_template(path)
  local chart_dir = path:match("^(.*)/templates/")
  if chart_dir and vim.uv.fs_stat(chart_dir .. "/Chart.yaml") then
    return "helm"
  end
end

local helm_rule = { helm_if_chart_template, { priority = helm_priority } }
local ansible_rule = { "yaml.ansible", { priority = ansible_priority } }

vim.filetype.add({
  extension = {
    tf = "terraform",
    tfvars = "terraform-vars",
  },
  filename = {
    ["site.yml"] = "yaml.ansible",
    ["playbook.yml"] = "yaml.ansible",
  },
  pattern = {
    [".*/templates/.*%.ya?ml"] = helm_rule,
    [".*/templates/.*%.tpl"] = helm_rule,
    [".*/templates/.*%.txt"] = helm_rule,
    [".*/playbooks/.*%.ya?ml"] = ansible_rule,
    [".*/roles/.*/tasks/.*%.ya?ml"] = ansible_rule,
    [".*/roles/.*/handlers/.*%.ya?ml"] = ansible_rule,
    [".*/group_vars/.*"] = ansible_rule,
    [".*/host_vars/.*"] = ansible_rule,
  },
})
