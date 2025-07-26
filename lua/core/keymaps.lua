-- lua/core/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>ut", function()
  require("core.colorscheme").cycle()
end, { desc = "Cycle theme" })

