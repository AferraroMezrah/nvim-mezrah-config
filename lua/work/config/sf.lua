-- lua/work/config/sf.lua

-- Find the path to sfdx-project.json upward from the current file's directory
local function find_sfdx_root()
  return vim.fs.find('sfdx-project.json', {
    upward = true,
    path = vim.fn.expand '%:p:h',
  })[1]
end

-- Deploy the current file using the sf CLI from the project root
local function deploy_current_file()
  local file = vim.fn.expand '%:p'
  local sfdx_config_path = find_sfdx_root()

  if not sfdx_config_path then
    vim.notify('Not inside a Salesforce DX project.', vim.log.levels.ERROR)
    return
  end

  local project_root = vim.fs.dirname(sfdx_config_path)

  local cmd = 'cd ' .. project_root .. ' && sf project deploy start --source-dir ' .. vim.fn.shellescape(file) .. ' --target-org Prosandbox'

  vim.cmd 'write'
  vim.cmd('!' .. cmd)
end

-- Create :Deploy command
vim.api.nvim_create_user_command('Deploy', deploy_current_file, {})

-- Create :Wd to write and deploy
vim.api.nvim_create_user_command('Wd', function()
  vim.cmd 'write'
  deploy_current_file()
end, {})

-- <leader>sd to deploy current file
vim.keymap.set('n', '<leader>sd', deploy_current_file, {
  desc = 'Deploy current file to Salesforce',
})
