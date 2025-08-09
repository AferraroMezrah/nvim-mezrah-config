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
    "sonokai",
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
        if vim.tbl_index_of(M.themes, name) then
            return name
        end
    end

    -- Missing / corrupt file → fall back to first theme and fix the file
    local fallback = M.themes[1]
    save_theme(fallback)
    return fallback
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
    if not vim.tbl_index_of(M.themes, name) then
        -- guard against typos / nil
        name = M.themes[1]
    end

    M.index = vim.tbl_index_of(M.themes, name)

    local ok = pcall(function()
        ColorMyPencils(name)
    end)

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
    M.index = ((M.index or 1) % #M.themes) + 1
    M.apply(M.themes[M.index])
end

function M.safe_startup()
    local name = M.load()
    M.apply(name, true)
end

return M

