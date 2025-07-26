-- lua/plugins/fugitive.lua

return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" }, -- Lazy-load on Git commands
  keys = {
    { "<leader>gs", ":Git<CR>", desc = "Fugitive Git status" },
    { "<leader>gd", ":Gdiffsplit<CR>", desc = "Fugitive diff against index" },
    { "<leader>gb", ":Git blame<CR>", desc = "Fugitive blame" },
    { "<leader>gc", ":G commit<CR>", desc = "Fugitive commit" },
    { "<leader>gl", ":G log<CR>", desc = "Fugitive log" },
  },
  config = function()
    -- Optional: Custom behavior goes here if needed later
    -- For now, Fugitive works great out of the box
  end,
}

