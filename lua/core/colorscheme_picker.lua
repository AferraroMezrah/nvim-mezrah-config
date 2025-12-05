-- lua/core/colorscheme_picker.lua

local themeset = require("core.colorscheme")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")

local uv = vim.loop

local M = {}

M.pick = function()
  local themes = themeset.themes
  local original = themeset.load() or themes[1]
  local previewed = nil
  local confirmed = false

  local timer = uv.new_timer()

  -- Preview mode cycling (Apex -> Visualforce -> Python -> ...)
  local preview_modes = { "apex", "vf", "py" }
  local mode_idx = 1
  local preview_mode = preview_modes[mode_idx]

  local samples = {
    apex = {
      "// Apex Theme Lab",
      "public with sharing class EnrollmentService {",
      "  @AuraEnabled(cacheable=true)",
      "  public static List<Account> findAccts(Set<Id> ids) {",
      "    try {",
      "      return [SELECT Id, Name, CreatedDate FROM Account WHERE Id IN :ids LIMIT 50];",
      "    } catch (Exception e) {",
      "      System.debug(LoggingLevel.ERROR, e.getMessage());",
      "      throw e;",
      "    }",
      "  }",
      "}",
    },
    vf = {
      "<!-- Visualforce Theme Lab -->",
      "<apex:page controller=\"MyCtrl\" sidebar=\"false\" showHeader=\"false\">",
      "  <apex:form>",
      "    <apex:pageBlock title=\"Enrollment\">",
      "      <apex:outputPanel rendered=\"{!NOT(ISBLANK(msg))}\">",
      "        <apex:messages />",
      "      </apex:outputPanel>",
      "      <apex:inputField value=\"{!c.Contact__c}\" required=\"true\" />",
      "      <apex:commandButton value=\"Save\" action=\"{!save}\" rerender=\"pb\" />",
      "    </apex:pageBlock>",
      "  </apex:form>",
      "</apex:page>",
    },
    py = {
      "# Python Theme Lab",
      "from dataclasses import dataclass",
      "",
      "@dataclass",
      "class User:",
      "    id: int",
      "    name: str",
      "",
      "def greet(u: User) -> str:",
      "    try:",
      "        return f\"Hello, {u.name}!\"",
      "    except Exception as e:",
      "        raise RuntimeError(\"boom\") from e",
    },
  }

  -- Filetypes: use your preferred ones here
  -- Apex highlighting depends on what you have installed; common values are "apex" or "sfapex".
  local filetypes = {
    apex = "apex",   -- change to "sfapex" if that's what your setup uses
    vf = "xml",      -- "html" also works; VF-specific highlighting requires extra ftplugin
    py = "python",
  }

  local function cycle_mode()
    mode_idx = (mode_idx % #preview_modes) + 1
    preview_mode = preview_modes[mode_idx]
  end

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

    previewer = previewers.new_buffer_previewer({
      title = "Theme Lab",
      define_preview = function(self, entry)
        local theme = entry[1]
        local mode = preview_mode

        local lines = {}
        lines[#lines + 1] = ("-- Theme Lab (%s): %s"):format(mode, theme)
        lines[#lines + 1] = ""
        for _, l in ipairs(samples[mode] or {}) do
          lines[#lines + 1] = l
        end

        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

        vim.bo[self.state.bufnr].filetype = filetypes[mode] or "text"
        vim.bo[self.state.bufnr].buftype = "nofile"
        vim.bo[self.state.bufnr].swapfile = false
        vim.bo[self.state.bufnr].modifiable = false

        vim.wo[self.state.winid].wrap = false
      end,
    }),

    attach_mappings = function(prompt_bufnr, map)
      start_preview_loop(prompt_bufnr)

      -- Restore original theme if picker is closed without confirming
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

      -- Confirm selection
      actions.select_default:replace(function()
        local theme = action_state.get_selected_entry()[1]
        if vim.tbl_index_of(themeset.themes, theme) then
          themeset.apply(theme)
        end
        confirmed = true
        timer:stop()
        actions.close(prompt_bufnr)
      end)

      -- Cycle preview mode (Apex/VF/Python) with one key
      local function cycle_and_refresh()
        cycle_mode()
        -- Force the preview window to re-render:
        -- easiest is to "nudge" selection change handling by re-applying preview theme
        local entry = action_state.get_selected_entry()
        if entry and entry[1] then
          themeset.apply(entry[1], true)
        end
        -- Also notify Telescope that selection changed so preview updates immediately
        actions.move_selection_next(prompt_bufnr) -- move
        actions.move_selection_previous(prompt_bufnr) -- and move back
      end

      map("i", "<C-n>", cycle_and_refresh)
      map("n", "<C-n>", cycle_and_refresh)

      map("i", "<CR>", actions.select_default)
      map("n", "<CR>", actions.select_default)

      return true
    end,
  })

  picker:find()
end

return M

