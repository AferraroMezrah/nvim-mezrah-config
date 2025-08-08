return {
  "neovim/nvim-lspconfig",
  ft = { "apex" },  -- ensures this runs when you open .cls/.apex files
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local lspconfig    = require("lspconfig")
    local util         = require("lspconfig.util")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local on_attach    = require("plugins.lsp").on_attach

    -- Use your local jar path here
    local jar = vim.fn.expand("~/.local/share/apex-lsp/apex-jorje-lsp.jar")
    if vim.fn.filereadable(jar) == 0 then
      vim.notify("Apex LSP jar not found at: " .. jar, vim.log.levels.ERROR)
      return
    end

    lspconfig.apex_ls.setup({
      cmd         = { "java", "-jar", jar },
      filetypes   = { "apex" },
      root_dir    = util.root_pattern("sfdx-project.json", "project-scratch-def.json", ".git"),
      on_attach   = on_attach,
      capabilities = capabilities,

      -- Optional flags; keep minimal first, add later if you want:
      -- settings = {
      --   apex = {
      --     enableSemanticErrors = true,
      --     enableCompletionStatistics = false,
      --   },
      -- },
    })
  end,
}

