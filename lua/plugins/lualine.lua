return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = 'auto',
            globalstatus = true,    -- match laststatus=3
            icons_enabled = true,
        },
        sections = {
            lualine_a = { 'mode' },                 -- big win: always-visible mode
            lualine_b = {
                {
                    "branch",
                    fmt = function(str)
                        if #str > 25 then
                            return str:sub(1, 22) .. "..."
                        end
                        return str
                    end,
                },
                'diff',
                'diagnostics',
            },
            lualine_c = {
                'filename',
                {
                    "require'salesforce.org_manager':get_default_alias()",
                    icon = "󰢎";
                },
            },
            lualine_x = { 'encoding', 'fileformat', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },             -- line,col
        },
    },
    config = function(_, opts)
        vim.opt.showmode = false
        require("lualine").setup(opts)
    end,
}

