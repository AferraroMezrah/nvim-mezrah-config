-- lua/core/colorscheme.lua

-- Compatibility shim
if not vim.tbl_index_of then
  function vim.tbl_index_of(t, val)
    for i, v in ipairs(t) do
      if v == val then return i end
    end
  end
end

local M = {}

M.themes = {
  "tokyonight",
  "gruvbox",
  "catppuccin",
  "everforest",
  "rose-pine",
}

local theme_file = vim.fn.stdpath("data") .. "/theme.txt"

local function save_theme(name)
  local f = io.open(theme_file, "w")
  if f then
    f:write(name)
    f:close()
  end
end

function M.load()
  local f = io.open(theme_file, "r")
  if f then
    local name = f:read("*l")
    f:close()
    return name
  end
end

local function ColorMyPencils(color)
    vim.cmd.colorscheme(color)
end

local function echo_theme(name)
  vim.schedule(function()
    vim.api.nvim_echo({ { "Colorscheme: " .. name, "Normal" } }, false, {})
  end)
end

function M.apply(name, preview_only)
  if not name then
    name = M.themes[M.index]
  end

  for i, theme in ipairs(M.themes) do
    if theme == name then
      M.index = i
      break
    end
  end

  local ok = pcall(function()
        ColorMyPencils(name)
  end)

  -- Transparent patch
  local transparent_groups = {
    "Normal", "NormalNC", "NormalFloat", "FloatBorder",
    "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
    "TelescopePromptBorder", "SignColumn", "VertSplit",
  }

  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end

  if ok then
    echo_theme(name)
        if not preview_only then
            save_theme(name)
        end
  else
    vim.api.nvim_echo({ { "Failed to load theme: " .. name, "ErrorMsg" } }, false, {})
  end
end

function M.cycle()
  M.index = (M.index % #M.themes) + 1
  M.apply(M.themes[M.index])
end

return M

