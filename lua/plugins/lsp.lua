-- plugins/lsp.lua

-- 1. Put on_attach in file scope so everyone can see it ------------
local M = {}

M.on_attach = function(_, bufnr)
    local opts    = { buffer = bufnr, noremap = true, silent = true }
    local keymap  = vim.keymap.set

    -- Core navigation
    keymap("n", "gd", vim.lsp.buf.definition,         opts)
    keymap("n", "gD", vim.lsp.buf.declaration,        opts)
    keymap("n", "gr", vim.lsp.buf.references,         opts)
    keymap("n", "gi", vim.lsp.buf.implementation,     opts)
    keymap("n", "gy", vim.lsp.buf.type_definition,    opts)
    keymap("n", "gh", vim.lsp.buf.hover,              opts)
    keymap("n", "gH", vim.lsp.buf.signature_help,     opts)

    -- Diagnostics
    keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
    keymap("n", "[d",         vim.diagnostic.goto_prev,  opts)
    keymap("n", "]d",         vim.diagnostic.goto_next,  opts)
    keymap("n", "<leader>q", vim.diagnostic.setloclist,  opts)

    -- Actions
    keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap("n", "<leader>rn", vim.lsp.buf.rename,      opts)
    keymap("n", "<leader>f",  function()
        vim.lsp.buf.format { async = true }
    end, opts)
end


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
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local util = require("lspconfig.util")

        -- Helper to create FileType autocommand for LSP
        local function setup_lsp(name, config)
            -- Merge with standard settings
            config.capabilities = capabilities
            config.on_attach = M.on_attach

            -- Register the config
            vim.lsp.config(name, config)

            -- Create FileType autocommand
            vim.api.nvim_create_autocmd("FileType", {
                pattern = config.filetypes,
                callback = function(ev)
                    local fname = vim.api.nvim_buf_get_name(ev.buf)

                    -- Find root directory
                    local root
                    if config.root_dir then
                        root = config.root_dir(fname, ev.buf)
                    end
                    root = root or vim.fs.dirname(fname)

                    -- Start the LSP client (reuses if already running for this root)
                    vim.lsp.start(vim.tbl_extend("force", config, {
                        name = name,
                        root_dir = root,
                    }))
                end,
            })
        end

        -- Configure each server
        setup_lsp("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            root_dir = util.root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git"),
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    telemetry = { enable = false },
                },
            },
        })

        setup_lsp("pyright", {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_dir = util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git"),
        })

        setup_lsp("ts_ls", {
            cmd = { "typescript-language-server", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
            root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
        })

        setup_lsp("html", {
            cmd = { "vscode-html-language-server", "--stdio" },
            filetypes = { "html", "templ" },
            root_dir = util.root_pattern("package.json", ".git"),
        })

        setup_lsp("cssls", {
            cmd = { "vscode-css-language-server", "--stdio" },
            filetypes = { "css", "scss", "less" },
            root_dir = util.root_pattern("package.json", ".git"),
        })

        setup_lsp("jsonls", {
            cmd = { "vscode-json-language-server", "--stdio" },
            filetypes = { "json", "jsonc" },
            root_dir = util.root_pattern(".git"),
        })

        setup_lsp("clangd", {
            cmd = { "clangd" },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
            root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
        })

        setup_lsp("gopls", {
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            root_dir = util.root_pattern("go.work", "go.mod", ".git"),
        })

        setup_lsp("rust_analyzer", {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_dir = util.root_pattern("Cargo.toml", "rust-project.json", ".git"),
        })

        -- Apex LSP (with jar check)
        local mason_apex_jar = vim.fn.expand(
            "~/.local/share/nvim/mason/packages/apex-language-server/extension/dist/apex-jorje-lsp.jar"
        )
        if vim.fn.filereadable(mason_apex_jar) == 1 then
            setup_lsp("apex_ls", {
                cmd = { "java", "-jar", mason_apex_jar },
                filetypes = { "apex" },
                root_dir = util.root_pattern("sfdx-project.json", "project-scratch-def.json", ".git"),
            })
        else
            vim.notify("Mason Apex jar not found at: " .. mason_apex_jar, vim.log.levels.WARN)
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

