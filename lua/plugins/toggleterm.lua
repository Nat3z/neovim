function create_term(num)
  local terminal = require('toggleterm.terminal').Terminal
  local term = terminal:new {
    id = num,
    direction = 'horizontal',
    display_name = 'Terminal ' .. tostring(num),
  }
  term:toggle()
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
  end,
}
