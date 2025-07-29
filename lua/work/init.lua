-- lua/work/init.lua

pcall(require, "work.config.sf")
pcall(require, "work.config.filetypes")

-- future additions:
-- pcall(require, "work.lsp")
-- pcall(require, "work.keymaps")

vim.opt.fixendofline = false
