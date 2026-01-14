return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
        local ls = require("luasnip")

        ls.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = false,
        })

        -- Optional: friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()

        -- Extend filetypes if needed
        ls.filetype_extend("visualforce", { "html", "javascript" })
        ls.filetype_extend("html", { "javascript" })

        local loaded_roots = {}

        local function find_repo_root()
            local git = vim.fs.find(".git", { upward = true, type = "directory" })[1]
            if not git then return nil end
            return vim.fs.dirname(git)
        end

        local function find_project_snippet_dir(root)
            local candidates = {}

            if vim.g.project_snippet_dir and vim.g.project_snippet_dir ~= "" then
                table.insert(candidates, vim.g.project_snippet_dir)
            end

            table.insert(candidates, root .. "/snippets/nvim")
            table.insert(candidates, root .. "/.snippets/nvim")
            table.insert(candidates, root .. "/MAPBENEFITS/snippets/nvim")

            for _, dir in ipairs(candidates) do
                if vim.fn.isdirectory(dir) == 1 then
                    return dir
                end
            end

            return nil
        end

        local function load_project_snips_once()
            local root = find_repo_root()
            if not root then return end
            if loaded_roots[root] then return end

            local snippet_dir = find_project_snippet_dir(root)
            if not snippet_dir then
                loaded_roots[root] = true
                return
            end

            require("luasnip.loaders.from_lua").lazy_load({ paths = { snippet_dir } })
            loaded_roots[root] = true
        end

        -- Try once on startup, then again as you move across projects.
        load_project_snips_once()

        vim.api.nvim_create_autocmd({ "BufEnter" }, {
            callback = function()
                load_project_snips_once()
            end,
        })

        -- -- Jump forward/back through snippet fields
        -- vim.keymap.set({ "i", "s" }, "<Tab>", function()
        --     if ls.jumpable(1) then
        --         ls.jump(1)
        --     else
        --         return "<Tab>"
        --     end
        -- end, { expr = true, silent = true })
        --
        -- vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
        --     if ls.jumpable(-1) then
        --         ls.jump(-1)
        --     else
        --         return "<S-Tab>"
        --     end
        -- end, { expr = true, silent = true })
        --
        -- Cycle through choice_node options
        vim.keymap.set({ "i", "s" }, "<C-n>", function()
            if ls.choice_active() then
                ls.change_choice(1)
            end
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<C-p>", function()
            if ls.choice_active() then
                ls.change_choice(-1)
            end
        end, { silent = true })
    end,
}
