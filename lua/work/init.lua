-- lua/work/init.lua

pcall(require, "work.config.sf")
pcall(require, "work.config.filetypes")
pcall(require, "work.lsp")

-- future additions:
-- pcall(require, "work.keymaps")

vim.opt.fixendofline = false
vim.opt.colorcolumn = "120"

