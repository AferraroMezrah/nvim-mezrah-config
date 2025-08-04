-- plugins/catppuccin.lua

return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha", -- or "auto" if you want to vary with background
            transparent_background = true,
            integrations = {
                treesitter = true,
                cmp = true,
                gitsigns = true,
            },
        })

        vim.cmd("colorscheme catppuccin")
    end,
}

