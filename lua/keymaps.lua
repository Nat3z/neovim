local plugins_to_reload = {
  'yeet.nvim',
  'cursortab',
}

vim.keymap.set('n', '<leader>rr', function()
  for _, plugin in ipairs(plugins_to_reload) do
    require('lazy.core.loader').reload(plugin)
  end
  vim.notify('Development plugins reloaded', vim.log.levels.INFO)
end, { desc = 'Reloads Development Plugins', expr = false, silent = true })

local pane_id = ''

vim.keymap.set('n', '<leader>p', function()
  if vim.env.TMUX == nil or vim.fn.TMUX == '' then
    vim.notify('Not running inside tmux', vim.log.levels.WARN)
    return
  end
  -- check if pi pane already is open
  if pane_id ~= '' then
    vim.fn.systemlist {
      'tmux',
      'kill-pane',
      '-t',
      pane_id,
    }
    vim.notify('Closed pi agent', vim.log.levels.INFO)
  end
  pane_id = vim.fn.systemlist({
    'tmux',
    'split-window',
    '-d',
    '-h',
    '-p',
    '25',
    '-c',
    vim.fn.getcwd(),
    '-P',
    '-F',
    '#{pane_id}',
    'pi',
  })[1]
  vim.notify('Opened pi agent', vim.log.levels.INFO)
end, { desc = 'open pi agent' })
