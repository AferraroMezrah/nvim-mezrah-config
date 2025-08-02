-- plugins/gruvbox.lua

return {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    priority = 1000,
    config = function()
        require("gruvbox").setup({
            transparent_mode = true,
            contrast = "soft", -- optional: "hard" | "soft" | ""
            terminal_colors = true,
            italic = {
                strings = true,
                comments = true,
            },
            overrides = {
                -- Optional tweaks:
                -- SignColumn = { bg = "none" },
                -- NormalFloat = { bg = "none" },
            }
        })

        vim.o.background = "dark"
        vim.cmd("colorscheme gruvbox")
    end,
}

