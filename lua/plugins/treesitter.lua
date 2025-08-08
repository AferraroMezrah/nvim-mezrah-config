-- lua/plugins/treesitter.lua

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        -- Guarded parser registration so a failure doesn't kill the session
        local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
        if ok_parsers then
            local cfg = parsers.get_parser_configs()
            if not cfg.apex then
                cfg.apex = {
                    install_info = {
                        -- Start with austinjones; if build fails, switch to MrMufflon and add scanner.c
                        url = "https://github.com/austinjones/tree-sitter-apex",
                        files = { "src/parser.c" }, -- try {"src/parser.c","src/scanner.c"} if it errors
                        branch = "main",
                    },
                    filetype = "apex",
                }
            end
        end

        -- Your normal setup
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "lua","vim","markdown","markdown_inline",
                "bash","python","html","json","css","scss","yaml","toml",
                "javascript","typescript","go","c","rust",
                "apex", -- add
            },
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            indent = { enable = true, disable = { "apex" } }, -- be explicit; apex likely has no indent module
            sync_install = false,
            auto_install = false, -- avoid auto failures blocking startup; install manually once
        })
    end,
}

