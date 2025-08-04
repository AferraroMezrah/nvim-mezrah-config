-- lua/work/plugins/apex_lsp.lua

return {
  "neovim/nvim-lspconfig",

  dependencies = { "williamboman/mason-lspconfig.nvim" },

  config = function()
    local lspconfig     = require("lspconfig")
    local capabilities  = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.apex_ls.setup({
      apex_jar_path                   = vim.fn.expand("~/.local/share/apex-lsp/apex-jorje-lsp.jar"),
      apex_enable_semantic_errors     = true,
      apex_enable_completion_statistics = false,
      filetypes = { "apex" },
      capabilities                    = capabilities,
      on_attach = require("plugins.lsp").on_attach,
    })
  end,
}

