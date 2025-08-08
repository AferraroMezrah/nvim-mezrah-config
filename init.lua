-- init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = vim.fn.has("mac") == 1
    and vim.fn.system("fc-list | grep -i 'nerd font'") ~= ''

require("core.options")
require("core.providers")
require("core.keymaps")
require("core.filetypes")
require("core.autocmds.node")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local lazy_plugins = {
    { import = "plugins"},
}

require("lazy").setup(lazy_plugins, {
    rocks = {
        enabled = false,
        hererocks = false
    },
})

require("core.colorscheme").safe_startup()

require("core.sf")

