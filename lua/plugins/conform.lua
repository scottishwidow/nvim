return {
  "stevearc/conform.nvim",
  optionsl = true,
  opts = {
    formatters_by_ft = {
      hcl = { "packer_fmt" },
      terraform = { "terraform_fmt" },
      tf = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
    },
  },
}
