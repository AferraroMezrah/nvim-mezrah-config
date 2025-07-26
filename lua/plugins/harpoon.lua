return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup()

    -- basic telescope configuration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
                results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
        }):find()
    end

    -- Keymaps
    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = desc })
    end

    map("<leader>a", function() harpoon:list():add() end, "Harpoon Add File")
    map("<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "Harpoon Quick Menu")

    map("<C-j>", function() harpoon:list():select(1) end, "Harpoon to file 1")
    map("<C-k>", function() harpoon:list():select(2) end, "Harpoon to file 2")
    map("<C-l>", function() harpoon:list():select(3) end, "Harpoon to file 3")
    map("<C-;>", function() harpoon:list():select(4) end, "Harpoon to file 4")
  end,
}

