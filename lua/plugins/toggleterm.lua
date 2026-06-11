function create_term(num)
  local terminal = require('toggleterm.terminal').Terminal
  local term = terminal:new {
    id = num,
    direction = 'horizontal',
    display_name = 'Terminal ' .. tostring(num),
  }
  term:toggle()
end

local function git_has_pending_work(cwd)
  local porcelain = vim.fn.systemlist({ 'git', '-C', cwd, 'status', '--porcelain' })
  if vim.v.shell_error ~= 0 then
    return false
  end
  if #porcelain > 0 then
    return true
  end

  local status = table.concat(vim.fn.systemlist({ 'git', '-C', cwd, 'status' }), '\n'):lower()
  return status:find('ahead', 1, true) ~= nil
    or status:find('behind', 1, true) ~= nil
    or status:find('have diverged', 1, true) ~= nil
end

local function git_is_up_to_date(cwd)
  local porcelain = vim.fn.systemlist({ 'git', '-C', cwd, 'status', '--porcelain' })
  if vim.v.shell_error ~= 0 or #porcelain > 0 then
    return false
  end

  local status = table.concat(vim.fn.systemlist({ 'git', '-C', cwd, 'status' }), '\n'):lower()
  local clean = status:find('nothing to commit', 1, true) ~= nil
    or status:find('working tree clean', 1, true) ~= nil
  if not clean then
    return false
  end

  return status:find('up to date', 1, true) ~= nil
    or (
      status:find('ahead', 1, true) == nil
      and status:find('behind', 1, true) == nil
      and status:find('have diverged', 1, true) == nil
    )
end

local function watch_git_up_to_date(pane_id, cwd, saw_work, checks)
  checks = checks or 0

  local panes = vim.fn.systemlist({ 'tmux', 'list-panes', '-F', '#{pane_id}', '-t', pane_id })
  if vim.v.shell_error ~= 0 or #panes == 0 then
    return
  end

  if git_has_pending_work(cwd) then
    saw_work = true
  end

  if saw_work and git_is_up_to_date(cwd) then
    vim.notify('Git is up to date; closing tmux pane ' .. pane_id, vim.log.levels.INFO)
    vim.fn.system({ 'tmux', 'kill-pane', '-t', pane_id })
    return
  end

  if checks >= 2000 then
    vim.notify('Stopped watching for git up to date', vim.log.levels.WARN)
    return
  end

  vim.defer_fn(function()
    watch_git_up_to_date(pane_id, cwd, saw_work, checks + 1)
  end, 600)
end

function open_pi_yeet()
  if vim.env.TMUX == nil or vim.env.TMUX == '' then
    vim.notify('<leader>gy needs to run inside tmux', vim.log.levels.WARN)
    return
  end

  local cwd = vim.fn.getcwd()
  local pane_id = vim.fn.systemlist({
    'tmux',
    'split-window',
    '-d',
    '-h',
    '-p',
    '25',
    '-c',
    cwd,
    '-P',
    '-F',
    '#{pane_id}',
    'pi',
    '--model',
    'cursor/auto',
  })[1]

  if vim.v.shell_error ~= 0 or not pane_id or pane_id == '' then
    vim.notify('Failed to open tmux pane for pi', vim.log.levels.ERROR)
    return
  end

  vim.notify('Opened pi in tmux pane ' .. pane_id .. '; sending /yeet', vim.log.levels.INFO)
  vim.defer_fn(function()
    vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, '-l', '/yeet' })
    vim.defer_fn(function()
      vim.fn.system({ 'tmux', 'send-keys', '-t', pane_id, 'Enter' })
      vim.defer_fn(function()
        watch_git_up_to_date(pane_id, cwd)
      end, 600)
    end, 600)
  end, 1000)
end

vim.cmd "let &shell = has('win32') ? 'powershell' : 'pwsh'"
vim.cmd "let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'"
vim.cmd "let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'"
vim.cmd "let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'"
vim.cmd 'set shellquote= shellxquote='

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = true,
  init = function()
    vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>:q<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>T', '<cmd>lua create_term(1)<CR><C-\\><C-n>i', { silent = true, desc = 'Create Terminal 1' })
    vim.keymap.set('n', '<leader>!T', '<cmd>lua create_term(2)<CR><C-\\><C-n>i', { silent = true, desc = 'Create Terminal 2' })
    vim.keymap.set('n', '<leader>@T', '<cmd>lua create_term(3)<CR><C-\\><C-n>i', { silent = true, desc = 'Create Terminal 3' })
    vim.keymap.set('n', '<leader>gy', '<cmd>lua open_pi_yeet()<CR>', { silent = true, desc = 'Open pi and run /yeet' })
  end,
}
