-- lua/plugins/telescope.lua

return {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        'nvim-telescope/telescope-ui-select.nvim',
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')

        telescope.setup {
            defaults = {
                path_display = { "smart" },
                sorting_strategy = "ascending",
                layout_config = { width = 0.9 },
            },
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        pcall(telescope.load_extension, 'fzf')
        pcall(telescope.load_extension, 'ui-select')

        -- Keymaps
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = '[P]roject [F]iles' })
        vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[G]it [F]iles' })
        vim.keymap.set('n', '<leader>pws', function()
            builtin.grep_string { search = vim.fn.expand '<cword>' }
        end, { desc = '[P]roject [W]ord under cursor' })
        vim.keymap.set('n', '<leader>pWs', function()
            builtin.grep_string { search = vim.fn.expand '<cWORD>' }
        end, { desc = '[P]roject [W]ORD under cursor' })
        vim.keymap.set('n', '<leader>pwS', function()
            builtin.grep_string { search = vim.fn.expand('<cword>'):lower() }
        end, { desc = '[P]roject [W]ord under cursor (case insensitive)' })

        vim.keymap.set('n', '<leader>pWS', function()
            builtin.grep_string { search = vim.fn.expand('<cWORD>'):lower() }
        end, { desc = '[P]roject [W]ORD under cursor (case insensitive)' })
        vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = '[P]roject [S]earch' })
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = '[V]im [H]elp' })
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })
        vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
            }
        end, { desc = '[S]earch [/] in Open Files' })
        vim.keymap.set('n', '<leader>fn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[F]ind [N]eovim config files' })
        vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = '[G]it [B]ranches' })

    end,
}


