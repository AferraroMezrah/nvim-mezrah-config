-- plugins/tokyonight.lua
return {
  "folke/tokyonight.nvim",
  lazy = true,
  name = "tokyonight",   -- This makes the theme work with Lazy
  priority = 1000, -- high so it loads early if chosen
  config = function()
    vim.g.tokyonight_style = "moon"
  end,
}

