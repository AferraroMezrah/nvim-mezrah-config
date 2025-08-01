-- plugins/gitsigns.lua

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          gs.next_hunk()
        end, "Next Hunk")

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          gs.prev_hunk()
        end, "Prev Hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage Hunk (Visual)")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset Hunk (Visual)")

        map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>hi", gs.preview_hunk_inline, "Inline Preview")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>hd", gs.diffthis, "Diff This")
        map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff ~")

        -- Toggles
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Blame")
        map("n", "<leader>tw", gs.toggle_word_diff, "Toggle Word Diff")

        -- Text object
        map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
      end,
    })
  end,
}

