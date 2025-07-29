-- lua/core/autocmds/node.lua

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        local package_json = vim.fn.findfile("package.json", ".;")

        if package_json ~= "" then
            -- Setup only once per session
            if vim.fn.exists(":NBuild") == 0 then
                vim.cmd("command! NBuild !npm run build")
                vim.cmd("command! NStart !npm start")
                vim.cmd("command! NDev !npm run dev")
            end

            -- Keymaps (buffer-local)
            local map = function(lhs, cmd, desc)
                vim.keymap.set("n", lhs, cmd, {
                    silent = true,
                    buffer = true,
                    desc = desc,
                })
            end

            map("<leader>nb", ":NBuild<CR>", "Run npm build")
            map("<leader>ns", ":NStart<CR>", "Run npm start")
            map("<leader>nd", ":NDev<CR>", "Run npm dev")
        end
    end,
})
