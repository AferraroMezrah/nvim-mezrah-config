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
        vim.keymap.set('n', '<leader>pF', function()
          builtin.find_files { no_ignore = true }
        end, { desc = '[P]roject [F]iles (all, incl ignored)' })
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

        -- Diff vs default branch (PR-style): show changed files in a Telescope picker
        local function pick_diff_files()
            -- Ensure we're in a git repo
            if not vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match('true') then
                vim.notify('Not inside a git repository', vim.log.levels.WARN)
                return
            end

            -- Resolve default branch via origin/HEAD
            local base = vim.fn.system('git symbolic-ref --quiet refs/remotes/origin/HEAD')
                :gsub('%s+', '')
                :gsub('^refs/remotes/', '')

            if base == '' then
                vim.notify('Could not determine default branch (origin/HEAD)', vim.log.levels.ERROR)
                return
            end

            local files = vim.fn.systemlist(string.format('git diff --name-only %s...HEAD', base))
            if vim.v.shell_error ~= 0 then
                vim.notify('git diff failed', vim.log.levels.ERROR)
                return
            end

            -- Filter empties
            local results = {}
            for _, f in ipairs(files) do
                if f and f ~= '' then table.insert(results, f) end
            end

            if #results == 0 then
                vim.notify('No changes vs ' .. base, vim.log.levels.INFO)
                return
            end

            local pickers = require('telescope.pickers')
            local finders = require('telescope.finders')
            local conf = require('telescope.config').values
            local make_entry = require('telescope.make_entry')

            pickers.new({}, {
                prompt_title = 'Diff files vs ' .. base,

                -- THIS is the key: make_entry.gen_from_file gives icons + nicer display
                finder = finders.new_table({
                    results = results,
                    entry_maker = make_entry.gen_from_file({}),
                }),

                -- Use the standard file previewer
                previewer = conf.file_previewer({}),
                sorter = conf.file_sorter({}),
            }):find()
        end


        vim.keymap.set('n', '<leader>gF', pick_diff_files, { desc = '[G]it diff [F]iles vs master (PR)' })

    end,
}


