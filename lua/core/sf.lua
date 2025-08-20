-- lua/core/sf.lua
-- Minimal, practical helpers for Salesforce DX projects

local M = {}

-- === Configuration ===========================================================
-- Prefer env var (CI/other shells) but fall back to your sandbox alias.
local TARGET_ORG = os.getenv("SF_TARGET_ORG") or "Prosandbox"

-- Default DX output directories (relative to project root)
local DX_DIRS = {
  classes    = "force-app/main/default/classes",
  pages      = "force-app/main/default/pages",
  components = "force-app/main/default/components",
}

-- === Utilities ===============================================================
local function find_sfdx_root()
  return vim.fs.find('sfdx-project.json', { upward = true, path = vim.fn.expand('%:p:h') })[1]
end

local function get_project_root_or_err()
  local sfdx_cfg = find_sfdx_root()
  if not sfdx_cfg then
    vim.notify('Not inside a Salesforce DX project.', vim.log.levels.ERROR)
    return nil
  end
  return vim.fs.dirname(sfdx_cfg)
end

local function sh_escape(arg) return vim.fn.shellescape(arg) end

local function run_from_root(cmd)
  local root = get_project_root_or_err()
  if not root then return end
  -- Use :terminal for better UX (doesn't block redraw/history)
  vim.cmd('write')
  vim.cmd('terminal cd ' .. sh_escape(root) .. ' && ' .. cmd)
  local buf = vim.api.nvim_get_current_buf()
  vim.keymap.set('n', 'q', '<cmd>bd!<CR>', { buffer = buf, silent = true })
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
  local root = get_project_root_or_err()
  if not root then return end
  local file = vim.fn.expand('%:p')
  local cmd = table.concat({
    "sf project deploy start",
    "--source-dir " .. sh_escape(file),
    "--target-org " .. sh_escape(TARGET_ORG),
  }, " ")
  run_from_root(cmd)
end

-- === Generators ==============================================================

local function gen_apex_class()
  local root = get_project_root_or_err()
  if not root then return end

  vim.ui.input({ prompt = "Apex Class Name: " }, function(name)
    if not name or name == "" then return end
    ensure_dir_exists(root, DX_DIRS.classes)
    local cmd = table.concat({
      "sf apex generate class",
      "--name " .. sh_escape(name),
      "--output-dir " .. sh_escape(DX_DIRS.classes),
    }, " ")
    run_from_root(cmd)
  end)
end

local function gen_vf_page()
  local root = get_project_root_or_err()
  if not root then return end

  vim.ui.input({ prompt = "VF Page Name: " }, function(name)
    if not name or name == "" then return end
    vim.ui.input({ prompt = "Label (optional): " }, function(label)
      ensure_dir_exists(root, DX_DIRS.pages)
      local parts = {
        "sf visualforce generate page",
        "--name " .. sh_escape(name),
        "--output-dir " .. sh_escape(DX_DIRS.pages),
      }
      if label and #label > 0 then
        table.insert(parts, "--label " .. sh_escape(label))
      end
      run_from_root(table.concat(parts, " "))
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
      local parts = {
        "sf visualforce generate component",
        "--name " .. sh_escape(name),
        "--output-dir " .. sh_escape(DX_DIRS.components),
      }
      if label and #label > 0 then
        table.insert(parts, "--label " .. sh_escape(label))
      end
      run_from_root(table.concat(parts, " "))
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
  local base = {
    "sf apex test run",
    "--target-org " .. sh_escape(TARGET_ORG),
    "--code-coverage",
    "--result-format human",
    "--detailed-coverage",
    "--wait 10",
  }
  if opts.tests then
    table.insert(base, "--test-names " .. sh_escape(opts.tests))
    -- synchronous allowed when single class; CLI decides, harmless if multiple
    table.insert(base, "--synchronous")
  elseif opts.classnames then
    table.insert(base, "--class-names " .. sh_escape(opts.classnames))
    table.insert(base, "--synchronous")
  else
    -- Fallback: run local tests (rarely used interactively)
    table.insert(base, "--test-level RunLocalTests")
  end
  run_from_root(table.concat(base, " "))
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
vim.keymap.set('n', '<leader>sd', deploy_current_file, { desc = 'SF: Deploy current file' })

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

vim.keymap.set('n', '<leader>st', test_current_class,  { desc = 'SF: Test current class (coverage)' })
vim.keymap.set('n', '<leader>sm', test_current_method, { desc = 'SF: Test method under cursor (coverage)' })

return M

