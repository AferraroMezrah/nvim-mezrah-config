-- plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    -- Completion engine
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",

    -- Snippet support
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    -------------------------------------------------
    -- Mason Setup
    -------------------------------------------------
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "clangd",
        "gopls",
      },
      automatic_installation = true,
    })

    -------------------------------------------------
    -- LSP Setup
    -------------------------------------------------
    local lspconfig = require("lspconfig")

    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local servers = {
      "lua_ls",
      "pyright",
      "ts_ls",
      "html",
      "cssls",
      "jsonls",
      "clangd",
      "gopls",
    }

    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end

    -------------------------------------------------
    -- Completion Setup
    -------------------------------------------------
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}

