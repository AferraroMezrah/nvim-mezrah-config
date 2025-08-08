-- lua/work/lsp.lua

local ok = pcall(require, "lspconfig")
if not ok then return end

local lspconfig = require("lspconfig")
local util      = require("lspconfig.util")
local on_attach = require("plugins.lsp").on_attach
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Use your local jar path
local jar = vim.fn.expand("~/.local/share/apex-lsp/apex-jorje-lsp.jar")
if vim.fn.filereadable(jar) == 0 then
  vim.notify("Apex LSP jar not found at: " .. jar, vim.log.levels.WARN)
  return
end

lspconfig.apex_ls.setup({
  cmd         = { "java", "-jar", jar },
  filetypes   = { "apex" },
  root_dir    = util.root_pattern("sfdx-project.json", "project-scratch-def.json", ".git"),
  on_attach   = on_attach,
  capabilities = capabilities,
})

