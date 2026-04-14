local normal_guicursor = ""
local terminal_guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

local group = vim.api.nvim_create_augroup("custom_terminal_cursor", { clear = true })

local function apply_cursor()
    local bufnr = vim.api.nvim_get_current_buf()
    local buftype = vim.bo[bufnr].buftype

    if buftype == "terminal" then
        vim.opt.guicursor = terminal_guicursor
    else
        vim.opt.guicursor = normal_guicursor
    end
end

local function apply_cursor_deferred()
    vim.defer_fn(apply_cursor, 10)
end

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "WinEnter" }, {
    group = group,
    callback = apply_cursor_deferred,
})

vim.api.nvim_create_autocmd({ "TermClose", "BufWinLeave", "WinClosed" }, {
    group = group,
    callback = apply_cursor_deferred,
})
