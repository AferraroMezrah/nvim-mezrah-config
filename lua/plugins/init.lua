-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    require("plugins.telescope"),

      -- Utility dependency (required by others)
  { "nvim-lua/plenary.nvim" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate", -- auto-updates parsers when running `:Lazy sync`
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "markdown", "bash", "python" }, -- customize as needed
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Harpoon (optional, but Primeagen-approved)
  {
    "ThePrimeagen/harpoon",
    config = function()
      require("harpoon").setup()
    end,
  },

  -- Colorscheme
  { "folke/tokyonight.nvim" },
}, {
    rocks = {
        enabled = false,
        hererocks = false
    },
})

