-- plugins/tokyonight.lua

return {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            style = "moon", -- or "storm", "night", "day"
            transparent = true, -- this is what you're looking for
            styles = {
                sidebars = "transparent", -- optional: makes sidebars see-through too
                floats = "transparent",   -- optional: same for floats
            },
        })

        vim.cmd("colorscheme tokyonight")
    end,
}

