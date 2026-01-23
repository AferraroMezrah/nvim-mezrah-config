-- lua/core/sf.lua
-- Minimal, practical helpers for Salesforce DX projects

local M = {}

-- === Configuration ===========================================================
-- Prefer env var (CI/other shells) but fall back to your sandbox alias.
local TARGET_ORG = os.getenv("SF_TARGET_ORG") or "prosandbox"

-- Default DX output directories (relative to project root)
local DX_DIRS = {
    classes    = "force-app/main/default/classes",
    pages      = "force-app/main/default/pages",
    components = "force-app/main/default/components",
}

-- === Utilities ===============================================================
local function is_sfdx_root(dir)
    return vim.fn.filereadable(dir .. "/sfdx-project.json") == 1
end

local function find_sfdx_root()
    local cwd = vim.fn.getcwd()
    if is_sfdx_root(cwd) then
        return cwd .. "/sfdx-project.json"
    end

    return vim.fs.find('sfdx-project.json', {
        upward = true,
        path = vim.fn.expand('%:p:h'),
    })[1]
end

local function get_project_root_or_err()
    local sfdx_cfg = find_sfdx_root()
    if not sfdx_cfg then
        vim.notify('Not inside a Salesforce DX project.', vim.log.levels.ERROR)
        return nil
    end
    return vim.fs.dirname(sfdx_cfg)
end

local function run_from_root(cmd, opts)
    opts = opts or {}
    local root = get_project_root_or_err()
    if not root then return end

    if opts.write ~= false and vim.bo.modified then
        vim.cmd("write")
    end

    vim.cmd("botright 15split")
    vim.cmd("enew")
    local term_buf = vim.api.nvim_get_current_buf()
    local term_win = vim.api.nvim_get_current_win()

    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    -- predictable close
    vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(term_win) then
            vim.api.nvim_win_close(term_win, true)
        end
    end, { buffer = term_buf, silent = true })

    -- run
    local job_id = vim.fn.termopen(cmd, {
        cwd = root,
        on_exit = function(_, code, _)
            vim.schedule(function()
                -- CRITICAL: leave terminal-mode so k/j work and don't trigger terminal maps
                pcall(vim.cmd, "stopinsert")

                if opts.on_exit then
                    opts.on_exit({ code = code, root = root })
                end

                if opts.close_on_exit then
                    if vim.api.nvim_win_is_valid(term_win) then
                        vim.api.nvim_win_close(term_win, true)
                    end
                end
            end)
        end,
    })

    if job_id <= 0 then
        vim.notify("Failed to start SF terminal job.", vim.log.levels.ERROR)
        return
    end

    pcall(vim.api.nvim_buf_set_name, term_buf, "sf://term")
    vim.cmd("startinsert")
end







local function ensure_dir_exists(root, rel)
    local path = root .. "/" .. rel
    vim.fn.mkdir(path, "p")
    return path
end

-- Infer Apex class name from current file path (MyClass.cls -> MyClass)
local function infer_class_from_file()
    local fname = vim.fn.expand('%:t')
    if fname:match('%.cls$') then
        return fname:gsub('%.cls$', '')
    end
    return nil
end

-- Try to infer @isTest method name on current line; fall back to nil
local function infer_test_method_on_line()
    local line = vim.api.nvim_get_current_line()
    -- Grab token before '(' and ensure this looks like a method signature line.
    local method = line:match('([A-Za-z_][A-Za-z0-9_]*)%s*%(')
    if not method then return nil end

    -- Quick heuristics: look at current + two previous lines for @isTest or testMethod
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local window = {}
    for i = math.max(1, row - 2), row do
        table.insert(window, vim.fn.getline(i))
    end
    local blob = table.concat(window, "\n"):lower()
    if blob:find("@istest") or blob:find("testmethod") then
        return method
    end
    return nil
end

-- === Deploy ==================================================================
local function deploy_current_file()
    local file = vim.fn.expand("%:p")
    run_from_root({
        "sf", "project", "deploy", "start",
        "--source-dir", file,
        "--target-org", TARGET_ORG,
    })
end




-- === Apex / SOQL runners =====================================================
local function sf_bin(opts)
    return (opts and opts.prod) and "sf-prod" or "sf"
end

local function run_apex_file(opts)
    opts = opts or {}
    local file = vim.fn.expand("%:p")
    if not file:match("%.apex$") then
        vim.notify("Current file is not a .apex script", vim.log.levels.ERROR)
        return
    end

    local args = { sf_bin(opts), "apex", "run", "--file", file }
    if not opts.prod then
        table.insert(args, "--target-org")
        table.insert(args, TARGET_ORG)
    end

    run_from_root(args, opts)
