-- plugins/lsp.lua

local M = {}

-- Baseline on_attach for ALL servers (no special cases)
function M.base_on_attach(client, bufnr)
    local opts   = { buffer = bufnr, noremap = true, silent = true }
    local keymap = vim.keymap.set

    -- Core navigation
    keymap("n", "gd", vim.lsp.buf.definition,      opts)
    keymap("n", "gD", vim.lsp.buf.declaration,     opts)
    keymap("n", "gr", vim.lsp.buf.references,      opts)
    keymap("n", "gi", vim.lsp.buf.implementation,  opts)
    keymap("n", "gy", vim.lsp.buf.type_definition, opts)
    keymap("n", "gh", vim.lsp.buf.hover,           opts)
    keymap("n", "gH", vim.lsp.buf.signature_help,  opts)

    -- Diagnostics
    keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
    keymap("n", "[d", function()
        vim.diagnostic.jump({
            count = -vim.v.count1,
            float=true,
        })
    end, opts)
    keymap("n", "]d", function()
        vim.diagnostic.jump({
            count = vim.v.count1,
            float=true,
        })
    end, opts)
    keymap("n", "<leader>q", vim.diagnostic.setqflist, opts)

    -- Actions
    keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap("n", "<leader>rn", vim.lsp.buf.rename,      opts)
    keymap("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
    end, opts)
end

-- Server-specific on_attach for HTML:
-- In Visualforce buffers, let visualforce_ls own completion to avoid duplicates.
local function html_on_attach(client, bufnr)
    if vim.bo[bufnr].filetype == "visualforce" then
        client.server_capabilities.completionProvider = nil
    end
    M.base_on_attach(client, bufnr)
end

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        -- Completion engine
        -- "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        -- "hrsh7th/cmp-buffer",
        -- "hrsh7th/cmp-path",
        -- "hrsh7th/cmp-cmdline",
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
                "visualforce_ls",
            },
            automatic_enable = false,
        })

        -------------------------------------------------
        -- LSP Setup
        -------------------------------------------------
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local util = require("lspconfig.util")

        -- Helper to start/attach LSP for matching filetypes when opening real files.
        local function setup_lsp(name, config)
            config.capabilities = capabilities
            config.on_attach = config.on_attach or M.base_on_attach

            -- Register server config (Neovim 0.11+ API)
            vim.lsp.config(name, config)

            vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
                callback = function(ev)
                    local bufnr = ev.buf
                    local ft = vim.bo[bufnr].filetype
                    if not ft or ft == "" then return end

                    -- Only run for filetypes this server claims
                    local ok_ft = false
                    for _, f in ipairs(config.filetypes or {}) do
                        if f == ft then ok_ft = true break end
                    end
                    if not ok_ft then return end

                    local fname = vim.api.nvim_buf_get_name(bufnr)
                    if fname == "" then return end

                    local root
                    if config.root_dir then
                        root = config.root_dir(fname, bufnr)
                        if not root then
                            return -- IMPORTANT: don't start without a real project root
                        end
                    else
                        root = vim.fs.dirname(fname)
                        if not root then return end
                    end

                    -- Start or attach (Neovim reuses an existing client for same name/root)
                    vim.lsp.start(vim.tbl_extend("force", config, {
                        name = name,
                        root_dir = root,
                    }))
                end,
            })
        end


        -------------------------------------------------
        -- Servers
        -------------------------------------------------
        setup_lsp("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            root_dir = util.root_pattern(
                ".luarc.json", ".luarc.jsonc", ".luacheckrc",
                ".stylua.toml", "stylua.toml",
                "selene.toml", "selene.yml",
                ".git"
            ),
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                    telemetry = { enable = false },
                },
            },
        })

        setup_lsp("pyright", {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_dir = util.root_pattern(
                "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt",
                "Pipfile", "pyrightconfig.json", ".git"
            ),
        })

        setup_lsp("ts_ls", {
            cmd = { "typescript-language-server", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
            root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
        })

        -- HTML server: attaches to visualforce too, but uses html_on_attach to disable completion there
        setup_lsp("html", {
            cmd = { "vscode-html-language-server", "--stdio" },
            filetypes = { "html", "templ", "visualforce" },
            root_dir = util.root_pattern("package.json", "sfdx-project.json", ".git"),
            on_attach = html_on_attach,
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

        setup_lsp("visualforce_ls", {
            cmd = { "visualforce-language-server", "--stdio" },
            filetypes = { "visualforce" },
            root_dir = util.root_pattern("sfdx-project.json", ".git"),
        })

        -- Apex LSP (Mason jar)
        local mason_apex_jar = vim.fn.expand(
            "~/.local/share/nvim/mason/packages/apex-language-server/extension/dist/apex-jorje-lsp.jar"
        )
        if vim.fn.filereadable(mason_apex_jar) == 1 then
            setup_lsp("apex_ls", {
                cmd = { "java", "-jar", mason_apex_jar },
                filetypes = { "apex" },
                root_dir = util.root_pattern("sfdx-project.json", "project-scratch-def.json"),
            })
        else
            vim.notify("Mason Apex jar not found at: " .. mason_apex_jar, vim.log.levels.WARN)
        end

    end,
}

