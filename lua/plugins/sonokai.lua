-- plugins/sonokai.lua

return {
    "sainnhe/sonokai",
    lazy = true,
    priority = 1000,
    config = function()
        -- Defaults — will be overridden by your picker when it applies a variant
        vim.g.sonokai_style = "espresso" -- "default", "atlantis", "andromeda", "shusia", "maia", "espresso"
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_enable_italic = 1
        vim.g.sonokai_disable_italic_comment = 0
    end,
}

