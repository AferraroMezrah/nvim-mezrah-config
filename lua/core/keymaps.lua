-- lua/core/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>ut", function()
    require("core.colorscheme").cycle()
end, { desc = "Cycle theme" })

vim.keymap.set("n", "<leader>fp", function()
    require("core.colorscheme_picker").pick()
end, { desc = "Pick colorscheme with preview" })

-- Primeagen inspired
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- "greatest remap ever
vim.keymap.set("x", "<leader>p", "\"_dP")

-- "next greateset remap ever : asbjornHaland"
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+y")

vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>")
vim.keymap.set("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
--vim.keymap.set("n", "<leader>f", function()
--    require("conform").format({ bufnr = 0 })
--end)

-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>",  { desc = "Quickfix open" })
vim.keymap.set("n", "<leader>qq", "<cmd>cclose<cr>", { desc = "Quickfix close" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>=", "`[v`]=", { desc = "Reindent last change" })

vim.keymap.set("i", "<C-d>", function()
    local date = vim.fn.strftime("%Y-%m-%d")
    vim.api.nvim_put({ date }, "c", true, true)
end, { desc = "Insert date YYYY-MM-DD" })

vim.keymap.set("i", "<C-g>", function()
    local line = "## " .. vim.fn.strftime("%Y-%m-%d")
    vim.api.nvim_put({ line }, "l", true, true)
end, { desc = "Insert heading with date" })

local function notes_root()
    if vim.env.NOTES_DIR and vim.env.NOTES_DIR ~= "" then
        return vim.env.NOTES_DIR
    end

    -- fallback: if current working dir *is* notes repo
    local cwd = vim.fn.getcwd()
    if cwd:match("[/\\]notes$") then
        return cwd
    end

    return nil
end

vim.keymap.set("n", "<leader>ni", function()
    local root = vim.env.NOTES_DIR
    if not root or root == "" then
        vim.notify("NOTES_DIR is not set", vim.log.levels.ERROR)
        return
    end

    root = root:gsub("\\", "/")
    local date = vim.fn.strftime("%Y-%m-%d")
    local path = root .. "/inbox/" .. date .. ".md"

    vim.cmd("edit " .. vim.fn.fnameescape(path))
    vim.cmd("normal! G")
end, { desc = "Notes: open today's inbox" })

vim.keymap.set("n", "<leader>nf", function()
    local root = vim.env.NOTES_DIR
    if not root or root == "" then
        vim.notify("NOTES_DIR is not set", vim.log.levels.ERROR)
        return
    end

    root = root:gsub("\\", "/")
    require("telescope.builtin").find_files({
        cwd = root,
        prompt_title = "Notes",
    })
end, { desc = "Notes: find file" })



local function qf_info()
  return vim.fn.getqflist({ size = 0, idx = 0 })
end

local function qf_jump_idx(idx)
  pcall(vim.cmd, ("cc %d"):format(idx))
  vim.cmd("normal! zz")
end

local function qf_next_wrap()
  local info = qf_info()
  if (info.size or 0) == 0 then return end
  if (info.idx or 0) >= (info.size or 0) then
    qf_jump_idx(1)
  else
    qf_jump_idx(info.idx + 1)
  end
end

local function qf_prev_wrap()
  local info = qf_info()
  if (info.size or 0) == 0 then return end
  if (info.idx or 0) <= 1 then
    qf_jump_idx(info.size)
  else
    qf_jump_idx(info.idx - 1)
  end
end

vim.keymap.set("n", "<C-n>", qf_next_wrap, { desc = "Quickfix next (wrap)" })
vim.keymap.set("n", "<C-p>", qf_prev_wrap, { desc = "Quickfix prev (wrap)" })


-- Make `q` close the quickfix window when you're focused inside it
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>cclose<cr>", { buffer = true, silent = true })
  end,
})

