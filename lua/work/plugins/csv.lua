-- lua/work/plugins/csv.lua

return {
  "chrisbra/csv.vim",
  ft = "csv",
  config = function()
    vim.g.csv_autocmd_arrange = 1
    vim.g.csv_autocmd_align = 1

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "csv",
      callback = function()
        local opts = { buffer = true }

        vim.keymap.set("n", "<leader>ca", ":ArrangeColumn<CR>", vim.tbl_extend("force", opts, {
          desc = "CSV: Align Columns",
        }))
        vim.keymap.set("n", "<leader>cs", ":CSVSort<CR>", vim.tbl_extend("force", opts, {
          desc = "CSV: Sort",
        }))
        vim.keymap.set("n", "<leader>cf", ":CSVFoldColumn<CR>", vim.tbl_extend("force", opts, {
          desc = "CSV: Fold Column",
        }))
      end,
    })
  end,
}
