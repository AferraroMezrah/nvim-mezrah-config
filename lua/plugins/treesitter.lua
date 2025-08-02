-- lua/plugins/treesitter.lua

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "lua", "vim", "markdown", "markdown_inline",
                "bash", "python", "html", "json", "css", "scss", "yaml", "toml",
                "javascript", "typescript", "go", "c", "rust",
            },

            highlight = 
                {
                    enable = true,
                    additional_vim_regex_highlighting = false
                },
            indent = { enable = true },
            sync_install = false,
            auto_install = true,
        })
    end,
}