end

local function run_soql_file(opts)
    opts = opts or {}
    local file = vim.fn.expand("%:p")
    if not file:match("%.soql$") then
        vim.notify("Current file is not a .soql query", vim.log.levels.ERROR)
        return
    end

    local result_format = opts.result_format or "human"

    local args = { sf_bin(opts), "data", "query", "--file", file, "--result-format", result_format }
    if not opts.prod then
        table.insert(args, "--target-org")
        table.insert(args, TARGET_ORG)
    end

    run_from_root(args)
end

-- === SfOut: export singleton output payload to a real file ====================

local function join_path(a, b)
    return (a:gsub("/$", "")) .. "/" .. (b:gsub("^/", ""))
end

local function project_file_or_err(root, relpath)
    local p = join_path(root, relpath)
    if vim.fn.filereadable(p) ~= 1 then
        vim.notify("Missing project file: " .. relpath, vim.log.levels.ERROR)
        return nil
    end
    return p
end

local function local_out_dir(root)
    local rel = ".local/sf"
    ensure_dir_exists(root, rel)
    return join_path(root, rel)
end

local function sf_out(opts)
    opts = opts or {}
    local root = get_project_root_or_err()
    if not root then return end

    local soql_file = project_file_or_err(root, "scripts/soql/out.soql")
    if not soql_file then return end

    local outdir  = local_out_dir(root)
    local wrapper = join_path(outdir, "out-wrapper.json")

    local args = {
        sf_bin(opts), "data", "query",
        "--file", soql_file,
        "--result-format", "json",
        "--output-file", wrapper,
    }
    if not opts.prod then
        table.insert(args, "--target-org")
        table.insert(args, TARGET_ORG)
    end

    run_from_root(args, {
        on_exit = function(res)
            if res.code == 0 and vim.fn.filereadable(wrapper) == 1 and vim.fn.getfsize(wrapper) > 0 then
                vim.cmd("edit " .. vim.fn.fnameescape(wrapper))
            else
                vim.notify("SfOut failed (exit " .. tostring(res.code) .. ")", vim.log.levels.ERROR)
            end
        end,
    })
end

-- === Generators ==============================================================

local function gen_apex_class()
    local root = get_project_root_or_err()
    if not root then return end

    vim.ui.input({ prompt = "Apex Class Name: " }, function(name)
        if not name or name == "" then return end
        ensure_dir_exists(root, DX_DIRS.classes)
        run_from_root({
            "sf", "apex", "generate", "class",
            "--name", name,
            "--output-dir", DX_DIRS.classes,
        })
    end)
end

local function gen_vf_page()
    local root = get_project_root_or_err()
    if not root then return end

    vim.ui.input({ prompt = "VF Page Name: " }, function(name)
        if not name or name == "" then return end

        vim.ui.input({ prompt = "Label (optional): " }, function(label)
            ensure_dir_exists(root, DX_DIRS.pages)

            local args = {
                "sf", "visualforce", "generate", "page",
                "--name", name,
                "--output-dir", DX_DIRS.pages,
            }
            if label and #label > 0 then
                table.insert(args, "--label")
                table.insert(args, label)
            end

            run_from_root(args)
        end)
    end)
end

local function gen_vf_component()
    local root = get_project_root_or_err()
    if not root then return end

    vim.ui.input({ prompt = "VF Component Name: " }, function(name)
        if not name or name == "" then return end

        vim.ui.input({ prompt = "Label (optional): " }, function(label)
            ensure_dir_exists(root, DX_DIRS.components)

            local args = {
                "sf", "visualforce", "generate", "component",
                "--name", name,
                "--output-dir", DX_DIRS.components,
            }
            if label and #label > 0 then
                table.insert(args, "--label")
                table.insert(args, label)
            end

            run_from_root(args)
        end)
    end)
end

-- === Tests ===================================================================

-- Run tests with coverage. Accepts one of:
--   { classnames = "ClassA,ClassB" }
--   { tests = "ClassA.method1,ClassA.method2" }
-- Uses human output with detailed coverage for quick readability.
local function run_tests(opts)
    opts = opts or {}
    local args = {
        "sf", "apex", "test", "run",
        "--target-org", TARGET_ORG,
        "--code-coverage",
        "--result-format", "human",
        "--detailed-coverage",
        "--wait", "10",
    }

    if opts.tests then
        table.insert(args, "--test-names")
        table.insert(args, opts.tests)
        table.insert(args, "--synchronous")
    elseif opts.classnames then
        table.insert(args, "--class-names")
        table.insert(args, opts.classnames)
        table.insert(args, "--synchronous")
    else
        table.insert(args, "--test-level")
        table.insert(args, "RunLocalTests")
    end

    run_from_root(args)
