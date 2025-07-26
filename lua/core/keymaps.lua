-- lua/core/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>ut", function()
  require("core.colorscheme").cycle()
end, { desc = "Cycle theme" })

vim.keymap.set("n", "<leader>fp", function()
  require("core.colorscheme_picker").pick()
end, { desc = "Pick colorscheme with preview" })

