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
                "rust_analyzer",
            },
            automatic_enable = false,
        })

        -------------------------------------------------
        -- LSP Setup
        -------------------------------------------------
        local lspconfig = require("lspconfig")

        local on_attach = function(_, bufnr)
            local opts = { buffer = bufnr, noremap = true, silent = true }

            local keymap = vim.keymap.set

            -- Core
            keymap("n", "gd", vim.lsp.buf.definition, opts)
            keymap("n", "gD", vim.lsp.buf.declaration, opts)
            keymap("n", "gr", vim.lsp.buf.references, opts)
            keymap("n", "gi", vim.lsp.buf.implementation, opts)
            keymap("n", "gt", vim.lsp.buf.type_definition, opts)
            keymap("n", "gh", vim.lsp.buf.hover, opts)
            keymap("n", "gH", vim.lsp.buf.signature_help, opts)

            -- Diagnostics
            keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
            keymap("n", "[d", vim.diagnostic.goto_prev, opts)
            keymap("n", "]d", vim.diagnostic.goto_next, opts)
            keymap("n", "<leader>q", vim.diagnostic.setloclist, opts)

            -- Actions
            keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
            keymap("n", "<leader>f", function()
                vim.lsp.buf.format { async = true }
            end, opts)
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
            "rust_analyzer",
        }

        for _, server in ipairs(servers) do
            local opts = {
                on_attach = on_attach,
                capabilities = capabilities,
            }
            
            if server == "lua_ls" then
                opts.settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                }
            end

            require("lspconfig")[server].setup(opts)
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