end

local function test_current_class()
    local class = infer_class_from_file()
    if not class then
        vim.ui.input({ prompt = "Test Class Name(s), comma-separated: " }, function(names)
            if names and #names > 0 then run_tests({ classnames = names }) end
        end)
        return
    end
    run_tests({ classnames = class })
end

local function test_current_method()
    local class = infer_class_from_file()
    local method = infer_test_method_on_line()
    local function go(c, m)
        if c and m then
            run_tests({ tests = string.format("%s.%s", c, m) })
        else
            vim.notify("Could not infer test method; please run :SfTestMethod ClassName.methodName", vim.log.levels.WARN)
        end
    end
    if class and method then
        go(class, method)
    else
        -- Prompt if inference fails
        vim.ui.input({ prompt = "ClassName.methodName: " }, function(arg)
            if not arg or #arg == 0 then return end
            local c, m = arg:match("^([%w_]+)%.([%w_]+)$")
            if c and m then go(c, m) else
                vim.notify("Format must be ClassName.methodName", vim.log.levels.ERROR)
            end
        end)
    end
end

-- === Commands & Keymaps ======================================================
-- Deploy
vim.api.nvim_create_user_command('Deploy', deploy_current_file, {})
vim.api.nvim_create_user_command('Wd', function() vim.cmd('write'); deploy_current_file() end, {})

-- Apex runners
vim.api.nvim_create_user_command('SfApexRun', function()
    run_apex_file({ prod = false })
end, {})

-- vim.api.nvim_create_user_command('SfApexRunProd', function()
--     run_apex_file({ prod = true })
-- end, {})

-- SOQL runners
vim.api.nvim_create_user_command('SfSoqlRun', function(opts)
    -- Allow :SfSoqlRun human/csv/json if you feel like it
    run_soql_file({ prod = false, result_format = opts.args ~= "" and opts.args or "human" })
end, { nargs = "?" })

-- vim.api.nvim_create_user_command('SfSoqlRunProd', function(opts)
--   run_soql_file({ prod = true, result_format = opts.args ~= "" and opts.args or "human" })
-- end, { nargs = "?" })

-- Generators
vim.api.nvim_create_user_command('SfGenClass', gen_apex_class, {})
vim.api.nvim_create_user_command('SfGenPage', gen_vf_page, {})
vim.api.nvim_create_user_command('SfGenComponent', gen_vf_component, {})

-- Tests
vim.api.nvim_create_user_command('SfTestClass', function(opts)
    if opts.args and #opts.args > 0 then
        run_tests({ classnames = opts.args })
    else
        test_current_class()
    end
end, { nargs = "?" })

vim.api.nvim_create_user_command('SfTestMethod', function(opts)
    if opts.args and #opts.args > 0 then
        run_tests({ tests = opts.args })
    else
        test_current_method()
    end
end, { nargs = "?" })

vim.keymap.set('n', '<leader>sd', deploy_current_file, { desc = 'SF: Deploy current file' })
vim.keymap.set('n', '<leader>st', test_current_class,  { desc = 'SF: Test current class (coverage)' })
vim.keymap.set('n', '<leader>sm', test_current_method, { desc = 'SF: Test method under cursor (coverage)' })
vim.keymap.set('n', '<leader>sa', function()
    run_apex_file({ prod = false })
end, { desc = 'SF: Run current .apex in sandbox' })

vim.keymap.set('n', '<leader>sA', function()
    run_apex_file({ prod = true })
end, { desc = 'SF: Run current .apex in PROD' })

vim.keymap.set('n', '<leader>sq', function()
    run_soql_file({ prod = false })
end, { desc = 'SF: Run current .soql in sandbox' })

vim.keymap.set('n', '<leader>sQ', function()
    run_soql_file({ prod = true })
end, { desc = 'SF: Run current .soql in PROD' })

-- SfOut (singleton payload export)
vim.api.nvim_create_user_command('SfOut', function()
    sf_out({ prod = false })
end, {})

vim.keymap.set('n', '<leader>so', function()
    sf_out({ prod = false })
end, { desc = 'SF: Write out-wrapper.json and open' })

vim.api.nvim_create_user_command('SfOutProd', function()
    sf_out({ prod = true })
end, {})

vim.keymap.set('n', '<leader>sO', function()
    sf_out({ prod = true })
end, { desc = 'SF: Write out-wrapper.json from PROD and open' })

return M

