-- lua/core/colorscheme_picker.lua

local themeset = require("core.colorscheme")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local uv = vim.loop

local M = {}

M.pick = function()
  local themes = themeset.themes
  local original = themeset.load() or themes[1]
  local previewed = nil
  local confirmed = false

  local timer = uv.new_timer()

  local function start_preview_loop(prompt_bufnr)
    timer:start(0, 100, vim.schedule_wrap(function()
      if not vim.api.nvim_buf_is_valid(prompt_bufnr) then
        timer:stop()
        return
      end

      local entry = action_state.get_selected_entry()
      if not entry or not entry[1] then return end

      local current = entry[1]
      if current ~= previewed then
        previewed = current
        themeset.apply(current, true)
      end
    end))
  end

  local picker = pickers.new({}, {
    prompt_title = "Color Themes",
    finder = finders.new_table({ results = themes }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}), -- dummy previewer

    attach_mappings = function(prompt_bufnr, map)
      start_preview_loop(prompt_bufnr)

      -- Set fallback for buffer close to restore original
      vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = prompt_bufnr,
        once = true,
        callback = function()
          timer:stop()
          if not confirmed then
            themeset.apply(original)
          end
        end,
      })

      actions.select_default:replace(function()
        local theme = action_state.get_selected_entry()[1]
        themeset.apply(theme) -- save + apply
        confirmed = true
        timer:stop()
        actions.close(prompt_bufnr)
      end)

      map("i", "<CR>", actions.select_default)
      map("n", "<CR>", actions.select_default)

      return true
    end,
  })

  picker:find()
end

return M

