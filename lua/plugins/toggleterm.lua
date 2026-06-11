function create_term(num)
  local terminal = require('toggleterm.terminal').Terminal
  local term = terminal:new {
    id = num,
    direction = 'horizontal',
    display_name = 'Terminal ' .. tostring(num),
  }
  term:toggle()
end

local function watch_pi_working(pane_id, saw_working, checks)
  checks = checks or 0

  local lines = vim.fn.systemlist({ 'tmux', 'capture-pane', '-t', pane_id, '-p' })
  if vim.v.shell_error ~= 0 then
    return
  end

  local output = table.concat(lines, '\n'):lower()
  local has_working = output:find('working...', 1, true) ~= nil

  if saw_working and not has_working then
    vim.notify('Pi is no longer working; closing tmux pane ' .. pane_id, vim.log.levels.INFO)
    vim.fn.system({ 'tmux', 'kill-pane', '-t', pane_id })
    return
  end

  if checks >= 2000 then
    vim.notify('Stopped watching pi pane for Working... timeout', vim.log.levels.WARN)
    return
  end

  vim.defer_fn(function()
    watch_pi_working(pane_id, saw_working or has_working, checks + 1)
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
    '-h',
    '-p',
    '40',
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
        watch_pi_working(pane_id)
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
