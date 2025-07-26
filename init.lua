-- init.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.providers")
require("core.keymaps")
require("plugins.init")
vim.cmd.colorscheme("tokyonight")

